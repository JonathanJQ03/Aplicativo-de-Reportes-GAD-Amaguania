# Firebase local en desarrollo

S01 usa **Firebase Authentication** con correo y contraseña. S03 agrega el
registro de vecinos y guarda el perfil en **Cloud Firestore**. Para no subir
claves ni archivos de configuración al repositorio, el modo de desarrollo usa un
proyecto demo y los emuladores locales.

## Requisitos

- Node.js y `npx` (para Firebase CLI).
- Java 11 o superior (el emulador de Firestore lo requiere).

## 1. Levantar los emuladores

Desde la raíz del repositorio:

```bash
npx firebase-tools emulators:start --only auth,firestore
```

La configuración está en `firebase.json` y `.firebaserc`:

- Auth: `127.0.0.1:9099`
- Firestore: `127.0.0.1:8080`
- Interfaz de los emuladores: `http://127.0.0.1:4000`

Las reglas de Firestore viven en `firestore.rules` y, en S03, solo permiten a
cada vecino leer y crear su propio perfil. S07 las ampliará por rol.

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

En modo `debug` la app usa el proyecto demo y conecta Auth y Firestore a los
emuladores. En el emulador de Android la dirección es `10.0.2.2`; en iOS, web o
escritorio es `localhost`.

Si usas un teléfono físico conectado por USB, redirige los puertos con `adb`:

```bash
adb reverse tcp:9099 tcp:9099
adb reverse tcp:8080 tcp:8080
flutter run --dart-define=FIREBASE_EMULATOR_HOST=localhost
```

Así el teléfono usa los emuladores de tu computadora sin depender de la red
Wi-Fi. También puedes indicar la IP de la computadora:

```bash
flutter run --dart-define=FIREBASE_EMULATOR_HOST=192.168.1.50
```

## 4. Registro de vecinos (S03)

Al crear una cuenta se escribe:

- `users/{uid}`: nombre visible, rol `vecino` y fecha de creación.
- `users_private/{uid}`: nombres, apellidos, cédula, correo y teléfono.

El correo es obligatorio y el teléfono es opcional. La cédula solo se valida por
formato en S03; el algoritmo ecuatoriano y la detección de duplicados llegan en
S04.

## 5. Usar un proyecto real de Firebase

Pasa las claves por `--dart-define` y desactiva los emuladores:

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

Tampoco se registran en logs correos, contraseñas, cédulas ni teléfonos. Las
reglas de Firestore no son abiertas: exigen una sesión activa y que el `uid`
coincida con el documento.
