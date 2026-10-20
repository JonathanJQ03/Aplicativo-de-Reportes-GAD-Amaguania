import 'package:flutter/material.dart';

import '../../../../core/l10n/app_strings.dart';

/// Pantalla de recuperación de contraseña.
///
/// TODO(S06): campo de correo para enviar el enlace de recuperación.
class ForgotPasswordView extends StatelessWidget {
  const ForgotPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          AppStrings.forgotPasswordTitle,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
