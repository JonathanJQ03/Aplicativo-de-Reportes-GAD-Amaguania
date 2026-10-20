import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/constants/app_constants.dart';
import '../../../models/app_user.dart';
import '../domain/auth_failure.dart';
import '../domain/auth_repository.dart';

/// Implementación de [AuthRepository] sobre Firebase Authentication.
///
/// Al registrar un vecino, el perfil se guarda en Firestore separando los
/// datos públicos (`users`) de los sensibles (`users_private`), según RNF-03.
class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    bool useEmulator = false,
    String emulatorHost = 'localhost',
  }) : _auth = auth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance {
    if (useEmulator) {
      // En un teléfono físico los emuladores se alcanzan con `adb reverse`.
      // Desactivamos el mapeo automático de localhost a 10.0.2.2, que solo
      // funciona dentro del emulador de Android.
      _auth.useAuthEmulator(emulatorHost, 9099, automaticHostMapping: false);
      _firestore.useFirestoreEmulator(
        emulatorHost,
        8080,
        automaticHostMapping: false,
      );
    }
  }

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  @override
  AppUser? get currentUser => _toAppUser(_auth.currentUser);

  @override
  Stream<AppUser?> get authStateChanges =>
      _auth.authStateChanges().map(_toAppUser);

  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final AppUser? user = _toAppUser(credential.user);
      if (user == null) {
        throw const AuthFailure(AuthFailureReason.unknown);
      }
      return user;
    } on FirebaseAuthException catch (error) {
      throw AuthFailure(authFailureReasonForCode(error.code));
    }
  }

  @override
  Future<AppUser> signUp({
    required String nombres,
    required String apellidos,
    required String cedula,
    required String email,
    String? phone,
    required String password,
    required bool consentAccepted,
  }) async {
    if (!consentAccepted) {
      throw const AuthFailure(AuthFailureReason.consentRequired);
    }

    User? user;
    try {
      final UserCredential credential = await _auth
          .createUserWithEmailAndPassword(
            email: email.trim(),
            password: password,
          );
      user = credential.user;
      if (user == null) {
        throw const AuthFailure(AuthFailureReason.unknown);
      }

      final String displayName = '${nombres.trim()} ${apellidos.trim()}'.trim();
      await user.updateDisplayName(displayName);
      await _saveProfile(
        uid: user.uid,
        nombres: nombres.trim(),
        apellidos: apellidos.trim(),
        cedula: cedula.trim(),
        email: email.trim(),
        phone: phone?.trim(),
        displayName: displayName,
      );
      // La cuenta ya existe; si el envío falla, la pantalla de verificación
      // permite reenviarlo sin perder el registro.
      await _sendVerificationEmailQuietly(user);

      return AppUser(
        uid: user.uid,
        email: user.email ?? email.trim(),
        role: UserRole.vecino,
        displayName: displayName,
        photoUrl: user.photoURL,
        emailVerified: user.emailVerified,
      );
    } on FirebaseAuthException catch (error) {
      throw AuthFailure(authFailureReasonForCode(error.code));
    } catch (error) {
      // Si el perfil no se pudo guardar, se elimina la cuenta recién creada
      // para que el vecino pueda reintentar con el mismo correo.
      if (user != null) {
        try {
          await user.delete();
        } on FirebaseAuthException {
          // Si tampoco se puede eliminar, prevalece el error de perfil.
        }
      }
      if (error is AuthFailure) {
        rethrow;
      }
      throw const AuthFailure(AuthFailureReason.profileCreationFailed);
    }
  }

  /// Guarda el perfil público y privado del vecino en una sola operación.
  Future<void> _saveProfile({
    required String uid,
    required String nombres,
    required String apellidos,
    required String cedula,
    required String email,
    required String? phone,
    required String displayName,
  }) async {
    final Map<String, dynamic> publicData = <String, dynamic>{
      'displayName': displayName,
      'role': 'vecino',
      'createdAt': FieldValue.serverTimestamp(),
    };
    final Map<String, dynamic> privateData = <String, dynamic>{
      'nombres': nombres,
      'apellidos': apellidos,
      'cedula': cedula,
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
      // RF-06: la aceptación se registra con hora del servidor para no
      // depender del reloj del teléfono.
      'consentVersion': AppConstants.privacyNoticeVersion,
      'consentAcceptedAt': FieldValue.serverTimestamp(),
    };
    if (phone != null && phone.isNotEmpty) {
      privateData['phone'] = phone;
    }

    final WriteBatch batch = _firestore.batch();
    batch.set(_firestore.collection('users').doc(uid), publicData);
    batch.set(_firestore.collection('users_private').doc(uid), privateData);
    await batch.commit();
  }

  /// Envía la verificación sin hacer fallar el registro si Firebase no puede
  /// entregar el correo. El usuario puede reenviarlo desde la pantalla de
  /// verificación.
  Future<void> _sendVerificationEmailQuietly(User user) async {
    try {
      await user.sendEmailVerification();
    } on FirebaseAuthException {
      // No se pierde la cuenta; el reenvío está disponible después.
    }
  }

  @override
  Future<UserRole> loadRole(String uid) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .get()
          .timeout(const Duration(seconds: 8));
      return UserRole.fromFirestore(snapshot.data()?['role']);
    } catch (_) {
      // Sin conexión o sin perfil, el rol seguro es el de menor privilegio.
      return UserRole.vecino;
    }
  }

  @override
  Future<void> sendVerificationEmail() async {
    final User? user = _auth.currentUser;
    if (user == null) {
      throw const AuthFailure(AuthFailureReason.unknown);
    }
    try {
      await user.sendEmailVerification();
    } on FirebaseAuthException catch (error) {
      throw AuthFailure(_emailActionFailure(error, isChange: false));
    }
  }

  @override
  Future<AppUser?> reloadCurrentUser() async {
    final User? user = _auth.currentUser;
    if (user == null) {
      return null;
    }
    try {
      await user.reload();
      final AppUser? refreshed = _toAppUser(_auth.currentUser);
      if (refreshed == null) {
        return null;
      }
      if (refreshed.emailVerified) {
        await _syncPrivateEmail(refreshed);
      }
      return refreshed;
    } on FirebaseAuthException catch (error) {
      throw AuthFailure(authFailureReasonForCode(error.code));
    }
  }

  @override
  Future<void> requestEmailChange(String newEmail) async {
    final User? user = _auth.currentUser;
    if (user == null) {
      throw const AuthFailure(AuthFailureReason.unknown);
    }
    try {
      await user.verifyBeforeUpdateEmail(newEmail.trim());
    } on FirebaseAuthException catch (error) {
      throw AuthFailure(_emailActionFailure(error, isChange: true));
    }
  }

  /// Mantiene sincronizado el correo privado cuando Auth confirma uno nuevo.
  ///
  /// Si la lectura o la escritura fallan, la verificación de la cuenta sigue
  /// siendo válida; el dato se puede corregir en una próxima recarga.
  Future<void> _syncPrivateEmail(AppUser user) async {
    try {
      final DocumentReference<Map<String, dynamic>> reference = _firestore
          .collection('users_private')
          .doc(user.uid);
      final DocumentSnapshot<Map<String, dynamic>> snapshot = await reference
          .get();
      if (!snapshot.exists || snapshot.data()?['email'] == user.email) {
        return;
      }
      await reference.update(<String, dynamic>{'email': user.email});
    } catch (_) {
      // No bloquear el acceso por un problema de sincronización del perfil.
    }
  }

  AuthFailureReason _emailActionFailure(
    FirebaseAuthException error, {
    required bool isChange,
  }) {
    return switch (error.code) {
      'requires-recent-login' => AuthFailureReason.requiresRecentLogin,
      'email-already-in-use' => AuthFailureReason.emailAlreadyInUse,
      'too-many-requests' => AuthFailureReason.tooManyRequests,
      'network-request-failed' => AuthFailureReason.network,
      _ =>
        isChange
            ? AuthFailureReason.emailChangeFailed
            : AuthFailureReason.verificationEmailFailed,
    };
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (error) {
      // No revelar si el correo está registrado. El mensaje de la interfaz es
      // intencionalmente genérico.
      if (error.code == 'user-not-found') {
        return;
      }
      throw AuthFailure(_passwordResetFailure(error));
    }
  }

  AuthFailureReason _passwordResetFailure(FirebaseAuthException error) {
    return switch (error.code) {
      'too-many-requests' => AuthFailureReason.tooManyRequests,
      'network-request-failed' => AuthFailureReason.network,
      'operation-not-allowed' => AuthFailureReason.notAllowed,
      _ => AuthFailureReason.passwordResetFailed,
    };
  }

  @override
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } on FirebaseAuthException catch (error) {
      throw AuthFailure(authFailureReasonForCode(error.code));
    }
  }

  AppUser? _toAppUser(User? user) {
    if (user == null) {
      return null;
    }
    return AppUser(
      uid: user.uid,
      email: user.email ?? '',
      // El rol real se consulta aparte con [loadRole] para no bloquear el
      // stream de autenticación. Mientras llega, se usa el rol de menor
      // privilegio.
      role: UserRole.vecino,
      displayName: user.displayName,
      photoUrl: user.photoURL,
      emailVerified: user.emailVerified,
    );
  }
}

/// Traduce un código de Firebase Auth a un motivo de dominio.
///
/// Se expone para poder probar el mapeo sin inicializar Firebase.
AuthFailureReason authFailureReasonForCode(String code) {
  return switch (code) {
    'invalid-credential' ||
    'user-not-found' ||
    'wrong-password' ||
    'invalid-email' => AuthFailureReason.invalidCredentials,
    'user-disabled' => AuthFailureReason.userDisabled,
    'too-many-requests' => AuthFailureReason.tooManyRequests,
    'network-request-failed' => AuthFailureReason.network,
    'operation-not-allowed' => AuthFailureReason.notAllowed,
    'email-already-in-use' => AuthFailureReason.emailAlreadyInUse,
    'weak-password' => AuthFailureReason.weakPassword,
    'requires-recent-login' => AuthFailureReason.requiresRecentLogin,
    _ => AuthFailureReason.unknown,
  };
}
