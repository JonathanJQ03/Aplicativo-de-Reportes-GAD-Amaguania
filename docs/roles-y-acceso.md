# Roles y control de acceso (S07)

Este documento explica cómo se guarda el rol, cómo se protege el panel de
administración y qué operaciones permiten las reglas de Firestore y Storage.
Corresponde a RF-07 y RNF-01.

## 1. Modelo de rol

El rol vive en el documento público del usuario:

```
users/{uid}
  displayName: string
  role: "vecino" | "vecinoVerificado" | "administrador"
  createdAt: timestamp
```

Decisiones de S07:

- **Firestore es la fuente de verdad.** No se usan custom claims todavía porque
  requieren el Admin SDK o Cloud Functions y el proyecto aún no tiene backend.
  Cuando exista, los claims se pueden agregar como espejo del mismo campo.
- Un valor ausente o desconocido se interpreta como `vecino`, el rol con menos
  permisos. Un error de red nunca concede acceso al panel.
- El cliente **no puede** asignarse `administrador` ni `vecinoVerificado`.
  Las reglas solo aceptan `role == "vecino"` al crear el perfil y bloquean
  cualquier cambio de `role` desde la app.
- El rol se asigna o cambia desde la consola de Firebase o con el Admin SDK.
  Esa operación queda fuera del cliente y, en producción, debe hacerla personal
  autorizado del GAD.

### Carga del rol en la app

`AuthViewModel` consulta `users/{uid}.role` después de autenticar y expone:

- `isRoleLoading`: hay una consulta en curso;
- `isAdmin`: el rol cargado es `administrador`.

Mientras el rol no se conoce, `isAdmin` es `false`. El panel espera en una
pantalla de comprobación en lugar de mostrar el contenido o negar el acceso por
anticipación.

## 2. Panel de administración

`lib/main_admin.dart` arranca `AdminApp`, que usa `createAdminRouter` y el mismo
`AuthViewModel` de la app móvil.

Rutas:

| Ruta | Contenido |
|---|---|
| `/login` | Login del personal del GAD, sin enlace de registro. |
| `/forgot-password` | Recuperación de contraseña existente. |
| `/checking` | Espera mientras se consulta el rol. |
| `/access-denied` | Cuenta autenticada sin rol de administrador. |
| `/` | Marcador del panel; el layout real llega en S15. |

Reglas del guard:

1. Sin sesión solo se permite `/login` y `/forgot-password`.
2. Con sesión pero sin rol resuelto, se muestra `/checking`.
3. Solo `administrador` entra a `/`.
4. `vecino` y `vecinoVerificado` terminan en `/access-denied`.
5. Al cerrar sesión se vuelve a `/login`.

La lógica está en `lib/core/router/route_guards.dart` y tiene pruebas unitarias
para toda la matriz.

### Alcance de S07

- El guard y las reglas son independientes de la plataforma.
- **La entrada web con `web/` se habilitará en S15.** En S07 el panel se
  verificó ejecutando `lib/main_admin.dart` en el teléfono de desarrollo; el
  mismo código servirá para la web cuando se agregue esa plataforma.
- El layout lateral, la bandeja y la moderación son de S15.
- La verificación de correo del vecino (S05) no se evalúa en el panel. Las
  cuentas de administrador las crea el GAD y se revisan antes de entregarlas.
  Cuando exista la verificación real, conviene exigir también el correo
  verificado para el panel.

## 3. Crear la primera cuenta de administrador

### Opción A: interfaz de los emuladores

1. Levanta los emuladores con `auth`, `firestore` y `storage`.
2. Abre `http://127.0.0.1:4000`.
3. En **Authentication**, crea un usuario con correo y contraseña.
4. Copia su UID.
5. En **Firestore**, crea el documento `users/{uid}` con:

```json
{
  "displayName": "Administrador de prueba",
  "role": "administrador",
  "createdAt": "2026-10-20T00:00:00Z"
}
```

La consola del emulador no pasa por las reglas, por eso puede asignar el rol.
No repitas este procedimiento a mano en producción sin un proceso auditado.

### Opción B: API local

Crea la cuenta en Authentication:

```bash
curl -X POST \
  'http://127.0.0.1:9099/identitytoolkit.googleapis.com/v1/accounts:signUp?key=demo-api-key' \
  -H 'Content-Type: application/json' \
  -d '{"email":"admin@ejemplo.com","password":"Admin123!","returnSecureToken":true}'
```

