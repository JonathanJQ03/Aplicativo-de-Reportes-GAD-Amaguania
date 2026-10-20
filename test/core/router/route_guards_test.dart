import 'package:amaguana_alerta/core/router/route_guards.dart';
import 'package:amaguana_alerta/models/app_user.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('resolveAdminRedirect', () {
    test('sin sesión solo permite el login y la recuperación', () {
      for (final String location in <String>[
        AdminRoutes.home,
        AdminRoutes.checking,
        AdminRoutes.accessDenied,
        '/reports',
      ]) {
        expect(
          resolveAdminRedirect(
            location: location,
            isLoggedIn: false,
            isRoleLoading: false,
            role: null,
          ),
          AdminRoutes.login,
          reason: 'La ruta $location requiere sesión',
        );
      }

      for (final String location in AdminRoutes.publicRoutes) {
        expect(
          resolveAdminRedirect(
            location: location,
            isLoggedIn: false,
            isRoleLoading: false,
            role: null,
          ),
          isNull,
        );
      }
    });

    test(
      'mientras se consulta el rol espera en la pantalla de comprobación',
      () {
        for (final String location in <String>[
          AdminRoutes.home,
          AdminRoutes.login,
          AdminRoutes.forgotPassword,
          AdminRoutes.accessDenied,
        ]) {
          expect(
            resolveAdminRedirect(
              location: location,
              isLoggedIn: true,
              isRoleLoading: true,
              role: null,
            ),
            AdminRoutes.checking,
          );
        }

        expect(
          resolveAdminRedirect(
            location: AdminRoutes.checking,
            isLoggedIn: true,
            isRoleLoading: true,
            role: null,
          ),
          isNull,
        );
      },
    );

    test('un vecino no entra al panel y termina en acceso restringido', () {
      for (final String location in <String>[
        AdminRoutes.home,
        AdminRoutes.login,
        AdminRoutes.checking,
        AdminRoutes.forgotPassword,
      ]) {
        expect(
          resolveAdminRedirect(
            location: location,
            isLoggedIn: true,
            isRoleLoading: false,
            role: UserRole.vecino,
          ),
          AdminRoutes.accessDenied,
        );
      }

      expect(
        resolveAdminRedirect(
          location: AdminRoutes.accessDenied,
          isLoggedIn: true,
          isRoleLoading: false,
          role: UserRole.vecino,
        ),
        isNull,
      );
    });

    test('un vecino verificado tampoco entra al panel', () {
      expect(
        resolveAdminRedirect(
          location: AdminRoutes.home,
          isLoggedIn: true,
          isRoleLoading: false,
          role: UserRole.vecinoVerificado,
        ),
        AdminRoutes.accessDenied,
      );
    });

    test('un rol ausente se trata como vecino', () {
      expect(
        resolveAdminRedirect(
          location: AdminRoutes.home,
          isLoggedIn: true,
          isRoleLoading: false,
          role: null,
        ),
        AdminRoutes.accessDenied,
      );
    });

    test('un administrador entra al panel y sale de las rutas de estado', () {
      expect(
        resolveAdminRedirect(
          location: AdminRoutes.home,
          isLoggedIn: true,
          isRoleLoading: false,
          role: UserRole.administrador,
        ),
        isNull,
      );

      for (final String location in AdminRoutes.statusRoutes) {
        expect(
          resolveAdminRedirect(
            location: location,
            isLoggedIn: true,
            isRoleLoading: false,
            role: UserRole.administrador,
          ),
          AdminRoutes.home,
        );
      }
    });
  });
}
