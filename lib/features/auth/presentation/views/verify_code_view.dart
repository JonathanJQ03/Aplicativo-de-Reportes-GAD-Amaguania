import 'package:flutter/material.dart';

import '../../../../core/l10n/app_strings.dart';

/// Pantalla de verificación por código (SMS o correo).
///
/// TODO(S05): campo de código de 6 dígitos para confirmar la cuenta.
class VerifyCodeView extends StatelessWidget {
  const VerifyCodeView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          AppStrings.verifyCodeTitle,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
