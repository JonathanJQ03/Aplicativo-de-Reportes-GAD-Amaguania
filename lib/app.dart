import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'core/l10n/app_strings.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/domain/auth_repository.dart';
import 'features/auth/presentation/viewmodels/auth_viewmodel.dart';

/// Raíz de VeciApp.
///
/// Recibe el repositorio de autenticación para poder probar la app con un
/// doble en memoria sin inicializar Firebase.
class VeciApp extends StatefulWidget {
  const VeciApp({
    super.key,
    required this.authRepository,
    this.autoVerifyEmail = false,
  });

  final AuthRepository authRepository;

  /// Modo temporal de desarrollo para no bloquear la app mientras se conecta
  /// un proyecto real de Firebase y se implementa la verificación definitiva.
  final bool autoVerifyEmail;

  @override
  State<VeciApp> createState() => _VeciAppState();
}

class _VeciAppState extends State<VeciApp> {
  late final AuthViewModel _authViewModel;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _authViewModel = AuthViewModel(
      repository: widget.authRepository,
      autoVerifyEmail: widget.autoVerifyEmail,
    );
    _router = createAppRouter(_authViewModel);
  }

  @override
  void dispose() {
    _router.dispose();
    _authViewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AuthViewModel>.value(
      value: _authViewModel,
      child: MaterialApp.router(
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        themeMode: ThemeMode.light,
        locale: const Locale('es', 'EC'),
        supportedLocales: const [Locale('es', 'EC')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        routerConfig: _router,
      ),
    );
  }
}
