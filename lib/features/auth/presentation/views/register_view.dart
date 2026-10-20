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
import '../../../../shared/widgets/app_checkbox.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../viewmodels/auth_viewmodel.dart';

/// Pantalla de registro de vecino.
///
/// La vista valida los campos con [AppValidators] y delega la creación de la
/// cuenta a [AuthViewModel]. La capa de datos guarda el perfil público y los
/// datos sensibles por separado.
class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final TextEditingController _namesController = TextEditingController();
  final TextEditingController _surnamesController = TextEditingController();
  final TextEditingController _cedulaController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FocusNode _namesFocus = FocusNode();
  final FocusNode _surnamesFocus = FocusNode();
  final FocusNode _cedulaFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  String? _namesError;
  String? _surnamesError;
  String? _cedulaError;
  String? _emailError;
  String? _phoneError;
  String? _passwordError;
  String? _consentError;
  bool _consentAccepted = false;
  final GlobalKey _consentKey = GlobalKey();

  @override
  void dispose() {
    _namesController.dispose();
    _surnamesController.dispose();
    _cedulaController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _namesFocus.dispose();
    _surnamesFocus.dispose();
    _cedulaFocus.dispose();
    _emailFocus.dispose();
    _phoneFocus.dispose();
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

    final String phone = _phoneController.text.trim();
    final bool success = await auth.signUp(
      nombres: _namesController.text.trim(),
      apellidos: _surnamesController.text.trim(),
      cedula: _cedulaController.text.trim(),
      email: _emailController.text.trim(),
      phone: phone.isEmpty ? null : phone,
      password: _passwordController.text,
      consentAccepted: _consentAccepted,
    );

    if (!mounted) {
      return;
    }
    if (success) {
      TextInput.finishAutofillContext();
    }
  }

  bool _validateFields() {
    final String? namesError = AppValidators.name(
      _namesController.text,
      requiredMessage: AppStrings.validationFirstNameRequired,
    );
    final String? surnamesError = AppValidators.name(
      _surnamesController.text,
      requiredMessage: AppStrings.validationLastNameRequired,
    );
    final String? cedulaError = AppValidators.cedula(_cedulaController.text);
    final String? emailError = AppValidators.email(_emailController.text);
    final String? phoneError = AppValidators.phoneOptional(
      _phoneController.text,
    );
    final String? passwordError = AppValidators.newPassword(
      _passwordController.text,
    );
    final String? consentError = _consentAccepted
        ? null
        : AppStrings.privacyConsentRequired;

    setState(() {
      _namesError = namesError;
      _surnamesError = surnamesError;
      _cedulaError = cedulaError;
      _emailError = emailError;
      _phoneError = phoneError;
      _passwordError = passwordError;
      _consentError = consentError;
    });

    final List<(FocusNode, String?)> fields = <(FocusNode, String?)>[
      (_namesFocus, namesError),
      (_surnamesFocus, surnamesError),
      (_cedulaFocus, cedulaError),
      (_emailFocus, emailError),
      (_phoneFocus, phoneError),
      (_passwordFocus, passwordError),
    ];
    for (final (focus, error) in fields) {
      if (error != null) {
        focus.requestFocus();
        return false;
      }
    }
    if (consentError != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final BuildContext? consentContext = _consentKey.currentContext;
        if (consentContext == null) {
          return;
        }
        Scrollable.ensureVisible(
          consentContext,
          duration: const Duration(milliseconds: 200),
          alignment: 0.9,
        );
      });
      return false;
    }
    return true;
  }

  void _onConsentChanged(bool accepted) {
    setState(() {
      _consentAccepted = accepted;
      if (accepted) {
        _consentError = null;
      }
    });
    _clearAuthError();
  }

  Future<void> _showPrivacyNotice() async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text(AppStrings.privacyNoticeTitle),
          scrollable: true,
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                AppStrings.privacyNoticeVersionLabel,
                style: AppTypography.small.copyWith(
                  color: AppColors.contentSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.sp3),
              Text(AppStrings.privacyNoticeBody, style: AppTypography.body),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text(AppStrings.privacyNoticeClose),
            ),
          ],
        );
      },
    );
  }

  void _clearFieldError(String? error, VoidCallback clear) {
    if (error != null) {
      setState(clear);
    }
    _clearAuthError();
  }

  void _clearAuthError() {
    final AuthViewModel auth = context.read<AuthViewModel>();
    if (auth.errorMessage != null) {
      auth.clearError();
    }
  }

  void _goToLogin() {
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final AuthViewModel auth = context.watch<AuthViewModel>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: AppStrings.backToLogin,
          onPressed: _goToLogin,
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text(AppStrings.registerScreenTitle),
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
              child: AutofillGroup(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Semantics(
                      header: true,
                      child: Text(
                        AppStrings.registerTitle,
                        style: AppTypography.h2,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sp2),
                    Text(
                      AppStrings.registerSubtitle,
                      style: AppTypography.body.copyWith(
                        color: AppColors.contentSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.sp4),
                    if (auth.errorMessage != null) ...[
                      AppBanner(
                        message: auth.errorMessage!,
                        type: AppBannerType.error,
                      ),
                      const SizedBox(height: AppSpacing.sp4),
                    ],
                    AppTextField(
                      controller: _namesController,
                      focusNode: _namesFocus,
                      label: AppStrings.firstNameLabel,
                      hint: AppStrings.firstNameHint,
                      errorText: _namesError,
                      keyboardType: TextInputType.name,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      autofillHints: const <String>[AutofillHints.givenName],
                      inputFormatters: <TextInputFormatter>[
                        LengthLimitingTextInputFormatter(60),
                      ],
                      onChanged: (_) => _clearFieldError(
                        _namesError,
                        () => _namesError = null,
                      ),
                      onSubmitted: (_) => _surnamesFocus.requestFocus(),
                    ),
                    const SizedBox(height: AppSpacing.sp3),
                    AppTextField(
                      controller: _surnamesController,
                      focusNode: _surnamesFocus,
                      label: AppStrings.lastNameLabel,
                      hint: AppStrings.lastNameHint,
                      errorText: _surnamesError,
                      keyboardType: TextInputType.name,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      autofillHints: const <String>[AutofillHints.familyName],
                      inputFormatters: <TextInputFormatter>[
                        LengthLimitingTextInputFormatter(60),
                      ],
                      onChanged: (_) => _clearFieldError(
                        _surnamesError,
                        () => _surnamesError = null,
                      ),
                      onSubmitted: (_) => _cedulaFocus.requestFocus(),
                    ),
                    const SizedBox(height: AppSpacing.sp3),
                    AppTextField(
                      controller: _cedulaController,
                      focusNode: _cedulaFocus,
                      label: AppStrings.cedulaLabel,
                      hint: AppStrings.cedulaHint,
                      errorText: _cedulaError,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                      onChanged: (_) => _clearFieldError(
                        _cedulaError,
                        () => _cedulaError = null,
                      ),
                      onSubmitted: (_) => _emailFocus.requestFocus(),
                    ),
                    const SizedBox(height: AppSpacing.sp3),
                    AppTextField(
                      controller: _emailController,
                      focusNode: _emailFocus,
                      label: AppStrings.emailLabel,
                      hint: AppStrings.emailHint,
                      errorText: _emailError,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const <String>[AutofillHints.email],
                      autocorrect: false,
                      enableSuggestions: false,
                      onChanged: (_) => _clearFieldError(
                        _emailError,
                        () => _emailError = null,
                      ),
                      onSubmitted: (_) => _phoneFocus.requestFocus(),
                    ),
                    const SizedBox(height: AppSpacing.sp3),
                    AppTextField(
                      controller: _phoneController,
                      focusNode: _phoneFocus,
                      label: AppStrings.phoneLabel,
                      hint: AppStrings.phoneHint,
                      errorText: _phoneError,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      autofillHints: const <String>[
                        AutofillHints.telephoneNumber,
                      ],
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                      onChanged: (_) => _clearFieldError(
                        _phoneError,
                        () => _phoneError = null,
                      ),
                      onSubmitted: (_) => _passwordFocus.requestFocus(),
                    ),
                    const SizedBox(height: AppSpacing.sp3),
                    AppTextField(
                      controller: _passwordController,
                      focusNode: _passwordFocus,
                      label: AppStrings.passwordLabel,
                      hint: AppStrings.passwordHint,
                      helperText: AppStrings.registerPasswordHelper,
                      errorText: _passwordError,
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      autofillHints: const <String>[AutofillHints.newPassword],
                      autocorrect: false,
                      enableSuggestions: false,
                      onChanged: (_) => _clearFieldError(
                        _passwordError,
                        () => _passwordError = null,
                      ),
                      onSubmitted: (_) => _submit(),
                    ),
                    const SizedBox(height: AppSpacing.sp3),
                    AppCheckbox(
                      key: _consentKey,
                      value: _consentAccepted,
                      onChanged: _onConsentChanged,
                      label: AppStrings.privacyConsentLabel,
                      errorText: _consentError,
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: _showPrivacyNotice,
                        child: const Text(AppStrings.privacyNoticeOpen),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sp2),
                    AppButton(
                      label: AppStrings.registerButton,
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
                          AppStrings.registerHaveAccount,
                          style: AppTypography.body.copyWith(
                            color: AppColors.contentSecondary,
                          ),
                        ),
                        TextButton(
                          onPressed: _goToLogin,
                          child: const Text(AppStrings.registerGoToLogin),
                        ),
                      ],
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
