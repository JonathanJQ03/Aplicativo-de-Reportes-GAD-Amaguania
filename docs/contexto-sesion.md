# Contexto para retomar la próxima sesión

**Última sesión cerrada:** S06 — Consentimiento LOPDP y recuperación de contraseña
**Fecha:** 2026-10-20
**Rama:** `feature/s06-consentimiento-recuperacion`
**Siguiente sesión:** S07 — Roles y control de acceso

> Este documento es un apoyo para retomar el trabajo. La fuente de verdad del
> avance sigue siendo `PROGRESS.md`; las reglas del proyecto están en
> `AGENTS.md` y el diseño en `DESIGN.md`.

## 1. Dónde nos quedamos

S06 quedó implementada y verificada en local:

- El registro muestra un **aviso de privacidad** en un diálogo y exige marcar
  una casilla antes de crear la cuenta. La casilla nunca está premarcada.
- `users_private` guarda `consentVersion` y `consentAcceptedAt`; la fecha usa
  `FieldValue.serverTimestamp()`. La regla de Firestore exige ambos campos al
  crear el perfil.
- Por decisión del usuario, el consentimiento se pide **solo a cuentas nuevas**.
  Las cuentas de prueba creadas antes de S06 no se ven afectadas.
- La recuperación de contraseña usa el **enlace de Firebase** desde una pantalla
  pública `/forgot-password`. El mensaje es genérico para no revelar si el
  correo existe.
- Al completar el enlace, Firebase cambia la contraseña y la anterior deja de
  servir. Se comprobó con el emulador.
- Sigue pendiente la **verificación real de correo (S05)**, que requiere un
  proyecto real de Firebase, backend/Cloud Functions y un proveedor de correo
  para el código de 6 dígitos.

## 2. Qué funciona hoy

### Consentimiento LOPDP

- Aviso de privacidad versión 1.0 en `AppStrings` (texto base pendiente de
  revisión legal).
- Diálogo con el aviso completo y botón “Entendido”.
- Casilla obligatoria con mensaje claro si el usuario intenta continuar sin
  aceptar.
- `AuthViewModel.signUp` y `FirebaseAuthRepository.signUp` rechazan el alta sin
  consentimiento; no se crea la cuenta ni el perfil.
- Escritura en `users_private`:
  - `consentVersion: "1.0"`;
  - `consentAcceptedAt` con hora del servidor.

### Recuperación de contraseña

- Enlace “¿Olvidaste tu contraseña?” en el login.
- Ruta pública `/forgot-password`.
- Validación del correo antes de enviar.
- `FirebaseAuth.sendPasswordResetEmail` envía el enlace.
- Si el correo no existe, la app muestra el mismo mensaje de éxito para evitar
  enumerar cuentas.
- Errores de red o de Firebase se traducen a mensajes claros; no se muestran
  códigos técnicos.
- El usuario completa el cambio en el navegador y vuelve a iniciar sesión en la
  app.

### Verificación de S06

- `dart format .`: aplicado.
- `flutter analyze`: sin problemas.
- `flutter test`: **115 pruebas pasan**.
- APK debug compilado e instalado en un Samsung SM-A546E contra los emuladores
  locales de Auth y Firestore.
- Casos comprobados en dispositivo:
  - cuenta nueva con consentimiento → `users_private` con versión y timestamp;
  - aviso de privacidad visible y casilla vacía por defecto;
  - envío del enlace de recuperación;
  - finalización del cambio con `oobCode` del emulador;
  - contraseña anterior rechazada y contraseña nueva aceptada;
  - correo inexistente con mensaje genérico.
- Capturas en `/home/javier/Descargas/VeciApp/`:
  - `s06-01-login-recuperacion.png`
  - `s06-02-aviso-privacidad.png`
  - `s06-03-consentimiento.png`
  - `s06-04-recuperacion.png`
  - `s06-05-enlace-enviado.png`
  - `s06-06-sesion-recuperada.png`
  - `s06-07-correo-no-registrado.png`

## 3. Firebase local y teléfono físico

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
- Los emuladores **no envían correos reales**: guardan los enlaces en
  `http://127.0.0.1:9099/emulator/v1/projects/demo-veciapp/oobCodes`.
- Para completar un restablecimiento de contraseña sin abrir el navegador:
  ```bash
  curl -X POST \
    'http://127.0.0.1:9099/identitytoolkit.googleapis.com/v1/accounts:resetPassword?key=demo-api-key' \
    -H 'Content-Type: application/json' \
    -d '{"oobCode":"<PASSWORD_RESET_CODE>","newPassword":"NuevaClave123!"}'
  ```
- La app debug desactiva `automaticHostMapping` para que `localhost` llegue al
  equipo mediante `adb reverse`.
- Solo los builds debug permiten HTTP local; producción sigue exigiendo HTTPS.
- Las instrucciones completas están en [`firebase-emulator.md`](firebase-emulator.md).

## 4. Archivos clave