Guarda el `localId` y crea el perfil con el token `owner` del emulador. **Ese
token solo funciona en local; nunca se usa en producción.**

```bash
curl -X PATCH \
  'http://127.0.0.1:8080/v1/projects/demo-veciapp/databases/(default)/documents/users/<UID>?updateMask.fieldPaths=displayName&updateMask.fieldPaths=role&updateMask.fieldPaths=createdAt' \
  -H 'Authorization: Bearer owner' \
  -H 'Content-Type: application/json' \
  -d '{"fields":{"displayName":{"stringValue":"Administrador de prueba"},"role":{"stringValue":"administrador"},"createdAt":{"timestampValue":"2026-10-20T00:00:00Z"}}}'
```

En producción, el rol se asigna con la consola de Firebase o un script con
Admin SDK y una cuenta de servicio. Las credenciales no se versionan.

## 4. Reglas de Firestore

Archivo: `firestore.rules`.

| Colección | Operación | Quién |
|---|---|---|
| `users/{uid}` | leer | el dueño o un administrador |
| `users/{uid}` | crear | el dueño, con `role == "vecino"` y campos permitidos |
| `users/{uid}` | actualizar | el dueño, solo `displayName` |
| `users/{uid}` | borrar | nadie desde el cliente |
| `users_private/{uid}` | leer | el dueño o un administrador |
| `users_private/{uid}` | crear | el dueño, con consentimiento LOPDP y campos permitidos |
| `users_private/{uid}` | actualizar | el dueño, solo `email` (S05) |
| `users_private/{uid}` | borrar | nadie desde el cliente |

`isAdmin()` consulta `users/{uid}.role` con `get()`. Cualquier colección que no
aparezca en el archivo queda denegada por defecto. Los reportes, residencias y
auditoría se agregan en sus sesiones.

## 5. Reglas de Storage

Archivo: `storage.rules`.

| Ruta | Operación | Quién |
|---|---|---|
| `users/{uid}/profile/{archivo}` | leer / borrar | el dueño |
| `users/{uid}/profile/{archivo}` | crear / actualizar | el dueño, imagen de máximo 2 MB |
| cualquier otra ruta | leer / escribir | denegado por ahora |

Las fotos de reportes se habilitan en S10 y las planillas de residencia en
S22/S23, con las validaciones de cada caso.

## 6. Verificación manual con los emuladores

Levanta los servicios:

```bash
npx firebase-tools emulators:start --only auth,firestore,storage
```

Obtén un token de un vecino y de un administrador con
`accounts:signInWithPassword` y usa el `idToken` en la cabecera
`Authorization: Bearer ...`. Resultados esperados de S07:

| Caso | Esperado |
|---|---|
| Sin sesión lee `users/{uid}` | 403 |
| Vecino lee su propio `users` | 200 |
| Vecino lee `users` de otro | 403 |
| Vecino cambia su `role` | 403 |
| Administrador lee `users` de un vecino | 200 |
| Administrador lee `users_private` de un vecino | 200 |
| Vecino lee `users_private` del administrador | 403 |
| Vecino crea un `users` con otro UID | 403 |
| Cuenta nueva intenta `role: administrador` | 403 |
| Cuenta nueva crea `role: vecino` | 200 |
| Cuenta nueva crea `users_private` sin consentimiento | 403 |
| Cuenta nueva crea `users_private` con consentimiento | 200 |
| Subida anónima a Storage | 403 |
| Vecino sube a su carpeta | 200 |
| Vecino sube a la carpeta de otro | 403 |
| Archivo que no es imagen | 403 |
| Imagen de 3 MB | 403 |
| Vecino borra su archivo | 204 |
| Administrador borra el archivo de un vecino | 403 |

## 7. Deuda y siguientes pasos

- **S15:** agregar la plataforma web (`web/`) y el layout real del panel.
- **S23/S24:** permitir que un administrador cambie rol o suspenda cuentas.
  Esa operación debe ser auditada y no puede quedar como una escritura libre
  del cliente.
- **S05 real:** evaluar si el panel exige correo verificado cuando exista la
  verificación definitiva.
- **Custom claims:** si se agregan, mantener `users/{uid}.role` como fuente de
  verdad y sincronizar los claims desde el backend.
- **Pruebas automáticas de reglas:** hoy se verifican con llamadas al emulador.
  Cuando exista infraestructura de pruebas de reglas (Node +
  `@firebase/rules-unit-testing`), trasladar esta matriz a pruebas.
