import '../../core/l10n/app_strings.dart';
import '../../core/utils/cedula_validator.dart';

/// Validador reutilizable de un campo de formulario.
///
/// Devuelve `null` cuando el valor es válido o el mensaje en español que debe
/// verse debajo del campo cuando no lo es.
typedef AppFieldValidator = String? Function(String? value);

/// Validadores compartidos por los formularios de VeciApp.
///
/// La capa de presentación decide cuándo ejecutarlos; los mensajes visibles
/// viven en [AppStrings] para que todos los formularios hablen igual.
abstract final class AppValidators {
  /// Longitud mínima de una contraseña nueva.
  static const int minPasswordLength = 8;

  static final RegExp _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  static final RegExp _namePattern = RegExp(r"^[a-zA-ZáéíóúüÁÉÍÓÚÜñÑ' -]+$");
  static final RegExp _digitsPattern = RegExp(r'^\d+$');
  static final RegExp _phonePattern = RegExp(r'^09\d{8}$');
  static final RegExp _upperCasePattern = RegExp(r'[A-ZÁÉÍÓÚÜÑ]');
  static final RegExp _lowerCasePattern = RegExp(r'[a-záéíóúüñ]');
  static final RegExp _digitPattern = RegExp(r'\d');
  static final RegExp _symbolPattern = RegExp(r'[^A-Za-z0-9\s]');

  /// Exige que el campo tenga contenido, sin contar espacios.
  static String? required(String? value, {required String message}) {
    if (value == null || value.trim().isEmpty) {
      return message;
    }
    return null;
  }

  /// Valida un correo electrónico con un formato claro y sin tecnicismos.
  static String? email(String? value) {
    final String? requiredMessage = required(
      value,
      message: AppStrings.validationEmailRequired,
    );
    if (requiredMessage != null) {
      return requiredMessage;
    }

    if (!_emailPattern.hasMatch(value!.trim())) {
      return AppStrings.validationEmailInvalid;
    }
    return null;
  }

  /// Valida la contraseña del inicio de sesión.
  ///
  /// En el login solo se exige que esté escrita; las reglas de creación de
  /// contraseñas se aplican en [newPassword].
  static String? loginPassword(String? value) {
    return required(value, message: AppStrings.validationPasswordRequired);
  }

  /// Valida un nombre o apellido: solo letras, espacios, apóstrofes y guiones.
  static String? name(String? value, {required String requiredMessage}) {
    final String? requiredMessageError = required(
      value,
      message: requiredMessage,
    );
    if (requiredMessageError != null) {
      return requiredMessageError;
    }

    final String name = value!.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (name.length < 2 || !_namePattern.hasMatch(name)) {
      return AppStrings.validationNameInvalid;
    }
    return null;
  }

  /// Valida el formato y el algoritmo de una cédula ecuatoriana.
  ///
  /// La detección de cédulas duplicadas se resolverá con un mecanismo del lado
  /// del servidor; no se consulta la cédula de otros vecinos desde el cliente.
  static String? cedula(String? value) {
    final String? requiredMessage = required(
      value,
      message: AppStrings.validationCedulaRequired,
    );
    if (requiredMessage != null) {
      return requiredMessage;
    }

    final String cedula = value!.trim();
    if (cedula.length != CedulaValidator.cedulaLength ||
        !_digitsPattern.hasMatch(cedula)) {
      return AppStrings.validationCedulaFormat;
    }
    if (!CedulaValidator.isValid(cedula)) {
      return AppStrings.validationCedulaInvalid;
    }
    return null;
  }

  /// Valida un teléfono celular ecuatoriano opcional.
  ///
  /// Un campo vacío es válido: el teléfono es un dato de contacto opcional.
  static String? phoneOptional(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    if (!_phonePattern.hasMatch(value.trim())) {
      return AppStrings.validationPhoneInvalid;
    }
    return null;
  }

  /// Valida una contraseña nueva con las reglas definidas para el registro.
  static String? newPassword(String? value) {
    final String? requiredMessage = required(
      value,
      message: AppStrings.validationPasswordRequired,
    );
    if (requiredMessage != null) {
      return requiredMessage;
    }

    final String password = value!;
    if (password.length < minPasswordLength) {
      return AppStrings.validationPasswordMinLength;
    }
    if (!_upperCasePattern.hasMatch(password)) {
      return AppStrings.validationPasswordUppercase;
    }
    if (!_lowerCasePattern.hasMatch(password)) {
      return AppStrings.validationPasswordLowercase;
    }
    if (!_digitPattern.hasMatch(password)) {
      return AppStrings.validationPasswordDigit;
    }
    if (!_symbolPattern.hasMatch(password)) {
      return AppStrings.validationPasswordSymbol;
    }
    return null;
  }
}
