import 'package:flutter/material.dart';

import '../../../core/l10n/app_strings.dart';

/// Pantalla de perfil del vecino.
///
/// TODO: mostrar y editar nombre, cédula, teléfono y foto; mostrar el rol
/// (vecino / vecino verificado / administrador) y el botón de cerrar sesión.
class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          AppStrings.profileTitle,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
