import 'package:flutter/material.dart';

/// Pantalla de recuperación de contraseña.
///
/// TODO: campo de correo que llama a `AuthViewModel.sendPasswordReset()`.
class ForgotPasswordView extends StatelessWidget {
  const ForgotPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Recuperar contraseña',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
