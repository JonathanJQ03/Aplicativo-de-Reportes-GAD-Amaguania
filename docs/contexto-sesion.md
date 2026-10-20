# Contexto para retomar la próxima sesión

**Última sesión cerrada:** S05 — Verificación de correo (modo local temporal)
**Fecha:** 2026-10-20
**Rama:** `feature/s05-verificacion`
**Siguiente sesión:** S06 — Consentimiento LOPDP y recuperación de contraseña

> Este documento es un apoyo para retomar el trabajo. La fuente de verdad del
> avance sigue siendo `PROGRESS.md`; las reglas del proyecto están en
> `AGENTS.md` y el diseño en `DESIGN.md`.

## 1. Dónde nos quedamos

S05 quedó implementada en su flujo local, pero **RF-03 no está cerrado**:

- La app ya envía el enlace de verificación de Firebase al registrarse y al
  reenviarlo, y bloquea el acceso con un guard hasta que el correo esté
  verificado.
- La pantalla permite comprobar el estado, reenviar, cambiar el correo y
  cancelar (cerrar sesión).
- El cambio de correo usa `verifyBeforeUpdateEmail`; al confirmar el nuevo
  correo, la app sincroniza el campo `email` de `users_private`.
- El usuario decidió que la verificación real use un **código de 6 dígitos**.
  Eso no está implementado: requiere backend/Cloud Functions y un proveedor de
  correo.
- Para no bloquear el avance, se agregó un **modo temporal solo para debug**:
  a los 3 segundos se desbloquea la cuenta localmente, sin verificar en Firebase
  ni enviar un correo real. En release el bloqueo se mantiene.
- Los emuladores no envían correos reales; guardan el enlace en la consola
  local. No se guardó en el repositorio el correo real indicado por el usuario.

## 2. Qué funciona hoy

- Login, registro, validación de cédula, sesión persistente y cierre de sesión.
- Registro con perfil público en `users` y datos sensibles en `users_private`.
- Verificación de correo:
  - pantalla `VerifyEmailView` con correo actual, reenvío, cambio de correo y
    cancelación;
  - guard en `app_router.dart`: sin correo verificado solo se accede a
    `/verify-email`;
  - al volver a la app se recarga el estado de Auth; el botón “Ya verifiqué mi
    correo” hace la comprobación manual;
  - el botón “Reenviar correo” reenvía al correo nuevo si hay un cambio
    pendiente;
  - el cambio de correo se completa al abrir el enlace enviado al nuevo correo.
- Modo temporal de desarrollo:
  - `AuthViewModel.autoVerifyEmail` (por defecto `false`);
  - `main_vecino.dart` lo activa en debug con
    `FIREBASE_AUTO_VERIFY_EMAIL` (por defecto `kDebugMode`);
  - espera 3 segundos y marca la sesión como desbloqueada solo en memoria;
  - una build release no lo activa y sigue bloqueando la cuenta.
- Reglas de Firestore: cada vecino puede leer/crear su perfil y actualizar
  únicamente el campo `email` de `users_private`.

## 3. Verificación de S05

- `dart format .`: aplicado.
- `flutter analyze`: sin problemas.
- `flutter test`: **102 pruebas pasan**.
- Casos cubiertos:
  - registro y redirección a la pantalla de verificación;
  - guard de correo no verificado;
  - reenvío y mensajes de error;
  - cambio de correo, correo pendiente y validación del mismo correo;
  - comprobación manual del estado;
  - cancelación con cierre de sesión;
  - desbloqueo automático de desarrollo tras 3 segundos.
- Verificado en el Samsung SM-A546E con APK debug:
  - registro → pantalla de verificación;
  - enlace del emulador → “Ya verifiqué” → inicio;
  - cambio de correo a otra dirección del emulador → enlace de cambio → inicio;
  - cuenta sin verificar → desbloqueo automático de debug.
- Capturas en `/home/javier/Descargas/VeciApp/`:
  - `s05-01-verificacion.png`
  - `s05-02-correo-pendiente.png`
  - `s05-03-verificado.png`
  - `s05-04-modo-desarrollo.png` (aviso de desbloqueo automático)
- **No se probó entrega real de correo**: no hay proyecto real configurado.

## 4. Firebase local y teléfono físico

El teléfono no se conecta directamente a Firebase. En desarrollo usa los
emuladores de la computadora a través de USB:

```bash
npx firebase-tools emulators:start --only auth,firestore

adb reverse tcp:9099 tcp:9099
adb reverse tcp:8080 tcp:8080

flutter run --dart-define=FIREBASE_EMULATOR_HOST=localhost
```

Puntos importantes:

- Auth usa `127.0.0.1:9099` y Firestore `127.0.0.1:8080`; la consola está en
  `http://127.0.0.1:4000`.
- En el emulador, los correos de verificación no salen a Internet. Para obtener
  el enlace:
  ```bash
  curl -s http://127.0.0.1:9099/emulator/v1/projects/demo-veciapp/oobCodes
  ```
  El JSON incluye `oobLink`; al abrirlo se confirma el correo y luego se usa
  “Ya verifiqué mi correo” en la app.
- La app debug desactiva `automaticHostMapping` para que `localhost` llegue al
  equipo mediante `adb reverse`.
- Solo los builds debug permiten HTTP local; producción sigue exigiendo HTTPS.
- Para desactivar el desbloqueo temporal y probar una verificación real:
  ```bash
  flutter run \
    --dart-define=FIREBASE_USE_EMULATOR=false \
    --dart-define=FIREBASE_AUTO_VERIFY_EMAIL=false \
    --dart-define=FIREBASE_PROJECT_ID=... \
    --dart-define=FIREBASE_API_KEY=... \
    --dart-define=FIREBASE_APP_ID=... \
    --dart-define=FIREBASE_MESSAGING_SENDER_ID=...
  ```
