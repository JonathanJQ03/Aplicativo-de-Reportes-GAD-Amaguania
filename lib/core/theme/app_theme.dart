import 'package:flutter/material.dart';

import '../../models/report_status.dart';

/// Paleta de colores de "Amaguaña Alerta".
///
/// TODO: afinar los tonos exactos si el GAD de Amaguaña entrega el
/// diseño gráfico oficial (brand guide).
class AppColors {
  AppColors._();

  // Colores generales.
  /// Amarillo pastel: color primario y de los botones principales.
  static const Color primary = Color(0xFFF6CF4A);

  /// Celeste pastel: fondos suaves y superficies secundarias.
  static const Color secondary = Color(0xFFD9EEFA);

  /// Celeste más saturado: bordes y campos de texto.
  static const Color secondaryStrong = Color(0xFF7FB6D9);

  /// Fondo general de la app.
  static const Color background = Colors.white;

  /// Color de texto principal (oscuro, buen contraste sobre blanco).
  static const Color textDark = Color(0xFF1F2A37);

  // Colores de estado de un reporte.
  /// Pendiente: amarillo.
  static const Color statusPending = primary;

  /// Aprobado: verde suave.
  static const Color statusApproved = Color(0xFFA9D6A4);

  /// En atención: celeste.
  static const Color statusInProgress = secondaryStrong;

  /// Resuelto: gris azulado.
  static const Color statusResolved = Color(0xFF93A9BF);

  /// Rechazado: rojo suave.
  static const Color statusRejected = Color(0xFFF0A9A2);

  /// Devuelve el color asociado a cada [ReportStatus].
  static Color statusColor(ReportStatus status) => switch (status) {
    ReportStatus.pendiente => statusPending,
    ReportStatus.aprobado => statusApproved,
    ReportStatus.enAtencion => statusInProgress,
    ReportStatus.resuelto => statusResolved,
    ReportStatus.rechazado => statusRejected,
  };
}

/// Tema Material 3 de la aplicación.
///
/// Reglas aplicadas: esquinas redondeadas de 8 px, tamaño táctil mínimo de
/// 44 px y contraste alto entre fondo y texto.
class AppTheme {
  AppTheme._();

  /// Radio de esquina estándar para botones, campos y tarjetas.
  static const double cornerRadius = 8;

  /// Tamaño táctil mínimo recomendado (altura de botones y campos).
  static const double minTouchTarget = 44;

  /// Tema claro (único soportado por ahora).
  static ThemeData get light {
    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      // Texto oscuro sobre amarillo: buen contraste (no blanco sobre amarillo).
      onPrimary: AppColors.textDark,
      secondary: AppColors.secondary,
      onSecondary: AppColors.textDark,
      surface: AppColors.background,
      onSurface: AppColors.textDark,
      error: AppColors.statusRejected,
      onError: AppColors.textDark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.background,
      // TODO: definir la fuente oficial del GAD si se entrega un brand guide.
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textDark,
        elevation: 0,
        centerTitle: true,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.background,
        // Padding que garantiza un alto táctil mínimo de 44 px.
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: _border(),
        enabledBorder: _border(),
        focusedBorder: _border(color: AppColors.secondaryStrong, width: 2),
        errorBorder: _border(color: scheme.error),
        focusedErrorBorder: _border(color: scheme.error, width: 2),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textDark,
          minimumSize: const Size(minTouchTarget, 48),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(cornerRadius),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textDark,
          minimumSize: const Size(minTouchTarget, 48),
          side: const BorderSide(color: AppColors.secondaryStrong),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(cornerRadius),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.textDark,
          minimumSize: const Size(minTouchTarget, minTouchTarget),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.background,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cornerRadius),
          side: const BorderSide(color: AppColors.secondaryStrong),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.secondary,
        selectedColor: AppColors.primary,
        labelStyle: const TextStyle(color: AppColors.textDark),
        side: const BorderSide(color: AppColors.secondaryStrong),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cornerRadius),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textDark,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.textDark,
        contentTextStyle: const TextStyle(color: AppColors.background),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cornerRadius),
        ),
      ),
    );
  }

  static OutlineInputBorder _border({Color? color, double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(cornerRadius),
      borderSide: BorderSide(
        color: color ?? AppColors.secondaryStrong,
        width: width,
      ),
    );
  }
}
