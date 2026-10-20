/// Constantes técnicas globales de la aplicación.
///
/// Los textos visibles viven en `lib/core/l10n/app_strings.dart`.
abstract final class AppConstants {
  /// Versión del aviso de privacidad que se guarda con el consentimiento.
  ///
  /// Si cambia el texto legal, subir la versión y volver a solicitar la
  /// aceptación cuando corresponda.
  static const String privacyNoticeVersion = '1.0';

  // TODO(S07): centralizar aquí nombres de colecciones de Firestore y rutas
  // privadas de Storage cuando se definan las reglas de seguridad.
}
