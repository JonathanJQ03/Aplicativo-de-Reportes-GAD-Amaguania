import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../shared/widgets/app_button.dart';
import '../l10n/app_strings.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Pantalla para direcciones que no existen en la aplicación.
class NotFoundView extends StatelessWidget {
  const NotFoundView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.sp4),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const Icon(
                    Icons.explore_off_outlined,
                    size: 64,
                    color: AppColors.contentTertiary,
                  ),
                  const SizedBox(height: AppSpacing.sp3),
                  Semantics(
                    header: true,
                    child: Text(
                      AppStrings.notFoundTitle,
                      style: AppTypography.h2,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sp2),
                  Text(
                    AppStrings.notFoundBody,
                    style: AppTypography.body.copyWith(
                      color: AppColors.contentSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.sp5),
                  AppButton(
                    label: AppStrings.notFoundBack,
                    icon: Icons.home_outlined,
                    size: AppButtonSize.large,
                    expand: true,
                    onPressed: () => context.go('/'),
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
