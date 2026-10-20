import 'dart:async';

import 'package:amaguana_alerta/admin_app.dart';
import 'package:amaguana_alerta/core/l10n/app_strings.dart';
import 'package:amaguana_alerta/models/app_user.dart';
import 'package:amaguana_alerta/shared/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'features/auth/fakes/fake_auth_repository.dart';

const AppUser _admin = AppUser(
  uid: 'admin-1',
  email: 'admin@ejemplo.com',
  role: UserRole.administrador,
  displayName: 'Funcionario del GAD',
  emailVerified: true,
);

const AppUser _vecino = AppUser(
  uid: 'vecino-1',
  email: 'vecino@ejemplo.com',
  role: UserRole.vecino,
  emailVerified: true,
);

Future<void> _signIn(WidgetTester tester, {required String email}) async {
  await tester.enterText(find.byType(TextField).at(0), email);
  await tester.enterText(find.byType(TextField).at(1), 'Clave123!');
  final Finder signInButton = find.byType(AppButton);
  await tester.ensureVisible(signInButton);
  await tester.tap(signInButton);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('muestra el login del panel sin enlace de registro', (
    tester,
  ) async {
    final FakeAuthRepository repository = FakeAuthRepository();
    addTearDown(repository.dispose);

    await tester.pumpWidget(AdminApp(authRepository: repository));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.adminLoginSubtitle), findsOneWidget);
    expect(find.text(AppStrings.loginGoToRegister), findsNothing);
    expect(find.text(AppStrings.loginForgotPassword), findsOneWidget);
  });

  testWidgets('un administrador entra al panel', (tester) async {
    final FakeAuthRepository repository = FakeAuthRepository()
      ..role = UserRole.administrador;
    addTearDown(repository.dispose);

    await tester.pumpWidget(AdminApp(authRepository: repository));
    await tester.pumpAndSettle();

    await _signIn(tester, email: 'admin@ejemplo.com');

    expect(find.text(AppStrings.adminPanelPreparingTitle), findsOneWidget);
    expect(find.text(AppStrings.adminRoleName), findsOneWidget);
    expect(find.text('admin@ejemplo.com'), findsOneWidget);
    expect(find.text(AppStrings.adminAccessDeniedTitle), findsNothing);
  });

  testWidgets('un vecino queda en acceso restringido', (tester) async {
    final FakeAuthRepository repository = FakeAuthRepository();
    addTearDown(repository.dispose);

    await tester.pumpWidget(AdminApp(authRepository: repository));
    await tester.pumpAndSettle();

    await _signIn(tester, email: 'vecino@ejemplo.com');

    expect(find.text(AppStrings.adminAccessDeniedTitle), findsOneWidget);
    expect(find.text(AppStrings.adminPanelPreparingTitle), findsNothing);
  });

  testWidgets('restaura la sesión de un administrador', (tester) async {
    final FakeAuthRepository repository = FakeAuthRepository(
      initialUser: _admin,
    );
    addTearDown(repository.dispose);

    await tester.pumpWidget(AdminApp(authRepository: repository));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.adminPanelPreparingTitle), findsOneWidget);
    expect(find.text(AppStrings.adminLoginSubtitle), findsNothing);
  });

  testWidgets('muestra la espera mientras consulta el rol', (tester) async {
    final FakeAuthRepository repository = FakeAuthRepository()
      ..role = UserRole.administrador
      ..pendingRole = Completer<UserRole>();
    addTearDown(repository.dispose);

    await tester.pumpWidget(AdminApp(authRepository: repository));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), 'admin@ejemplo.com');
    await tester.enterText(find.byType(TextField).at(1), 'Clave123!');
    final Finder signInButton = find.byType(AppButton);
    await tester.ensureVisible(signInButton);
    await tester.tap(signInButton);
    await tester.pump();

    expect(find.text(AppStrings.adminCheckingAccess), findsOneWidget);
    expect(find.text(AppStrings.adminPanelPreparingTitle), findsNothing);

    repository.pendingRole!.complete(UserRole.administrador);
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.adminPanelPreparingTitle), findsOneWidget);
  });

  testWidgets('cerrar sesión desde acceso restringido vuelve al login', (
    tester,
  ) async {
    final FakeAuthRepository repository = FakeAuthRepository(
      initialUser: _vecino,
    );
    addTearDown(repository.dispose);

    await tester.pumpWidget(AdminApp(authRepository: repository));
    await tester.pumpAndSettle();

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
}
