import 'package:flutter/material.dart';

/// Pantalla de nuevo reporte de mascota extraviada o abandonada.
///
/// TODO: formulario con fotos, descripción, datos de la mascota (nombre,
/// raza, tamaño, color) y envío a `ReportViewModel.createPetReport(...)`.
class NewPetReportView extends StatelessWidget {
  const NewPetReportView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Nuevo reporte de mascota',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
