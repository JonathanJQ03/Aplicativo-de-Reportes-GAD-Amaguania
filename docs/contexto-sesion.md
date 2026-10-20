# Contexto para retomar la próxima sesión

**Última sesión cerrada:** S07 — Roles y control de acceso
**Fecha:** 2026-10-20
**Rama:** `feature/s07-roles-acceso` (se integra en `main` al cerrar)
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
  rol, el panel espera en `/checking`.
- El panel de administración (`lib/main_admin.dart`) tiene login propio, guard
  de rol, pantalla de acceso restringido y un marcador **Panel en preparación**.
  Un `vecino` o `vecinoVerificado` no entra; solo `administrador`.
- Las reglas de Firestore separan perfiles públicos y privados, impiden que el
  cliente se asigne otro rol y permiten al administrador consultar perfiles.
- `storage.rules` existe con reglas base: solo el dueño escribe imágenes de
  hasta 2 MB en `users/{uid}/profile/`; el resto queda denegado.
- La plataforma `web/` todavía no existe. El panel se probó ejecutando
  `lib/main_admin.dart` en el teléfono; la entrada web y el layout llegan en
  S15.
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

### Panel de administración

Rutas en `lib/core/router/admin_router.dart`:

| Ruta | Pantalla |
|---|---|
| `/login` | Login del GAD, sin enlace de registro. |
| `/forgot-password` | Recuperación existente. |
| `/checking` | Espera mientras se consulta el rol. |
| `/access-denied` | Cuenta autenticada sin permiso. |
| `/` | Marcador del panel. |

La lógica pura está en `lib/core/router/route_guards.dart` y tiene pruebas para
toda la matriz. El panel tiene su propio `AdminApp` en `lib/admin_app.dart` y
reutiliza el tema, los textos y los widgets compartidos.

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
- `flutter test`: **135 pruebas pasan**.
- APK debug compilado para ambos entry points e instalado en un Samsung
  SM-A546E contra los emuladores locales.
- Casos comprobados:
  - vecino en el panel → **Acceso restringido**;
  - administrador en el panel → **Panel en preparación**;
  - login de vecino en la app móvil → **Inicio**;
  - 13 casos de reglas de Firestore y 10 de Storage con los códigos esperados.
- Capturas en `/home/javier/Descargas/VeciApp/`:
  - `s07-01-login-admin.png`
  - `s07-02-vecino-acceso-restringido.png`
  - `s07-03-admin-panel.png`
  - `s07-04-movil-vecino.png`

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

Para el panel:

```bash
flutter run -t lib/main_admin.dart \
  --dart-define=FIREBASE_EMULATOR_HOST=localhost
```

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
| `lib/core/router/route_guards.dart` | Matriz de redirección del panel. |
| `lib/core/router/admin_router.dart` | Rutas del panel y guard. |
| `lib/core/router/app_router.dart` | Router móvil y `errorBuilder`. |
| `lib/admin_app.dart` | Raíz del panel de administración. |
| `lib/main_admin.dart` | Entrada del panel. |
| `lib/features/moderation/presentation/views/` | Login/guard/placeholder del panel. |
| `lib/features/auth/presentation/views/login_view.dart` | Login compartido con modo administrador. |
| `lib/core/errors/not_found_view.dart` | Página no encontrada para ambos routers. |
| `firestore.rules` | Reglas por rol de perfiles públicos y privados. |
| `storage.rules` | Reglas base de Storage. |
| `docs/roles-y-acceso.md` | Modelo, seed y matriz de reglas. |
| `test/admin_app_test.dart` | Guard del panel de extremo a extremo. |
| `test/core/router/route_guards_test.dart` | Matriz de redirección. |
| `test/features/auth/auth_viewmodel_test.dart` | Carga y fallo del rol. |

## 5. Estado de Git

- `main` contiene S00–S06. La rama `feature/s07-roles-acceso` contiene S07 y se
  integra con un merge al cerrar.
- La rama `feature/s06-consentimiento-recuperacion` se conserva como historial.
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
- **Plataforma web:** `web/` no existe; se agrega en S15. El guard ya está
  probado y es independiente de la plataforma.
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
   el guard de sesión y verificación existente.
4. Reemplazar `HomeView` por el inicio real y `ProfileView` por el perfil con
   nombre, correo, rol y cierre de sesión.
5. Mantener el panel de administración separado; no adelantar S15.
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