- Las instrucciones completas están en
  [`firebase-emulator.md`](firebase-emulator.md).

## 5. Archivos clave

| Archivo | Para qué |
|---|---|
| `lib/features/auth/presentation/views/verify_email_view.dart` | Pantalla de verificación, reenvío, cambio y cancelación. |
| `lib/features/auth/presentation/viewmodels/auth_viewmodel.dart` | Estado de sesión, verificación, modo temporal y acciones. |
| `lib/features/auth/data/firebase_auth_repository.dart` | Auth, enlace de verificación, cambio de correo y sincronización privada. |
| `lib/core/router/app_router.dart` | Guard de sesión y de correo verificado. |
| `lib/core/l10n/app_strings.dart` | Todos los textos visibles. |
| `lib/models/app_user.dart` | `AppUser.emailVerified`. |
| `lib/main_vecino.dart` | Activa el modo temporal en debug. |
| `firestore.rules` | Actualización del correo privado solo por el dueño. |
| `test/app_test.dart` | Flujo de registro, guard, cancelación y auto desbloqueo. |
| `test/features/auth/verify_email_view_test.dart` | Pruebas de la pantalla. |
| `test/features/auth/auth_viewmodel_test.dart` | Estado y acciones de verificación. |
| `docs/firebase-emulator.md` | Entorno local y obtención del enlace de verificación. |

## 6. Estado de Git

- Rama de trabajo: `feature/s05-verificacion`, creada desde
  `feature/s04-cedula`.
- S03, S04 y S05 no se han integrado a `main`; son ramas de sesión.
- `android/gradle.properties` tiene un ajuste local para compilar en este equipo
  (heap de 2 GB, sin daemon/incremental). **No se commiteó**.
- `AGENTS.md` y `DESIGN.md` siguen sin versionar en la raíz. No borrarlos ni
  commitearlos sin confirmar con el usuario.
- El SRS está en `docs/srs/SRS_GAD_AMAGUANIA_APLICATIVO_MOVIL.pdf`.

## 7. Deuda conocida

- **Verificación real (RF-03):** implementar código de 6 dígitos con backend y
  proveedor de correo; eliminar `autoVerifyEmail`; conectar un proyecto real de
  Firebase y probar con un correo real.
- **Duplicados de cédula (RF-02 incompleto):** el registro acepta una cédula
  válida que ya pertenezca a otra cuenta. Opciones:
  - Cloud Function con Admin SDK que valide y reserve la cédula en una
    transacción (requiere Functions y probablemente plan Blaze);
  - colección de reserva con reglas que impidan duplicados sin permitir leer la
    cédula;
  - otra alternativa que defina el usuario.
- **Sincronización de `users_private.email`:** es best-effort. Si falla la red,
  no bloquea el acceso y se reintenta en una recarga posterior de la cuenta.
  Falta una prueba de reglas de Firestore.
- **S06:** consentimiento LOPDP y recuperación de contraseña.
- **S07:** rol real desde Firestore, guards por rol, reglas por rol y
  `storage.rules`.
- **S08:** navegación principal definitiva; `HomeView` sigue siendo provisional.
- **S15:** panel de administración.
- No existe todavía `storage.rules`.
- No hay proyecto real de Firebase configurado; las pruebas fueron con el
  proyecto demo y emuladores.

## 8. Próxima sesión: S06

**Objetivo:** consentimiento LOPDP con fecha y hora, y recuperación de
contraseña (RF-06, RF-05).

**Criterio de cierre:** sin consentimiento no se crea la cuenta; la contraseña
anterior deja de servir después de recuperarla.

Antes de codificar hay que confirmar con el usuario:

- texto exacto del consentimiento y si se guarda versión/fecha;
- si la recuperación usa el enlace de Firebase o un código propio;
- si se pedirá confirmación de correo antes de recuperar;
- qué pantalla se muestra al volver desde el enlace.

Plan sugerido:

1. Leer `AGENTS.md`, `DESIGN.md`, `PROGRESS.md`, este documento y RF-05/RF-06
   del SRS.
2. Confirmar el flujo con el usuario.
3. Implementar consentimiento en el registro y guardar fecha/hora.
4. Implementar recuperación de contraseña con mensajes claros.
5. Agregar pruebas unitarias y de widget.
6. Ejecutar `dart format .`, `flutter analyze` y `flutter test`.
7. Actualizar `PROGRESS.md` y este documento. Detenerse y esperar “continuar”.

## 9. Preguntas abiertas

- ¿Cuándo se conectará un proyecto real de Firebase para probar correos reales?
- ¿Qué backend se usará para el código de 6 dígitos (Cloud Functions, servidor
  propio u otro)?
- ¿Cuándo se integrará la detección de duplicados de cédula?
- ¿Se versionarán `AGENTS.md` y `DESIGN.md`?
- ¿Se integrarán las ramas de sesión a `main` antes de continuar?

## 10. Checklist para retomar

- [ ] Leer `AGENTS.md`, `DESIGN.md`, `PROGRESS.md` y este archivo.
- [ ] Revisar `git status` y la rama `feature/s05-verificacion`.
- [ ] Confirmar que sigue vigente el modo temporal o desactivarlo si ya hay
      proyecto real.
- [ ] Levantar Auth + Firestore y configurar `adb reverse` si se prueba en el
      teléfono.
- [ ] No adelantar S07 ni la detección de duplicados.
- [ ] Al terminar, actualizar `PROGRESS.md` y esperar el siguiente “continuar”.
