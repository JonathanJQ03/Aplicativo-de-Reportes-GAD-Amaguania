# PROGRESS

**Sesión actual:** S07 — Roles y control de acceso
**Última actualización:** 2026-10-20

> Contexto detallado para retomar el trabajo: [`docs/contexto-sesion.md`](docs/contexto-sesion.md).

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
  cédula, correo obligatorio, teléfono opcional y contraseña; creación de la
  cuenta en Firebase Authentication con rol `vecino`; perfil público en `users`
  y datos sensibles en `users_private`; mensajes claros de error; pruebas
  unitarias y de widget.
- S04 — Validación de cédula ✅ (RF-02, alcance ajustado): algoritmo
  ecuatoriano módulo 10 en `CedulaValidator`, formateo con guion, integración
  con `AppValidators.cedula` y el formulario de registro, mensaje específico
  para cédulas con algoritmo inválido. La detección de **cédulas duplicadas
  quedó diferida** por decisión del usuario.
- S05 — Verificación de correo ⚠️ (RF-03, parcial y en modo local):
  - pantalla de verificación con correo registrado, reenvío, cambio de correo y
    cancelación;
  - guard de router: una cuenta sin correo verificado no entra a la app;
  - el registro envía el enlace de Firebase y guarda el perfil como en S03;
  - cambio de correo con `verifyBeforeUpdateEmail`; al confirmar el nuevo
    correo se sincroniza `users_private.email` y la regla de Firestore permite
    al dueño actualizar solo ese campo;
  - **modo temporal de desarrollo**: en builds debug, si el correo no está
    verificado, se desbloquea la cuenta localmente a los 3 segundos
    (`FIREBASE_AUTO_VERIFY_EMAIL`, por defecto `true` solo en debug). Esto **no
    verifica la cuenta en Firebase ni envía un correo real**;
  - **pendiente para cerrar RF-03 de verdad**: conectar un proyecto real de
    Firebase, implementar el código de 6 dígitos elegido por el usuario y
    retirar la verificación automática.
- S06 — Consentimiento LOPDP y recuperación ✅ (RF-06, RF-05):
  - aviso de privacidad en español, versión 1.0, visible desde el registro;
  - casilla de aceptación obligatoria, nunca premarcada; sin aceptación no se
    crea la cuenta ni se escribe el perfil;
  - `users_private` guarda `consentVersion` y `consentAcceptedAt` con hora del
    servidor. La regla de Firestore exige ambos campos al crear un perfil;
  - por decisión del usuario, el consentimiento se exige **solo a cuentas
    nuevas**; las cuentas creadas antes de S06 siguen funcionando;
  - recuperación de contraseña por **enlace de Firebase**: pantalla desde el
    login, validación del correo, mensaje genérico, enlace enviado por Firebase
    y contraseña anterior invalidada al completar el cambio;
  - no se revela si un correo está registrado: una dirección inexistente
    recibe el mismo mensaje de confirmación;
  - pruebas unitarias y de widget para consentimiento, mensajes y recuperación.
- S07 — Roles y control de acceso ✅ (RF-07, RNF-01):
  - el rol se lee de `users/{uid}.role` al iniciar sesión; si falta o falla la
    consulta se usa `vecino`, nunca un rol con más permisos;
  - el cliente no puede crear ni cambiar su rol: las reglas solo aceptan
    `role == "vecino"` al crear el perfil y bloquean cualquier cambio de `role`;
  - panel de administración con login propio, pantalla de comprobación, acceso
    restringido para vecinos y marcador **Panel en preparación** para
    administradores;
  - guard de rutas probado para sesión ausente, rol cargando, vecino, vecino
    verificado y administrador;
  - reglas de Firestore por rol para `users` y `users_private`;
  - reglas base de Storage: solo el dueño escribe imágenes de hasta 2 MB en su
    carpeta `users/{uid}/profile/`; el resto queda denegado;
  - seed del primer administrador documentado para los emuladores.

## En curso

