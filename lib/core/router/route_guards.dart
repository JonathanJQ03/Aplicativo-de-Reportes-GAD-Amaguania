import '../../models/app_user.dart';

/// Rutas del panel de administración.
abstract final class AdminRoutes {
  static const String login = '/login';
  static const String forgotPassword = '/forgot-password';
  static const String checking = '/checking';
  static const String accessDenied = '/access-denied';
  static const String home = '/';

  /// Rutas que puede ver alguien sin sesión.
  static const Set<String> publicRoutes = <String>{login, forgotPassword};

  /// Rutas de estado que solo tienen sentido mientras se resuelve el acceso.
  static const Set<String> statusRoutes = <String>{
    checking,
    accessDenied,
    login,
    forgotPassword,
  };
}

/// Decide a dónde redirigir en el panel de administración.
///
/// Devuelve `null` cuando la ruta solicitada se puede mostrar.
///
/// Reglas:
/// - sin sesión solo se ven el login y la recuperación de contraseña;
/// - mientras se consulta el rol se muestra la pantalla de espera;
/// - solo [UserRole.administrador] entra al panel;
/// - cualquier otro rol termina en la pantalla de acceso restringido.
///
/// La verificación del correo se mantiene en el flujo del vecino (S05). Las
/// cuentas de administrador las crea el GAD y se revisan antes de entregarlas.
String? resolveAdminRedirect({
  required String location,
  required bool isLoggedIn,
  required bool isRoleLoading,
  required UserRole? role,
}) {
  if (!isLoggedIn) {
    return AdminRoutes.publicRoutes.contains(location)
        ? null
        : AdminRoutes.login;
  }

  if (isRoleLoading) {
    return location == AdminRoutes.checking ? null : AdminRoutes.checking;
  }

  if (role != UserRole.administrador) {
    return location == AdminRoutes.accessDenied
        ? null
        : AdminRoutes.accessDenied;
  }

  if (AdminRoutes.statusRoutes.contains(location)) {
    return AdminRoutes.home;
  }

  return null;
}
