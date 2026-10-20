# Contexto para retomar la próxima sesión

**Última sesión cerrada:** S03 — Registro de vecino
**Fecha:** 2026-10-19
**Rama:** `feature/s03-registro`
**Siguiente sesión:** S04 — Validación de cédula ecuatoriana y duplicados

> Este documento es un apoyo para retomar el trabajo. La fuente de verdad del
> avance sigue siendo `PROGRESS.md`; las reglas del proyecto están en
> `AGENTS.md` y el diseño en `DESIGN.md`.

## 1. Dónde nos quedamos

S03 quedó **completa y verificada en un teléfono físico**. El registro crea la
cuenta en Firebase Authentication y guarda el perfil en Firestore:

- `users/{uid}`: nombre visible, rol `vecino` y fecha de creación.
- `users_private/{uid}`: nombres, apellidos, cédula, correo, teléfono opcional
  y fecha.

La cuenta queda con sesión abierta y el router redirige a la pantalla principal.
No se inició S04 ni ninguna sesión posterior.

## 2. Qué funciona hoy

- Formulario de registro con nombres, apellidos, cédula, correo obligatorio,
  teléfono opcional y contraseña.
- Validadores reutilizables para:
  - campos obligatorios;
  - nombre y apellido;
  - cédula de 10 dígitos (solo formato, **sin algoritmo**);
  - correo;
  - teléfono opcional de 10 dígitos que empieza por `09`;
  - contraseña nueva de 8+ caracteres con mayúscula, minúscula, número y
    símbolo.
- Mensajes de error claros en español, sin mostrar excepciones ni códigos.
- Registro en Auth + escritura en Firestore; si falla la escritura del perfil se
  intenta borrar el usuario recién creado en Auth.
- Protección contra toques repetidos mientras carga.
- Navegación login → registro y registro → login.
- Reglas mínimas de Firestore para que cada vecino lea y cree **solo su propio**
  perfil (`firestore.rules`).

## 3. Verificación de S03

- `dart format .`: aplicado.
- `flutter analyze`: sin problemas.
- `flutter test`: **71 pruebas pasan**.
- Prueba de extremo a extremo en Samsung SM-A546E contra los emuladores locales
  de Auth y Firestore:
  - cuenta creada;
  - documentos `users` y `users_private` verificados;
  - rol `vecino` y datos sensibles separados.
- Capturas en `/home/javier/Descargas/VeciApp/`:
  - `s03-01-login.png`
  - `s03-02-registro.png`
  - `s03-03-registro-accion.png`
  - `s03-04-registro-errores.png`
  - `s03-05-registro-datos.png`
  - `s03-06-registro-resultado.png`

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
| `lib/features/auth/presentation/views/register_view.dart` | Formulario y validación visual. |
| `lib/features/auth/presentation/viewmodels/auth_viewmodel.dart` | Estado del registro, carga y errores. |
| `lib/features/auth/data/firebase_auth_repository.dart` | Auth + escritura del perfil en Firestore. |
| `lib/shared/validators/validators.dart` | Validadores reutilizables. |
| `lib/core/l10n/app_strings.dart` | Todos los textos visibles. |
| `lib/core/router/app_router.dart` | Rutas públicas y redirección al iniciar sesión. |
| `firestore.rules` | Reglas mínimas del perfil. |
| `docs/firebase-emulator.md` | Entorno local paso a paso. |

## 6. Estado de Git

- Rama actual: `feature/s03-registro`.
- S03 tiene 6 commits y **no se hizo merge a `main`**.
- `android/gradle.properties` tiene un ajuste local para compilar en este equipo
  (heap de 2 GB, sin daemon/incremental). **No se commiteó**.
- `AGENTS.md` y `DESIGN.md` están sin versionar en la raíz. No borrarlos ni
  commitearlos sin confirmar con el usuario.
- El SRS quedó en `docs/srs/SRS_GAD_AMAGUANIA_APLICATIVO_MOVIL.pdf`.

## 7. Deuda conocida

- **S04:** implementar el algoritmo ecuatoriano de cédula y bloquear cédulas
  repetidas. El validador actual `lib/core/utils/cedula_validator.dart` es un
  stub y el registro solo comprueba 10 dígitos.
- **S05:** verificación por correo. Hoy la cuenta queda con sesión abierta sin
  verificar.
- **S06:** consentimiento LOPDP y recuperación de contraseña.
- **S07:** rol real desde Firestore, guards por rol, reglas por rol y
  `storage.rules`. La regla actual permite crear el perfil propio, pero S07 debe
  impedir que un cliente escriba un rol distinto de `vecino`.
- **S08:** navegación principal definitiva; `HomeView` sigue siendo provisional.
- **S15:** panel de administración.
- No existe todavía `storage.rules`.
- No hay proyecto real de Firebase configurado; todas las pruebas fueron con el
  proyecto demo y emuladores.

## 8. Próxima sesión: S04

**Objetivo:** validar la cédula ecuatoriana y detectar duplicados (RF-02).
**Criterio de cierre:** una cédula inválida o repetida bloquea el registro, con
pruebas de casos válidos e inválidos.

Plan sugerido:

1. Leer `AGENTS.md`, `DESIGN.md`, `PROGRESS.md`, este documento y el RF-02 del
   SRS.
2. Implementar el algoritmo de cédula ecuatoriana en
   `lib/core/utils/cedula_validator.dart` con pruebas unitarias de provincias,
   dígito verificador inválido, longitud y caracteres no numéricos.
3. Integrar el validador en el formulario de registro y actualizar los mensajes.
4. Resolver la detección de duplicados.
5. Ejecutar `dart format .`, `flutter analyze` y `flutter test`.
6. Probar el registro en el teléfono con los emuladores.
7. Actualizar `PROGRESS.md` y las capturas si cambia la interfaz.

## 9. Decisión pendiente antes de codificar S04

La detección de duplicados **no se puede hacer solo desde el cliente** con las
reglas actuales: `users_private` solo permite leer el documento propio, por
privacidad. Hay que decidir el mecanismo antes de implementar:

- una Cloud Function con Admin SDK que compruebe y reserve la cédula (requiere
  confirmar el plan de Firebase y el uso de Functions);
- una colección auxiliar de unicidad con reglas y hashes, cuidando no exponer la
  cédula ni permitir enumeración;
- otra alternativa definida por el usuario.

No elegir una opción por cuenta propia: preguntar al inicio de S04 y anotar la
decisión en `PROGRESS.md`.

## 10. Checklist para retomar

- [ ] Leer `AGENTS.md`, `DESIGN.md`, `PROGRESS.md` y este archivo.
- [ ] Revisar `git status` y la rama `feature/s03-registro`.
- [ ] Confirmar si se sigue en S04 y qué mecanismo se usará para duplicados.
- [ ] Levantar Auth + Firestore y configurar `adb reverse` si se prueba en el
      teléfono.
- [ ] No adelantar S05, S06 ni S07.
- [ ] Al terminar, actualizar `PROGRESS.md` y esperar el siguiente “continuar”.

## 11. Preguntas abiertas que conviene resolver pronto

- ¿La detección de duplicados se hará con Cloud Functions o con otra estrategia?
- ¿Se usará un proyecto real de Firebase para las pruebas finales o se queda el
  proyecto demo con emuladores?
- ¿Se mantiene la decisión de no pedir confirmación de contraseña?
- ¿Se versionarán `AGENTS.md` y `DESIGN.md` en el repositorio?