Ninguna. S07 queda cerrada. **La verificación real del correo (S05) sigue
pendiente** y no se inicia S08 hasta que el usuario escriba “continuar”.

## Pendientes

- **S05 real (RF-03)**: proyecto real de Firebase, envío de correo, código de
  6 dígitos y eliminación del modo temporal `autoVerifyEmail`.
- **Detección de cédulas duplicadas** (parte pendiente de RF-02). No se puede
  consultar `users_private` de otros vecinos con las reglas actuales; hay que
  definir el mecanismo antes de implementarla.
- S07 … S28 (ver `AGENTS.md` para el alcance de cada sesión).

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
  `DESIGN.md`. Queda pendiente confirmar la decisión abierta n.º 1 del SRS.
- (2026-10-19) El punto de entrada móvil es `lib/main_vecino.dart`;
  `lib/main.dart` delega en él. `lib/main_admin.dart` sigue como marcador del
  panel web para S15.
- (2026-10-19) Los validadores compartidos viven en
  `lib/shared/validators/validators.dart` y los mensajes visibles en
  `AppStrings`.
- (2026-10-19) En S03 el **correo es obligatorio y el teléfono es opcional**.
  La contraseña nueva exige mínimo 8 caracteres con mayúscula, minúscula,
  número y símbolo; no se pide confirmación.
- (2026-10-19) `users/{uid}` guarda el nombre visible, el rol `vecino` y la
  fecha de creación. `users_private/{uid}` guarda nombres, apellidos, cédula,
  correo, teléfono opcional y fecha.
- (2026-10-19) Las reglas de Firestore de S03 solo permiten a cada usuario leer
  y crear su propio perfil. S07 las ampliará por rol.
- (2026-10-19) Para probar en un teléfono físico con los emuladores se usa
  `adb reverse` y `FIREBASE_EMULATOR_HOST=localhost`. La app desactiva
  `automaticHostMapping` para que `localhost` llegue al equipo.
- (2026-10-20) **S04 se limita al algoritmo y la validación del formulario.**
  La detección de cédulas duplicadas queda como deuda de RF-02.
- (2026-10-20) `CedulaValidator` es Dart puro y vive en `lib/core/utils/`. La
  regla de provincia se implementa como 01–24, el tercer dígito debe ser 0–5 y
  el verificador se calcula con los coeficientes `[2,1,2,1,2,1,2,1,2]`.
- (2026-10-20) **S05 conserva el perfil creado al registrarse** y bloquea el
  acceso con el guard del router hasta que el correo esté verificado.
- (2026-10-20) **“Cancelar” cierra la sesión**, no elimina la cuenta. El usuario
  puede volver a entrar y verificar después.
- (2026-10-20) El cambio de correo usa `verifyBeforeUpdateEmail`: el correo
  anterior sigue activo hasta que el usuario confirme el nuevo. Al verificarse,
  la app sincroniza `users_private.email`; la regla de Firestore permite al
  dueño actualizar únicamente el campo `email`.
- (2026-10-20) El usuario eligió un **código de 6 dígitos** para la verificación
  real. No se implementó porque requiere un backend propio o Cloud Functions y
  un proveedor de correo. El flujo actual de Firebase usa un enlace.
- (2026-10-20) Los emuladores **no envían correos reales**: guardan el enlace
  en la consola local. No se guarda en el repositorio el correo real que indicó
  el usuario. Para enviar a un correo real hace falta configurar un proyecto
  real de Firebase.
- (2026-10-20) Como el usuario pidió no bloquear el avance, se agregó el modo
  temporal `autoVerifyEmail`: **solo debug**, espera 3 segundos y permite entrar
  sin verificar. Una build release mantiene el bloqueo. Se puede desactivar con
  `--dart-define=FIREBASE_AUTO_VERIFY_EMAIL=false`.
- (2026-10-20) La rama `feature/s05-verificacion` se subió al remoto y S05 se
  integró en `main` con un merge. `main` es la base para S06; la verificación
  real sigue pendiente.
