import 'package:flutter/material.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// Pantalla de espera mientras se resuelve la sesión y el rol.
///
/// Evita mostrar el inicio de vecino o el panel antes de conocer el rol real.
class SessionLoadingView extends StatelessWidget {
  const SessionLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sp4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: AppColors.skyStrong,
                  ),
                ),
                const SizedBox(height: AppSpacing.sp4),
                Text(
                  AppStrings.sessionChecking,
                  style: AppTypography.body.copyWith(
                    color: AppColors.contentSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
