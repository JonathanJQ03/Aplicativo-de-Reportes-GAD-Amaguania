import 'package:flutter/material.dart';

/// Pantalla de inicio de sesión.
///
/// TODO: formulario de email y contraseña que llama a `AuthViewModel.login()`.
/// La vista solo conversa con el ViewModel, nunca con Firebase.
class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Iniciar sesión',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
