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
}
