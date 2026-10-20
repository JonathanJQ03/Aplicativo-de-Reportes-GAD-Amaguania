import 'package:flutter/material.dart';

import '../../../core/l10n/app_strings.dart';

/// Pantalla de nuevo reporte de fuga de agua.
///
/// TODO: formulario con descripción, fotos (image_picker), ubicación
/// (geolocator) y envío a `ReportViewModel.createLeakReport(...)`.
class NewLeakReportView extends StatelessWidget {
  const NewLeakReportView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          AppStrings.newLeakReportTitle,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