- (2026-10-20) **S06 usa un aviso de privacidad base redactado para el
  proyecto, versión 1.0.** Debe revisarlo el GAD antes de producción; si cambia
  el texto, se sube `AppConstants.privacyNoticeVersion` y se define si se vuelve
  a pedir la aceptación.
- (2026-10-20) El consentimiento se guarda en `users_private` con
  `consentVersion` y `consentAcceptedAt` (hora del servidor). Se exige solo a
  cuentas nuevas, por decisión del usuario.
- (2026-10-20) La recuperación de contraseña usa el **enlace de Firebase**, no
  un código propio. El mensaje es genérico para no revelar si el correo existe;
  al completar el cambio, la contraseña anterior deja de funcionar.
- (2026-10-20) La rama `feature/s06-consentimiento-recuperacion` se subió al
  remoto y S06 se integró en `main` con un merge. S07 parte de `main`.
- (2026-10-20) **S07 usa `users/{uid}.role` como fuente de verdad**:
  `vecino`, `vecinoVerificado` o `administrador`. Los custom claims quedan
  para cuando exista un backend/Cloud Functions; no se implementaron ahora.
- (2026-10-20) El rol ausente o desconocido se interpreta como `vecino`. Un
  error de red al leer el rol no concede acceso al panel.
- (2026-10-20) El cliente no puede escribir un rol distinto de `vecino` ni
  cambiar el rol después de crear el perfil. El primer administrador se crea
  manualmente en el emulador (consola o API local con token `owner`) y el
  procedimiento queda documentado en `docs/roles-y-acceso.md`.
- (2026-10-20) S07 incluye el **login del panel, el guard y un marcador**. El
  layout lateral, la bandeja y la moderación siguen en S15. La plataforma web
  (`web/`) también se agrega en S15; en S07 el panel se verificó ejecutando
  `lib/main_admin.dart` en el teléfono.
- (2026-10-20) Se creó `storage.rules` en S07 con reglas base deny-by-default.
  Las rutas de fotos de reportes (S10) y planillas (S22/S23) se agregan en sus
  sesiones.
- (2026-10-20) La rama `feature/s07-roles-acceso` se integró en `main` con un
  merge. S08 parte de `main`.

## Deuda y TODO

- **TODO(S05): verificación real por código de 6 dígitos.** Requiere decidir el
  backend (Cloud Functions con plan Blaze o un servicio propio), el proveedor de
  correo y el almacenamiento seguro de códigos con expiración. Al implementarlo,
  eliminar `autoVerifyEmail` de `VeciApp` y `main_vecino.dart`.
- **TODO(S05): probar con un proyecto real de Firebase.** Hoy no hay
  `google-services.json`, `firebase_options.dart` ni credenciales reales. Los
  emuladores no entregan correos a Gmail.
- **TODO(RF-02): detección de cédulas duplicadas.** La validación matemática ya
  está resuelta, pero el registro todavía permite una cédula repetida. Opciones:
  Cloud Function con Admin SDK o una colección de reserva con reglas que impidan
  duplicados sin exponer la cédula. No implementar por cuenta propia.
- **TODO(S06): revisión legal del aviso de privacidad.** El texto actual es una
  base técnica; el GAD debe validarlo con su área jurídica antes de producción.
  Si se modifica, actualizar la versión y decidir si se solicita una nueva
  aceptación a las cuentas existentes.
- **TODO(S08):** reemplazar `HomeView` por la navegación principal definitiva.
- **TODO(S15):** agregar la plataforma web (`web/`), el layout lateral y la
  bandeja del panel de administración. El guard y el login ya existen.
- **TODO(S23/S24):** habilitar desde el panel el cambio de rol y la suspensión
  de cuentas. Debe ser una operación auditada, no una escritura libre del
  cliente; las reglas actuales no permiten cambiar `role`.
- **TODO(S05):** cuando exista verificación real de correo, decidir si el panel
  exige correo verificado además del rol de administrador.
