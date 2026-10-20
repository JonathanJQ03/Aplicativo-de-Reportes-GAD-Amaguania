# Contexto para retomar la próxima sesión

**Última sesión cerrada:** S07 — Roles y control de acceso
**Ajuste posterior:** acceso de administrador dentro de una sola app
**Fecha:** 2026-10-20
**Rama:** `main` (S07 integrada)
**Siguiente sesión:** S08 — Navegación principal, inicio y perfil

> Este documento es un apoyo para retomar el trabajo. La fuente de verdad del
> avance sigue siendo `PROGRESS.md`; las reglas del proyecto están en
> `AGENTS.md` y el diseño en `DESIGN.md`.

## 1. Dónde nos quedamos

S07 quedó implementada y verificada en local:

- El rol se lee de `users/{uid}.role` al restaurar la sesión o iniciar sesión.
  Si el campo falta, tiene un valor desconocido o la consulta falla, se usa
  `vecino`. Nunca se concede un rol mayor por error.
- `AuthViewModel` expone `isRoleLoading` e `isAdmin`. Mientras se consulta el
  rol, la app espera en `/session-loading` y el área de administración en
  `/admin/checking`.
- **VeciApp es una sola app.** El login principal muestra la acción
  **Administrador** arriba a la derecha; abre `/admin/login`. Al autenticarse,
  el router lleva al panel si el rol es `administrador` y al inicio si es
  `vecino`. Un vecino que intenta entrar por el acceso de administrador ve
  **Acceso restringido** y puede volver a la app.
- El panel conserva el marcador **Panel en preparación** y el login propio. El
  layout, la bandeja y la moderación se construyen en S15.
- `lib/main_admin.dart` se conserva como alias de `lib/main_vecino.dart` para
  no romper comandos antiguos, pero **no genera una app distinta** ni un segundo
  APK.
- Las reglas de Firestore separan perfiles públicos y privados, impiden que el
  cliente se asigne otro rol y permiten al administrador consultar perfiles.
- `storage.rules` existe con reglas base: solo el dueño escribe imágenes de
  hasta 2 MB en `users/{uid}/profile/`; el resto queda denegado.
- La plataforma `web/` todavía no existe. El panel se probó dentro de la misma
  app Android; la entrada web y el layout llegan en S15.
- Sigue pendiente la **verificación real de correo (S05)** y la **detección de
  cédulas duplicadas (RF-02)**.

## 2. Qué funciona hoy

### Rol y sesión

- `UserRole` tiene `vecino`, `vecinoVerificado` y `administrador`, con su valor
  de Firestore en `lib/models/app_user.dart`.
- `AuthRepository.loadRole(uid)` consulta Firestore con un tiempo máximo de
  8 segundos; ante cualquier fallo devuelve `vecino`.
- `AuthViewModel` carga el rol después de cada cambio de sesión y lo descarta al
  cerrar sesión. `isAdmin` es `false` mientras el rol está en camino.
- El perfil público `users/{uid}` se crea con `role: "vecino"`; el rol no se
  puede cambiar desde la app.

### Acceso de administrador en la app única

El árbol de navegación vive en `lib/core/router/app_router.dart`:

| Ruta | Pantalla |
|---|---|
| `/login` | Login de vecinos con la acción **Administrador** arriba a la derecha. |
| `/admin/login` | Login del GAD, sin enlace de registro y con acción **Volver**. |
| `/admin/forgot-password` | Recuperación que vuelve al login del GAD. |
| `/session-loading` | Espera mientras se consulta el rol en la app de vecinos. |
| `/admin/checking` | Espera mientras se consulta el rol en el área de administración. |
| `/admin/denied` | Cuenta autenticada sin permiso, con **Volver a la app**. |
| `/admin` | Marcador **Panel en preparación**. |

La lógica pura está en `lib/core/router/route_guards.dart`, en
`resolveAppRedirect`, y tiene pruebas para toda la matriz. El login es el mismo
widget (`LoginView`) en modo normal y en modo administrador; el tema, los textos
y los widgets compartidos son únicos. Ya no existen `AdminApp` ni
`admin_router.dart`.

### Reglas

