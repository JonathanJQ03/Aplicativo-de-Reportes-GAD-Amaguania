import 'dart:async';

import 'package:amaguana_alerta/core/l10n/app_strings.dart';
import 'package:amaguana_alerta/core/theme/app_theme.dart';
import 'package:amaguana_alerta/features/auth/domain/auth_failure.dart';
import 'package:amaguana_alerta/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:amaguana_alerta/features/auth/presentation/views/register_view.dart';
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
  displayName: 'María Fernanda Pérez Gómez',
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

  Future<void> pumpRegister(WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<AuthViewModel>.value(
        value: viewModel,
        child: MaterialApp(theme: AppTheme.light, home: const RegisterView()),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tapRegister(WidgetTester tester) async {
    final Finder button = find.byType(AppButton);
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pump();
  }

  Future<void> fillValidForm(
    WidgetTester tester, {
    String phone = '0991234567',
    String password = 'Vecino123!',
  }) async {
    await tester.enterText(find.byType(TextField).at(0), 'María Fernanda');
    await tester.enterText(find.byType(TextField).at(1), 'Pérez Gómez');
    await tester.enterText(find.byType(TextField).at(2), '1710034065');
    await tester.enterText(find.byType(TextField).at(3), 'vecino@ejemplo.com');
    await tester.enterText(find.byType(TextField).at(4), phone);
    await tester.enterText(find.byType(TextField).at(5), password);
  }

  testWidgets('muestra los campos y la acción principal', (tester) async {
    await pumpRegister(tester);

    expect(find.text(AppStrings.registerTitle), findsOneWidget);
    expect(find.text(AppStrings.firstNameLabel), findsOneWidget);
    expect(find.text(AppStrings.lastNameLabel), findsOneWidget);
    expect(find.text(AppStrings.cedulaLabel), findsOneWidget);
    expect(find.text(AppStrings.emailLabel), findsOneWidget);
    expect(find.text(AppStrings.phoneLabel), findsOneWidget);
    expect(find.text(AppStrings.passwordLabel), findsOneWidget);
    expect(find.text(AppStrings.registerPasswordHelper), findsOneWidget);
    expect(
      find.widgetWithText(AppButton, AppStrings.registerButton),
      findsOneWidget,
    );
  });

  testWidgets('no se desborda en una pantalla pequeña', (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpRegister(tester);

    expect(tester.takeException(), isNull);
  });

  testWidgets('muestra los errores de los campos obligatorios', (tester) async {
    await pumpRegister(tester);
    await tapRegister(tester);

    expect(find.text(AppStrings.validationFirstNameRequired), findsOneWidget);
    expect(find.text(AppStrings.validationLastNameRequired), findsOneWidget);
    expect(find.text(AppStrings.validationCedulaRequired), findsOneWidget);
    expect(find.text(AppStrings.validationEmailRequired), findsOneWidget);
    expect(find.text(AppStrings.validationPasswordRequired), findsOneWidget);
    expect(find.text(AppStrings.validationPhoneInvalid), findsNothing);
    expect(repository.signUpCalls, 0);

    final TextField names = tester.widget<TextField>(
      find.byType(TextField).at(0),
    );
    expect(names.focusNode?.hasFocus, isTrue);
  });

  testWidgets('no se desborda al mostrar errores en pantalla pequeña', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpRegister(tester);
    await tapRegister(tester);

    expect(tester.takeException(), isNull);
    expect(find.text(AppStrings.validationCedulaRequired), findsOneWidget);
  });

  testWidgets('rechaza cédula, correo y teléfono con formato inválido', (
    tester,
  ) async {
    await pumpRegister(tester);
    await tester.enterText(find.byType(TextField).at(0), 'María');
    await tester.enterText(find.byType(TextField).at(1), 'Pérez');
    await tester.enterText(find.byType(TextField).at(2), '123456789');
    await tester.enterText(find.byType(TextField).at(3), 'correo');
    await tester.enterText(find.byType(TextField).at(4), '0812345678');
    await tester.enterText(find.byType(TextField).at(5), 'Vecino123!');

    await tapRegister(tester);

    expect(find.text(AppStrings.validationCedulaFormat), findsOneWidget);
    expect(find.text(AppStrings.validationEmailInvalid), findsOneWidget);
    expect(find.text(AppStrings.validationPhoneInvalid), findsOneWidget);
    expect(repository.signUpCalls, 0);
  });

  testWidgets('rechaza una cédula con dígito verificador incorrecto', (
    tester,
  ) async {
    await pumpRegister(tester);
    await tester.enterText(find.byType(TextField).at(0), 'María');
    await tester.enterText(find.byType(TextField).at(1), 'Pérez');
    await tester.enterText(find.byType(TextField).at(2), '1710034066');
    await tester.enterText(find.byType(TextField).at(3), 'vecino@ejemplo.com');
    await tester.enterText(find.byType(TextField).at(4), '0991234567');
    await tester.enterText(find.byType(TextField).at(5), 'Vecino123!');

    await tapRegister(tester);

    expect(find.text(AppStrings.validationCedulaInvalid), findsOneWidget);
    expect(repository.signUpCalls, 0);
  });

  testWidgets('rechaza una contraseña sin símbolo', (tester) async {
    await pumpRegister(tester);
    await fillValidForm(tester, password: 'Vecino123');

    await tapRegister(tester);

    expect(find.text(AppStrings.validationPasswordSymbol), findsOneWidget);
    expect(repository.signUpCalls, 0);
  });

  testWidgets('crea la cuenta y deja la sesión abierta', (tester) async {
    await pumpRegister(tester);
    await fillValidForm(tester);

    await tapRegister(tester);
    await tester.pumpAndSettle();

    expect(repository.signUpCalls, 1);
    expect(repository.lastSignUp?.nombres, 'María Fernanda');
    expect(repository.lastSignUp?.apellidos, 'Pérez Gómez');
    expect(repository.lastSignUp?.cedula, '1710034065');
    expect(repository.lastSignUp?.email, 'vecino@ejemplo.com');
    expect(repository.lastSignUp?.phone, '0991234567');
    expect(viewModel.isAuthenticated, isTrue);
    expect(viewModel.currentUser?.role, UserRole.vecino);
  });

  testWidgets('acepta el teléfono vacío porque es opcional', (tester) async {
    await pumpRegister(tester);
    await fillValidForm(tester, phone: '');

    await tapRegister(tester);
    await tester.pumpAndSettle();

    expect(repository.signUpCalls, 1);
    expect(repository.lastSignUp?.phone, isNull);
    expect(viewModel.isAuthenticated, isTrue);
  });

  testWidgets('recorta los espacios antes de enviar los datos', (tester) async {
    await pumpRegister(tester);
    await tester.enterText(find.byType(TextField).at(0), '  María  ');
    await tester.enterText(find.byType(TextField).at(1), '  Pérez  ');
    await tester.enterText(find.byType(TextField).at(2), '1710034065');
    await tester.enterText(
      find.byType(TextField).at(3),
      ' vecino@ejemplo.com ',
    );
    await tester.enterText(find.byType(TextField).at(4), '0991234567');
    await tester.enterText(find.byType(TextField).at(5), 'Vecino123!');

    await tapRegister(tester);
    await tester.pumpAndSettle();

    expect(repository.lastSignUp?.nombres, 'María');
    expect(repository.lastSignUp?.apellidos, 'Pérez');
    expect(repository.lastSignUp?.email, 'vecino@ejemplo.com');
  });

  testWidgets('muestra el error de correo ya registrado', (tester) async {
    repository.signUpFailure = const AuthFailure(
      AuthFailureReason.emailAlreadyInUse,
    );
    await pumpRegister(tester);
    await fillValidForm(tester);

    await tapRegister(tester);
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.authEmailAlreadyInUse), findsOneWidget);
    expect(viewModel.isAuthenticated, isFalse);
  });

  testWidgets('bloquea toques repetidos mientras carga', (tester) async {
    repository.pendingSignUp = Completer<AppUser>();
    await pumpRegister(tester);
    await fillValidForm(tester);

    await tapRegister(tester);

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tapRegister(tester);
    expect(repository.signUpCalls, 1);

    repository.completeSignUp(_user);
    await tester.pumpAndSettle();

    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('limpia los errores de cada campo al corregirlo', (tester) async {
    await pumpRegister(tester);
    await tapRegister(tester);

    expect(find.text(AppStrings.validationFirstNameRequired), findsOneWidget);
    expect(find.text(AppStrings.validationCedulaRequired), findsOneWidget);

    await tester.enterText(find.byType(TextField).at(0), 'María');
    await tester.pump();

    expect(find.text(AppStrings.validationFirstNameRequired), findsNothing);
    expect(find.text(AppStrings.validationCedulaRequired), findsOneWidget);
  });
}
