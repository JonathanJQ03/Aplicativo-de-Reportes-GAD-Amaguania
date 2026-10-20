import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Datos que la inicialización de Firebase deja disponibles al arranque.
class FirebaseSetup {
  const FirebaseSetup({
    required this.useAuthEmulator,
    required this.authEmulatorHost,
  });

  final bool useAuthEmulator;
  final String authEmulatorHost;
}

/// Inicializa Firebase a partir de configuración local o del emulador.
///
/// En modo de desarrollo se usa por defecto un proyecto demo y el emulador de
/// Authentication, de modo que no hace falta subir claves al repositorio. Para
/// una build real se deben pasar las claves con `--dart-define` o configurar
/// los archivos nativos con `flutterfire configure`.
abstract final class FirebaseBootstrap {
  static const String _projectId = String.fromEnvironment(
    'FIREBASE_PROJECT_ID',
  );
  static const String _apiKey = String.fromEnvironment('FIREBASE_API_KEY');
  static const String _appId = String.fromEnvironment('FIREBASE_APP_ID');
  static const String _messagingSenderId = String.fromEnvironment(
    'FIREBASE_MESSAGING_SENDER_ID',
  );
  static const String _authDomain = String.fromEnvironment(
    'FIREBASE_AUTH_DOMAIN',
  );
  static const String _storageBucket = String.fromEnvironment(
    'FIREBASE_STORAGE_BUCKET',
  );
  static const String _emulatorHostOverride = String.fromEnvironment(
    'FIREBASE_EMULATOR_HOST',
  );
  static const bool _useEmulator = bool.fromEnvironment(
    'FIREBASE_USE_EMULATOR',
    defaultValue: kDebugMode,
  );

  static FirebaseOptions get _demoOptions {
    final String appId = kIsWeb
        ? '1:000000000000:web:veciapp-demo'
        : switch (defaultTargetPlatform) {
            TargetPlatform.android => '1:000000000000:android:veciapp-demo',
            TargetPlatform.iOS => '1:000000000000:ios:veciapp-demo',
            _ => '1:000000000000:web:veciapp-demo',
          };
    return FirebaseOptions(
      apiKey: 'demo-api-key',
      appId: appId,
      messagingSenderId: '000000000000',
      projectId: 'demo-veciapp',
      authDomain: 'demo-veciapp.firebaseapp.com',
      storageBucket: 'demo-veciapp.appspot.com',
    );
  }

  static bool get _hasExplicitOptions =>
      _projectId.isNotEmpty &&
      _apiKey.isNotEmpty &&
      _appId.isNotEmpty &&
      _messagingSenderId.isNotEmpty;

  /// Inicializa Firebase una sola vez y devuelve cómo conectar Auth.
  static Future<FirebaseSetup> initialize() async {
    if (Firebase.apps.isEmpty) {
      final FirebaseOptions? options = _options();
      if (options == null) {
        await Firebase.initializeApp();
      } else {
        await Firebase.initializeApp(options: options);
      }
    }

    return FirebaseSetup(
      useAuthEmulator: _useEmulator,
      authEmulatorHost: _emulatorHostOverride.isNotEmpty
          ? _emulatorHostOverride
          : _defaultEmulatorHost,
    );
  }

  static FirebaseOptions? _options() {
    if (_hasExplicitOptions) {
      return FirebaseOptions(
        apiKey: _apiKey,
        appId: _appId,
        messagingSenderId: _messagingSenderId,
        projectId: _projectId,
        authDomain: _authDomain.isEmpty ? null : _authDomain,
        storageBucket: _storageBucket.isEmpty ? null : _storageBucket,
      );
    }
    if (_useEmulator) {
      return _demoOptions;
    }
    return null;
  }

  static String get _defaultEmulatorHost {
    if (kIsWeb) {
      return 'localhost';
    }
    return defaultTargetPlatform == TargetPlatform.android
        ? '10.0.2.2'
        : 'localhost';
  }
}
