# Amaguaña Alerta

Aplicación móvil de **reportes ciudadanos** para el Gobierno Autónomo Descentralizado (GAD) de Amaguaña.

Permite a los vecinos reportar dos tipos de incidencias:

- 💧 **Fugas de agua** en la red de acueducto o en vía pública.
- 🐕 **Mascotas extraviadas o abandonadas.**

Los reportes pasan por un proceso de revisión por parte del GAD antes de ser publicados en el mapa para toda la comunidad.

---

## Estado del proyecto

🚧 **Fase: estructura base.** Solo existe la estructura de carpetas y los stubs (clases vacías con `// TODO:`). **No hay lógica de negocio implementada todavía.**

> ⚠️ **Firebase y Google Maps aún NO están configurados.** Las dependencias están agregadas en `pubspec.yaml`, pero falta:
> - `flutterfire configure` (genera los archivos de configuración de Firebase).
> - La API key de Google Maps en los ficheros de Android (`AndroidManifest.xml`) e iOS (`AppDelegate.swift` / `Info.plist`).
> - Los permisos de ubicación y cámara en ambos sistemas.
>
> Esto se hará en una segunda fase, sobre esta misma estructura.

---

## Arquitectura

**MVVM simple organizado por funcionalidades** (features-first).

```
Vista  →  ViewModel  →  Repositorio  →  Firebase
```

| Capa | Responsabilidad |
|---|---|
| **View** (`features/*/views/`) | Dibuja la interfaz y recoge la interacción del usuario. **Nunca** accede a Firebase. |
| **ViewModel** (`features/*/viewmodels/`) | Contiene el estado de la pantalla y la orquestación. Notifica cambios a la vista mediante `ChangeNotifier` (Provider). |
| **Repository** (`repositories/`) | Única capa que habla con Firebase (Auth, Firestore, Storage). Expone métodos y streams. |
| **Model** (`models/`) | Entidades de datos y enums compartidos. |
| **Core** (`core/`) | Tema, constantes, utilidades y rutas. Sin dependencias de funcionalidades. |

La regla es estricta: **una vista solo conversa con su ViewModel, y un ViewModel solo conversa con repositorios.** Ninguna vista importa un paquete de Firebase.

### Stack

- **Estado:** `provider`
- **Navegación:** `go_router`
- **Backend:** Firebase (`firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_storage`, `firebase_messaging`)
- **Mapa y ubicación:** `google_maps_flutter`, `geolocator`
- **Imágenes:** `image_picker`, `flutter_image_compress`

---

## Estructura de carpetas

```
.
├── lib/
│   ├── main.dart                          # Punto de entrada
│   ├── app.dart                           # MaterialApp, tema y rutas
│   ├── core/
│   │   ├── constants/
│   │   │   └── app_constants.dart         # Constantes globales
│   │   ├── router/
│   │   │   └── app_router.dart            # Rutas con go_router
│   │   ├── theme/
│   │   │   └── app_theme.dart             # Tema Material 3 + paleta
│   │   └── utils/
│   │       ├── cedula_validator.dart      # Validación módulo 10 (cédula EC)
│   │       └── image_compressor.dart      # Compresión de fotos a máx. 1 MB
│   ├── models/
│   │   ├── app_user.dart                  # Usuario y roles
│   │   ├── report.dart                    # Reporte base
│   │   ├── report_status.dart             # Enum de estados
│   │   └── report_type.dart               # Enum fuga / mascota
│   ├── repositories/
│   │   ├── auth_repository.dart           # Firebase Auth
│   │   ├── report_repository.dart         # Cloud Firestore
│   │   └── storage_repository.dart        # Firebase Storage
│   └── features/
│       ├── auth/
│       │   ├── viewmodels/auth_viewmodel.dart
│       │   └── views/
│       │       ├── forgot_password_view.dart
│       │       ├── login_view.dart
│       │       ├── register_view.dart
│       │       └── verify_code_view.dart
│       ├── home/
│       │   ├── viewmodels/home_viewmodel.dart
│       │   └── views/home_view.dart       # Mapa + lista + filtros
│       ├── profile/
│       │   ├── viewmodels/profile_viewmodel.dart
│       │   └── views/profile_view.dart
│       └── reports/
│           ├── viewmodels/report_viewmodel.dart
│           └── views/
│               ├── my_reports_view.dart
│               ├── new_leak_report_view.dart
│               ├── new_pet_report_view.dart
│               └── report_detail_view.dart
├── docs/                                  # Documentación del proyecto
│   ├── README.md                          # Índice de la documentación
│   ├── srs/                               # Documento de requisitos
│   ├── wireframes/
│   ├── diagrams/
│   └── assets/
├── test/
│   └── widget_test.dart
└── android/ · ios/                        # Plataformas generadas
```

---

## Tema (Material 3)

| Uso | Color |
|---|---|
| Primario / botones principales | Amarillo pastel `#F6CF4A` |
| Secundario / fondos suaves | Celeste pastel `#D9EEFA` |
| Bordes y campos | Celeste `#7FB6D9` |
| Fondo | Blanco `#FFFFFF` |
| Texto | Oscuro `#1F2A37` |

**Colores de estado de un reporte:**

| Estado | Color |
|---|---|
| Pendiente | Amarillo |
| Aprobado | Verde suave |
| En atención | Celeste |
| Resuelto | Gris azulado |
| Rechazado | Rojo suave |

Accesibilidad: esquinas redondeadas de **8 px**, tamaño táctil mínimo de **44 px** y contraste alto (texto oscuro sobre amarillo, no blanco).

---

## Puesta en marcha

Requisitos: [Flutter SDK](https://docs.flutter.dev/get-started/install) estable.

```bash
flutter pub get
flutter run
```

Verificación:

```bash
flutter analyze
flutter test
```

---

## Documentación

La documentación del proyecto (SRS, wireframes, diagramas) vive en [`docs/`](docs/README.md).

---

## Autoría

Proyecto para el **GAD de Amaguaña**.
