import 'package:flutter/material.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

/// Variantes visuales de [AppButton] definidas en `DESIGN.md`.
enum AppButtonVariant { primary, secondary, ghost, destructive }

/// Tamaños disponibles de [AppButton].
enum AppButtonSize { medium, large }

/// Botón base de VeciApp.
///
/// Mantiene una zona táctil mínima de 48 px, texto en negrita y un único
/// estado de carga que bloquea toques repetidos.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.expand = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = onPressed == null;
    final double minHeight = size == AppButtonSize.large ? 56 : 48;
    final TextStyle baseStyle =
        (size == AppButtonSize.large
                ? AppTypography.bodyLarge
                : AppTypography.body)
            .copyWith(fontWeight: FontWeight.w700);

    final Color background = switch (variant) {
      AppButtonVariant.primary => AppColors.sol,
      AppButtonVariant.secondary => AppColors.transparent,
      AppButtonVariant.ghost => AppColors.transparent,
      AppButtonVariant.destructive => AppColors.errorText,
    };
    final Color foreground = switch (variant) {
      AppButtonVariant.primary => AppColors.contentOnSol,
      AppButtonVariant.secondary => AppColors.skyStrong,
      AppButtonVariant.ghost => AppColors.skyStrong,
      AppButtonVariant.destructive => AppColors.background,
    };
    final Color pressedOverlay = switch (variant) {
      AppButtonVariant.primary => AppColors.solPressed,
      AppButtonVariant.secondary => AppColors.skyPressed,
      AppButtonVariant.ghost => AppColors.skyHover,
      AppButtonVariant.destructive => AppColors.deepBlue,
    };

    final RoundedRectangleBorder shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
    );
    final EdgeInsets padding = size == AppButtonSize.large
        ? const EdgeInsets.symmetric(
            horizontal: AppSpacing.sp5,
            vertical: AppSpacing.sp3,
          )
        : const EdgeInsets.symmetric(
            horizontal: AppSpacing.sp4,
            vertical: AppSpacing.sp2,
          );

    final Widget content = isLoading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: foreground,
            ),
          )
        : Row(
            mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20, color: foreground),
                const SizedBox(width: AppSpacing.sp2),
              ],
              Flexible(
                child: Text(
                  label,
                  style: baseStyle.copyWith(color: foreground),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          );

    final VoidCallback? effectiveOnPressed = isDisabled
        ? null
        : () {
            if (!isLoading) {
              onPressed!();
            }
          };

    final Widget button = switch (variant) {
      AppButtonVariant.primary => ElevatedButton(
        onPressed: effectiveOnPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: background,
          foregroundColor: foreground,
          disabledBackgroundColor: background.withValues(alpha: 0.4),
          disabledForegroundColor: foreground.withValues(alpha: 0.4),
          overlayColor: pressedOverlay,
          minimumSize: const Size(0, 0),
          padding: padding,
          shape: shape,
          elevation: 0,
          textStyle: baseStyle,
        ),
        child: content,
      ),
      AppButtonVariant.secondary => OutlinedButton(
        onPressed: effectiveOnPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: foreground,
          disabledForegroundColor: foreground.withValues(alpha: 0.4),
          overlayColor: pressedOverlay,
          minimumSize: const Size(0, 0),
          padding: padding,
          side: BorderSide(
            color: isDisabled ? foreground.withValues(alpha: 0.4) : foreground,
            width: 2,
          ),
          shape: shape,
          textStyle: baseStyle,
        ),
        child: content,
      ),
      AppButtonVariant.ghost => TextButton(
        onPressed: effectiveOnPressed,
        style: TextButton.styleFrom(
          foregroundColor: foreground,
          disabledForegroundColor: foreground.withValues(alpha: 0.4),
          overlayColor: pressedOverlay,
          minimumSize: const Size(0, 0),
          padding: padding,
          shape: shape,
          textStyle: baseStyle,
        ),
        child: content,
      ),
      AppButtonVariant.destructive => ElevatedButton(
        onPressed: effectiveOnPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: background,
          foregroundColor: foreground,
          disabledBackgroundColor: background.withValues(alpha: 0.4),
          disabledForegroundColor: foreground.withValues(alpha: 0.4),
          overlayColor: pressedOverlay,
          minimumSize: const Size(0, 0),
          padding: padding,
          shape: shape,
          elevation: 0,
          textStyle: baseStyle,
        ),
        child: content,
      ),
    };

    return Semantics(
      button: true,
      enabled: !isDisabled && !isLoading,
      label: isLoading ? '$label. ${AppStrings.loading}' : label,
      onTap: effectiveOnPressed,
      child: ExcludeSemantics(
        child: SizedBox(
          width: expand ? double.infinity : null,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: minHeight),
            child: button,
          ),
        ),
      ),
    );
  }
}
