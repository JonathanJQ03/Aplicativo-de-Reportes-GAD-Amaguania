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

  group('AppValidators.name', () {
    test('exige el mensaje específico del campo', () {
      expect(
        AppValidators.name(
          null,
          requiredMessage: AppStrings.validationFirstNameRequired,
        ),
        AppStrings.validationFirstNameRequired,
      );
      expect(
        AppValidators.name(
          '   ',
          requiredMessage: AppStrings.validationLastNameRequired,
        ),
        AppStrings.validationLastNameRequired,
      );
    });

    test('rechaza nombres con números, símbolos o demasiado cortos', () {
      for (final String value in <String>['María2', 'Pérez@', 'A']) {
        expect(
          AppValidators.name(
            value,
            requiredMessage: AppStrings.validationFirstNameRequired,
          ),
          AppStrings.validationNameInvalid,
          reason: 'Debería rechazar "$value"',
        );
      }
    });

    test('acepta tildes, espacios, apóstrofes y guiones', () {
      for (final String value in <String>[
        'María Fernanda',
        "O'Connor",
        'Pérez-Gómez',
        '  Ana  María  ',
      ]) {
        expect(
          AppValidators.name(
            value,
            requiredMessage: AppStrings.validationFirstNameRequired,
          ),
          isNull,
          reason: 'Debería aceptar "$value"',
        );
      }
    });
  });

  group('AppValidators.cedula', () {
    test('exige la cédula cuando está vacía', () {
      expect(AppValidators.cedula(null), AppStrings.validationCedulaRequired);
      expect(AppValidators.cedula('   '), AppStrings.validationCedulaRequired);
    });

    test('rechaza valores que no tienen 10 dígitos', () {
      for (final String value in <String>[
        '123456789',
        '12345678901',
        '17123456a8',
        '1712 45678',
        'abcdefghij',
      ]) {
        expect(
          AppValidators.cedula(value),
          AppStrings.validationCedulaFormat,
          reason: 'Debería rechazar "$value"',
        );
      }
    });

    test('rechaza cédulas de 10 dígitos con algoritmo inválido', () {
      for (final String value in <String>[
        '1710034066',
        '1760034064',
        '0010034064',
        '2510034065',
      ]) {
        expect(
          AppValidators.cedula(value),
          AppStrings.validationCedulaInvalid,
          reason: 'Debería rechazar "$value"',
        );
      }
    });

    test('acepta cédulas ecuatorianas válidas', () {
      for (final String value in <String>[
        '1710034065',
        '0102030400',
        ' 1710034065 ',
      ]) {
        expect(
          AppValidators.cedula(value),
          isNull,
          reason: 'Debería aceptar "$value"',
        );
      }
    });
  });

  group('AppValidators.phoneOptional', () {
    test('acepta vacío porque el teléfono es opcional', () {
      expect(AppValidators.phoneOptional(null), isNull);
      expect(AppValidators.phoneOptional(''), isNull);
      expect(AppValidators.phoneOptional('   '), isNull);
    });

    test('rechaza teléfonos con formato inválido', () {
      for (final String value in <String>[
        '099123456',
        '09912345678',
        '0812345678',
        '09912345a7',
        '099 123 4567',
      ]) {
        expect(
          AppValidators.phoneOptional(value),
          AppStrings.validationPhoneInvalid,
          reason: 'Debería rechazar "$value"',
        );
      }
    });

    test('acepta un celular ecuatoriano de 10 dígitos', () {
      expect(AppValidators.phoneOptional('0991234567'), isNull);
    });
  });

  group('AppValidators.newPassword', () {
    test('exige la contraseña cuando está vacía', () {
      expect(
        AppValidators.newPassword(null),
        AppStrings.validationPasswordRequired,
      );
      expect(
        AppValidators.newPassword('   '),
        AppStrings.validationPasswordRequired,
      );
    });

    test('exige al menos 8 caracteres', () {
      expect(
        AppValidators.newPassword('Abc1!'),
        AppStrings.validationPasswordMinLength,
      );
    });

    test('exige mayúscula, minúscula, número y símbolo', () {
      expect(
        AppValidators.newPassword('abcdefg1!'),
        AppStrings.validationPasswordUppercase,
      );
      expect(
        AppValidators.newPassword('ABCDEFG1!'),
        AppStrings.validationPasswordLowercase,
      );
      expect(
        AppValidators.newPassword('Abcdefgh!'),
        AppStrings.validationPasswordDigit,
      );
      expect(
        AppValidators.newPassword('Abcdefg1'),
        AppStrings.validationPasswordSymbol,
      );
    });

    test('acepta una contraseña segura', () {
      expect(AppValidators.newPassword('Vecino123!'), isNull);
    });
  });
}
