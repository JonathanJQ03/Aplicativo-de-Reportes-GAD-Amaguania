/// Ciclo de vida de un reporte.
///
/// Flujo esperado: pendiente -> aprobado -> enAtencion -> resuelto.
/// El reporte puede saltar a `rechazado` desde `pendiente` si el GAD lo descarta.
enum ReportStatus {
  /// Recién creado, esperando revisión del GAD.
  pendiente,

  /// Revisado y publicado; visible para todos los vecinos.
  aprobado,

  /// Un funcionario del GAD ya está trabajando en el caso.
  enAtencion,

  /// El caso fue atendido y cerrado.
  resuelto,

  /// El reporte fue descartado por el GAD.
  rechazado,
}

/// Extensión con datos de presentación en español para [ReportStatus].
extension ReportStatusX on ReportStatus {
  /// Etiqueta en español para mostrar en la interfaz.
  String get label => switch (this) {
    ReportStatus.pendiente => 'Pendiente',
    ReportStatus.aprobado => 'Aprobado',
    ReportStatus.enAtencion => 'En atención',
    ReportStatus.resuelto => 'Resuelto',
    ReportStatus.rechazado => 'Rechazado',
  };
}
