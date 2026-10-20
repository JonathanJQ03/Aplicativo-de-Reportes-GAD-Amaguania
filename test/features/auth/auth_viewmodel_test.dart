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
        cedula: '1712345678',
        email: 'vecino@ejemplo.com',
        phone: '0991234567',
        password: 'Vecino123!',
      );

      expect(result, isTrue);
      expect(repository.signUpCalls, 1);
      expect(repository.lastSignUp?.nombres, 'María Fernanda');
      expect(repository.lastSignUp?.apellidos, 'Pérez Gómez');
      expect(repository.lastSignUp?.cedula, '1712345678');
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
        cedula: '1712345678',
        email: 'vecino@ejemplo.com',
        password: 'Vecino123!',
      );

      expect(result, isFalse);
      expect(repository.signUpCalls, 0);
      expect(viewModel.errorMessage, AppStrings.authMissingRegistrationData);
    });

    test('traduce el correo ya registrado durante el registro', () async {
      repository.signUpFailure = const AuthFailure(
        AuthFailureReason.emailAlreadyInUse,
      );

      final bool result = await viewModel.signUp(
        nombres: 'María',
        apellidos: 'Pérez',
        cedula: '1712345678',
        email: 'vecino@ejemplo.com',
        password: 'Vecino123!',
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
        cedula: '1712345678',
        email: 'vecino@ejemplo.com',
        password: 'Vecino123!',
      );

      expect(result, isFalse);
      expect(viewModel.errorMessage, AppStrings.authProfileCreationFailed);
    });

    test('mantiene el estado de carga durante el registro', () async {
      repository.pendingSignUp = Completer<AppUser>();

      final Future<bool> pending = viewModel.signUp(
        nombres: 'María',
        apellidos: 'Pérez',
        cedula: '1712345678',
        email: 'vecino@ejemplo.com',
        password: 'Vecino123!',
      );

      expect(viewModel.isLoading, isTrue);
      expect(viewModel.errorMessage, isNull);

      repository.completeSignUp(_user);

      expect(await pending, isTrue);
      expect(viewModel.isLoading, isFalse);
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
  });
}
