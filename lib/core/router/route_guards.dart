import '../../models/app_user.dart';

/// Rutas de la aplicación.
///
/// La app móvil y el panel de administración comparten un solo árbol de
/// navegación. Las rutas del panel viven bajo `/admin` y siempre pasan por
/// [resolveAppRedirect].
abstract final class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String verifyEmail = '/verify-email';
  static const String sessionLoading = '/session-loading';
  static const String home = '/';

  static const String adminLogin = '/admin/login';
  static const String adminForgotPassword = '/admin/forgot-password';
  static const String adminChecking = '/admin/checking';
  static const String adminDenied = '/admin/denied';
  static const String adminHome = '/admin';

  /// Rutas que puede ver alguien sin sesión.
  static const Set<String> publicRoutes = <String>{
    login,
    register,
    forgotPassword,
    adminLogin,
    adminForgotPassword,
  };

  /// Indica si la ruta pertenece al área de administración.
  ///
  /// Se usa el prefijo para que una ruta desconocida bajo `/admin` tampoco
  /// quede expuesta a una cuenta sin sesión.
  static bool isAdminArea(String location) {
    return location == adminHome || location.startsWith('$adminHome/');
  }
}

/// Decide a dónde redirigir según la sesión, el correo y el rol.
///
/// Devuelve `null` cuando la ruta solicitada se puede mostrar.
///
/// Reglas:
/// - sin sesión solo se ven las rutas públicas; el área `/admin` lleva a su
///   login y el resto al login de vecinos;
/// - mientras se consulta el rol se muestra una pantalla de espera, distinta
///   para el área de administración;
/// - un administrador entra al panel después de iniciar sesión, aunque su
///   correo todavía no esté verificado (las cuentas las provisiona el GAD);
/// - un vecino o vecino verificado que intenta entrar al área de administración
///   termina en acceso restringido y puede volver a la app.
String? resolveAppRedirect({
  required String location,
  required bool isLoggedIn,
  required bool isEmailVerified,
  required bool isRoleLoading,
  required UserRole? role,
}) {
  final bool isAdminArea = AppRoutes.isAdminArea(location);

  if (!isLoggedIn) {
    if (AppRoutes.publicRoutes.contains(location)) {
      return null;
    }
    return isAdminArea ? AppRoutes.adminLogin : AppRoutes.login;
  }

  if (isRoleLoading) {
    if (location == AppRoutes.sessionLoading ||
        location == AppRoutes.adminChecking) {
      return null;
    }
    return isAdminArea ? AppRoutes.adminChecking : AppRoutes.sessionLoading;
  }

  final bool isAdmin = role == UserRole.administrador;

  if (isAdmin) {
    // El panel es el destino del administrador. Las rutas de espera, login,
    // verificación y las pantallas de vecino lo devuelven a `/admin`.
    if (location == AppRoutes.adminHome) {
      return null;
    }
    if (location == AppRoutes.sessionLoading ||
        location == AppRoutes.adminChecking ||
        location == AppRoutes.adminDenied ||
        AppRoutes.publicRoutes.contains(location) ||
        location == AppRoutes.verifyEmail ||
        location == AppRoutes.home) {
      return AppRoutes.adminHome;
    }
    // Las rutas internas del panel se agregan en S15. Mientras tanto, una ruta
    // desconocida bajo `/admin` puede mostrarse para que el error sea visible.
    return null;
  }

  // Cuenta sin rol de administrador.
  if (location == AppRoutes.adminDenied) {
    return null;
  }
  if (isAdminArea) {
    return AppRoutes.adminDenied;
  }
  if (location == AppRoutes.sessionLoading) {
    return isEmailVerified ? AppRoutes.home : AppRoutes.verifyEmail;
  }
  if (!isEmailVerified) {
    return location == AppRoutes.verifyEmail ? null : AppRoutes.verifyEmail;
  }
  if (location == AppRoutes.verifyEmail ||
      AppRoutes.publicRoutes.contains(location)) {
    return AppRoutes.home;
  }
  return null;
}
