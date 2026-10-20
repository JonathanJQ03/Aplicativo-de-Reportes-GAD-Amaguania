import 'package:firebase_auth/firebase_auth.dart';

import '../../../models/app_user.dart';
import '../domain/auth_failure.dart';
import '../domain/auth_repository.dart';

/// Implementación de [AuthRepository] sobre Firebase Authentication.
class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({
    FirebaseAuth? auth,
    bool useEmulator = false,
    String emulatorHost = 'localhost',
  }) : _auth = auth ?? FirebaseAuth.instance {
    if (useEmulator) {
      _auth.useAuthEmulator(emulatorHost, 9099);
    }
  }

  final FirebaseAuth _auth;

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
    _ => AuthFailureReason.unknown,
  };
}
