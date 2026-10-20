import 'dart:async';

import 'package:amaguana_alerta/app.dart';
import 'package:amaguana_alerta/core/l10n/app_strings.dart';
import 'package:amaguana_alerta/models/app_user.dart';
import 'package:amaguana_alerta/shared/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../auth/fakes/fake_auth_repository.dart';

const AppUser _admin = AppUser(
  uid: 'admin-1',
  email: 'admin@ejemplo.com',
  role: UserRole.administrador,
  displayName: 'Funcionario del GAD',
  emailVerified: true,
);

Future<void> _pumpApp(
  WidgetTester tester,
  FakeAuthRepository repository,
) async {
  await tester.pumpWidget(VeciApp(authRepository: repository));
  await tester.pumpAndSettle();
}

Future<void> _openAdminLogin(WidgetTester tester) async {
  await tester.tap(find.text(AppStrings.loginAdminAccess));
  await tester.pumpAndSettle();
}

Future<void> _signIn(WidgetTester tester, {required String email}) async {
  await tester.enterText(find.byType(TextField).at(0), email);
  await tester.enterText(find.byType(TextField).at(1), 'Clave123!');
  final Finder signInButton = find.widgetWithText(AppButton, AppStrings.signIn);
  await tester.ensureVisible(signInButton);
  await tester.tap(signInButton);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('muestra el acceso de administrador arriba a la derecha', (
    tester,
  ) async {
    final FakeAuthRepository repository = FakeAuthRepository();
    addTearDown(repository.dispose);

    await _pumpApp(tester, repository);

    expect(find.text(AppStrings.loginAdminAccess), findsOneWidget);

    await _openAdminLogin(tester);

    expect(find.text(AppStrings.adminLoginSubtitle), findsOneWidget);
    expect(find.text(AppStrings.loginGoToRegister), findsNothing);
    expect(find.text(AppStrings.loginBack), findsOneWidget);

    await tester.tap(find.text(AppStrings.loginBack));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.loginGreeting), findsOneWidget);
    expect(find.text(AppStrings.loginAdminAccess), findsOneWidget);
  });

  testWidgets('un administrador entra al panel desde el login normal', (
    tester,
  ) async {
    final FakeAuthRepository repository = FakeAuthRepository()
      ..role = UserRole.administrador;
    addTearDown(repository.dispose);

    await _pumpApp(tester, repository);
    await _signIn(tester, email: 'admin@ejemplo.com');

    expect(find.text(AppStrings.adminPanelPreparingTitle), findsOneWidget);
    expect(find.text(AppStrings.adminRoleName), findsOneWidget);
    expect(find.text('admin@ejemplo.com'), findsOneWidget);
    expect(find.text(AppStrings.adminAccessDeniedTitle), findsNothing);
  });

  testWidgets(
    'la recuperación desde el acceso de administrador vuelve a su login',
    (tester) async {
      final FakeAuthRepository repository = FakeAuthRepository();
      addTearDown(repository.dispose);

      await _pumpApp(tester, repository);
      await _openAdminLogin(tester);

      final Finder forgotPassword = find.text(AppStrings.loginForgotPassword);
      await tester.ensureVisible(forgotPassword);
      await tester.pumpAndSettle();
      await tester.tap(forgotPassword);
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.forgotPasswordHeading), findsOneWidget);

      await tester.tap(find.text(AppStrings.forgotPasswordBack));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.adminLoginSubtitle), findsOneWidget);
      expect(find.text(AppStrings.loginGreeting), findsNothing);
    },
  );

  testWidgets('un administrador entra desde el acceso de administrador', (
    tester,
  ) async {
    final FakeAuthRepository repository = FakeAuthRepository()
      ..role = UserRole.administrador;
    addTearDown(repository.dispose);

    await _pumpApp(tester, repository);
    await _openAdminLogin(tester);
    await _signIn(tester, email: 'admin@ejemplo.com');

    expect(find.text(AppStrings.adminPanelPreparingTitle), findsOneWidget);
    expect(find.text(AppStrings.adminAccessDeniedTitle), findsNothing);
  });

  testWidgets('un vecino entra al inicio desde el login normal', (
    tester,
  ) async {
    final FakeAuthRepository repository = FakeAuthRepository();
    addTearDown(repository.dispose);

    await _pumpApp(tester, repository);
    await _signIn(tester, email: 'vecino@ejemplo.com');

    expect(find.text(AppStrings.homeSessionTitle), findsOneWidget);
    expect(find.text(AppStrings.adminAccessDeniedTitle), findsNothing);
  });

  testWidgets(
    'un vecino que usa el acceso de administrador ve acceso restringido',
    (tester) async {
      final FakeAuthRepository repository = FakeAuthRepository();
      addTearDown(repository.dispose);

      await _pumpApp(tester, repository);
      await _openAdminLogin(tester);
      await _signIn(tester, email: 'vecino@ejemplo.com');

      expect(find.text(AppStrings.adminAccessDeniedTitle), findsOneWidget);
      expect(find.text(AppStrings.adminPanelPreparingTitle), findsNothing);

      final Finder backToApp = find.widgetWithText(
        AppButton,
        AppStrings.adminBackToApp,
      );
      await tester.ensureVisible(backToApp);
      await tester.tap(backToApp);
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.homeSessionTitle), findsOneWidget);
    },
  );

  testWidgets('cerrar sesión desde acceso restringido vuelve al login admin', (
    tester,
  ) async {
    final FakeAuthRepository repository = FakeAuthRepository();
    addTearDown(repository.dispose);

    await _pumpApp(tester, repository);
    await _openAdminLogin(tester);
    await _signIn(tester, email: 'vecino@ejemplo.com');

    expect(find.text(AppStrings.adminAccessDeniedTitle), findsOneWidget);

    final Finder signOutButton = find.widgetWithText(
      AppButton,
      AppStrings.signOut,
    );
    await tester.ensureVisible(signOutButton);
    await tester.tap(signOutButton);
    await tester.pumpAndSettle();

    expect(repository.signOutCalls, 1);
    expect(find.text(AppStrings.adminLoginSubtitle), findsOneWidget);
  });

  testWidgets('muestra la espera mientras consulta el rol de administrador', (
    tester,
  ) async {
    final FakeAuthRepository repository = FakeAuthRepository()
      ..role = UserRole.administrador
      ..pendingRole = Completer<UserRole>();
    addTearDown(repository.dispose);

    await _pumpApp(tester, repository);
    await _openAdminLogin(tester);

    await tester.enterText(find.byType(TextField).at(0), 'admin@ejemplo.com');
    await tester.enterText(find.byType(TextField).at(1), 'Clave123!');
    final Finder signInButton = find.widgetWithText(
      AppButton,
      AppStrings.signIn,
    );
    await tester.ensureVisible(signInButton);
    await tester.tap(signInButton);
    await tester.pump();

    expect(find.text(AppStrings.adminCheckingAccess), findsOneWidget);
    expect(find.text(AppStrings.adminPanelPreparingTitle), findsNothing);

    repository.pendingRole!.complete(UserRole.administrador);
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.adminPanelPreparingTitle), findsOneWidget);
  });

  testWidgets('restaura la sesión de un administrador', (tester) async {
    final FakeAuthRepository repository = FakeAuthRepository(
      initialUser: _admin,
    );
    addTearDown(repository.dispose);

    await _pumpApp(tester, repository);

    expect(find.text(AppStrings.adminPanelPreparingTitle), findsOneWidget);
    expect(find.text(AppStrings.adminLoginSubtitle), findsNothing);
  });
}
