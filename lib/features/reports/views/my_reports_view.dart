import 'package:flutter/material.dart';

/// Pantalla con los reportes creados por el vecino autenticado.
///
/// TODO: listar los reportes del usuario con su estado usando
/// `ReportViewModel` y permitir navegar al detalle.
class MyReportsView extends StatelessWidget {
  const MyReportsView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Mis reportes',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
