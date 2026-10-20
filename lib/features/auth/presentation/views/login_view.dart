import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/validators/validators.dart';
import '../../../../shared/widgets/app_banner.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../viewmodels/auth_viewmodel.dart';

/// Pantalla de inicio de sesión.
///
/// La vista solo conversa con [AuthViewModel]; la sesión y los errores se
/// gestionan en el ViewModel y la capa de datos.
class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
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

    if (!_validateFields()) {
      return;
    }

    final bool success = await auth.signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) {
      return;
    }
    if (success) {
      TextInput.finishAutofillContext();
    }
  }

  bool _validateFields() {
    final String? emailError = AppValidators.email(_emailController.text);
    final String? passwordError = AppValidators.loginPassword(
      _passwordController.text,
    );

    setState(() {
      _emailError = emailError;
      _passwordError = passwordError;
    });

    if (emailError != null) {
      _emailFocus.requestFocus();
      return false;
    }
    if (passwordError != null) {
      _passwordFocus.requestFocus();
      return false;
    }
    return true;
  }

  void _handleEmailSubmitted(String _) {
    final String? emailError = AppValidators.email(_emailController.text);
    setState(() {
      _emailError = emailError;
    });

    if (emailError != null) {
      _emailFocus.requestFocus();
      return;
    }
    _passwordFocus.requestFocus();
  }

  void _onEmailChanged(String _) {
    if (_emailError != null) {
      setState(() {
        _emailError = null;
      });
    }
    _clearAuthError();
  }

  void _onPasswordChanged(String _) {
    if (_passwordError != null) {
      setState(() {
        _passwordError = null;
      });
    }
    _clearAuthError();
  }

  void _clearAuthError() {
    final AuthViewModel auth = context.read<AuthViewModel>();
    if (auth.errorMessage != null) {
      auth.clearError();
    }
  }

  @override
  Widget build(BuildContext context) {
    final AuthViewModel auth = context.watch<AuthViewModel>();
    final String? error = auth.errorMessage;

    return Scaffold(
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
                  children: [
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
                            Icons.water_drop_rounded,
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
                        AppStrings.loginGreeting,
                        style: AppTypography.h1,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sp2),
                    Text(
                      AppStrings.loginSubtitle,
                      style: AppTypography.body.copyWith(
                        color: AppColors.contentSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.sp5),
                    if (error != null) ...[
                      AppBanner(message: error, type: AppBannerType.error),
                      const SizedBox(height: AppSpacing.sp4),
                    ],
                    AppTextField(
                      controller: _emailController,
                      focusNode: _emailFocus,
                      label: AppStrings.emailLabel,
                      hint: AppStrings.emailHint,
                      errorText: _emailError,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email],
                      autocorrect: false,
                      enableSuggestions: false,
                      onChanged: _onEmailChanged,
                      onSubmitted: _handleEmailSubmitted,
                    ),
                    const SizedBox(height: AppSpacing.sp4),
                    AppTextField(
                      controller: _passwordController,
                      focusNode: _passwordFocus,
                      label: AppStrings.passwordLabel,
                      hint: AppStrings.passwordHint,
                      errorText: _passwordError,
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.password],
                      autocorrect: false,
                      enableSuggestions: false,
                      onChanged: _onPasswordChanged,
                      onSubmitted: (_) => _submit(),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => context.go('/forgot-password'),
                        child: const Text(AppStrings.loginForgotPassword),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sp4),
                    AppButton(
                      label: AppStrings.signIn,
                      size: AppButtonSize.large,
                      expand: true,
                      isLoading: auth.isLoading,
                      onPressed: _submit,
                    ),
                    const SizedBox(height: AppSpacing.sp3),
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: <Widget>[
                        Text(
                          AppStrings.loginNoAccount,
                          style: AppTypography.body.copyWith(
                            color: AppColors.contentSecondary,
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.go('/register'),
                          child: const Text(AppStrings.loginGoToRegister),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sp4),
                    Text(
                      AppStrings.loginSupport,
                      style: AppTypography.small.copyWith(
                        color: AppColors.contentTertiary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.sp5),
                    Text(
                      AppStrings.gadName,
                      style: AppTypography.tiny.copyWith(
                        color: AppColors.contentTertiary,
                      ),
                      textAlign: TextAlign.center,
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
