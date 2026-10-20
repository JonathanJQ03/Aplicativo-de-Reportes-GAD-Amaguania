import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'admin_app.dart';
import 'core/config/firebase_bootstrap.dart';
import 'core/errors/startup_error_app.dart';
import 'features/auth/data/firebase_auth_repository.dart';

/// Punto de entrada del panel web de administración.
///
/// S07 agrega el login y el guard de rol; el layout del panel se construye en
/// S15.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    final FirebaseSetup setup = await FirebaseBootstrap.initialize();
    if (kDebugMode) {
      debugPrint(
        'Firebase local (panel): host=${setup.authEmulatorHost}, '
        'emulador=${setup.useAuthEmulator}',
      );
    }
    runApp(
      AdminApp(
        authRepository: FirebaseAuthRepository(
          useEmulator: setup.useAuthEmulator,
          emulatorHost: setup.authEmulatorHost,
        ),
      ),
    );
  } catch (error) {
    // Nunca se muestran datos personales ni detalles técnicos al usuario.
    if (kDebugMode) {
      debugPrint('No se pudo inicializar Firebase (panel): $error');
    }
    runApp(StartupErrorApp(onRetry: main));
  }
}
