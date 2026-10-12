import 'package:flutter/material.dart';

/// Pantalla de registro de vecino.
///
/// TODO: formulario con nombre, cédula (validada con `CedulaValidator`),
/// teléfono, correo y contraseña. Llama a `AuthViewModel.register()`.
class RegisterView extends StatelessWidget {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Registro de vecino',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
