# PROGRESS

**Sesión actual:** S03 — Registro (completada)
**Última actualización:** 2026-10-19

## Completadas

- S00 — Preparación ✅ (RNF-08): base normalizada con tokens de `DESIGN.md`,
  tipografía Nunito/Nunito Sans, textos centralizados, widgets compartidos,
  localización en español y `PROGRESS.md`.
- S01 — Login ✅ (RF-04): pantalla de inicio de sesión, conexión con Firebase
  Authentication, sesión persistente, cierre de sesión y redirección básica.
- S02 — Validación de campos ✅ (RNF-05): validadores reutilizables de
  obligatoriedad y correo, mensajes claros en español, validación del login,
  estados de error de `AppTextField` con borde, icono y mensaje, foco en el
  primer campo inválido, pruebas unitarias y de widget.
- S03 — Registro ✅ (RF-01): formulario de cuenta con nombres, apellidos,
  cédula, correo obligatorio, teléfono opcional y contraseña; validadores de
  nombre, cédula (formato), teléfono y contraseña nueva; creación de la cuenta
  en Firebase Authentication con rol `vecino`; perfil público en `users` y
  datos sensibles en `users_private`; mensajes claros de error; pruebas
  unitarias y de widget.

## En curso

Ninguna. La siguiente sesión es S04 (validación de cédula) y no se inicia hasta
que el usuario lo indique.

## Pendientes

S04 … S28 (ver `AGENTS.md`).

## Decisiones tomadas

- (2026-10-19) Se mantiene **Provider** como gestor de estado porque ya estaba
  configurado y documentado en el repositorio. La feature `auth` quedó migrada
  a Clean Architecture (`domain` / `data` / `presentation`); las demás features
  se migrarán al tocarlas en su sesión.
- (2026-10-19) El login usa **correo y contraseña**. El rol se asigna como
  `vecino` por defecto hasta que S07 lo lea de Firestore.
- (2026-10-19) En modo `debug` Firebase usa un **proyecto demo y los emuladores
  locales de Authentication y Firestore**. Para un proyecto real se pasan las
  claves con `--dart-define` y `FIREBASE_USE_EMULATOR=false`. No se versionan
  claves ni archivos de configuración.
- (2026-10-19) El nombre visible es **VeciApp**, según `AGENTS.md` y
  `DESIGN.md`. Queda pendiente confirmar la decisión abierta n.º 1 del SRS
  (VeciApp vs. Amaguaña Alerta).
- (2026-10-19) El punto de entrada móvil es `lib/main_vecino.dart`;
  `lib/main.dart` delega en él para que `flutter run` siga funcionando.
  `lib/main_admin.dart` existe como marcador con el tema aplicado; el panel
  real se construye en S15.
- (2026-10-19) Los validadores compartidos viven en
  `lib/shared/validators/validators.dart` y los mensajes visibles en
  `AppStrings`. El login valida el formato del correo y exige la contraseña en
  la capa de presentación; el ViewModel conserva una comprobación defensiva de
  campos vacíos.
- (2026-10-19) La validación se muestra al enviar; al corregir un campo se
  limpia su error y se enfoca el primer campo inválido. Los errores de Firebase
  siguen mostrándose en el aviso superior.
- (2026-10-19) En S03 el **correo es obligatorio y el teléfono es opcional**,
  según lo acordado con el usuario: el login y la verificación de S05 usan
  correo. El teléfono se guarda como dato de contacto privado.
- (2026-10-19) La contraseña nueva exige **mínimo 8 caracteres con mayúscula,
  minúscula, número y símbolo**. No se pide confirmación de contraseña porque el
  SRS no la exige.
- (2026-10-19) `users/{uid}` guarda el nombre visible, el rol `vecino` y la
  fecha de creación. `users_private/{uid}` guarda nombres, apellidos, cédula,
  correo, teléfono opcional y fecha. La cédula solo se valida por formato (10
  dígitos) en S03; el algoritmo ecuatoriano y la detección de duplicados son
  S04.
- (2026-10-19) El registro deja la sesión abierta y el router redirige a `/`.
  Si falla la escritura del perfil, se intenta borrar el usuario recién creado
  en Auth y se muestra un mensaje claro.
- (2026-10-19) Las reglas de Firestore de S03 solo permiten a cada usuario leer
  y crear su propio perfil (`users/{uid}` y `users_private/{uid}`). S07 las
  ampliará por rol; no se versionan reglas abiertas.
- (2026-10-19) Para probar en un teléfono físico con los emuladores se usa
  `adb reverse` y `FIREBASE_EMULATOR_HOST=localhost`. La app desactiva
  `automaticHostMapping` en Auth y Firestore porque el SDK de Android convierte
  `localhost` en `10.0.2.2`, que solo existe dentro del emulador de Android.
  El build de debug permite HTTP local solo hacia `10.0.2.2`, `localhost` y
  `127.0.0.1`; la build de producción sigue exigiendo HTTPS.

## Deuda y TODO

- TODO(S04): validar la cédula ecuatoriana con su algoritmo y detectar
  duplicados; en S03 solo se comprueban 10 dígitos y el borrador de validación
  queda en `lib/core/utils/cedula_validator.dart`.
- TODO(S05): verificación por correo; TODO(S06): consentimiento y recuperación
  de contraseña. Sus pantallas siguen como stubs sin enlaces desde el login.
- TODO(S07): cargar el rol real desde Firestore, agregar guards por rol,
  ampliar las reglas de Firestore y Storage e impedir que el cliente escriba un
  rol distinto de `vecino`.
- TODO(S08): reemplazar `HomeView` por la navegación principal definitiva.
- TODO(S15): construir el panel de administración sobre el marcador
  `lib/main_admin.dart`.
- `firestore.rules` cubre solo el perfil de S03; todavía no existe
  `storage.rules` (llega con S07/S10).
- Verificado en un dispositivo físico Samsung SM-A546E contra los emuladores
  locales de Auth y Firestore: APK debug instalado, registro de una cuenta
  nueva y capturas en `/home/javier/Descargas/VeciApp/`
  (`s03-01-login.png`, `s03-02-registro.png`, `s03-03-registro-accion.png`,
  `s03-04-registro-errores.png`, `s03-05-registro-datos.png` y
  `s03-06-registro-resultado.png`). En Firestore se comprobó que `users` guarda
  el rol `vecino` y que `users_private` conserva la cédula, el correo y el
  teléfono separados del perfil público.
- `android/gradle.properties` tiene un ajuste local (heap de 2 GB, sin daemon
  ni incremental) para compilar en este equipo; no se incluyó en los commits.
- El SRS está en `docs/srs/SRS_GAD_AMAGUANIA_APLICATIVO_MOVIL.pdf`.
- Los emuladores de Firebase requieren Node.js y Java 11 o superior; las
  instrucciones están en `docs/firebase-emulator.md`.
