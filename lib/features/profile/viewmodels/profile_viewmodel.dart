import 'package:flutter/foundation.dart';

import '../../../models/app_user.dart';
import '../../auth/domain/auth_repository.dart';

/// ViewModel del perfil: datos del usuario y cierre de sesión.
///
/// TODO: gestionar la carga del perfil actual, la edición de los datos y el
/// cierre de sesión, exponiendo el estado a `ProfileView`.
class ProfileViewModel extends ChangeNotifier {
  ProfileViewModel({required this.authRepository});

  /// Repositorio con el que este ViewModel trabaja (única vía a Firebase).
  final AuthRepository authRepository;

  /// Usuario actualmente autenticado.
  AppUser? user;

  /// Indica si hay una operación en curso (para mostrar spinner).
  bool isLoading = false;

  // TODO: implementar loadProfile() para traer el usuario actual.
  // TODO: implementar updateProfile(...) con los datos editados.
  // TODO: implementar changePassword(...).
  // TODO: implementar logout() navegando al login.
}
