import '../models/report.dart';
import '../models/report_type.dart';

/// Repositorio de reportes.
///
/// Única capa que conversa con Cloud Firestore para la colección de
/// reportes. Las vistas NUNCA acceden a Firebase directamente.
///
/// TODO: implementar los métodos con `cloud_firestore`. Este archivo es solo
/// el stub de la estructura.
class ReportRepository {
  const ReportRepository();

  /// Devuelve el stream de reportes **aprobados** para el mapa y la lista.
  ///
  /// TODO: implementar consulta filtrable por [type] y por rango geográfico.
  Stream<List<Report>> watchApprovedReports({ReportType? type}) {
    // TODO: implementar consulta a Firestore.
    return const Stream<List<Report>>.empty();
  }

  /// Devuelve el stream de reportes creados por [authorUid].
  ///
  /// TODO: implementar consulta filtrada por autor.
  Stream<List<Report>> watchReportsByAuthor(String authorUid) {
    // TODO: implementar consulta a Firestore.
    return const Stream<List<Report>>.empty();
  }

  /// Devuelve un reporte puntual por su [id].
  ///
  /// TODO: implementar lectura de un documento.
  Future<Report?> getReportById(String id) async {
    // TODO: implementar lectura del documento.
    return null;
  }

  /// Crea un nuevo reporte.
  ///
  /// TODO: implementar escritura del documento en Firestore.
  Future<void> createReport(Report report) async {
    // TODO: implementar creación del reporte.
  }

  /// Actualiza el estado de un reporte (solo administradores).
  ///
  /// TODO: implementar actualización del documento y reglas de seguridad.
  Future<void> updateReportStatus(String id, String status) async {
    // TODO: implementar cambio de estado.
  }
}
