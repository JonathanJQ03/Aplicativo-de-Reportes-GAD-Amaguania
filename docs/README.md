# Documentación — VeciApp

Carpeta dedicada a la documentación del proyecto. **No** forma parte del código
Dart (toda vive fuera de `lib/`, para que no se incluya en el build).

## Índice de subcarpetas

| Carpeta | Contenido |
|---|---|
| `srs/` | Documento de requisitos de software (SRS): alcance, requisitos funcionales y no funcionales, actores, casos de uso. |
| `wireframes/` | Bocetos / pantallas de las vistas (pueden ser imágenes, PDF o archivos de diseño). |
| `diagrams/` | Diagramas UML y afines: casos de uso, clases, secuencias, arquitectura, esquema de Firestore. |
| `assets/` | Recursos estáticos usados solo en documentación (logos, fotos de muestra, iconos de estado, etc.). |

## Guías

- [`contexto-sesion.md`](contexto-sesion.md): resumen del estado del proyecto y
  checklist para retomar la próxima sesión.
- [`firebase-emulator.md`](firebase-emulator.md): cómo levantar los emuladores
  locales de Authentication y Firestore, y crear el usuario de prueba.

> Nota: los assets que **sí** se usan en la app (imágenes embebidas en el
> binario) van en `assets/` dentro de la raíz del proyecto Flutter y se declaran
> en `pubspec.yaml`, no aquí.
