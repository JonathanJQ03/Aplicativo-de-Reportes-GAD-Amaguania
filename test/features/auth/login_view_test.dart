import 'dart:async';

import 'package:amaguana_alerta/core/l10n/app_strings.dart';
import 'package:amaguana_alerta/core/theme/app_theme.dart';
import 'package:amaguana_alerta/features/auth/domain/auth_failure.dart';
import 'package:amaguana_alerta/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:amaguana_alerta/features/auth/presentation/views/login_view.dart';
import 'package:amaguana_alerta/models/app_user.dart';
import 'package:amaguana_alerta/shared/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'fakes/fake_auth_repository.dart';

const AppUser _user = AppUser(
  uid: 'uid-1',
  email: 'vecino@ejemplo.com',
  role: UserRole.vecino,
  emailVerified: true,
);

void main() {
  late FakeAuthRepository repository;
  late AuthViewModel viewModel;

  setUp(() {
    repository = FakeAuthRepository();
    viewModel = AuthViewModel(repository: repository);
  });

  tearDown(() async {
    viewModel.dispose();
    await repository.dispose();
  });

  Future<void> pumpLogin(WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<AuthViewModel>.value(
        value: viewModel,
        child: MaterialApp(theme: AppTheme.light, home: const LoginView()),
      ),
    );
  }

  Future<void> fillCredentials(WidgetTester tester) async {
    await tester.enterText(find.byType(TextField).at(0), 'vecino@ejemplo.com');
    await tester.enterText(find.byType(TextField).at(1), 'Clave123!');
  }

  testWidgets('muestra los campos y la acción principal', (tester) async {
    await pumpLogin(tester);

    expect(find.text(AppStrings.loginGreeting), findsOneWidget);
    expect(find.text(AppStrings.emailLabel), findsOneWidget);
    expect(find.text(AppStrings.passwordLabel), findsOneWidget);
    expect(find.widgetWithText(AppButton, AppStrings.signIn), findsOneWidget);
  });

  testWidgets('no se desborda en una pantalla pequeña', (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpLogin(tester);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('no se desborda al mostrar errores en pantalla pequeña', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpLogin(tester);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byType(AppButton));
    await tester.tap(find.byType(AppButton));
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text(AppStrings.validationEmailRequired), findsOneWidget);
  });

  testWidgets('permite mostrar y ocultar la contraseña', (tester) async {
    await pumpLogin(tester);

    expect(find.byTooltip(AppStrings.showPassword), findsOneWidget);

    await tester.tap(find.byTooltip(AppStrings.showPassword));
    await tester.pump();

    expect(find.byTooltip(AppStrings.hidePassword), findsOneWidget);
  });

  testWidgets('inicia sesión con los datos ingresados', (tester) async {
    await pumpLogin(tester);
    await fillCredentials(tester);

    await tester.ensureVisible(find.byType(AppButton));
    await tester.tap(find.byType(AppButton));
    await tester.pumpAndSettle();

    expect(repository.signInCalls, 1);
    expect(viewModel.isAuthenticated, isTrue);
    expect(viewModel.currentUser?.email, 'vecino@ejemplo.com');
  });

  testWidgets('muestra errores claros cuando los campos están vacíos', (
    tester,
  ) async {
    await pumpLogin(tester);

    await tester.ensureVisible(find.byType(AppButton));
    await tester.tap(find.byType(AppButton));
    await tester.pump();

    expect(find.text(AppStrings.validationEmailRequired), findsOneWidget);
    expect(find.text(AppStrings.validationPasswordRequired), findsOneWidget);
    expect(find.text(AppStrings.authMissingCredentials), findsNothing);
    expect(repository.signInCalls, 0);

    final TextField email = tester.widget<TextField>(
      find.byType(TextField).at(0),
    );
    expect(email.focusNode?.hasFocus, isTrue);
  });

  testWidgets('rechaza un correo con formato inválido', (tester) async {
    await pumpLogin(tester);
    await tester.enterText(find.byType(TextField).at(0), 'correo');
    await tester.enterText(find.byType(TextField).at(1), 'Clave123!');

    await tester.ensureVisible(find.byType(AppButton));
    await tester.tap(find.byType(AppButton));
    await tester.pump();

    expect(find.text(AppStrings.validationEmailInvalid), findsOneWidget);
    expect(find.text(AppStrings.validationPasswordRequired), findsNothing);
    expect(repository.signInCalls, 0);
  });

  testWidgets('pide la contraseña cuando el correo es válido', (tester) async {
    await pumpLogin(tester);
    await tester.enterText(find.byType(TextField).at(0), 'vecino@ejemplo.com');

    await tester.ensureVisible(find.byType(AppButton));
    await tester.tap(find.byType(AppButton));
    await tester.pump();

    expect(find.text(AppStrings.validationEmailRequired), findsNothing);
    expect(find.text(AppStrings.validationPasswordRequired), findsOneWidget);
    expect(repository.signInCalls, 0);
  });

  testWidgets('limpia el error de cada campo al corregirlo', (tester) async {
    await pumpLogin(tester);
    await tester.ensureVisible(find.byType(AppButton));
    await tester.tap(find.byType(AppButton));
    await tester.pump();

    expect(find.text(AppStrings.validationEmailRequired), findsOneWidget);
    expect(find.text(AppStrings.validationPasswordRequired), findsOneWidget);

    await tester.enterText(find.byType(TextField).at(0), 'vecino@ejemplo.com');
    await tester.pump();

    expect(find.text(AppStrings.validationEmailRequired), findsNothing);
    expect(find.text(AppStrings.validationPasswordRequired), findsOneWidget);

    await tester.enterText(find.byType(TextField).at(1), 'Clave123!');
    await tester.pump();

    expect(find.text(AppStrings.validationPasswordRequired), findsNothing);
    expect(repository.signInCalls, 0);
  });

  testWidgets('desactiva la autocorrección en el correo', (tester) async {
    await pumpLogin(tester);

    final TextField email = tester.widget<TextField>(
      find.byType(TextField).at(0),
    );

    expect(email.autocorrect, isFalse);
    expect(email.enableSuggestions, isFalse);
  });

  testWidgets('muestra el error de credenciales del ViewModel', (tester) async {
    repository.failure = const AuthFailure(
      AuthFailureReason.invalidCredentials,
    );
    await pumpLogin(tester);
    await fillCredentials(tester);

    await tester.ensureVisible(find.byType(AppButton));
    await tester.tap(find.byType(AppButton));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.authInvalidCredentials), findsOneWidget);
  });

  testWidgets('bloquea toques repetidos mientras carga', (tester) async {
    repository.pendingSignIn = Completer<AppUser>();
    await pumpLogin(tester);
    await fillCredentials(tester);

    await tester.ensureVisible(find.byType(AppButton));
    await tester.tap(find.byType(AppButton));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.ensureVisible(find.byType(AppButton));
    await tester.tap(find.byType(AppButton));
    await tester.pump();
    expect(repository.signInCalls, 1);

    repository.completeSignIn(_user);
    await tester.pumpAndSettle();

    expect(find.byType(CircularProgressIndicator), findsNothing);
  });
}
