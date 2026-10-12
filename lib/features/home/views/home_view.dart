import 'package:flutter/material.dart';

/// Pantalla principal: mapa de reportes + lista + filtros.
///
/// TODO: implementar el mapa con `google_maps_flutter`, la lista de reportes
/// aprobados y los filtros por tipo (fuga / mascota) y estado.
/// El mapa se muestra cuando Firebase y Google Maps ya estén configurados.
class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Inicio: mapa y reportes',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
