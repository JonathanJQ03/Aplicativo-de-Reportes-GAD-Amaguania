import 'package:flutter/material.dart';

import '../../../core/l10n/app_strings.dart';

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
          AppStrings.newPetReportTitle,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
