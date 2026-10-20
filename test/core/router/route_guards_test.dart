import 'package:amaguana_alerta/core/router/route_guards.dart';
import 'package:amaguana_alerta/models/app_user.dart';
import 'package:flutter_test/flutter_test.dart';

String? _resolve(
  String location, {
  bool isLoggedIn = false,
  bool isEmailVerified = true,
  bool isRoleLoading = false,
  UserRole? role,
}) {
  return resolveAppRedirect(
    location: location,
    isLoggedIn: isLoggedIn,
    isEmailVerified: isEmailVerified,
    isRoleLoading: isRoleLoading,
    role: role,
  );
}

void main() {
  group('resolveAppRedirect', () {
    test('sin sesión solo permite las rutas públicas', () {
      for (final String location in AppRoutes.publicRoutes) {
        expect(
          _resolve(location),
          isNull,
          reason: 'La ruta pública $location no debe redirigir',
        );
      }

      for (final String location in <String>[
        AppRoutes.home,
        AppRoutes.verifyEmail,
        AppRoutes.sessionLoading,
        '/profile',
      ]) {
        expect(
          _resolve(location),
          AppRoutes.login,
          reason: 'La ruta $location requiere sesión',
        );
      }

      for (final String location in <String>[
        AppRoutes.adminHome,
        AppRoutes.adminChecking,
        AppRoutes.adminDenied,
        '/admin/desconocida',
      ]) {
        expect(
          _resolve(location),
          AppRoutes.adminLogin,
          reason: 'El área de administración debe pedir su login',
        );
      }
    });

    test('mientras se consulta el rol espera según el área', () {
      for (final String location in <String>[
        AppRoutes.login,
        AppRoutes.home,
        AppRoutes.verifyEmail,
        AppRoutes.sessionLoading,
      ]) {
        expect(
          _resolve(location, isLoggedIn: true, isRoleLoading: true, role: null),
          location == AppRoutes.sessionLoading
              ? isNull
              : AppRoutes.sessionLoading,
        );
      }

      for (final String location in <String>[
        AppRoutes.adminLogin,
        AppRoutes.adminHome,
        AppRoutes.adminDenied,
        AppRoutes.adminChecking,
      ]) {
        expect(
          _resolve(location, isLoggedIn: true, isRoleLoading: true, role: null),
          location == AppRoutes.adminChecking
              ? isNull
              : AppRoutes.adminChecking,
        );
      }
    });

    test('un administrador aterriza en el panel aunque no haya verificado', () {
      for (final String location in <String>[
        AppRoutes.login,
        AppRoutes.register,
        AppRoutes.forgotPassword,
        AppRoutes.verifyEmail,
        AppRoutes.home,
        AppRoutes.sessionLoading,
        AppRoutes.adminLogin,
        AppRoutes.adminForgotPassword,
        AppRoutes.adminChecking,
        AppRoutes.adminDenied,
      ]) {
        expect(
          _resolve(
            location,
            isLoggedIn: true,
            isEmailVerified: false,
            role: UserRole.administrador,
          ),
          AppRoutes.adminHome,
          reason: 'Un administrador debe salir de $location hacia el panel',
        );
      }

      expect(
        _resolve(
          AppRoutes.adminHome,
          isLoggedIn: true,
          isEmailVerified: false,
          role: UserRole.administrador,
        ),
        isNull,
      );
    });

    test('un vecino verificado usa la app y no entra al panel', () {
      for (final String location in <String>[
        AppRoutes.login,
        AppRoutes.register,
        AppRoutes.forgotPassword,
        AppRoutes.verifyEmail,
        AppRoutes.sessionLoading,
      ]) {
        expect(
          _resolve(location, isLoggedIn: true, role: UserRole.vecino),
          AppRoutes.home,
        );
      }

      for (final String location in <String>[
        AppRoutes.adminLogin,
        AppRoutes.adminForgotPassword,
        AppRoutes.adminHome,
        AppRoutes.adminChecking,
        '/admin/desconocida',
      ]) {
        expect(
          _resolve(location, isLoggedIn: true, role: UserRole.vecino),
          AppRoutes.adminDenied,
          reason: 'Un vecino no debe entrar a $location',
        );
      }

      expect(
        _resolve(AppRoutes.home, isLoggedIn: true, role: UserRole.vecino),
        isNull,
      );
      expect(
        _resolve(
          AppRoutes.adminDenied,
          isLoggedIn: true,
          role: UserRole.vecino,
        ),
        isNull,
      );
    });

    test('un vecino sin correo verificado queda en la verificación', () {
      for (final String location in <String>[
        AppRoutes.home,
        AppRoutes.login,
        AppRoutes.register,
        AppRoutes.forgotPassword,
        AppRoutes.sessionLoading,
      ]) {
        expect(
          _resolve(
            location,
            isLoggedIn: true,
            isEmailVerified: false,
            role: UserRole.vecino,
          ),
          AppRoutes.verifyEmail,
        );
      }

      expect(
        _resolve(
          AppRoutes.verifyEmail,
          isLoggedIn: true,
          isEmailVerified: false,
          role: UserRole.vecino,
        ),
        isNull,
      );
      expect(
        _resolve(
          AppRoutes.adminDenied,
          isLoggedIn: true,
          isEmailVerified: false,
          role: UserRole.vecino,
        ),
        isNull,
      );
      expect(
        _resolve(
          AppRoutes.adminChecking,
          isLoggedIn: true,
          isEmailVerified: false,
          role: UserRole.vecino,
        ),
        AppRoutes.adminDenied,
      );
    });

    test(
      'vecino verificado y rol ausente se tratan como no administradores',
      () {
        expect(
          _resolve(
            AppRoutes.adminHome,
            isLoggedIn: true,
            role: UserRole.vecinoVerificado,
          ),
          AppRoutes.adminDenied,
        );
        expect(
          _resolve(AppRoutes.adminHome, isLoggedIn: true, role: null),
          AppRoutes.adminDenied,
        );
      },
    );

    test('una ruta desconocida dentro del panel no se expone', () {
      expect(_resolve('/admin/desconocida'), AppRoutes.adminLogin);
      expect(
        _resolve('/admin/desconocida', isLoggedIn: true, role: UserRole.vecino),
        AppRoutes.adminDenied,
      );
      expect(
        _resolve(
          '/admin/desconocida',
          isLoggedIn: true,
          role: UserRole.administrador,
        ),
        isNull,
      );
    });
  });
}
