import 'report_status.dart';
import 'report_type.dart';

/// Reporte ciudadano base, compartido por fugas de agua y mascotas.
///
/// TODO: implementar `fromMap`/`toMap` y los campos específicos de cada
/// tipo de reporte (por ejemplo, raza y tamaño para mascotas). Este archivo
/// es solo el stub de la estructura del modelo base.
class Report {
  const Report({
    required this.id,
    required this.type,
    required this.status,
    required this.description,
    required this.authorUid,
    required this.createdAt,
    this.photos = const <String>[],
    this.lat,
    this.lng,
    this.updatedAt,
  });

  /// Identificador del documento en Firestore.
  final String id;

  /// Tipo de reporte: fuga de agua o mascota.
  final ReportType type;

  /// Estado actual del reporte en su ciclo de vida.
  final ReportStatus status;

  /// Descripción escrita por el vecino.
  final String description;

  /// Rutas o URLs de las fotos adjuntas en Firebase Storage.
  final List<String> photos;

  /// Latitud del punto donde ocurrió el reporte.
  final double? lat;

  /// Longitud del punto donde ocurrió el reporte.
  final double? lng;

  /// uid del vecino que creó el reporte.
  final String authorUid;

  /// Momento de creación del reporte.
  final DateTime createdAt;

  /// Última modificación (por ejemplo, cambio de estado).
  final DateTime? updatedAt;

  // TODO: crear factory Report.fromMap(Map<String, dynamic> map).
  // TODO: crear Map<String, dynamic> toMap().
  // TODO: crear Report copyWith(...).
}
