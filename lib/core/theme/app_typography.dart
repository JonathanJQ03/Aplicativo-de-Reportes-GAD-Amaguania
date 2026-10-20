import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Escala tipográfica de `DESIGN.md`.
///
/// Nunito se usa en títulos y Nunito Sans en cuerpo y etiquetas.
abstract final class AppTypography {
  static const String headlineFont = 'Nunito';
  static const String bodyFont = 'NunitoSans';

  static const TextStyle h1 = TextStyle(
    fontFamily: headlineFont,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.2,
    color: AppColors.contentPrimary,
  );

  static const TextStyle h2 = TextStyle(
    fontFamily: headlineFont,
    fontSize: 26,
    fontWeight: FontWeight.w700,
    height: 1.25,
    color: AppColors.contentPrimary,
  );

  static const TextStyle h3 = TextStyle(
    fontFamily: headlineFont,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: AppColors.contentPrimary,
  );

  static const TextStyle h4 = TextStyle(
    fontFamily: headlineFont,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.35,
    color: AppColors.contentPrimary,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: bodyFont,
    fontSize: 18,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.contentPrimary,
  );

  static const TextStyle body = TextStyle(
    fontFamily: bodyFont,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.contentPrimary,
  );

  static const TextStyle small = TextStyle(
    fontFamily: bodyFont,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.contentPrimary,
  );

  static const TextStyle tiny = TextStyle(
    fontFamily: bodyFont,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: AppColors.contentPrimary,
  );

  static const TextTheme textTheme = TextTheme(
    displayLarge: h1,
    displayMedium: h1,
    displaySmall: h2,
    headlineLarge: h1,
    headlineMedium: h2,
    headlineSmall: h3,
    titleLarge: h3,
    titleMedium: h4,
    titleSmall: h4,
    bodyLarge: bodyLarge,
    bodyMedium: body,
    bodySmall: small,
    labelLarge: body,
    labelMedium: small,
    labelSmall: tiny,
  );
}
