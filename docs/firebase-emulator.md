# Firebase local en desarrollo

S01 usa **Firebase Authentication** con correo y contraseña. S03 agrega el
registro de vecinos y guarda el perfil en **Cloud Firestore**. S05 agrega la
verificación del correo y el cambio de correo. Para no subir claves ni archivos
de configuración al repositorio, el modo de desarrollo usa un proyecto demo y
los emuladores locales.

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
Wi-Fi. La app configura los emuladores con `automaticHostMapping: false` para
que `localhost` llegue al equipo mediante `adb reverse` también en un teléfono
físico. También puedes indicar la IP de la computadora:

```bash
flutter run --dart-define=FIREBASE_EMULATOR_HOST=192.168.1.50
```

Los builds de desarrollo permiten tráfico HTTP solo hacia `10.0.2.2`,
`localhost` y `127.0.0.1` mediante
`android/app/src/debug/res/xml/network_security_config.xml`. La build de
producción no incluye esa configuración y sigue exigiendo HTTPS.

## 4. Registro de vecinos (S03)

Al crear una cuenta se escribe:

- `users/{uid}`: nombre visible, rol `vecino` y fecha de creación.
- `users_private/{uid}`: nombres, apellidos, cédula, correo y teléfono.

El correo es obligatorio y el teléfono es opcional. La cédula se valida con el
algoritmo ecuatoriano (S04). La detección de **cédulas duplicadas sigue
pendiente** y no debe darse por terminada.

## 5. Verificación de correo (S05)

Al registrarse, Firebase envía un enlace de verificación. La app guarda el
perfil, pero el guard del router mantiene al usuario en `/verify-email` hasta
que el correo esté verificado.

### Importante: los emuladores no envían correos reales

El emulador de Authentication **captura** el correo y el enlace; no los entrega
a Gmail, Outlook ni a ninguna dirección real. Por eso no es posible validar una
cuenta con un correo personal usando solo los emuladores.

Para obtener el enlace de verificación:

```bash
curl -s http://127.0.0.1:9099/emulator/v1/projects/demo-veciapp/oobCodes
```

El JSON devuelve un `oobLink` para cada solicitud. Abre ese enlace en el
navegador para simular el clic del correo; después vuelve a la app y usa **“Ya
verifiqué mi correo”**. También puedes revisar las solicitudes en la interfaz
del emulador (`http://127.0.0.1:4000`, pestaña **Authentication**).

### Modo temporal de desarrollo

Para no bloquear el avance mientras no haya un proyecto real, la app debug
desbloquea la cuenta **localmente** a los 3 segundos:

- no marca `emailVerified` en Firebase;
- no escribe en Firestore;
- no envía ningún correo;
- una build release mantiene el bloqueo.

El valor se controla con `FIREBASE_AUTO_VERIFY_EMAIL` y por defecto es
`kDebugMode` (activo solo en debug). Se puede desactivar:

```bash
flutter run \
  --dart-define=FIREBASE_EMULATOR_HOST=localhost \
  --dart-define=FIREBASE_AUTO_VERIFY_EMAIL=false
```

Este modo es temporal. La verificación real se implementará con un **código de
6 dígitos** y un backend/proveedor de correo, según la decisión del usuario.

### Cambio de correo

El cambio usa `verifyBeforeUpdateEmail`: el correo anterior sigue activo hasta
que se confirme el nuevo. Si hay un cambio pendiente, **“Reenviar correo”**
reenvía al correo nuevo. Al verificarse, la app intenta sincronizar el campo
`email` de `users_private`; la regla de Firestore permite al dueño actualizar
solo ese campo. La sincronización es best-effort y no bloquea el acceso.

## 6. Usar un proyecto real de Firebase

Pasa las claves por `--dart-define`, desactiva los emuladores y, si vas a probar
la verificación real, desactiva el desbloqueo temporal:

```bash
flutter run \
  --dart-define=FIREBASE_USE_EMULATOR=false \
  --dart-define=FIREBASE_AUTO_VERIFY_EMAIL=false \
  --dart-define=FIREBASE_PROJECT_ID=tu-proyecto \
  --dart-define=FIREBASE_API_KEY=tu-api-key \
  --dart-define=FIREBASE_APP_ID=tu-app-id \
  --dart-define=FIREBASE_MESSAGING_SENDER_ID=tu-sender-id
```

También puedes configurar los archivos nativos con `flutterfire configure` y
ejecutar con `--dart-define=FIREBASE_USE_EMULATOR=false`. Con un proyecto real,
Firebase sí envía el enlace al correo registrado. El **código de 6 dígitos**
todavía no está implementado; el flujo actual usa un enlace.

## Seguridad

Nunca se versionan estos archivos (ya están en `.gitignore`):

- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`
- `lib/firebase_options.dart`
- `.env` y variantes

Tampoco se registran en logs correos, contraseñas, cédulas ni teléfonos. No se
guarda en el repositorio el correo real usado para una prueba. Las reglas de
Firestore no son abiertas: exigen una sesión activa y que el `uid` coincida con
el documento.
