import 'package:flutter/foundation.dart';

import '../../../models/report.dart';
import '../../../models/report_type.dart';
import '../../../repositories/report_repository.dart';
import '../../../repositories/storage_repository.dart';

/// ViewModel de reportes: creación, listado propio y cambio de estado.
///
/// TODO: gestionar la creación de reportes (subiendo las fotos comprimidas
/// con `StorageRepository`), el stream de reportes del usuario y el cambio
/// de estado para administradores.
class ReportViewModel extends ChangeNotifier {
  ReportViewModel({
    required this.reportRepository,
    required this.storageRepository,
  });

  /// Repositorio de reportes (única vía a Firestore).
  final ReportRepository reportRepository;

  /// Repositorio de fotos (única vía a Firebase Storage).
  final StorageRepository storageRepository;

  /// Reportes creados por el usuario actual.
  final List<Report> myReports = <Report>[];

  /// Indica si hay una operación en curso (para mostrar spinner).
  bool isLoading = false;

  /// Mensaje de error listo para mostrar en la interfaz.
  String? errorMessage;

  // TODO: implementar createReport(...) subiendo fotos y guardando el documento.
  // TODO: implementar watchMyReports(...) suscribiéndome al repositorio.
  // TODO: implementar updateStatus(...) solo para administradores.
  // TODO: implementar dispose para cancelar la suscripción.
}

/// Datos capturados para crear un reporte.
///
/// TODO: ampliar con los campos específicos de cada tipo de reporte.
class ReportDraft {
  const ReportDraft({required this.type, this.description = ''});

  /// Tipo de reporte que se está creando.
  final ReportType type;

  /// Descripción escrita por el vecino.
  final String description;

  // TODO: añadir fotos, lat, lng y campos específicos de mascotas.
}
