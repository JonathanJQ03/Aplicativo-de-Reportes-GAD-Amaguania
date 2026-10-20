import 'package:flutter/material.dart';

import 'core/l10n/app_strings.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_spacing.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_typography.dart';

/// Punto de entrada del panel web de administración.
///
/// En S15 se reemplaza este marcador por el login y el layout del panel.
void main() {
  runApp(const _AdminPlaceholderApp());
}

class _AdminPlaceholderApp extends StatelessWidget {
  const _AdminPlaceholderApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.adminPanelTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      themeMode: ThemeMode.light,
      home: Scaffold(
        appBar: AppBar(title: const Text(AppStrings.adminPanelTitle)),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.sp4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.admin_panel_settings_outlined,
                    size: 64,
                    color: AppColors.skyStrong,
                  ),
                  const SizedBox(height: AppSpacing.sp3),
                  Text(
                    AppStrings.adminPanelComingSoon,
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
      ),
    );
  }
}
