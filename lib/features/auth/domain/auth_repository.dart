import '../../../models/app_user.dart';
import 'auth_failure.dart';

/// Contrato de autenticación de VeciApp.
///
/// La implementación concreta vive en `data/` y es la única que conoce
/// Firebase. La presentación depende solo de esta interfaz.
abstract interface class AuthRepository {
  /// Usuario actualmente autenticado, o `null` si no hay sesión.
  AppUser? get currentUser;

  /// Cambios del estado de autenticación, incluida la sesión persistente.
  Stream<AppUser?> get authStateChanges;

  /// Inicia sesión con correo y contraseña.
  ///
  /// Lanza [AuthFailure] cuando las credenciales no son válidas o la cuenta
  /// no puede ingresar.
  Future<AppUser> signIn({required String email, required String password});

  /// Cierra la sesión actual.
  Future<void> signOut();
}
