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
  AuthViewModel({
    required this.repository,
    this.autoVerifyEmail = false,
    this.autoVerifyDelay = const Duration(seconds: 3),
  }) {
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
    _scheduleDevelopmentVerification();
  }

  /// Repositorio inyectado; la vista no lo usa directamente.
  final AuthRepository repository;

  /// Modo temporal de desarrollo: desbloquea la cuenta sin verificar de verdad.
  ///
  /// TODO(S05): quitar cuando se conecte un proyecto real y se implemente el
  /// código de 6 dígitos. En producción siempre debe ser `false`.
  final bool autoVerifyEmail;

  /// Tiempo de espera del modo temporal antes de desbloquear la cuenta.
  final Duration autoVerifyDelay;

  StreamSubscription<AppUser?>? _subscription;

  AppUser? _user;
  AuthStatus _status = AuthStatus.unauthenticated;
  bool _isLoading = false;
  String? _errorMessage;
  String? _infoMessage;
  String? _pendingEmail;
  bool _developmentEmailVerified = false;
  Timer? _developmentVerificationTimer;
  bool _disposed = false;

  AppUser? get currentUser => _user;
  AuthStatus get status => _status;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isEmailVerified =>
      (_user?.emailVerified ?? false) || _developmentEmailVerified;
  bool get needsEmailVerification => isAuthenticated && !isEmailVerified;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get infoMessage => _infoMessage;
  String? get pendingEmail => _pendingEmail;

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
      _infoMessage = null;
      _pendingEmail = null;
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

  /// Crea una cuenta de vecino y deja la sesión abierta.
  ///
  /// Devuelve `true` si la cuenta se creó y el perfil se guardó.
  Future<bool> signUp({
    required String nombres,
    required String apellidos,
    required String cedula,
    required String email,
    String? phone,
    required String password,
  }) async {
    if (_isLoading) {
      return false;
    }

    if (nombres.trim().isEmpty ||
        apellidos.trim().isEmpty ||
        cedula.trim().isEmpty ||
        email.trim().isEmpty ||
        password.isEmpty) {
      _errorMessage = AppStrings.authMissingRegistrationData;
      _notify();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    _notify();

    try {
      final AppUser user = await repository.signUp(
        nombres: nombres,
        apellidos: apellidos,
        cedula: cedula,
        email: email,
        phone: phone,
        password: password,
      );
      _applyUser(user);
      _infoMessage = null;
      _pendingEmail = null;
      return true;
    } on AuthFailure catch (failure) {
      _errorMessage = _messageFor(failure.reason);
      return false;
    } catch (_) {
      _errorMessage = AppStrings.authUnexpectedSignUp;
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
      _infoMessage = null;
      _pendingEmail = null;
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

  /// Reenvía el enlace de verificación al correo actual.
  ///
  /// Devuelve `true` si Firebase aceptó el envío.
  Future<bool> resendVerificationEmail() async {
    if (_isLoading) {
      return false;
    }

    // Si hay un cambio de correo pendiente, el reenvío debe ir a la dirección
    // nueva; de lo contrario se reenviaría la verificación al correo anterior.
    final String? pendingEmail = _pendingEmail;
    if (pendingEmail != null) {
      return requestEmailChange(pendingEmail);
    }

    _isLoading = true;
    _errorMessage = null;
    _infoMessage = null;
    _notify();

    try {
      await repository.sendVerificationEmail();
      _infoMessage = AppStrings.verifyEmailSent;
      return true;
    } on AuthFailure catch (failure) {
      _errorMessage = _messageFor(failure.reason);
      return false;
    } catch (_) {
      _errorMessage = AppStrings.authVerificationEmailFailed;
      return false;
    } finally {
      _isLoading = false;
      _notify();
    }
  }

  /// Recarga el estado de la cuenta después de abrir el enlace de verificación.
  Future<void> refreshUser() async {
    if (_isLoading) {
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    _notify();

    try {
      final AppUser? user = await repository.reloadCurrentUser();
      if (user == null) {
        _infoMessage = null;
        _pendingEmail = null;
        _applyUser(null);
        return;
      }
      _applyUser(user);
      if (user.emailVerified) {
        _infoMessage = null;
        _pendingEmail = null;
      } else {
        _infoMessage = AppStrings.verifyEmailStillPending;
      }
    } on AuthFailure catch (failure) {
      _errorMessage = _messageFor(failure.reason);
    } catch (_) {
      _errorMessage = AppStrings.authUnexpected;
    } finally {
      _isLoading = false;
      _notify();
    }
  }

  /// Solicita cambiar el correo de la cuenta.
  ///
  /// Firebase envía el enlace al nuevo correo; el cambio no se completa hasta
  /// que el usuario lo verifica.
  Future<bool> requestEmailChange(String newEmail) async {
    if (_isLoading) {
      return false;
    }

    final String email = newEmail.trim();
    if (email.isEmpty) {
      _errorMessage = AppStrings.validationEmailRequired;
      _notify();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    _infoMessage = null;
    _notify();

    try {
      await repository.requestEmailChange(email);
      _pendingEmail = email;
      _infoMessage = AppStrings.verifyEmailChangeSent;
      return true;
    } on AuthFailure catch (failure) {
      _errorMessage = _messageFor(failure.reason);
      return false;
    } catch (_) {
      _errorMessage = AppStrings.authEmailChangeFailed;
      return false;
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
    _developmentVerificationTimer?.cancel();
    _developmentVerificationTimer = null;
    _developmentEmailVerified = false;
    _user = user;
    _status = user == null
        ? AuthStatus.unauthenticated
        : AuthStatus.authenticated;
    if (user == null || user.emailVerified) {
      _pendingEmail = null;
    }
    _scheduleDevelopmentVerification();
    _notify();
  }

  /// Desbloquea la cuenta tras [autoVerifyDelay] solo en el modo temporal.
  ///
  /// No cambia `emailVerified` en Firebase ni escribe en Firestore. Sirve para
  /// avanzar en el desarrollo mientras no haya un proyecto real configurado.
  void _scheduleDevelopmentVerification() {
    _developmentVerificationTimer?.cancel();
    _developmentVerificationTimer = null;

    final AppUser? user = _user;
    if (!autoVerifyEmail || user == null || user.emailVerified || _disposed) {
      return;
    }

    _developmentVerificationTimer = Timer(
      autoVerifyDelay,
      _completeDevelopmentVerification,
    );
  }

  void _completeDevelopmentVerification() {
    if (_disposed || !autoVerifyEmail || _user == null) {
      return;
    }
    _developmentEmailVerified = true;
    _infoMessage = null;
    _pendingEmail = null;
    _notify();
  }

  String _messageFor(AuthFailureReason reason) {
    return switch (reason) {
      AuthFailureReason.invalidCredentials => AppStrings.authInvalidCredentials,
      AuthFailureReason.userDisabled => AppStrings.authUserDisabled,
      AuthFailureReason.tooManyRequests => AppStrings.authTooManyRequests,
      AuthFailureReason.network => AppStrings.authNetwork,
      AuthFailureReason.notAllowed => AppStrings.authNotAllowed,
      AuthFailureReason.emailAlreadyInUse => AppStrings.authEmailAlreadyInUse,
      AuthFailureReason.weakPassword => AppStrings.authWeakPassword,
      AuthFailureReason.requiresRecentLogin =>
        AppStrings.authRequiresRecentLogin,
      AuthFailureReason.verificationEmailFailed =>
        AppStrings.authVerificationEmailFailed,
      AuthFailureReason.emailChangeFailed => AppStrings.authEmailChangeFailed,
      AuthFailureReason.profileCreationFailed =>
        AppStrings.authProfileCreationFailed,
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
    _developmentVerificationTimer?.cancel();
    _subscription?.cancel();
    super.dispose();
  }
}
