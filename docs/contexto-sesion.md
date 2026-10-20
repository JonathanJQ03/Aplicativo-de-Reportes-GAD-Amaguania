# Contexto para retomar la próxima sesión

**Última sesión cerrada:** S04 — Validación de cédula (algoritmo; duplicados diferidos)
**Fecha:** 2026-10-20
**Rama:** `feature/s04-cedula`
**Siguiente sesión:** S05 — Verificación por correo electrónico

> Este documento es un apoyo para retomar el trabajo. La fuente de verdad del
> avance sigue siendo `PROGRESS.md`; las reglas del proyecto están en
> `AGENTS.md` y el diseño en `DESIGN.md`.

## 1. Dónde nos quedamos

S04 quedó cerrada con un **alcance ajustado por decisión del usuario**:

- Se implementó el algoritmo completo de la cédula ecuatoriana.
- El formulario de registro ahora rechaza cédulas con longitud o caracteres
  inválidos y también cédulas de 10 dígitos cuyo dígito verificador no
  corresponde.
- La **detección de cédulas duplicadas no se implementó** en esta sesión. El
  usuario prefirió no agregar Cloud Functions, una colección de unicidad ni
  nuevas dependencias. Queda como deuda de RF-02 y se debe resolver con un
  mecanismo del lado del servidor o una reserva que no exponga cédulas.
- S05 no se ha iniciado.

## 2. Qué funciona hoy

- Registro con nombres, apellidos, cédula, correo obligatorio, teléfono
  opcional y contraseña.
- Validación de cédula en dos niveles:
  - formato: exactamente 10 dígitos;
  - algoritmo: provincia `01`–`24`, tercer dígito `0`–`5` y verificador
    módulo 10 con coeficientes `[2,1,2,1,2,1,2,1,2]`.
- Mensaje específico para cédulas con algoritmo inválido:
  `La cédula no es válida. Revísala e intenta de nuevo.`
- `CedulaValidator.format` devuelve el formato `171003406-5`.
- El ejemplo del campo de cédula usa una cédula válida (`1710034065`).
- Validadores reutilizables para campos obligatorios, nombre y apellido,
  correo, teléfono opcional y contraseña nueva.
- Registro en Auth + escritura del perfil en Firestore; si falla la escritura
  del perfil se intenta borrar el usuario recién creado en Auth.
- Reglas mínimas de Firestore para que cada vecino lea y cree **solo su propio**
  perfil (`firestore.rules`).
- Protección contra toques repetidos mientras carga y navegación
  login ↔ registro.

## 3. Verificación de S04

- `dart format .`: aplicado.
- `flutter analyze`: sin problemas.
- `flutter test`: **80 pruebas pasan**.
- Casos cubiertos:
  - cédulas válidas: `1710034065`, `0102030400`, `0912345675`;
  - longitud incorrecta, letras y espacios internos;
  - provincia `00` o `25`;
  - tercer dígito `6` reservado para personas jurídicas;
  - dígito verificador incorrecto;
  - recorte de espacios externos;
  - formato con guion.
- Pruebas de widget: el registro bloquea una cédula con verificador
  incorrecto antes de llamar al repositorio.
- Verificado en el Samsung SM-A546E con el APK debug de S04:
  - `1710034066` muestra `La cédula no es válida. Revísala e intenta de nuevo.`;
  - al corregirla por `1710034065`, el error desaparece;
  - el formulario no se envía mientras la cédula es inválida.
- Capturas en `/home/javier/Descargas/VeciApp/`:
  - `s04-01-cedula-invalida.png`
  - `s04-02-cedula-valida.png`

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

- Auth usa `127.0.0.1:9099` y Firestore `127.0.0.1:8080`.
- La app debug desactiva `automaticHostMapping` en Auth y Firestore. Sin eso, el
  SDK de Android cambia `localhost` por `10.0.2.2`, que solo existe dentro del
  emulador de Android, y el registro falla en un teléfono real.
- Solo los builds debug permiten HTTP local hacia `10.0.2.2`, `localhost` y
  `127.0.0.1`; producción sigue exigiendo HTTPS.
- Las instrucciones completas están en
  [`firebase-emulator.md`](firebase-emulator.md).
- El build de producción se hace con `--dart-define=FIREBASE_USE_EMULATOR=false`
  y las claves reales; no se versionan claves ni archivos de configuración.

## 5. Archivos clave

| Archivo | Para qué |
|---|---|
| `lib/core/utils/cedula_validator.dart` | Algoritmo módulo 10 y formateo de la cédula. |
| `lib/shared/validators/validators.dart` | Validadores reutilizables; integra el algoritmo. |
| `lib/features/auth/presentation/views/register_view.dart` | Formulario y validación visual. |
| `lib/features/auth/presentation/viewmodels/auth_viewmodel.dart` | Estado del registro, carga y errores. |
| `lib/features/auth/data/firebase_auth_repository.dart` | Auth + escritura del perfil en Firestore. |
| `lib/core/l10n/app_strings.dart` | Todos los textos visibles. |
| `lib/core/router/app_router.dart` | Rutas públicas y redirección al iniciar sesión. |
| `test/core/utils/cedula_validator_test.dart` | Pruebas del algoritmo y del formato. |
| `test/shared/validators/validators_test.dart` | Pruebas de los validadores compartidos. |
| `test/features/auth/register_view_test.dart` | Pruebas de widget del registro. |
| `firestore.rules` | Reglas mínimas del perfil. |
| `docs/firebase-emulator.md` | Entorno local paso a paso. |

