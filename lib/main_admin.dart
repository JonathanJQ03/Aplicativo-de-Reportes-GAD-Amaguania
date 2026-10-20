import 'main_vecino.dart' as unified_app;

/// Compatibilidad con la entrada anterior del panel.
///
/// VeciApp ya es una sola aplicación: el acceso de administrador está dentro
/// del login principal, arriba a la derecha. Este archivo se conserva para que
/// los comandos y la documentación existentes sigan funcionando, pero arranca
/// exactamente la misma app que `main_vecino.dart`.
Future<void> main() => unified_app.main();
