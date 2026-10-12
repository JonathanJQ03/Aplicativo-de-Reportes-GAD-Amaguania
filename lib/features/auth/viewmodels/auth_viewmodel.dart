import 'package:flutter/foundation.dart';

import '../../../repositories/auth_repository.dart';

/// ViewModel de autenticación (registro, login, verificación y recuperación).
///
/// Expone el estado a las vistas de `auth/` mediante `ChangeNotifier`.
/// La vista NUNCA toca Firebase: llama a estos métodos y este ViewModel usa
/// [AuthRepository].
///
/// TODO: implementar los métodos y exponer flags de carga y errores.
class AuthViewModel extends ChangeNotifier {
  AuthViewModel({required this.authRepository});

  /// Repositorio con el que este ViewModel trabaja (única vía a Firebase).
  final AuthRepository authRepository;

  /// Indica si hay una operación en curso (para mostrar spinner).
  bool isLoading = false;

  /// Mensaje de error listo para mostrar en la interfaz.
  String? errorMessage;

  // TODO: implementar register(...) y notificar a los oyentes.
  // TODO: implementar login(...) y notificar a los oyentes.
  // TODO: implementar sendVerificationCode(...) y confirmVerificationCode(...).
  // TODO: implementar sendPasswordReset(...).
  // TODO: implementar logout(...).
  // TODO: exponer el usuario actual y el stream de estado de autenticación.
}