| Archivo | Para qué |
|---|---|
| `lib/core/l10n/app_strings.dart` | Aviso de privacidad, textos de recuperación y mensajes visibles. |
| `lib/core/constants/app_constants.dart` | `privacyNoticeVersion`. |
| `lib/shared/widgets/app_checkbox.dart` | Casilla reutilizable con etiqueta y error. |
| `lib/features/auth/presentation/views/register_view.dart` | Consentimiento y registro. |
| `lib/features/auth/presentation/views/forgot_password_view.dart` | Pantalla de recuperación. |
| `lib/features/auth/presentation/views/login_view.dart` | Enlace de recuperación. |
| `lib/features/auth/presentation/viewmodels/auth_viewmodel.dart` | Estado de consentimiento y recuperación. |
| `lib/features/auth/data/firebase_auth_repository.dart` | Alta con consentimiento y envío del enlace. |
| `lib/features/auth/domain/auth_repository.dart` | Contrato de auth. |
| `lib/core/router/app_router.dart` | Ruta pública `/forgot-password` y guards existentes. |
| `firestore.rules` | Creación de `users_private` con consentimiento. |
| `test/features/auth/register_view_test.dart` | Consentimiento y aviso. |
| `test/features/auth/forgot_password_view_test.dart` | Recuperación y mensajes. |
| `test/features/auth/auth_viewmodel_test.dart` | Lógica de consentimiento y recuperación. |
| `test/features/auth/fakes/fake_auth_repository.dart` | Doble de pruebas actualizado. |
| `docs/firebase-emulator.md` | Emuladores, consentimiento y recuperación. |

## 5. Estado de Git

- Rama de S06: `feature/s06-consentimiento-recuperacion`.
- `main` contiene S00–S05. La rama de S06 se integrará siguiendo el mismo
  proceso de las sesiones anteriores.
- `AGENTS.md` y `DESIGN.md` siguen sin versionar en la raíz. No borrarlos ni
  commitearlos sin confirmar con el usuario.
- `android/gradle.properties` tiene un ajuste local para compilar en este equipo
  (heap de 2 GB, sin daemon/incremental). **No se commiteó.**
- El SRS está en `docs/srs/SRS_GAD_AMAGUANIA_APLICATIVO_MOVIL.pdf`.

## 6. Deuda conocida

- **Verificación real (RF-03):** implementar código de 6 dígitos con backend y
  proveedor de correo; eliminar `autoVerifyEmail`; conectar un proyecto real de
  Firebase y probar con un correo real.
- **Duplicados de cédula (RF-02 incompleto):** el registro acepta una cédula
  válida que ya pertenezca a otra cuenta. Definir una Cloud Function o una
  colección de reserva con reglas.
- **Aviso de privacidad (S06):** es un texto base; debe revisarlo el área
  jurídica del GAD. Si cambia, subir la versión en `AppConstants` y decidir si
  se vuelve a pedir aceptación.
- **Sincronización de `users_private.email`:** es best-effort. Si falla la red,
  no bloquea el acceso y se reintenta en una recarga posterior.
- No existe todavía `storage.rules`.
- No hay proyecto real de Firebase configurado; las pruebas fueron con el
  proyecto demo y emuladores.

## 7. Próxima sesión: S07

**Objetivo:** roles y control de acceso (RF-07, RNF-01).

**Criterio de cierre:** un vecino no entra al panel de administración; las
reglas de Firestore y Storage rechazan operaciones sin sesión o con rol
insuficiente.

Antes de codificar hay que decidir con el usuario:

- cómo se almacena y lee el rol (`users/{uid}.role`, custom claims o ambos);
- cómo se crea la primera cuenta de administrador;
- qué rutas del panel web existen en esta sesión y cuáles quedan para S15;
- si `storage.rules` se crea en S07 o se deja hasta S10.

Plan sugerido:

1. Leer `AGENTS.md`, `DESIGN.md`, `PROGRESS.md`, este documento y RF-07/RNF-01.
2. Confirmar el modelo de roles y el seed del administrador.
3. Implementar guards por rol en el router móvil y web.
4. Ampliar `firestore.rules` y crear `storage.rules` base.
5. Agregar pruebas de guards y reglas.
6. Ejecutar `dart format .`, `flutter analyze` y `flutter test`.
7. Actualizar `PROGRESS.md` y este documento. Detenerse y esperar “continuar”.

## 8. Preguntas abiertas

- ¿Cuándo se conectará un proyecto real de Firebase para probar correos reales?
- ¿Qué backend se usará para el código de 6 dígitos (Cloud Functions, servidor
  propio u otro)?
- ¿Cuándo se integrará la detección de duplicados de cédula?
- ¿Quién revisará y aprobará el aviso de privacidad del GAD?
- ¿Se versionarán `AGENTS.md` y `DESIGN.md`?
- ¿Se eliminarán las ramas de sesión ya integradas o se conservarán como
  historial?

## 9. Checklist para retomar

- [ ] Leer `AGENTS.md`, `DESIGN.md`, `PROGRESS.md` y este archivo.
- [ ] Revisar `git status` y confirmar que S06 está en `main` o en su rama.
- [ ] Confirmar que sigue vigente el modo temporal de verificación.
- [ ] Levantar Auth + Firestore y configurar `adb reverse` si se prueba en el
      teléfono.
- [ ] No adelantar S08 ni la detección de duplicados.
