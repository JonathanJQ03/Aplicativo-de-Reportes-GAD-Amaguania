import 'package:flutter/material.dart';

import '../../../../core/l10n/app_strings.dart';

/// Pantalla de registro de vecino.
///
/// TODO: formulario con nombre, cédula (validada con `CedulaValidator`),
/// teléfono, correo y contraseña. El envío se conecta en S03.
class RegisterView extends StatelessWidget {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          AppStrings.registerTitle,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
