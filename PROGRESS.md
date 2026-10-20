# PROGRESS

**Sesión actual:** S02 — Validación de campos (completada)
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

## En curso

Ninguna. La siguiente sesión es S03 (registro) y no se inicia hasta que el
usuario lo indique.

## Pendientes

S03 … S28 (ver `AGENTS.md`).

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
- (2026-10-19) Los validadores compartidos viven en
  `lib/shared/validators/validators.dart` y los mensajes visibles en
  `AppStrings`. El login valida el formato del correo y exige la contraseña en
  la capa de presentación; el ViewModel conserva una comprobación defensiva de
  campos vacíos.
- (2026-10-19) En el login la contraseña solo se exige escrita. Las reglas de
  fortaleza se definirán en el registro (S03), junto con la validación de
  cédula en S04.
- (2026-10-19) La validación se muestra al enviar; al corregir un campo se
  limpia su error y se enfoca el primer campo inválido. Los errores de Firebase
  siguen mostrándose en el aviso superior.

## Deuda y TODO

- TODO(S03): formulario de registro; TODO(S05): verificación por correo;
  TODO(S06): consentimiento y recuperación de contraseña. Sus pantallas siguen
  como stubs sin enlaces desde el login.
- TODO(S07): cargar el rol real desde Firestore y agregar guards por rol.
- TODO(S08): reemplazar `HomeView` por la navegación principal definitiva.
- TODO(S15): construir el panel de administración sobre el marcador
  `lib/main_admin.dart`.
- Verificado en un dispositivo físico Samsung SM-A546E: APK debug compilado,
  instalado y capturas de los estados de error en
  `/home/javier/Descargas/VeciApp/` (`s02-login-errores-vacios.png` y
  `s02-login-correo-invalido.png`). El login real contra Firebase no se pudo
  completar desde el teléfono porque el build apunta al emulador de Auth en
  `10.0.2.2`; para probarlo hay que levantar el emulador y recompilar con
  `--dart-define=FIREBASE_EMULATOR_HOST=<IP de la PC>`, o configurar un
  proyecto real.
- `android/gradle.properties` tiene un ajuste local (heap de 2 GB, sin daemon
  ni incremental) para compilar en este equipo; no se incluyó en los commits de
  S02 para no imponerlo al resto del equipo.
- El repositorio no incluye `docs/SRS.pdf` (la carpeta `docs/srs` está vacía);
  S02 se basó en la hoja de ruta de `AGENTS.md` y RNF-05. Pedir el SRS si hace
  falta para S03/S04.
- El emulador de Firebase requiere Node.js y Java 17; las instrucciones están
  en `docs/firebase-emulator.md`.
