import 'package:flutter/foundation.dart';

import '../../../models/report.dart';
import '../../../repositories/report_repository.dart';

/// ViewModel del inicio: mapa, lista de reportes aprobados y filtros.
///
/// TODO: gestionar el stream de reportes aprobados, el filtro activo y la
/// posición de la cámara del mapa, exponiendo el estado a `HomeView`.
class HomeViewModel extends ChangeNotifier {
  HomeViewModel({required this.reportRepository});

  /// Repositorio con el que este ViewModel trabaja (única vía a Firebase).
  final ReportRepository reportRepository;

  /// Reportes aprobados actualmente visibles.
  final List<Report> reports = <Report>[];

  /// Filtro de tipo aplicado (null = todos).
  HomeTypeFilter? activeTypeFilter;

  // TODO: suscribirse a watchApprovedReports y notificar cambios.
  // TODO: implementar applyTypeFilter(...) y applyStatusFilter(...).
  // TODO: implementar dispose para cancelar la suscripción.
}

/// Filtro de tipo usado por el inicio.
enum HomeTypeFilter { fuga, mascota }
