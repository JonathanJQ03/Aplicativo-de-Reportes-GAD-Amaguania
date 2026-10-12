import 'package:flutter/material.dart';

/// Pantalla de verificación por código (SMS o correo).
///
/// TODO: campo de código de 6 dígitos que llama a
/// `AuthViewModel.confirmVerificationCode()`.
class VerifyCodeView extends StatelessWidget {
  const VerifyCodeView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Verificar código',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
