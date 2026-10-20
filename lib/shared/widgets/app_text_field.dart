import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

/// Campo de texto base de VeciApp.
///
/// La etiqueta siempre está visible sobre el campo y los errores explican qué
/// pasó y cómo corregirlo. Los campos de contraseña incluyen mostrar u ocultar.
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
    this.enabled = true,
    this.prefixIcon,
    this.maxLines = 1,
    this.inputFormatters,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.textCapitalization = TextCapitalization.none,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FocusNode? focusNode;
  final bool enabled;
  final IconData? prefixIcon;
  final int maxLines;
  final List<TextInputFormatter>? inputFormatters;
  final bool autocorrect;
  final bool enableSuggestions;
  final TextCapitalization textCapitalization;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscure = widget.obscureText;

  @override
  void didUpdateWidget(AppTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.obscureText != widget.obscureText) {
      _obscure = widget.obscureText;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool hasError =
        widget.errorText != null && widget.errorText!.trim().isNotEmpty;

    return Opacity(
      opacity: widget.enabled ? 1 : 0.4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.label,
            style: AppTypography.small.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.contentSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Semantics(
            label: widget.label,
            child: TextField(
              controller: widget.controller,
              focusNode: widget.focusNode,
              enabled: widget.enabled,
              obscureText: _obscure,
              keyboardType: widget.keyboardType,
              textInputAction: widget.textInputAction,
              autofillHints: widget.autofillHints,
              inputFormatters: widget.inputFormatters,
              autocorrect: widget.autocorrect,
              enableSuggestions: widget.enableSuggestions,
              textCapitalization: widget.textCapitalization,
              onChanged: widget.onChanged,
              onSubmitted: widget.onSubmitted,
              onTapOutside: (_) => FocusScope.of(context).unfocus(),
              maxLines: widget.obscureText ? 1 : widget.maxLines,
              style: AppTypography.body.copyWith(
                color: AppColors.contentPrimary,
              ),
              decoration: InputDecoration(
                hintText: widget.hint,
                prefixIcon: widget.prefixIcon == null
                    ? null
                    : Icon(widget.prefixIcon),
                suffixIcon: widget.obscureText
                    ? IconButton(
                        tooltip: _obscure
                            ? AppStrings.showPassword
                            : AppStrings.hidePassword,
                        icon: Icon(
                          _obscure
                              ? Icons.visibility_rounded
                              : Icons.visibility_off_rounded,
                        ),
                        onPressed: () {
                          setState(() => _obscure = !_obscure);
                        },
                      )
                    : null,
                enabledBorder: hasError ? _border(AppColors.errorText) : null,
                focusedBorder: hasError
                    ? _border(AppColors.errorText)
                    : _border(AppColors.skyStrong),
                border: hasError ? _border(AppColors.errorText) : null,
              ),
            ),
          ),
          if (hasError) ...[
            const SizedBox(height: 6),
            Semantics(
              liveRegion: true,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 16,
                    color: AppColors.errorText,
                  ),
                  const SizedBox(width: AppSpacing.sp1),
                  Flexible(
                    child: Text(
                      widget.errorText!,
                      style: AppTypography.small.copyWith(
                        color: AppColors.errorText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else if (widget.helperText != null) ...[
            const SizedBox(height: 6),
            Text(
              widget.helperText!,
              style: AppTypography.small.copyWith(
                color: AppColors.contentTertiary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  OutlineInputBorder _border(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: BorderSide(color: color, width: 2),
    );
  }
}