- `firestore.rules`:
  - `users`: lee el dueño o un administrador; crea el dueño solo como
    `vecino`; actualiza el dueño solo `displayName`; nadie borra.
  - `users_private`: lee el dueño o un administrador; crea el dueño con
    consentimiento y campos permitidos; actualiza el dueño solo `email`;
    nadie borra.
  - `isAdmin()` consulta `users/{uid}.role` con `get()`.
- `storage.rules`:
  - `users/{uid}/profile/{archivo}`: dueño, imagen de hasta 2 MB;
  - cualquier otra ruta queda denegada por ahora.
- La matriz completa, el seed del administrador y los comandos de verificación
  están en [`roles-y-acceso.md`](roles-y-acceso.md).

### Verificación de S07

- `dart format .`: aplicado.
- `flutter analyze`: sin problemas.
- `flutter test`: **139 pruebas pasan**.
- **Un solo APK debug** compilado desde `lib/main_vecino.dart` e instalado en un
  Samsung SM-A546E contra los emuladores locales. `lib/main_admin.dart` es un
  alias y no produce una aplicación aparte.
- Casos comprobados en el teléfono:
  - login normal con administrador → **Panel en preparación**;
  - login normal con vecino → **Inicio**;
  - acción **Administrador** → login del GAD;
  - vecino en el login del GAD → **Acceso restringido**;
  - **Volver a la app** desde el acceso restringido → **Inicio**;
  - recuperación desde el login del GAD → vuelve al login del GAD;
  - 13 casos de reglas de Firestore y 10 de Storage con los códigos esperados.
- Capturas en `/home/javier/Descargas/VeciApp/`:
  - `s07-01-login-admin.png`
  - `s07-02-vecino-acceso-restringido.png`
  - `s07-03-admin-panel.png`
  - `s07-04-movil-vecino.png`
  - `s07-05-login-acceso-admin.png`
  - `s07-06-login-admin.png`
  - `s07-07-acceso-restringido.png`
  - `s07-08-panel-admin-integrado.png`
  - `s07-09-inicio-vecino.png`

## 3. Firebase local y teléfono físico

El teléfono no se conecta directamente a Firebase. En desarrollo usa los
emuladores de la computadora a través de USB:

```bash
npx firebase-tools emulators:start --only auth,firestore,storage

adb reverse tcp:9099 tcp:9099
adb reverse tcp:8080 tcp:8080
adb reverse tcp:9199 tcp:9199

flutter run -t lib/main_vecino.dart \
  --dart-define=FIREBASE_EMULATOR_HOST=localhost
```

El panel se abre desde la acción **Administrador** del login. No hace falta un
segundo comando ni un segundo APK. `lib/main_admin.dart` sigue funcionando como
alias de la misma app por compatibilidad.

Puntos importantes:

- Auth usa `127.0.0.1:9099`, Firestore `127.0.0.1:8080`, Storage
  `127.0.0.1:9199` y la consola está en `http://127.0.0.1:4000`.
- En el teléfono, **sin** `FIREBASE_EMULATOR_HOST=localhost` Android intenta
  `10.0.2.2` y muestra un error de conexión. Para instalar un APK ya compilado,
  incluir el `--dart-define` al compilar.
