import 'package:amaguana_alerta/core/l10n/app_strings.dart';
import 'package:amaguana_alerta/core/theme/app_theme.dart';
import 'package:amaguana_alerta/features/auth/domain/auth_failure.dart';
import 'package:amaguana_alerta/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:amaguana_alerta/features/auth/presentation/views/forgot_password_view.dart';
import 'package:amaguana_alerta/shared/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'fakes/fake_auth_repository.dart';

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

  Future<void> pumpForgotPassword(WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<AuthViewModel>.value(
        value: viewModel,
        child: MaterialApp(
          theme: AppTheme.light,
          home: const ForgotPasswordView(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> submit(WidgetTester tester) async {
    final Finder button = find.byType(AppButton);
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pumpAndSettle();
  }

  testWidgets('muestra el correo y la acción de recuperación', (tester) async {
    await pumpForgotPassword(tester);

    expect(find.text(AppStrings.forgotPasswordHeading), findsOneWidget);
    expect(find.text(AppStrings.forgotPasswordBody), findsOneWidget);
    expect(find.text(AppStrings.emailLabel), findsOneWidget);
    expect(
      find.widgetWithText(AppButton, AppStrings.forgotPasswordButton),
      findsOneWidget,
    );
  });

  testWidgets('valida el correo antes de enviar', (tester) async {
    await pumpForgotPassword(tester);

    await submit(tester);

    expect(find.text(AppStrings.validationEmailRequired), findsOneWidget);
    expect(repository.passwordResetCalls, 0);
  });

  testWidgets('envía el enlace y muestra un mensaje genérico', (tester) async {
    await pumpForgotPassword(tester);
    await tester.enterText(find.byType(TextField), '  vecino@ejemplo.com  ');

    await submit(tester);

    expect(repository.passwordResetCalls, 1);
    expect(repository.lastPasswordResetEmail, 'vecino@ejemplo.com');
    expect(find.text(AppStrings.forgotPasswordSent), findsOneWidget);
    expect(viewModel.passwordResetSent, isTrue);
  });

  testWidgets('muestra el error de red sin revelar datos técnicos', (
    tester,
  ) async {
    repository.passwordResetFailure = const AuthFailure(
      AuthFailureReason.network,
    );
    await pumpForgotPassword(tester);
    await tester.enterText(find.byType(TextField), 'vecino@ejemplo.com');

    await submit(tester);

    expect(find.text(AppStrings.authNetwork), findsOneWidget);
    expect(find.textContaining('Firebase'), findsNothing);
    expect(viewModel.passwordResetSent, isFalse);
  });

  testWidgets('limpia la confirmación al editar el correo', (tester) async {
    await pumpForgotPassword(tester);
    await tester.enterText(find.byType(TextField), 'vecino@ejemplo.com');
    await submit(tester);
    expect(find.text(AppStrings.forgotPasswordSent), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'otro@ejemplo.com');
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.forgotPasswordSent), findsNothing);
  });
}
