import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

/// Tipos de mensaje de [AppBanner], alineados con los colores semánticos.
enum AppBannerType { info, success, warning, error }

/// Aviso en línea con icono y texto.
///
/// El color nunca comunica solo: cada banner incluye un icono y un mensaje.
class AppBanner extends StatelessWidget {
  const AppBanner({
    super.key,
    required this.message,
    this.type = AppBannerType.info,
  });

  final String message;
  final AppBannerType type;

  @override
  Widget build(BuildContext context) {
    final (Color background, Color foreground, IconData icon) = switch (type) {
      AppBannerType.info => (
        AppColors.infoBackground,
        AppColors.infoText,
        Icons.info_outline_rounded,
      ),
      AppBannerType.success => (
        AppColors.successBackground,
        AppColors.successText,
        Icons.check_circle_outline_rounded,
      ),
      AppBannerType.warning => (
        AppColors.warningBackground,
        AppColors.warningText,
        Icons.warning_amber_rounded,
      ),
      AppBannerType.error => (
        AppColors.errorBackground,
        AppColors.errorText,
        Icons.error_outline_rounded,
      ),
    };

    return Semantics(
      container: true,
      liveRegion: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.sp3),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: foreground),
            const SizedBox(width: AppSpacing.sp2),
            Expanded(
              child: Text(
                message,
                style: AppTypography.small.copyWith(
                  color: foreground,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
