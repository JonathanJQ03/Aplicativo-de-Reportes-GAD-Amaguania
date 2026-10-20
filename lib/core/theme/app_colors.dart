import 'package:flutter/material.dart';

/// Paleta de VeciApp definida en `DESIGN.md`.
///
/// Ningún widget debe declarar colores literales: todos se toman de estos
/// tokens.
abstract final class AppColors {
  // Marca.
  static const Color sol = Color(0xFFFFD84D);
  static const Color deepBlue = Color(0xFF1E3A5F);
  static const Color sky = Color(0xFFBAE6FD);
  static const Color skyStrong = Color(0xFF0369A1);

  // Superficies.
  static const Color background = Color(0xFFFFFFFF);
  static const Color surfaceSoft = Color(0xFFF0F9FF);
  static const Color surfaceSunken = Color(0xFFE0F2FE);
  static const Color overlay = Color(0x801E3A5F);
  static const Color transparent = Color(0x00000000);

  // Texto.
  static const Color contentPrimary = Color(0xFF1E293B);
  static const Color contentSecondary = Color(0xFF475569);
  static const Color contentTertiary = Color(0xFF64748B);
  static const Color contentOnSol = Color(0xFF1E3A5F);

  // Bordes.
  static const Color borderDefault = Color(0xFFE2E8F0);
  static const Color borderStrong = Color(0xFF7B8CA3);

  // Estados del reporte.
  static const Color statusPendingText = Color(0xFFB45309);
  static const Color statusPendingBackground = Color(0xFFFEF3C7);
  static const Color statusApprovedText = Color(0xFF0369A1);
  static const Color statusApprovedBackground = Color(0xFFE0F2FE);
  static const Color statusInAttentionText = Color(0xFF6D28D9);
  static const Color statusInAttentionBackground = Color(0xFFEDE9FE);
  static const Color statusResolvedText = Color(0xFF15803D);
  static const Color statusResolvedBackground = Color(0xFFDCFCE7);
  static const Color statusRejectedText = Color(0xFFB91C1C);
  static const Color statusRejectedBackground = Color(0xFFFEE2E2);
  static const Color statusSuspendedText = Color(0xFF475569);
  static const Color statusSuspendedBackground = Color(0xFFF1F5F9);

  // Tipos de reporte.
  static const Color typeLeakText = Color(0xFF0284C7);
  static const Color typeLeakBackground = Color(0xFFE0F2FE);
  static const Color typePetText = Color(0xFFC2410C);
  static const Color typePetBackground = Color(0xFFFFEDD5);

  // Semánticos.
  static const Color successText = Color(0xFF15803D);
  static const Color successBackground = Color(0xFFDCFCE7);
  static const Color warningText = Color(0xFFB45309);
  static const Color warningBackground = Color(0xFFFEF3C7);
  static const Color errorText = Color(0xFFB91C1C);
  static const Color errorBackground = Color(0xFFFEE2E2);
  static const Color infoText = Color(0xFF0369A1);
  static const Color infoBackground = Color(0xFFE0F2FE);

  // Interacción.
  static const Color solPressed = Color(0xFFF2C93F);
  static const Color skyPressed = Color(0x66BAE6FD);
  static const Color skyHover = Color(0x40BAE6FD);
  static const Color focusRing = Color(0x660369A1);
}
