import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  }) async {
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

      return AppUser(
        uid: user.uid,
        email: user.email ?? email.trim(),
        role: UserRole.vecino,
        displayName: displayName,
        photoUrl: user.photoURL,
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
    };
    if (phone != null && phone.isNotEmpty) {
      privateData['phone'] = phone;
    }

    final WriteBatch batch = _firestore.batch();
    batch.set(_firestore.collection('users').doc(uid), publicData);
    batch.set(_firestore.collection('users_private').doc(uid), privateData);
    await batch.commit();
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
      // TODO(S07): cargar el rol real desde Firestore.
      role: UserRole.vecino,
      displayName: user.displayName,
      photoUrl: user.photoURL,
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
    _ => AuthFailureReason.unknown,
  };
}
