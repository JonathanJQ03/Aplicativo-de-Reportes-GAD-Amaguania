import 'dart:async';

import 'package:amaguana_alerta/core/l10n/app_strings.dart';
import 'package:amaguana_alerta/features/auth/domain/auth_failure.dart';
import 'package:amaguana_alerta/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:amaguana_alerta/models/app_user.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes/fake_auth_repository.dart';

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
  group('AuthViewModel', () {
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

    test('inicia sin sesión cuando el repositorio no tiene usuario', () {
      expect(viewModel.status, AuthStatus.unauthenticated);
      expect(viewModel.isAuthenticated, isFalse);
      expect(viewModel.currentUser, isNull);
    });

    test('restaura una sesión persistente al construirse', () async {
      final FakeAuthRepository persistedRepository = FakeAuthRepository(
        initialUser: _user,
      );
      final AuthViewModel persistedViewModel = AuthViewModel(
        repository: persistedRepository,
      );
      addTearDown(() async {
        persistedViewModel.dispose();
        await persistedRepository.dispose();
      });

      expect(persistedViewModel.status, AuthStatus.authenticated);
      expect(persistedViewModel.currentUser, _user);
    });

    test('escucha los cambios de sesión del repositorio', () async {
      repository.emit(_user);
      await Future<void>.delayed(Duration.zero);

      expect(viewModel.isAuthenticated, isTrue);
      expect(viewModel.currentUser, _user);
    });

    test('inicia sesión correctamente y actualiza el estado', () async {
      final bool result = await viewModel.signIn(
        email: ' vecino@ejemplo.com ',
        password: 'Clave123!',
      );

      expect(result, isTrue);
      expect(repository.signInCalls, 1);
      expect(viewModel.isAuthenticated, isTrue);
      expect(viewModel.currentUser?.email, 'vecino@ejemplo.com');
      expect(viewModel.errorMessage, isNull);
      expect(viewModel.isLoading, isFalse);
    });

    test('pide correo y contraseña cuando faltan datos', () async {
      final bool result = await viewModel.signIn(email: '', password: '');

      expect(result, isFalse);
      expect(repository.signInCalls, 0);
      expect(viewModel.errorMessage, AppStrings.authMissingCredentials);
    });

    test('muestra un mensaje claro cuando las credenciales fallan', () async {
      repository.failure = const AuthFailure(
        AuthFailureReason.invalidCredentials,
      );

      final bool result = await viewModel.signIn(
        email: 'vecino@ejemplo.com',
        password: 'incorrecta',
      );

      expect(result, isFalse);
      expect(viewModel.isAuthenticated, isFalse);
      expect(viewModel.errorMessage, AppStrings.authInvalidCredentials);
    });

    test(
      'mantiene el estado de carga mientras espera al repositorio',
      () async {
        repository.pendingSignIn = Completer<AppUser>();

        final Future<bool> pending = viewModel.signIn(
          email: 'vecino@ejemplo.com',
          password: 'Clave123!',
        );

        expect(viewModel.isLoading, isTrue);
        expect(viewModel.errorMessage, isNull);

        repository.completeSignIn(_user);

        expect(await pending, isTrue);
        expect(viewModel.isLoading, isFalse);
      },
    );

    test('registra un vecino y abre la sesión', () async {
      final bool result = await viewModel.signUp(
        nombres: 'María Fernanda',
        apellidos: 'Pérez Gómez',
        cedula: '1710034065',
        email: 'vecino@ejemplo.com',
        phone: '0991234567',
        password: 'Vecino123!',
        consentAccepted: true,
      );

      expect(result, isTrue);
      expect(repository.signUpCalls, 1);
      expect(repository.lastSignUp?.nombres, 'María Fernanda');
      expect(repository.lastSignUp?.apellidos, 'Pérez Gómez');
      expect(repository.lastSignUp?.cedula, '1710034065');
      expect(repository.lastSignUp?.email, 'vecino@ejemplo.com');
      expect(repository.lastSignUp?.phone, '0991234567');
      expect(viewModel.isAuthenticated, isTrue);
      expect(viewModel.currentUser?.role, UserRole.vecino);
      expect(viewModel.currentUser?.displayName, 'María Fernanda Pérez Gómez');
      expect(viewModel.errorMessage, isNull);
      expect(viewModel.isLoading, isFalse);
    });

    test('no registra si faltan datos obligatorios', () async {
      final bool result = await viewModel.signUp(
        nombres: '',
        apellidos: 'Pérez',
        cedula: '1710034065',
        email: 'vecino@ejemplo.com',
        password: 'Vecino123!',
        consentAccepted: true,
      );

      expect(result, isFalse);
      expect(repository.signUpCalls, 0);
      expect(viewModel.errorMessage, AppStrings.authMissingRegistrationData);
    });

    test('no registra sin aceptar el aviso de privacidad', () async {
      final bool result = await viewModel.signUp(
        nombres: 'María',
        apellidos: 'Pérez',
        cedula: '1710034065',
        email: 'vecino@ejemplo.com',
        password: 'Vecino123!',
        consentAccepted: false,
      );

      expect(result, isFalse);
      expect(repository.signUpCalls, 0);
      expect(viewModel.errorMessage, AppStrings.authConsentRequired);
    });

    test('traduce el correo ya registrado durante el registro', () async {
      repository.signUpFailure = const AuthFailure(
        AuthFailureReason.emailAlreadyInUse,
      );

      final bool result = await viewModel.signUp(
        nombres: 'María',
        apellidos: 'Pérez',
        cedula: '1710034065',
        email: 'vecino@ejemplo.com',
        password: 'Vecino123!',
        consentAccepted: true,
      );

      expect(result, isFalse);
      expect(viewModel.isAuthenticated, isFalse);
      expect(viewModel.errorMessage, AppStrings.authEmailAlreadyInUse);
      expect(viewModel.isLoading, isFalse);
    });

    test('traduce el fallo al guardar el perfil', () async {
      repository.signUpFailure = const AuthFailure(
        AuthFailureReason.profileCreationFailed,
      );

      final bool result = await viewModel.signUp(
        nombres: 'María',
        apellidos: 'Pérez',
        cedula: '1710034065',
        email: 'vecino@ejemplo.com',
        password: 'Vecino123!',
        consentAccepted: true,
      );

      expect(result, isFalse);
      expect(viewModel.errorMessage, AppStrings.authProfileCreationFailed);
    });

    test('mantiene el estado de carga durante el registro', () async {
      repository.pendingSignUp = Completer<AppUser>();

      final Future<bool> pending = viewModel.signUp(
        nombres: 'María',
        apellidos: 'Pérez',
        cedula: '1710034065',
        email: 'vecino@ejemplo.com',
        password: 'Vecino123!',
        consentAccepted: true,
      );

      expect(viewModel.isLoading, isTrue);
      expect(viewModel.errorMessage, isNull);

      repository.completeSignUp(_user);

      expect(await pending, isTrue);
      expect(viewModel.isLoading, isFalse);
    });

    test('envía el enlace de recuperación y marca el estado', () async {
      final bool result = await viewModel.requestPasswordReset(
        ' vecino@ejemplo.com ',
      );

      expect(result, isTrue);
      expect(repository.passwordResetCalls, 1);
      expect(repository.lastPasswordResetEmail, 'vecino@ejemplo.com');
      expect(viewModel.passwordResetSent, isTrue);
      expect(viewModel.errorMessage, isNull);
      expect(viewModel.isLoading, isFalse);
    });

    test('no envía recuperación sin correo', () async {
      final bool result = await viewModel.requestPasswordReset('   ');

      expect(result, isFalse);
      expect(repository.passwordResetCalls, 0);
      expect(viewModel.passwordResetSent, isFalse);
      expect(viewModel.errorMessage, AppStrings.validationEmailRequired);
    });

    test('traduce el fallo al enviar recuperación', () async {
      repository.passwordResetFailure = const AuthFailure(
        AuthFailureReason.network,
      );

      final bool result = await viewModel.requestPasswordReset(
        'vecino@ejemplo.com',
      );

      expect(result, isFalse);
      expect(viewModel.passwordResetSent, isFalse);
      expect(viewModel.errorMessage, AppStrings.authNetwork);
    });

    test('limpia el resultado de recuperación al editar el correo', () async {
      await viewModel.requestPasswordReset('vecino@ejemplo.com');
      expect(viewModel.passwordResetSent, isTrue);

      viewModel.clearPasswordResetState();

      expect(viewModel.passwordResetSent, isFalse);
      expect(viewModel.errorMessage, isNull);
    });

    test('cierra la sesión correctamente', () async {
      final FakeAuthRepository signedInRepository = FakeAuthRepository(
        initialUser: _user,
      );
      final AuthViewModel signedInViewModel = AuthViewModel(
        repository: signedInRepository,
      );
      addTearDown(() async {
        signedInViewModel.dispose();
        await signedInRepository.dispose();
      });

      await signedInViewModel.signOut();

      expect(signedInRepository.signOutCalls, 1);
      expect(signedInViewModel.isAuthenticated, isFalse);
      expect(signedInViewModel.currentUser, isNull);
      expect(signedInViewModel.isLoading, isFalse);
    });

    test('limpia el error al corregir los datos', () async {
      await viewModel.signIn(email: '', password: '');
      expect(viewModel.errorMessage, isNotNull);

      viewModel.clearError();

      expect(viewModel.errorMessage, isNull);
    });

    test('reenvía la verificación y muestra la confirmación', () async {
      final bool result = await viewModel.resendVerificationEmail();

      expect(result, isTrue);
      expect(repository.sendVerificationCalls, 1);
      expect(viewModel.infoMessage, AppStrings.verifyEmailSent);
      expect(viewModel.errorMessage, isNull);
      expect(viewModel.isLoading, isFalse);
    });

    test('traduce el fallo al reenviar la verificación', () async {
      repository.verificationFailure = const AuthFailure(
        AuthFailureReason.verificationEmailFailed,
      );

      final bool result = await viewModel.resendVerificationEmail();

      expect(result, isFalse);
      expect(viewModel.errorMessage, AppStrings.authVerificationEmailFailed);
    });

    test('mantiene el bloqueo si el correo sigue sin verificar', () async {
      repository.emit(_unverifiedUser);
      await Future<void>.delayed(Duration.zero);

      await viewModel.refreshUser();

      expect(viewModel.isEmailVerified, isFalse);
      expect(viewModel.needsEmailVerification, isTrue);
      expect(viewModel.infoMessage, AppStrings.verifyEmailStillPending);
    });

    test('desbloquea la sesión cuando el correo quedó verificado', () async {
      repository.emit(_unverifiedUser);
      await Future<void>.delayed(Duration.zero);
      repository.reloadResult = _user;

      await viewModel.refreshUser();

      expect(viewModel.isEmailVerified, isTrue);
      expect(viewModel.needsEmailVerification, isFalse);
      expect(viewModel.infoMessage, isNull);
    });

    test('solicita el cambio de correo y guarda el pendiente', () async {
      repository.emit(_unverifiedUser);
      await Future<void>.delayed(Duration.zero);

      final bool result = await viewModel.requestEmailChange(
        ' nuevo@ejemplo.com ',
      );

      expect(result, isTrue);
      expect(repository.requestEmailChangeCalls, 1);
      expect(repository.lastRequestedEmail, 'nuevo@ejemplo.com');
      expect(viewModel.pendingEmail, 'nuevo@ejemplo.com');
      expect(viewModel.infoMessage, AppStrings.verifyEmailChangeSent);
    });

    test('reenvía al correo nuevo si hay un cambio pendiente', () async {
      repository.emit(_unverifiedUser);
      await Future<void>.delayed(Duration.zero);
      await viewModel.requestEmailChange('nuevo@ejemplo.com');

      final bool result = await viewModel.resendVerificationEmail();

      expect(result, isTrue);
      expect(repository.requestEmailChangeCalls, 2);
      expect(repository.lastRequestedEmail, 'nuevo@ejemplo.com');
      expect(repository.sendVerificationCalls, 0);
    });

    test('el modo temporal desbloquea la cuenta sin verificar', () async {
      final FakeAuthRepository temporaryRepository = FakeAuthRepository(
        initialUser: _unverifiedUser,
      );
      final AuthViewModel temporaryViewModel = AuthViewModel(
        repository: temporaryRepository,
        autoVerifyEmail: true,
        autoVerifyDelay: const Duration(milliseconds: 5),
      );
      addTearDown(() async {
        temporaryViewModel.dispose();
        await temporaryRepository.dispose();
      });

      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(temporaryViewModel.isEmailVerified, isTrue);
      expect(temporaryViewModel.needsEmailVerification, isFalse);
    });

    test('traduce el fallo por inicio de sesión antiguo', () async {
      repository.emit(_unverifiedUser);
      await Future<void>.delayed(Duration.zero);
      repository.emailChangeFailure = const AuthFailure(
        AuthFailureReason.requiresRecentLogin,
      );

      final bool result = await viewModel.requestEmailChange(
        'nuevo@ejemplo.com',
      );

      expect(result, isFalse);
      expect(viewModel.pendingEmail, isNull);
      expect(viewModel.errorMessage, AppStrings.authRequiresRecentLogin);
    });
  });
}
