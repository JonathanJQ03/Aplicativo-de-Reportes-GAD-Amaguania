import 'package:amaguana_alerta/core/l10n/app_strings.dart';
import 'package:amaguana_alerta/core/theme/app_theme.dart';
import 'package:amaguana_alerta/features/auth/domain/auth_failure.dart';
import 'package:amaguana_alerta/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:amaguana_alerta/features/auth/presentation/views/verify_email_view.dart';
import 'package:amaguana_alerta/models/app_user.dart';
import 'package:amaguana_alerta/shared/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'fakes/fake_auth_repository.dart';

const AppUser _unverifiedUser = AppUser(
  uid: 'uid-1',
  email: 'vecino@ejemplo.com',
  role: UserRole.vecino,
);

const AppUser _verifiedUser = AppUser(
  uid: 'uid-1',
  email: 'vecino@ejemplo.com',
  role: UserRole.vecino,
  emailVerified: true,
);

void main() {
  late FakeAuthRepository repository;
  late AuthViewModel viewModel;

  setUp(() {
    repository = FakeAuthRepository(initialUser: _unverifiedUser);
    viewModel = AuthViewModel(repository: repository);
  });

  tearDown(() async {
    viewModel.dispose();
    await repository.dispose();
  });

  Future<void> pumpVerify(WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<AuthViewModel>.value(
        value: viewModel,
        child: MaterialApp(
          theme: AppTheme.light,
          home: const VerifyEmailView(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('muestra el correo y las acciones de verificación', (
    tester,
  ) async {
    await pumpVerify(tester);

    expect(find.text(AppStrings.verifyEmailTitle), findsOneWidget);
    expect(find.text(_unverifiedUser.email), findsOneWidget);
    expect(
      find.widgetWithText(AppButton, AppStrings.verifyEmailCheckButton),
      findsOneWidget,
    );
    expect(
      find.widgetWithText(AppButton, AppStrings.verifyEmailResendButton),
      findsOneWidget,
    );
    expect(
      find.widgetWithText(AppButton, AppStrings.verifyEmailChangeButton),
      findsOneWidget,
    );
    expect(
      find.widgetWithText(AppButton, AppStrings.verifyEmailCancelButton),
      findsOneWidget,
    );
  });

  testWidgets('reenvía el correo y muestra la confirmación', (tester) async {
    await pumpVerify(tester);

    await tester.tap(
      find.widgetWithText(AppButton, AppStrings.verifyEmailResendButton),
    );
    await tester.pumpAndSettle();

    expect(repository.sendVerificationCalls, 1);
    expect(find.text(AppStrings.verifyEmailSent), findsOneWidget);
  });

  testWidgets('muestra un error claro si no puede reenviar', (tester) async {
    repository.verificationFailure = const AuthFailure(
      AuthFailureReason.verificationEmailFailed,
    );
    await pumpVerify(tester);

    await tester.tap(
      find.widgetWithText(AppButton, AppStrings.verifyEmailResendButton),
    );
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.authVerificationEmailFailed), findsOneWidget);
  });

  testWidgets('permite cambiar el correo y avisa que está pendiente', (
    tester,
  ) async {
    await pumpVerify(tester);

    await tester.tap(
      find.widgetWithText(AppButton, AppStrings.verifyEmailChangeButton),
    );
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.verifyEmailChangeTitle), findsOneWidget);

    const String newEmail = 'nuevo@ejemplo.com';
    await tester.enterText(find.byType(TextField), newEmail);
    await tester.tap(
      find.widgetWithText(AppButton, AppStrings.verifyEmailChangeSubmit),
    );
    await tester.pumpAndSettle();

    expect(repository.requestEmailChangeCalls, 1);
    expect(repository.lastRequestedEmail, newEmail);
    expect(find.text(newEmail), findsOneWidget);
    expect(find.text(AppStrings.verifyEmailChangeSent), findsOneWidget);
    expect(
      find.text(AppStrings.verifyEmailChangePendingPrefix),
      findsOneWidget,
    );
  });

  testWidgets('rechaza un cambio al mismo correo', (tester) async {
    await pumpVerify(tester);

    await tester.tap(
      find.widgetWithText(AppButton, AppStrings.verifyEmailChangeButton),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), _unverifiedUser.email);
    await tester.tap(
      find.widgetWithText(AppButton, AppStrings.verifyEmailChangeSubmit),
    );
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.verifyEmailChangeSame), findsOneWidget);
    expect(repository.requestEmailChangeCalls, 0);
  });

  testWidgets('muestra que el correo sigue pendiente al comprobarlo', (
    tester,
  ) async {
    await pumpVerify(tester);

    await tester.tap(
      find.widgetWithText(AppButton, AppStrings.verifyEmailCheckButton),
    );
    await tester.pumpAndSettle();

    expect(repository.reloadCalls, 1);
    expect(find.text(AppStrings.verifyEmailStillPending), findsOneWidget);
  });

  testWidgets('actualiza la sesión cuando el correo ya está verificado', (
    tester,
  ) async {
    repository.reloadResult = _verifiedUser;
    await pumpVerify(tester);

    await tester.tap(
      find.widgetWithText(AppButton, AppStrings.verifyEmailCheckButton),
    );
    await tester.pumpAndSettle();

    expect(viewModel.isEmailVerified, isTrue);
    expect(viewModel.needsEmailVerification, isFalse);
  });

  testWidgets('cancelar cierra la sesión', (tester) async {
    await pumpVerify(tester);

    final Finder cancelButton = find.widgetWithText(
      AppButton,
      AppStrings.verifyEmailCancelButton,
    );
    await tester.ensureVisible(cancelButton);
    await tester.pumpAndSettle();
    await tester.tap(cancelButton);
    await tester.pumpAndSettle();

    expect(repository.signOutCalls, 1);
    expect(viewModel.isAuthenticated, isFalse);
  });
}
