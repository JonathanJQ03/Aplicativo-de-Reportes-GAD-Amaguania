import 'package:flutter/material.dart';

import '../../../core/l10n/app_strings.dart';

/// Pantalla de detalle de un reporte.
///
/// TODO: mostrar fotos, descripción, ubicación en el mapa, fechas y estado
/// del reporte. Para administradores, añadir acciones de cambio de estado
/// vía `ReportViewModel.updateStatus(...)`.
class ReportDetailView extends StatelessWidget {
  const ReportDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          AppStrings.reportDetailTitle,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
