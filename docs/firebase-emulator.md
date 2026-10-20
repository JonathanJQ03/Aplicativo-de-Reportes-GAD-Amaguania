# Firebase Auth en desarrollo

S01 usa **Firebase Authentication** con correo y contraseña. Para no subir
claves ni archivos de configuración al repositorio, el modo de desarrollo usa
un proyecto demo y el **emulador de Authentication**.

## Requisitos

- Node.js y `npx` (para Firebase CLI).
- Java 17 o superior (el emulador de Auth lo requiere).

## 1. Levantar el emulador

Desde la raíz del repositorio:

```bash
npx firebase-tools emulators:start --only auth
```

La configuración está en `firebase.json` y `.firebaserc`:

- Auth: `127.0.0.1:9099`
- Interfaz del emulador: `http://127.0.0.1:4000`

## 2. Crear un usuario de prueba

En la interfaz del emulador (`http://127.0.0.1:4000`) abre **Authentication** y
crea el usuario, o usa la API REST:

```bash
curl -X POST \
  'http://127.0.0.1:9099/identitytoolkit.googleapis.com/v1/accounts:signUp?key=demo-api-key' \
  -H 'Content-Type: application/json' \
  -d '{"email":"vecino@ejemplo.com","password":"Vecino123!","returnSecureToken":true}'
```

Credenciales sugeridas para S01:

- Correo: `vecino@ejemplo.com`
- Contraseña: `Vecino123!`

## 3. Ejecutar la app

En una terminal aparte:

```bash
flutter run
```

En modo `debug` la app usa el proyecto demo y conecta Auth al emulador. En el
emulador de Android la dirección es `10.0.2.2`; en iOS, web o escritorio es
`localhost`.

Si usas un teléfono físico, indica la IP de tu computadora:

```bash
flutter run --dart-define=FIREBASE_EMULATOR_HOST=192.168.1.50
```

## 4. Usar un proyecto real de Firebase

Pasa las claves por `--dart-define` y desactiva el emulador:

```bash
flutter run \
  --dart-define=FIREBASE_USE_EMULATOR=false \
  --dart-define=FIREBASE_PROJECT_ID=tu-proyecto \
  --dart-define=FIREBASE_API_KEY=tu-api-key \
  --dart-define=FIREBASE_APP_ID=tu-app-id \
  --dart-define=FIREBASE_MESSAGING_SENDER_ID=tu-sender-id
```

También puedes configurar los archivos nativos con `flutterfire configure` y
ejecutar con `--dart-define=FIREBASE_USE_EMULATOR=false`.

## Seguridad

Nunca se versionan estos archivos (ya están en `.gitignore`):

- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`
- `lib/firebase_options.dart`
- `.env` y variantes

Tampoco se registran en logs correos, contraseñas, cédulas ni teléfonos.