- **TODO(reglas):** trasladar la matriz manual de Firestore y Storage a pruebas
  automáticas cuando exista infraestructura (Node +
  `@firebase/rules-unit-testing`). Hoy se verificó con llamadas a los emuladores.
- La sincronización de `users_private.email` es best-effort: si falla la red o
  la escritura, no bloquea la verificación y se reintenta en una próxima recarga
  de la cuenta.
- `firestore.rules` ya separa el perfil público y el privado por rol;
  `storage.rules` solo permite la carpeta de perfil propia. Los reportes,
  residencias y auditoría se agregan en sus sesiones.
- **Verificación de S06:** `dart format .` aplicado, `flutter analyze` sin
  problemas, **115 pruebas pasan** (`flutter test`), APK debug compilado e
  instalado en un Samsung SM-A546E contra los emuladores locales.
  - Se creó una cuenta nueva aceptando el aviso; `users_private` quedó con
    `consentVersion: "1.0"` y `consentAcceptedAt` con timestamp del servidor.
  - Se abrió el aviso desde el registro y se comprobó que la casilla no se marca
    sin acción del usuario.
  - Se solicitó recuperación y se completó con el `oobCode` del emulador: la
    contraseña anterior respondió `INVALID_PASSWORD` y la nueva permitió iniciar
    sesión.
  - Un correo no registrado mostró el mismo mensaje genérico, sin revelar que no
    existía.
  - Capturas en `/home/javier/Descargas/VeciApp/`: `s06-01-login-recuperacion.png`,
    `s06-02-aviso-privacidad.png`, `s06-03-consentimiento.png`,
    `s06-04-recuperacion.png`, `s06-05-enlace-enviado.png`,
    `s06-06-sesion-recuperada.png` y `s06-07-correo-no-registrado.png`.
- **Verificación de S07:** `dart format .` aplicado, `flutter analyze` sin
  problemas, **135 pruebas pasan** (`flutter test`). APK debug compilado para
  `main_vecino.dart` y `main_admin.dart` e instalado en un Samsung SM-A546E
  contra los emuladores locales.
  - En el panel, una cuenta `vecino` quedó en **Acceso restringido** y una
    cuenta `administrador` llegó a **Panel en preparación**.
  - En la app móvil, el login de un vecino siguió funcionando con el rol
    cargado desde Firestore.
  - Reglas de Firestore verificadas con 13 llamadas al emulador: sin sesión
    `403`, vecino leyendo a otro `403`, cambio de rol `403`, administrador
    leyendo perfiles `200`, creación con rol `administrador` `403` y creación
    con rol `vecino` + consentimiento `200`.
  - Reglas de Storage verificadas: subida anónima `403`, subida propia `200`,
    subida a otra carpeta `403`, archivo que no es imagen `403`, imagen de 3 MB
    `403` y borrado propio `204`.
  - Capturas en `/home/javier/Descargas/VeciApp/`: `s07-01-login-admin.png`,
    `s07-02-vecino-acceso-restringido.png`, `s07-03-admin-panel.png` y
    `s07-04-movil-vecino.png`.
  - Para el teléfono físico, el APK se compila con
    `--dart-define=FIREBASE_EMULATOR_HOST=localhost`; sin ese valor Android
    intenta `10.0.2.2` y muestra el error de conexión.
  - La plataforma `web/` todavía no existe; el panel se probó en Android y la
    entrada web se agrega en S15.
- **No se probó entrega real de correo** porque no hay proyecto real
  configurado; la recuperación se verificó capturando el enlace del emulador.
- `android/gradle.properties` tiene un ajuste local (heap de 2 GB, sin daemon
  ni incremental) para compilar en este equipo; no se incluyó en los commits.
- El SRS está en `docs/srs/SRS_GAD_AMAGUANIA_APLICATIVO_MOVIL.pdf`.
- Los emuladores de Firebase requieren Node.js y Java 11 o superior; las
  instrucciones están en `docs/firebase-emulator.md`.
