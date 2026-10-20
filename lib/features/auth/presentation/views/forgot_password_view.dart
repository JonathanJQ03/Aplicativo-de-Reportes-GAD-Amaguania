import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/router/route_guards.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/validators/validators.dart';
import '../../../../shared/widgets/app_banner.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../viewmodels/auth_viewmodel.dart';

/// Pantalla para solicitar el enlace de recuperación de contraseña.
///
/// El enlace lo envía Firebase al correo registrado y el usuario crea la nueva
/// contraseña en el navegador. La app no muestra si el correo existe.
class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key, this.backRoute = AppRoutes.login});

  /// Ruta a la que vuelve el botón de regreso.
  ///
  /// El login de administración usa [AppRoutes.adminLogin] para no llevar al
  /// usuario al login de vecinos.
  final String backRoute;

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final TextEditingController _emailController = TextEditingController();
  final FocusNode _emailFocus = FocusNode();
  String? _emailError;

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final AuthViewModel auth = context.read<AuthViewModel>();
    if (auth.isLoading) {
      return;
    }

    FocusScope.of(context).unfocus();
    if (auth.errorMessage != null) {
      auth.clearError();
    }

    final String? emailError = AppValidators.email(_emailController.text);
    setState(() {
      _emailError = emailError;
    });
    if (emailError != null) {
      _emailFocus.requestFocus();
      return;
    }

    final bool success = await auth.requestPasswordReset(
      _emailController.text.trim(),
    );
    if (!mounted) {
      return;
    }
    if (success) {
      TextInput.finishAutofillContext();
    }
  }

  void _onEmailChanged(String _) {
    if (_emailError != null) {
      setState(() {
        _emailError = null;
      });
    }
    final AuthViewModel auth = context.read<AuthViewModel>();
    if (auth.passwordResetSent || auth.errorMessage != null) {
      auth.clearPasswordResetState();
    }
  }

  void _goToLogin() {
    context.go(widget.backRoute);
  }

  @override
  Widget build(BuildContext context) {
    final AuthViewModel auth = context.watch<AuthViewModel>();
    final String? error = auth.errorMessage;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: AppStrings.backToLogin,
          onPressed: _goToLogin,
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text(AppStrings.forgotPasswordTitle),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenHorizontal,
              vertical: AppSpacing.sp4,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: AutofillGroup(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Center(
                      child: ExcludeSemantics(
                        child: Container(
                          width: 88,
                          height: 88,
                          decoration: const BoxDecoration(
                            color: AppColors.sky,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.lock_reset_rounded,
                            size: 44,
                            color: AppColors.skyStrong,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sp4),
                    Semantics(
                      header: true,
                      child: Text(
                        AppStrings.forgotPasswordHeading,
                        style: AppTypography.h2,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sp2),
                    Text(
                      AppStrings.forgotPasswordBody,
                      style: AppTypography.body.copyWith(
                        color: AppColors.contentSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.sp4),
                    if (error != null) ...[
                      AppBanner(message: error, type: AppBannerType.error),
                      const SizedBox(height: AppSpacing.sp3),
                    ],
                    if (auth.passwordResetSent) ...[
                      const AppBanner(
                        message: AppStrings.forgotPasswordSent,
                        type: AppBannerType.success,
                      ),
                      const SizedBox(height: AppSpacing.sp3),
                    ],
                    AppTextField(
                      controller: _emailController,
                      focusNode: _emailFocus,
                      label: AppStrings.emailLabel,
                      hint: AppStrings.emailHint,
                      errorText: _emailError,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.done,
                      autofillHints: const <String>[AutofillHints.email],
                      autocorrect: false,
                      enableSuggestions: false,
                      prefixIcon: Icons.mail_outline_rounded,
                      onChanged: _onEmailChanged,
                      onSubmitted: (_) => _submit(),
                    ),
                    const SizedBox(height: AppSpacing.sp4),
                    AppButton(
                      label: AppStrings.forgotPasswordButton,
                      size: AppButtonSize.large,
                      expand: true,
                      isLoading: auth.isLoading,
                      onPressed: _submit,
                    ),
                    const SizedBox(height: AppSpacing.sp3),
                    TextButton(
                      onPressed: _goToLogin,
                      child: const Text(AppStrings.forgotPasswordBack),
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
