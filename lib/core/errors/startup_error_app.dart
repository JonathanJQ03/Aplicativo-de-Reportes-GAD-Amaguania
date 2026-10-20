import 'package:flutter/material.dart';

import '../../shared/widgets/app_button.dart';
import '../l10n/app_strings.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_theme.dart';
import '../theme/app_typography.dart';

/// Pantalla de arranque cuando Firebase no pudo inicializarse.
///
/// Nunca muestra el error técnico: explica qué puede hacer el usuario.
class StartupErrorApp extends StatelessWidget {
  const StartupErrorApp({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      themeMode: ThemeMode.light,
      home: Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.sp4),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(
                      Icons.cloud_off_rounded,
                      size: 64,
                      color: AppColors.contentTertiary,
                    ),
                    const SizedBox(height: AppSpacing.sp3),
                    Semantics(
                      header: true,
                      child: Text(
                        AppStrings.startupErrorTitle,
                        style: AppTypography.h2,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sp2),
                    Text(
                      AppStrings.startupErrorBody,
                      style: AppTypography.body.copyWith(
                        color: AppColors.contentSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.sp5),
                    AppButton(
                      label: AppStrings.retry,
                      icon: Icons.refresh_rounded,
                      size: AppButtonSize.large,
                      expand: true,
                      onPressed: onRetry,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
