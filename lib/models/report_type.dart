/// Tipo de reporte ciudadano.
enum ReportType {
  /// Fuga de agua (acueducto, pérdida en vía pública, etc.).
  fuga,

  /// Mascota extraviada o abandonada.
  mascota,
}

/// Extensión con datos de presentación en español para [ReportType].
extension ReportTypeX on ReportType {
  /// Etiqueta en español para mostrar en la interfaz.
  String get label => switch (this) {
    ReportType.fuga => 'Fuga de agua',
    ReportType.mascota => 'Mascota',
  };
}