- El primer administrador se crea en el emulador y se le asigna
  `users/{uid}.role = "administrador"` desde la interfaz de Firestore o con la
  API local. Pasos en
  [`roles-y-acceso.md`](roles-y-acceso.md#3-crear-la-primera-cuenta-de-administrador).
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
| `lib/models/app_user.dart` | Roles y valores de Firestore; `copyWith`. |
| `lib/features/auth/domain/auth_repository.dart` | Contrato de auth, incluido `loadRole`. |
| `lib/features/auth/data/firebase_auth_repository.dart` | Lectura del rol y alta con consentimiento. |
| `lib/features/auth/presentation/viewmodels/auth_viewmodel.dart` | Sesión, rol, `isRoleLoading` e `isAdmin`. |
| `lib/core/router/route_guards.dart` | Rutas y matriz de redirección única. |
| `lib/core/router/app_router.dart` | Router de la app y del área `/admin`. |
| `lib/main_vecino.dart` | Entrada única de la app. |
| `lib/main_admin.dart` | Alias de `main_vecino.dart` por compatibilidad. |
| `lib/features/moderation/presentation/views/` | Comprobación, acceso restringido y marcador del panel. |
| `lib/features/auth/presentation/views/login_view.dart` | Login compartido con acción de administrador. |
| `lib/features/auth/presentation/views/session_loading_view.dart` | Espera de sesión/rol de la app de vecinos. |
| `lib/core/errors/not_found_view.dart` | Página no encontrada. |
| `firestore.rules` | Reglas por rol de perfiles públicos y privados. |
| `storage.rules` | Reglas base de Storage. |
| `docs/roles-y-acceso.md` | Modelo, seed y matriz de reglas. |
| `test/features/moderation/admin_access_test.dart` | Acceso único de administrador de extremo a extremo. |
| `test/core/router/route_guards_test.dart` | Matriz de redirección. |
| `test/features/auth/auth_viewmodel_test.dart` | Carga y fallo del rol. |

## 5. Estado de Git

- `main` contiene S00–S07. La rama `feature/s07-roles-acceso` se integró con un
  merge y se conserva como historial.
- El ajuste de **app única** se desarrolló en `fix/s07-admin-unificado` y se
  integró en `main`; el panel dejó de ser una aplicación aparte.
- La rama `feature/s06-consentimiento-recuperacion` también se conserva.
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
- **Rol de administrador:** hoy se asigna manualmente en el emulador. En
  producción debe existir un procedimiento auditado con la consola o el Admin
  SDK. El cambio de rol y la suspensión de cuentas llegan en S23/S24.
- **Plataforma web:** `web/` no existe; se agrega en S15. El panel ya está
  integrado en la app única y su guard es independiente de la plataforma.
- **Pruebas de reglas:** la matriz se verificó con llamadas al emulador. Falta
  automatizarla con Node + `@firebase/rules-unit-testing`.
- No hay proyecto real de Firebase configurado; las pruebas fueron con el
  proyecto demo y emuladores.

## 7. Próxima sesión: S08

**Objetivo:** navegación principal, pantalla de inicio y perfil (RNF-05).

**Criterio de cierre:** barra inferior con 4 destinos funcionando.

Plan sugerido:

1. Leer `AGENTS.md`, `DESIGN.md`, `PROGRESS.md`, este documento y las secciones
   del SRS sobre navegación y perfil.
2. Revisar `DESIGN.md` para la barra inferior, el inicio y el perfil.
3. Implementar el shell de navegación con `go_router` y 4 destinos, conservando
   el guard de sesión, verificación y rol existente.
4. Reemplazar `HomeView` por el inicio real y `ProfileView` por el perfil con
   nombre, correo, rol y cierre de sesión.
5. Mantener el área `/admin` dentro de la misma app; no adelantar S15.
6. Pruebas de widget para la barra y la navegación; `dart format .`,
   `flutter analyze`, `flutter test`.
7. Verificar en el teléfono y actualizar `PROGRESS.md` y este documento.

## 8. Preguntas abiertas

- ¿Cuándo se conectará un proyecto real de Firebase para probar correos reales?
- ¿Qué backend se usará para el código de 6 dígitos (Cloud Functions, servidor
  propio u otro)?
- ¿Cuándo se integrará la detección de duplicados de cédula?
- ¿Quién revisará y aprobará el aviso de privacidad del GAD?
- ¿Se versionarán `AGENTS.md` y `DESIGN.md`?
- ¿Se eliminarán las ramas de sesión ya integradas o se conservarán como
  historial?
- ¿El GAD entregará la lista oficial de sectores antes de S19/S26?
- ¿Se usará el plan Blaze para Cloud Functions antes de S23/S25?

## 9. Checklist para retomar

- [ ] Leer `AGENTS.md`, `DESIGN.md`, `PROGRESS.md` y este archivo.
- [ ] Revisar `git status` y confirmar que S07 está en `main` o en su rama.
- [ ] Confirmar que sigue vigente el modo temporal de verificación.
- [ ] Levantar Auth + Firestore + Storage y configurar `adb reverse` si se
      prueba en el teléfono.
- [ ] No adelantar S09 ni la detección de duplicados.
