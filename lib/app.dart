import 'package:flutter/material.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

/// Punto de raíz de la aplicación "Amaguaña Alerta".
class AmaguanaAlertaApp extends StatelessWidget {
  const AmaguanaAlertaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Amaguaña Alerta',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: appRouter,
      // TODO: añadir localizationsDelegates para textos en español (ES-EC).
    );
  }
}
