import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Sombras de `DESIGN.md`, construidas sobre Azul Profundo.
abstract final class AppShadows {
  static const List<BoxShadow> elev1 = [
    BoxShadow(color: Color(0x1F1E3A5F), blurRadius: 3, offset: Offset(0, 1)),
  ];

  static const List<BoxShadow> elev2 = [
    BoxShadow(color: Color(0x291E3A5F), blurRadius: 12, offset: Offset(0, 4)),
  ];

  static const List<BoxShadow> elev3 = [
    BoxShadow(color: Color(0x331E3A5F), blurRadius: 24, offset: Offset(0, 8)),
  ];

  /// Anillo de foco para teclado y lector de pantalla.
  static const List<BoxShadow> focusRing = [
    BoxShadow(color: AppColors.focusRing, spreadRadius: 3),
  ];
}
