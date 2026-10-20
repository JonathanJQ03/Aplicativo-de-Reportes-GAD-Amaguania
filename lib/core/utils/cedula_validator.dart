/// Validación de cédula ecuatoriana con el algoritmo módulo 10.
///
/// Una cédula ecuatoriana de persona natural cumple:
/// 1. Tiene exactamente 10 dígitos.
/// 2. Los dos primeros dígitos son el código de provincia (01 a 24).
/// 3. El tercer dígito es menor a 6 (persona natural).
/// 4. El último dígito es el verificador calculado con el algoritmo módulo 10.
class CedulaValidator {
  CedulaValidator._();

  /// Longitud esperada de una cédula ecuatoriana.
  static const int cedulaLength = 10;

  static final RegExp _digitsPattern = RegExp(r'^\d{10}$');
  static const List<int> _coefficients = <int>[2, 1, 2, 1, 2, 1, 2, 1, 2];

  /// Valida una [cedula] ecuatoriana.
  ///
  /// Devuelve `true` si la cédula es válida. Se ignoran los espacios externos.
  static bool isValid(String cedula) {
    final String value = cedula.trim();
    if (!_digitsPattern.hasMatch(value)) {
      return false;
    }

    final int province = int.parse(value.substring(0, 2));
    if (province < 1 || province > 24) {
      return false;
    }

    final int thirdDigit = int.parse(value[2]);
    if (thirdDigit >= 6) {
      return false;
    }

    int sum = 0;
    for (int index = 0; index < _coefficients.length; index++) {
      int product = int.parse(value[index]) * _coefficients[index];
      if (product >= 10) {
        product -= 9;
      }
      sum += product;
    }

    final int checkDigit = (10 - (sum % 10)) % 10;
    return checkDigit == int.parse(value[9]);
  }

  /// Formatea la [cedula] para mostrarla (ej: 1710034065 -> 171003406-5).
  ///
  /// Si el valor no contiene exactamente 10 dígitos, se devuelve sin cambios.
  static String format(String cedula) {
    final String value = cedula.trim();
    if (!_digitsPattern.hasMatch(value)) {
      return value;
    }
    return '${value.substring(0, 9)}-${value.substring(9)}';
  }
}
