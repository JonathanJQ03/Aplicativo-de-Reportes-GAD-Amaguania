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
    if (kDebugMode) {
      debugPrint(
        'Firebase local: host=${setup.authEmulatorHost}, '
        'emulador=${setup.useAuthEmulator}',
      );
    }
    // Temporal mientras no haya un proyecto real ni verificación por código.
    // En release el valor por defecto es `false` y la cuenta sigue bloqueada.
    const bool autoVerifyEmail = bool.fromEnvironment(
      'FIREBASE_AUTO_VERIFY_EMAIL',
      defaultValue: kDebugMode,
    );
    runApp(
      VeciApp(
        authRepository: FirebaseAuthRepository(
          useEmulator: setup.useAuthEmulator,
          emulatorHost: setup.authEmulatorHost,
        ),
        autoVerifyEmail: autoVerifyEmail,
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
