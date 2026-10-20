import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

/// Casilla de verificación con etiqueta y mensaje de error.
///
/// El área táctil incluye toda la etiqueta, según `DESIGN.md`. La casilla
/// nunca se marca por defecto: el consentimiento debe ser una acción expresa
/// del usuario.
class AppCheckbox extends StatelessWidget {
  const AppCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
    this.errorText,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final String label;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final bool hasError = errorText != null && errorText!.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        CheckboxListTile(
          value: value,
          onChanged: onChanged == null
              ? null
              : (bool? checked) => onChanged!(checked ?? false),
          title: Text(
            label,
            style: AppTypography.body.copyWith(color: AppColors.contentPrimary),
          ),
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
          activeColor: AppColors.skyStrong,
          checkColor: AppColors.background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          dense: false,
        ),
        if (hasError) ...[
          const SizedBox(height: 6),
          Semantics(
            liveRegion: true,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Icon(
                  Icons.error_outline,
                  size: 16,
                  color: AppColors.errorText,
                ),
                const SizedBox(width: AppSpacing.sp1),
                Flexible(
                  child: Text(
                    errorText!,
                    style: AppTypography.small.copyWith(
                      color: AppColors.errorText,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
