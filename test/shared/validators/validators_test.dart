import 'package:amaguana_alerta/core/l10n/app_strings.dart';
import 'package:amaguana_alerta/shared/validators/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppValidators.required', () {
    const String message = 'Este campo es obligatorio.';

    test('rechaza null, vacío y solo espacios', () {
      expect(AppValidators.required(null, message: message), message);
      expect(AppValidators.required('', message: message), message);
      expect(AppValidators.required('   ', message: message), message);
    });

    test('acepta un valor con contenido', () {
      expect(AppValidators.required('Correo', message: message), isNull);
    });
  });

  group('AppValidators.email', () {
    test('exige el correo cuando está vacío', () {
      expect(AppValidators.email(null), AppStrings.validationEmailRequired);
      expect(AppValidators.email('   '), AppStrings.validationEmailRequired);
    });

    test('rechaza correos con formato inválido', () {
      for (final String value in <String>[
        'correo',
        'correo@',
        '@dominio.com',
        'correo@dominio',
        'correo @dominio.com',
        'correo@dominio .com',
      ]) {
        expect(
          AppValidators.email(value),
          AppStrings.validationEmailInvalid,
          reason: 'Debería rechazar "$value"',
        );
      }
    });

    test('acepta correos válidos y recorta espacios externos', () {
      for (final String value in <String>[
        'vecino@ejemplo.com',
        ' vecino@ejemplo.com ',
        'vecino+reportes@sub.ejemplo.ec',
      ]) {
        expect(
          AppValidators.email(value),
          isNull,
          reason: 'Debería aceptar "$value"',
        );
      }
    });
  });

  group('AppValidators.loginPassword', () {
    test('exige la contraseña cuando está vacía', () {
      expect(
        AppValidators.loginPassword(null),
        AppStrings.validationPasswordRequired,
      );
      expect(
        AppValidators.loginPassword('   '),
        AppStrings.validationPasswordRequired,
      );
    });

    test('acepta una contraseña escrita', () {
      expect(AppValidators.loginPassword('Clave123!'), isNull);
    });
  });
}
