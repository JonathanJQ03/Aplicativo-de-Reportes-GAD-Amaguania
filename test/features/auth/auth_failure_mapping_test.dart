import 'package:amaguana_alerta/features/auth/data/firebase_auth_repository.dart';
import 'package:amaguana_alerta/features/auth/domain/auth_failure.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('authFailureReasonForCode', () {
    test('agrupa los errores de credenciales', () {
      for (final String code in [
        'invalid-credential',
        'user-not-found',
        'wrong-password',
        'invalid-email',
      ]) {
        expect(
          authFailureReasonForCode(code),
          AuthFailureReason.invalidCredentials,
        );
      }
    });

    test('traduce cuenta suspendida y exceso de intentos', () {
      expect(
        authFailureReasonForCode('user-disabled'),
        AuthFailureReason.userDisabled,
      );
      expect(
        authFailureReasonForCode('too-many-requests'),
        AuthFailureReason.tooManyRequests,
      );
    });

    test('traduce problemas de red y método no habilitado', () {
      expect(
        authFailureReasonForCode('network-request-failed'),
        AuthFailureReason.network,
      );
      expect(
        authFailureReasonForCode('operation-not-allowed'),
        AuthFailureReason.notAllowed,
      );
    });

    test('usa desconocido para códigos no contemplados', () {
      expect(
        authFailureReasonForCode('internal-error'),
        AuthFailureReason.unknown,
      );
    });
  });
}
