import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../models/app_user.dart';
import '../../domain/auth_failure.dart';
import '../../domain/auth_repository.dart';

/// Estado de la sesión del usuario.
enum AuthStatus { unauthenticated, authenticated }

/// ViewModel de autenticación.
///
/// La vista solo conversa con este ViewModel; Firebase vive en la capa de
/// datos. Mantiene la sesión persistente mediante el stream del repositorio.
class AuthViewModel extends ChangeNotifier {
  AuthViewModel({required this.repository}) {
    _user = repository.currentUser;
    _status = _user == null
        ? AuthStatus.unauthenticated
        : AuthStatus.authenticated;
    _subscription = repository.authStateChanges.listen(
      _handleAuthState,
      onError: (_) {
        _errorMessage = AppStrings.authUnexpected;
        _notify();
      },
    );
  }

  /// Repositorio inyectado; la vista no lo usa directamente.
  final AuthRepository repository;
  StreamSubscription<AppUser?>? _subscription;

  AppUser? _user;
  AuthStatus _status = AuthStatus.unauthenticated;
  bool _isLoading = false;
  String? _errorMessage;
  bool _disposed = false;

  AppUser? get currentUser => _user;
  AuthStatus get status => _status;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Inicia sesión y devuelve `true` si la sesión quedó abierta.
  Future<bool> signIn({required String email, required String password}) async {
    if (_isLoading) {
      return false;
    }

    if (email.trim().isEmpty || password.isEmpty) {
      _errorMessage = AppStrings.authMissingCredentials;
      _notify();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    _notify();

    try {
      final AppUser user = await repository.signIn(
        email: email,
        password: password,
      );
      _applyUser(user);
      return true;
    } on AuthFailure catch (failure) {
      _errorMessage = _messageFor(failure.reason);
      return false;
    } catch (_) {
      _errorMessage = AppStrings.authUnexpected;
      return false;
    } finally {
      _isLoading = false;
      _notify();
    }
  }

  /// Cierra la sesión actual.
  Future<void> signOut() async {
    if (_isLoading) {
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    _notify();

    try {
      await repository.signOut();
      _applyUser(null);
    } on AuthFailure catch (failure) {
      _errorMessage = _messageFor(failure.reason);
    } catch (_) {
      _errorMessage = AppStrings.authUnexpectedSignOut;
    } finally {
      _isLoading = false;
      _notify();
    }
  }

  /// Limpia el mensaje de error al corregir los datos.
  void clearError() {
    if (_errorMessage == null) {
      return;
    }
    _errorMessage = null;
    _notify();
  }

  void _handleAuthState(AppUser? user) {
    _applyUser(user);
  }

  void _applyUser(AppUser? user) {
    _user = user;
    _status = user == null
        ? AuthStatus.unauthenticated
        : AuthStatus.authenticated;
    _notify();
  }

  String _messageFor(AuthFailureReason reason) {
    return switch (reason) {
      AuthFailureReason.invalidCredentials => AppStrings.authInvalidCredentials,
      AuthFailureReason.userDisabled => AppStrings.authUserDisabled,
      AuthFailureReason.tooManyRequests => AppStrings.authTooManyRequests,
      AuthFailureReason.network => AppStrings.authNetwork,
      AuthFailureReason.notAllowed => AppStrings.authNotAllowed,
      AuthFailureReason.unknown => AppStrings.authUnexpected,
    };
  }

  void _notify() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _subscription?.cancel();
    super.dispose();
  }
}