## 6. Estado de Git

- Rama actual: `feature/s04-cedula`, creada desde `feature/s03-registro`.
- S04 tiene commits pequeños; **no se hizo merge a `main`**.
- `feature/s03-registro` tampoco se ha integrado a `main`; S04 se apoya en sus
  cambios.
- `android/gradle.properties` tiene un ajuste local para compilar en este equipo
  (heap de 2 GB, sin daemon/incremental). **No se commiteó**.
- `AGENTS.md` y `DESIGN.md` están sin versionar en la raíz. No borrarlos ni
  commitearlos sin confirmar con el usuario.
- El SRS quedó en `docs/srs/SRS_GAD_AMAGUANIA_APLICATIVO_MOVIL.pdf`.

## 7. Deuda conocida

- **Duplicados de cédula (RF-02 incompleto):** el registro acepta una cédula
  válida que ya pertenezca a otra cuenta. No se puede comprobar desde el
  cliente con las reglas actuales de `users_private`. Opciones:
  - Cloud Function con Admin SDK que valide y reserve la cédula en una
    transacción (requiere Functions y probablemente plan Blaze);
  - colección de reserva con reglas que impidan duplicados sin permitir leer
    la cédula;
  - otra alternativa que defina el usuario.
- **S05:** verificación por correo. Hoy la cuenta queda con sesión abierta sin
  verificar. Hay que decidir si el perfil se escribe antes o después de la
  verificación y cómo se bloquea el acceso.
- **S06:** consentimiento LOPDP y recuperación de contraseña.
- **S07:** rol real desde Firestore, guards por rol, reglas por rol y
  `storage.rules`. La regla actual permite crear el perfil propio, pero S07 debe
  impedir que un cliente escriba un rol distinto de `vecino`.
- **S08:** navegación principal definitiva; `HomeView` sigue siendo provisional.
- **S15:** panel de administración.
- No existe todavía `storage.rules`.
- No hay proyecto real de Firebase configurado; las pruebas fueron con el
  proyecto demo y emuladores.

## 8. Próxima sesión: S05

**Objetivo:** verificar el correo electrónico registrado y activar la cuenta
solo después de la verificación (RF-03).

**Criterio de cierre:** una cuenta sin correo verificado no entra a la app; el
usuario puede reenviar el enlace, cambiar el correo o cancelar.

Plan sugerido:

1. Leer `AGENTS.md`, `DESIGN.md`, `PROGRESS.md`, este documento y RF-03 del SRS.
2. Decidir con el usuario el flujo de activación y qué pasa con el perfil que
   hoy se escribe antes de verificar.
3. Enviar la verificación de Firebase Auth al terminar el registro y mostrar
   una pantalla de “verifica tu correo”.
4. Añadir guard de correo verificado en el router; impedir el acceso a `/` si
   `emailVerified` es falso.
5. Implementar reenvío, cambio de correo y cancelación con mensajes claros.
6. Actualizar pruebas unitarias, de widget y el flujo de Auth.
7. Ejecutar `dart format .`, `flutter analyze` y `flutter test`; probar con los
   emuladores.
8. Actualizar `PROGRESS.md` y este documento. Detenerse y esperar “continuar”.

## 9. Preguntas abiertas para S05

- ¿La cuenta debe guardar el perfil en Firestore antes de verificar, con un
  estado “pendiente”, o solo después de verificar?
- ¿“Cancelar” debe cerrar sesión y dejar la cuenta sin verificar, o eliminarla?
- ¿Se usará el enlace de verificación de Firebase o un código propio? El SRS
  permite cualquiera de los dos; el enlace evita Cloud Functions.
- ¿Se usará un proyecto real de Firebase o se mantiene el proyecto demo con
  emuladores?
- ¿Se versionarán `AGENTS.md` y `DESIGN.md`?
- ¿Cuándo se integrará la detección de duplicados de cédula?

## 10. Checklist para retomar

- [ ] Leer `AGENTS.md`, `DESIGN.md`, `PROGRESS.md` y este archivo.
- [ ] Revisar `git status` y la rama `feature/s04-cedula`.
- [ ] Confirmar el flujo de activación de S05 antes de codificar.
- [ ] Levantar Auth + Firestore y configurar `adb reverse` si se prueba en el
      teléfono.
- [ ] No adelantar S06, S07 ni la detección de duplicados.
- [ ] Al terminar, actualizar `PROGRESS.md` y esperar el siguiente “continuar”.
