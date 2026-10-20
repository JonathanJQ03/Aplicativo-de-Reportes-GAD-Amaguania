import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/validators/validators.dart';
import '../../../../shared/widgets/app_banner.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../viewmodels/auth_viewmodel.dart';

/// Pantalla que bloquea el acceso hasta confirmar el correo electrónico.
///
/// Firebase envía un enlace al correo registrado. La pantalla permite
/// reenviarlo, cambiar la dirección y volver a comprobar el estado al regresar
/// desde el navegador.
class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed || !mounted) {
      return;
    }
    final AuthViewModel auth = context.read<AuthViewModel>();
    if (!auth.isLoading) {
      unawaited(auth.refreshUser());
    }
  }

  Future<void> _checkVerification() async {
    final AuthViewModel auth = context.read<AuthViewModel>();
    await auth.refreshUser();
  }

  Future<void> _resend() async {
    final AuthViewModel auth = context.read<AuthViewModel>();
    await auth.resendVerificationEmail();
  }

  Future<void> _changeEmail() async {
    final AuthViewModel auth = context.read<AuthViewModel>();
    final String? newEmail = await showDialog<String>(
      context: context,
      builder: (dialogContext) =>
          _ChangeEmailDialog(currentEmail: auth.currentUser?.email ?? ''),
    );
    if (newEmail == null || !mounted) {
      return;
    }
    await auth.requestEmailChange(newEmail);
  }

  Future<void> _cancel() async {
    final AuthViewModel auth = context.read<AuthViewModel>();
    await auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final AuthViewModel auth = context.watch<AuthViewModel>();
    final String email = auth.currentUser?.email ?? '';
    final String? error = auth.errorMessage;
    final String? info = auth.infoMessage;
    final String? pendingEmail = auth.pendingEmail;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.verifyEmailScreenTitle),
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
              child: Column(
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
                        Icons.mark_email_unread_outlined,
                        size: 44,
                        color: AppColors.skyStrong,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sp4),
                  Semantics(
                    header: true,
                    child: Text(
                      AppStrings.verifyEmailTitle,
                      style: AppTypography.h2,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sp2),
                  Text(
                    AppStrings.verifyEmailBody,
                    style: AppTypography.body.copyWith(
                      color: AppColors.contentSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (auth.autoVerifyEmail) ...[
                    const SizedBox(height: AppSpacing.sp4),
                    const AppBanner(
                      message: AppStrings.verifyEmailDevelopmentNotice,
                      type: AppBannerType.warning,
                    ),
                  ],
                  const SizedBox(height: AppSpacing.sp4),
                  _EmailCard(email: email),
                  if (pendingEmail != null) ...[
                    const SizedBox(height: AppSpacing.sp3),
                    _PendingEmailCard(email: pendingEmail),
                  ],
                  if (error != null) ...[
                    const SizedBox(height: AppSpacing.sp4),
                    AppBanner(message: error, type: AppBannerType.error),
                  ] else if (info != null) ...[
                    const SizedBox(height: AppSpacing.sp4),
                    AppBanner(message: info, type: AppBannerType.info),
                  ],
                  const SizedBox(height: AppSpacing.sp5),
                  AppButton(
                    label: AppStrings.verifyEmailCheckButton,
                    icon: Icons.mark_email_read_outlined,
                    expand: true,
                    size: AppButtonSize.large,
                    isLoading: auth.isLoading,
                    onPressed: auth.isLoading ? null : _checkVerification,
                  ),
                  const SizedBox(height: AppSpacing.sp3),
                  AppButton(
                    label: AppStrings.verifyEmailResendButton,
                    icon: Icons.send_outlined,
                    variant: AppButtonVariant.secondary,
                    expand: true,
                    onPressed: auth.isLoading ? null : _resend,
                  ),
                  const SizedBox(height: AppSpacing.sp2),
                  AppButton(
                    label: AppStrings.verifyEmailChangeButton,
                    icon: Icons.edit_outlined,
                    variant: AppButtonVariant.ghost,
                    expand: true,
                    onPressed: auth.isLoading ? null : _changeEmail,
                  ),
                  const SizedBox(height: AppSpacing.sp2),
                  Text(
                    AppStrings.verifyEmailSpamHint,
                    style: AppTypography.small.copyWith(
                      color: AppColors.contentTertiary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.sp4),
                  AppButton(
                    label: AppStrings.verifyEmailCancelButton,
                    variant: AppButtonVariant.ghost,
                    expand: true,
                    onPressed: auth.isLoading ? null : _cancel,
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

/// Tarjeta con el correo que Firebase tiene registrado actualmente.
class _EmailCard extends StatelessWidget {
  const _EmailCard({required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sp3),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            AppStrings.verifyEmailCurrentEmailLabel,
            style: AppTypography.small.copyWith(
              color: AppColors.contentSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sp1),
          Text(
            email,
            style: AppTypography.h4.copyWith(color: AppColors.skyStrong),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Aviso del correo nuevo que está pendiente de verificación.
class _PendingEmailCard extends StatelessWidget {
  const _PendingEmailCard({required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sp3),
      decoration: BoxDecoration(
        color: AppColors.warningBackground,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            AppStrings.verifyEmailChangePendingPrefix,
            style: AppTypography.small.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.warningText,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sp1),
          Text(
            email,
            style: AppTypography.body.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.warningText,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sp1),
          Text(
            AppStrings.verifyEmailChangePendingBody,
            style: AppTypography.small.copyWith(color: AppColors.warningText),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Diálogo para pedir la nueva dirección de correo.
class _ChangeEmailDialog extends StatefulWidget {
  const _ChangeEmailDialog({required this.currentEmail});

  final String currentEmail;

  @override
  State<_ChangeEmailDialog> createState() => _ChangeEmailDialogState();
}

class _ChangeEmailDialogState extends State<_ChangeEmailDialog> {
  final TextEditingController _controller = TextEditingController();
  String? _errorText;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final String email = _controller.text.trim();
    final String? validation = AppValidators.email(email);
    if (validation != null) {
      setState(() => _errorText = validation);
      return;
    }
    if (email.toLowerCase() == widget.currentEmail.trim().toLowerCase()) {
      setState(() => _errorText = AppStrings.verifyEmailChangeSame);
      return;
    }
    Navigator.of(context).pop(email);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppStrings.verifyEmailChangeTitle, style: AppTypography.h3),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              AppStrings.verifyEmailChangeBody,
              style: AppTypography.body.copyWith(
                color: AppColors.contentSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.sp3),
            AppTextField(
              controller: _controller,
              label: AppStrings.emailLabel,
              hint: AppStrings.emailHint,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              autofillHints: const <String>[AutofillHints.email],
              autocorrect: false,
              enableSuggestions: false,
              errorText: _errorText,
              onChanged: (_) {
                if (_errorText != null) {
                  setState(() => _errorText = null);
                }
              },
              onSubmitted: (_) => _submit(),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        AppButton(
          label: AppStrings.verifyEmailChangeCancel,
          variant: AppButtonVariant.ghost,
          onPressed: () => Navigator.of(context).pop(),
        ),
        AppButton(
          label: AppStrings.verifyEmailChangeSubmit,
          onPressed: _submit,
        ),
      ],
    );
  }
}
