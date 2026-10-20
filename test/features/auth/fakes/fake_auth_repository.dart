import 'dart:async';

import 'package:amaguana_alerta/features/auth/domain/auth_failure.dart';
import 'package:amaguana_alerta/features/auth/domain/auth_repository.dart';
import 'package:amaguana_alerta/models/app_user.dart';

/// Datos de un registro que el doble en memoria recuerda para las pruebas.
typedef SignUpRequest = ({
  String nombres,
  String apellidos,
  String cedula,
  String email,
  String? phone,
  String password,
  bool consentAccepted,
});

/// Doble en memoria de [AuthRepository] para pruebas.
class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({AppUser? initialUser}) : _currentUser = initialUser;

  AppUser? _currentUser;
  final StreamController<AppUser?> _controller =
      StreamController<AppUser?>.broadcast();

  AuthFailure? failure;
  AuthFailure? signUpFailure;
  AuthFailure? verificationFailure;
  AuthFailure? emailChangeFailure;
  AuthFailure? passwordResetFailure;
  AppUser? reloadResult;
  Completer<AppUser>? pendingSignIn;
  Completer<AppUser>? pendingSignUp;
  int signInCalls = 0;
  int signUpCalls = 0;
  int signOutCalls = 0;
  int sendVerificationCalls = 0;
  int reloadCalls = 0;
  int requestEmailChangeCalls = 0;
  int passwordResetCalls = 0;
  String? lastRequestedEmail;
  String? lastPasswordResetEmail;
  SignUpRequest? lastSignUp;

  @override
  AppUser? get currentUser => _currentUser;

  @override
  Stream<AppUser?> get authStateChanges => _controller.stream;

  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    signInCalls++;
    if (failure != null) {
      throw failure!;
    }
    if (pendingSignIn != null) {
      final AppUser user = await pendingSignIn!.future;
      _save(user);
      return user;
    }
    final AppUser user = AppUser(
      uid: 'uid-1',
      email: email.trim(),
      role: UserRole.vecino,
      emailVerified: true,
    );
    _save(user);
    return user;
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
    signUpCalls++;
    lastSignUp = (
      nombres: nombres,
      apellidos: apellidos,
      cedula: cedula,
      email: email,
      phone: phone,
      password: password,
      consentAccepted: consentAccepted,
    );
    if (signUpFailure != null) {
      throw signUpFailure!;
    }
    if (pendingSignUp != null) {
      final AppUser user = await pendingSignUp!.future;
      _save(user);
      return user;
    }
    final AppUser user = AppUser(
      uid: 'uid-1',
      email: email.trim(),
      role: UserRole.vecino,
      displayName: '$nombres $apellidos'.trim(),
      emailVerified: false,
    );
    _save(user);
    sendVerificationCalls++;
    return user;
  }

  @override
  Future<void> signOut() async {
    signOutCalls++;
    _currentUser = null;
    _controller.add(null);
  }

  @override
  Future<void> sendVerificationEmail() async {
    sendVerificationCalls++;
    if (verificationFailure != null) {
      throw verificationFailure!;
    }
  }

  @override
  Future<AppUser?> reloadCurrentUser() async {
    reloadCalls++;
    if (reloadResult != null) {
      _save(reloadResult);
    }
    return _currentUser;
  }

  @override
  Future<void> requestEmailChange(String newEmail) async {
    requestEmailChangeCalls++;
    lastRequestedEmail = newEmail;
    if (emailChangeFailure != null) {
      throw emailChangeFailure!;
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    passwordResetCalls++;
    lastPasswordResetEmail = email;
    if (passwordResetFailure != null) {
      throw passwordResetFailure!;
    }
  }

  void emit(AppUser? user) {
    _save(user);
  }

  void completeSignIn(AppUser user) {
    pendingSignIn?.complete(user);
  }

  void completeSignUp(AppUser user) {
    pendingSignUp?.complete(user);
  }

  void _save(AppUser? user) {
    _currentUser = user;
    _controller.add(user);
  }

  Future<void> dispose() => _controller.close();
}
