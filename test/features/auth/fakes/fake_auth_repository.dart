import 'dart:async';

import 'package:amaguana_alerta/features/auth/domain/auth_failure.dart';
import 'package:amaguana_alerta/features/auth/domain/auth_repository.dart';
import 'package:amaguana_alerta/models/app_user.dart';

/// Doble en memoria de [AuthRepository] para pruebas.
class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({AppUser? initialUser}) : _currentUser = initialUser;

  AppUser? _currentUser;
  final StreamController<AppUser?> _controller =
      StreamController<AppUser?>.broadcast();

  AuthFailure? failure;
  Completer<AppUser>? pendingSignIn;
  int signInCalls = 0;
  int signOutCalls = 0;

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
    );
    _save(user);
    return user;
  }

  @override
  Future<void> signOut() async {
    signOutCalls++;
    _currentUser = null;
    _controller.add(null);
  }

  void emit(AppUser? user) {
    _save(user);
  }

  void completeSignIn(AppUser user) {
    pendingSignIn?.complete(user);
  }

  void _save(AppUser? user) {
    _currentUser = user;
    _controller.add(user);
  }

  Future<void> dispose() => _controller.close();
}
