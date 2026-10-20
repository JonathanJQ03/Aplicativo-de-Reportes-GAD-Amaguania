import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'app.dart';
import 'core/config/firebase_bootstrap.dart';
import 'core/errors/startup_error_app.dart';
import 'features/auth/data/firebase_auth_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    final FirebaseSetup setup = await FirebaseBootstrap.initialize();
    runApp(
      VeciApp(
        authRepository: FirebaseAuthRepository(
          useEmulator: setup.useAuthEmulator,
          emulatorHost: setup.authEmulatorHost,
        ),
      ),
    );
  } catch (error) {
    // Nunca se muestran datos personales ni detalles técnicos al usuario.
    if (kDebugMode) {
      debugPrint('No se pudo inicializar Firebase: $error');
    }
    runApp(StartupErrorApp(onRetry: main));
  }
}
