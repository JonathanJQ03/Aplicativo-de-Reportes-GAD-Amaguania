import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../auth/presentation/viewmodels/auth_viewmodel.dart';

/// Marcador del panel de administración para S07.
///
/// La navegación lateral, la bandeja y la moderación se construyen en S15.
/// Aquí solo se comprueba que el rol correcto llegó al panel.
class AdminHomeView extends StatelessWidget {
  const AdminHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthViewModel auth = context.watch<AuthViewModel>();
    final String? email = auth.currentUser?.email;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.adminPanelTitle),
        automaticallyImplyLeading: false,
      ),
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
                  children: <Widget>[
                    Center(
                      child: Container(
                        width: 88,
                        height: 88,
                        decoration: const BoxDecoration(
                          color: AppColors.sky,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.admin_panel_settings_outlined,
                          size: 44,
                          color: AppColors.skyStrong,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sp4),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sp3,
                          vertical: AppSpacing.sp1,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.sky,
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                        child: Text(
                          AppStrings.adminRoleName,
                          style: AppTypography.tiny.copyWith(
                            color: AppColors.deepBlue,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sp3),
                    Semantics(
                      header: true,
                      child: Text(
                        AppStrings.adminPanelPreparingTitle,
                        style: AppTypography.h2,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sp2),
                    Text(
                      AppStrings.adminPanelPreparingBody,
                      style: AppTypography.body.copyWith(
                        color: AppColors.contentSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (email != null && email.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.sp4),
                      Text(
                        AppStrings.adminSessionLabel,
                        style: AppTypography.small.copyWith(
                          color: AppColors.contentTertiary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        email,
                        style: AppTypography.small.copyWith(
                          color: AppColors.contentSecondary,
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
