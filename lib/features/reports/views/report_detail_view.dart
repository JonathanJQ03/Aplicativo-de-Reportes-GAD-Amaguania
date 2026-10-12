import 'package:flutter/material.dart';

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
          'Detalle del reporte',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
