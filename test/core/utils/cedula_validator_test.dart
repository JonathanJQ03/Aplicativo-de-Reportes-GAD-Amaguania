import 'package:amaguana_alerta/core/utils/cedula_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CedulaValidator.isValid', () {
    test('acepta cédulas ecuatorianas válidas', () {
      for (final String cedula in <String>[
        '1710034065',
        '0102030400',
        '0912345675',
        ' 1710034065 ',
      ]) {
        expect(
          CedulaValidator.isValid(cedula),
          isTrue,
          reason: 'Debería aceptar "$cedula"',
        );
      }
    });

    test('rechaza valores que no tienen 10 dígitos', () {
      for (final String cedula in <String>[
        '',
        '171003406',
        '17100340655',
        '17100340a5',
        '1710 34065',
        'abcdefghij',
      ]) {
        expect(
          CedulaValidator.isValid(cedula),
          isFalse,
          reason: 'Debería rechazar "$cedula"',
        );
      }
    });

    test('rechaza provincias fuera del rango 01 a 24', () {
      expect(CedulaValidator.isValid('0010034064'), isFalse);
      expect(CedulaValidator.isValid('2510034065'), isFalse);
      expect(CedulaValidator.isValid('0000000000'), isFalse);
    });

    test('rechaza el tercer dígito reservado para personas jurídicas', () {
      // La cédula tiene un verificador correcto, pero el tercer dígito es 6.
      expect(CedulaValidator.isValid('1760034064'), isFalse);
    });

    test('rechaza un dígito verificador incorrecto', () {
      expect(CedulaValidator.isValid('1710034066'), isFalse);
      expect(CedulaValidator.isValid('1710034064'), isFalse);
    });
  });

  group('CedulaValidator.format', () {
    test('separa el dígito verificador con un guion', () {
      expect(CedulaValidator.format('1710034065'), '171003406-5');
      expect(CedulaValidator.format(' 1710034065 '), '171003406-5');
    });

    test('devuelve el valor sin cambios si no tiene 10 dígitos', () {
      expect(CedulaValidator.format('171003406'), '171003406');
      expect(CedulaValidator.format('17100340a5'), '17100340a5');
    });
  });
}
