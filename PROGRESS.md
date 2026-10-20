# PROGRESS

**Sesión actual:** S05 — Verificación de correo (modo local temporal)
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

## En curso

Ninguna. S05 queda cerrada en su parte de interfaz y flujo local, pero **la
verificación real del correo sigue pendiente**. No se inicia S06 hasta que el
usuario lo indique.

## Pendientes

- **S05 real (RF-03)**: proyecto real de Firebase, envío de correo, código de
  6 dígitos y eliminación del modo temporal `autoVerifyEmail`.
- **Detección de cédulas duplicadas** (parte pendiente de RF-02). No se puede
  consultar `users_private` de otros vecinos con las reglas actuales; hay que
  definir el mecanismo antes de implementarla.
- S06 … S28 (ver `AGENTS.md` para el alcance de cada sesión).

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
- TODO(S06): consentimiento LOPDP y recuperación de contraseña.
- TODO(S07): cargar el rol real desde Firestore, guards por rol, ampliar reglas
  de Firestore y Storage e impedir que el cliente escriba un rol distinto de
  `vecino`.
- TODO(S08): reemplazar `HomeView` por la navegación principal definitiva.
- TODO(S15): construir el panel de administración sobre `lib/main_admin.dart`.
- La sincronización de `users_private.email` es best-effort: si falla la red o
  la escritura, no bloquea la verificación y se reintenta en una próxima recarga
  de la cuenta. Agregar una prueba de reglas de Firestore cuando exista
  infraestructura para ello.
- `firestore.rules` cubre solo el perfil; todavía no existe `storage.rules`
  (llega con S07/S10).
- Verificado en un dispositivo físico Samsung SM-A546E contra los emuladores
  locales de Auth y Firestore:
  - S03: registro y perfil separado en `users` / `users_private`; capturas
    `s03-01-login.png` … `s03-06-registro-resultado.png`.
  - S04: cédula inválida y válida; capturas `s04-01-cedula-invalida.png` y
    `s04-02-cedula-valida.png`.
  - S05: pantalla de verificación, cambio de correo pendiente y desbloqueo
    automático de desarrollo; capturas `s05-01-verificacion.png`,
    `s05-02-correo-pendiente.png`, `s05-03-verificado.png` y
    `s05-04-modo-desarrollo.png`.
- S05: `dart format .` aplicado, `flutter analyze` sin problemas, **102 pruebas
  pasan** (`flutter test`), APK debug compilado e instalado. Se comprobó el
  flujo de registro → verificación con enlace del emulador → inicio, el cambio
  de correo y el desbloqueo automático a los 3 segundos. **No se probó entrega
  real de correo** porque no hay proyecto real configurado.
- `android/gradle.properties` tiene un ajuste local (heap de 2 GB, sin daemon
  ni incremental) para compilar en este equipo; no se incluyó en los commits.
- El SRS está en `docs/srs/SRS_GAD_AMAGUANIA_APLICATIVO_MOVIL.pdf`.
- Los emuladores de Firebase requieren Node.js y Java 11 o superior; las
  instrucciones están en `docs/firebase-emulator.md`.
