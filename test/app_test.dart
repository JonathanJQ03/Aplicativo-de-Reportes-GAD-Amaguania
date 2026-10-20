import 'package:amaguana_alerta/app.dart';
import 'package:amaguana_alerta/core/l10n/app_strings.dart';
import 'package:amaguana_alerta/models/app_user.dart';
import 'package:amaguana_alerta/shared/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'features/auth/fakes/fake_auth_repository.dart';

const AppUser _user = AppUser(
  uid: 'uid-1',
  email: 'vecino@ejemplo.com',
  role: UserRole.vecino,
  emailVerified: true,
);

const AppUser _unverifiedUser = AppUser(
  uid: 'uid-1',
  email: 'vecino@ejemplo.com',
  role: UserRole.vecino,
);

void main() {
  testWidgets('arranca en el login cuando no hay sesión', (tester) async {
    final FakeAuthRepository repository = FakeAuthRepository();
    addTearDown(repository.dispose);

    await tester.pumpWidget(VeciApp(authRepository: repository));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.loginGreeting), findsOneWidget);
  });

  testWidgets('abre el registro y vuelve al login sin sesión', (tester) async {
    final FakeAuthRepository repository = FakeAuthRepository();
    addTearDown(repository.dispose);

    await tester.pumpWidget(VeciApp(authRepository: repository));
    await tester.pumpAndSettle();

    final Finder registerLink = find.text(AppStrings.loginGoToRegister);
    await tester.ensureVisible(registerLink);
    await tester.tap(registerLink);
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.registerTitle), findsOneWidget);
    expect(find.text(AppStrings.loginGreeting), findsNothing);

    final Finder loginLink = find.text(AppStrings.registerGoToLogin);
    await tester.ensureVisible(loginLink);
    await tester.tap(loginLink);
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.loginGreeting), findsOneWidget);
  });

  testWidgets('inicia sesión y muestra la pantalla principal', (tester) async {
    final FakeAuthRepository repository = FakeAuthRepository();
    addTearDown(repository.dispose);

    await tester.pumpWidget(VeciApp(authRepository: repository));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), 'vecino@ejemplo.com');
    await tester.enterText(find.byType(TextField).at(1), 'Clave123!');
    await tester.tap(find.byType(AppButton));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.homeSessionTitle), findsOneWidget);
  });

  testWidgets('cierra sesión y vuelve al login', (tester) async {
    final FakeAuthRepository repository = FakeAuthRepository(
      initialUser: _user,
    );
    addTearDown(repository.dispose);

    await tester.pumpWidget(VeciApp(authRepository: repository));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.homeSessionTitle), findsOneWidget);

    await tester.tap(find.widgetWithText(AppButton, AppStrings.signOut));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.loginGreeting), findsOneWidget);
  });

  testWidgets('restaura la sesión persistente al abrir la app', (tester) async {
    final FakeAuthRepository repository = FakeAuthRepository(
      initialUser: _user,
    );
    addTearDown(repository.dispose);

    await tester.pumpWidget(VeciApp(authRepository: repository));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.homeSessionTitle), findsOneWidget);
    expect(find.text(AppStrings.loginGreeting), findsNothing);
  });

  testWidgets('bloquea el acceso cuando el correo no está verificado', (
    tester,
  ) async {
    final FakeAuthRepository repository = FakeAuthRepository(
      initialUser: _unverifiedUser,
    );
    addTearDown(repository.dispose);

    await tester.pumpWidget(VeciApp(authRepository: repository));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.verifyEmailTitle), findsOneWidget);
    expect(find.text(AppStrings.homeSessionTitle), findsNothing);
  });

  testWidgets('desbloquea el acceso al comprobar la verificación', (
    tester,
  ) async {
    final FakeAuthRepository repository = FakeAuthRepository(
      initialUser: _unverifiedUser,
    );
    addTearDown(repository.dispose);
    repository.reloadResult = _user;

    await tester.pumpWidget(VeciApp(authRepository: repository));
    await tester.pumpAndSettle();

    await tester.tap(
      find.widgetWithText(AppButton, AppStrings.verifyEmailCheckButton),
    );
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.homeSessionTitle), findsOneWidget);
  });

  testWidgets('cancelar la verificación cierra la sesión', (tester) async {
    final FakeAuthRepository repository = FakeAuthRepository(
      initialUser: _unverifiedUser,
    );
    addTearDown(repository.dispose);

    await tester.pumpWidget(VeciApp(authRepository: repository));
    await tester.pumpAndSettle();

    final Finder cancelButton = find.widgetWithText(
      AppButton,
      AppStrings.verifyEmailCancelButton,
    );
    await tester.ensureVisible(cancelButton);
    await tester.pumpAndSettle();
    await tester.tap(cancelButton);
    await tester.pumpAndSettle();

    expect(repository.signOutCalls, 1);
    expect(find.text(AppStrings.loginGreeting), findsOneWidget);
  });

  testWidgets('el modo de desarrollo desbloquea el acceso tras 3 segundos', (
    tester,
  ) async {
    final FakeAuthRepository repository = FakeAuthRepository(
      initialUser: _unverifiedUser,
    );
    addTearDown(repository.dispose);

    await tester.pumpWidget(
      VeciApp(authRepository: repository, autoVerifyEmail: true),
    );
    await tester.pump();
    expect(find.text(AppStrings.verifyEmailTitle), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.homeSessionTitle), findsOneWidget);
  });

  testWidgets('después de registrarse pide verificar el correo', (
    tester,
  ) async {
    final FakeAuthRepository repository = FakeAuthRepository();
    addTearDown(repository.dispose);

    await tester.pumpWidget(VeciApp(authRepository: repository));
    await tester.pumpAndSettle();

    final Finder registerLink = find.text(AppStrings.loginGoToRegister);
    await tester.ensureVisible(registerLink);
    await tester.tap(registerLink);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), 'María Fernanda');
    await tester.enterText(find.byType(TextField).at(1), 'Pérez Gómez');
    await tester.enterText(find.byType(TextField).at(2), '1710034065');
    await tester.enterText(find.byType(TextField).at(3), 'vecino@ejemplo.com');
    await tester.enterText(find.byType(TextField).at(4), '0991234567');
    await tester.enterText(find.byType(TextField).at(5), 'Vecino123!');
    final Finder consent = find.byType(Checkbox);
    await tester.ensureVisible(consent);
    await tester.tap(consent);
    await tester.pump();

    final Finder registerButton = find.widgetWithText(
      AppButton,
      AppStrings.registerButton,
    );
    await tester.ensureVisible(registerButton);
    await tester.tap(registerButton);
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.verifyEmailTitle), findsOneWidget);
    expect(repository.sendVerificationCalls, 1);
    expect(repository.lastSignUp?.email, 'vecino@ejemplo.com');
  });
}
