# PROGRESS

**Sesión actual:** S02 — Validación de campos (pendiente de inicio)
**Última actualización:** 2026-10-19

## Completadas

- S00 — Preparación ✅ (RNF-08): base normalizada con tokens de `DESIGN.md`,
  tipografía Nunito/Nunito Sans, textos centralizados, widgets compartidos,
  localización en español y `PROGRESS.md`.
- S01 — Login ✅ (RF-04): pantalla de inicio de sesión, conexión con Firebase
  Authentication, sesión persistente, cierre de sesión y redirección básica.

## En curso

Ninguna. La siguiente sesión es S02 y no se inicia hasta que el usuario lo
indique.

## Pendientes

S02 … S28 (ver `AGENTS.md`).

## Decisiones tomadas

- (2026-10-19) Se mantiene **Provider** como gestor de estado porque ya estaba
  configurado y documentado en el repositorio. La feature `auth` quedó migrada
  a Clean Architecture (`domain` / `data` / `presentation`); las demás features
  se migrarán al tocarlas en su sesión.
- (2026-10-19) El login usa **correo y contraseña**. El rol se asigna como
  `vecino` por defecto hasta que S07 lo lea de Firestore.
- (2026-10-19) En modo `debug` Firebase usa un **proyecto demo y el emulador de
  Authentication**. Para un proyecto real se pasan las claves con
  `--dart-define` y `FIREBASE_USE_EMULATOR=false`. No se versionan claves ni
  archivos de configuración.
- (2026-10-19) El nombre visible es **VeciApp**, según `AGENTS.md` y
  `DESIGN.md`. Queda pendiente confirmar la decisión abierta n.º 1 del SRS
  (VeciApp vs. Amaguaña Alerta).
- (2026-10-19) El punto de entrada móvil es `lib/main_vecino.dart`;
  `lib/main.dart` delega en él para que `flutter run` siga funcionando.
  `lib/main_admin.dart` existe como marcador con el tema aplicado; el panel
  real se construye en S15.

## Deuda y TODO

- TODO(S02): validadores reutilizables y estados de error de `AppTextField`.
  Por ahora el login solo comprueba que los campos no estén vacíos.
- TODO(S03): formulario de registro; TODO(S05): verificación por correo;
  TODO(S06): consentimiento y recuperación de contraseña. Sus pantallas siguen
  como stubs sin enlaces desde el login.
- TODO(S07): cargar el rol real desde Firestore y agregar guards por rol.
- TODO(S08): reemplazar `HomeView` por la navegación principal definitiva.
- TODO(S15): construir el panel de administración sobre el marcador
  `lib/main_admin.dart`.
- El entorno de esta sesión no tiene Java, Chrome ni el toolchain de Android
  disponible, así que no se pudo abrir la app en un dispositivo. La sesión se
  verificó con `flutter analyze` y `flutter test`, incluidos pruebas de widget
  del login y de la redirección de sesión.
- El emulador de Firebase requiere Node.js y Java 17; las instrucciones están
  en `docs/firebase-emulator.md`.
