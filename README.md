# VeciApp

Aplicación móvil de **reportes ciudadanos** para el Gobierno Autónomo
Descentralizado (GAD) de Amaguaña.

Los vecinos reportan **fugas de agua** y **mascotas extraviadas o abandonadas**
con descripción, fotos y ubicación. Todo reporte nace como pendiente y solo se
publica después de la aprobación de un administrador del GAD.

---

## Estado del proyecto

✅ **Sesión actual: S07 — Roles y control de acceso.**

Completado:

- **S00:** base del proyecto, tokens de `DESIGN.md`, tipografía, textos
  centralizados, widgets compartidos y localización en español.
- **S01:** login con Firebase Authentication, sesión persistente y cierre de
  sesión.
- **S02:** validadores reutilizables, mensajes claros y estados de error.
- **S03:** registro de vecinos con perfil público y datos privados separados.
- **S04:** validación de la cédula ecuatoriana (duplicados pendientes).
- **S05 (parcial):** pantalla de verificación, guard de correo, reenvío, cambio
  de correo y cancelación. En debug se desbloquea la cuenta a los 3 segundos
  para no bloquear el avance; **la verificación real por código de 6 dígitos y
  el envío a un correo real siguen pendientes**.
- **S06:** consentimiento LOPDP y recuperación de contraseña.
- **S07:** rol leído desde Firestore, reglas por rol y **acceso de
  administrador dentro de la misma app**: la acción **Administrador** del login
  abre el panel del GAD. Un vecino que intenta entrar ve **Acceso restringido**.
  Es un solo APK; la pantalla del panel completo llega en S15.

Consulta `PROGRESS.md` para el detalle y `AGENTS.md` para la hoja de ruta.

---

## Stack

- **Flutter / Dart** para la app móvil y el futuro panel web.
- **Firebase:** Authentication, Cloud Firestore, Storage y Cloud Messaging.
- **Google Maps Platform** para mapas y ubicación.
- **Provider** para el estado (decisión registrada en `PROGRESS.md`).
- **go_router** para la navegación y la guarda de sesión.

---

## Arquitectura

La feature `auth` sigue Clean Architecture por capas:

```
presentation  →  domain  ←  data
   vistas          contrato    Firebase Auth
   viewmodels      errores
```

Las demás features se migrarán a esta estructura cuando se trabajen en su
sesión. La regla se mantiene: **las vistas no conocen Firebase**; pasan por un
ViewModel y un repositorio.

```
lib/
├── main.dart                  # entrada por defecto (delega en main_vecino)
├── main_vecino.dart           # entrada única de la app
├── main_admin.dart            # alias de main_vecino (compatibilidad)
├── app.dart                   # MaterialApp, Provider y router
├── core/
│   ├── config/                # inicialización de Firebase
│   ├── errors/                # pantalla de arranque con error
│   ├── l10n/                  # textos visibles en español
│   ├── router/                # rutas y guarda de sesión
│   └── theme/                 # tokens de DESIGN.md
├── shared/widgets/            # AppButton, AppTextField, AppBanner
├── features/
│   ├── auth/
│   │   ├── data/              # FirebaseAuthRepository
│   │   ├── domain/            # AuthRepository y AuthFailure
│   │   └── presentation/      # LoginView y AuthViewModel
│   ├── home/
│   ├── moderation/            # panel del GAD (marcador en S07)
│   └── profile/
└── models/                    # AppUser, Report, estados y tipos
```

---

## Diseño

Todos los colores, tipografías, espaciados, radios y sombras viven en
`lib/core/theme/` y provienen de `DESIGN.md`. No se escriben valores literales
en los widgets. Los textos visibles están en `lib/core/l10n/app_strings.dart`.

---

## Puesta en marcha

Requisitos: Flutter estable y Node.js (para el emulador de Firebase).

```bash
flutter pub get
npx firebase-tools emulators:start --only auth,firestore,storage
```

En otra terminal:

```bash
flutter run -t lib/main_vecino.dart
```

En `debug` la app usa un proyecto demo y el emulador de Authentication. El
usuario de prueba y la configuración de un proyecto real están en
[`docs/firebase-emulator.md`](docs/firebase-emulator.md).

Verificación:

```bash
dart format .
flutter analyze
flutter test
```

---

## Seguridad

- Sin sesión no se accede a rutas privadas.
- No se versionan `google-services.json`, `GoogleService-Info.plist`,
  `firebase_options.dart` ni archivos `.env`.
- No se registran en logs correos, cédulas, teléfonos ni URLs privadas.
- Los datos sensibles del usuario se separarán de los datos públicos en
  Firestore (`users` y `users_private`).

---

## Documentación

- [`AGENTS.md`](AGENTS.md): metodología, reglas y hoja de ruta por sesiones.
- [`DESIGN.md`](DESIGN.md): sistema de diseño.
- [`PROGRESS.md`](PROGRESS.md): estado actual.
- [`docs/firebase-emulator.md`](docs/firebase-emulator.md): Firebase en local.

Proyecto para el **GAD de Amaguaña**.
