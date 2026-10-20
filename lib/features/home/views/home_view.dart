import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/l10n/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/app_button.dart';
import '../../auth/presentation/viewmodels/auth_viewmodel.dart';

/// Pantalla principal.
///
/// En S01 solo confirma la sesión y permite cerrarla. El mapa, la lista y los
/// filtros se construyen en S08 y S18.
class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthViewModel auth = context.watch<AuthViewModel>();
    final String? email = auth.currentUser?.email;

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.homeTitle)),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenHorizontal,
              vertical: AppSpacing.sp4,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.sp4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSoft,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(color: AppColors.borderDefault),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      size: 56,
                      color: AppColors.successText,
                    ),
                    const SizedBox(height: AppSpacing.sp3),
                    Semantics(
                      header: true,
                      child: Text(
                        AppStrings.homeSessionTitle,
                        style: AppTypography.h2,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sp2),
                    Text(
                      AppStrings.homeSessionBody,
                      style: AppTypography.body.copyWith(
                        color: AppColors.contentSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (email != null && email.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.sp3),
                      Text(
                        email,
                        style: AppTypography.small.copyWith(
                          color: AppColors.contentTertiary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const SizedBox(height: AppSpacing.sp5),
                    AppButton(
                      label: AppStrings.signOut,
                      icon: Icons.logout_rounded,
                      variant: AppButtonVariant.secondary,
                      expand: true,
                      isLoading: auth.isLoading,
                      onPressed: auth.signOut,
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
