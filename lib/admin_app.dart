import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'core/l10n/app_strings.dart';
import 'core/router/admin_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/domain/auth_repository.dart';
import 'features/auth/presentation/viewmodels/auth_viewmodel.dart';

/// Raíz del panel de administración.
///
/// Comparte el tema, los textos y el [AuthViewModel] con la app móvil, pero
/// usa su propio router con guard de rol. El layout definitivo del panel se
/// construye en S15.
class AdminApp extends StatefulWidget {
  const AdminApp({super.key, required this.authRepository});

  final AuthRepository authRepository;

  @override
  State<AdminApp> createState() => _AdminAppState();
}

class _AdminAppState extends State<AdminApp> {
  late final AuthViewModel _authViewModel;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _authViewModel = AuthViewModel(repository: widget.authRepository);
    _router = createAdminRouter(_authViewModel);
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
        title: AppStrings.adminPanelTitle,
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
