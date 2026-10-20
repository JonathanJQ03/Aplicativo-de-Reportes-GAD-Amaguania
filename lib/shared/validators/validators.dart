import '../../core/l10n/app_strings.dart';

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
  static final RegExp _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

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
  /// contraseñas se aplicarán en el registro (S03).
  static String? loginPassword(String? value) {
    return required(value, message: AppStrings.validationPasswordRequired);
  }
}
