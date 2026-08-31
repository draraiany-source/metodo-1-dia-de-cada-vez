import 'package:flutter/material.dart';

/// Paleta oficial — Método 1 Dia / Lily Fit.
/// Tema **dark premium**: preto profundo + rosa + lilás (branco só para contraste).
class AppColors {
  AppColors._();

  // Identidade
  static const Color secondary = Color(0xFFFF6BCB); // Rosa
  static const Color primary = Color(0xFFB26BFF); // Lilás
  static const Color primaryDark = Color(0xFF6D3CCB); // Roxo
  static const Color accent = Color(0xFFC9A7F5);
  static const Color hotPink = Color(0xFFFF6BCB);

  // Superfícies escuras
  static const Color background = Color(0xFF0E0E12);
  static const Color surface = Color(0xFF1A1822);
  static const Color surface2 = Color(0xFF241F30);
  static const Color surfacePink = Color(0xFF2A1528);
  static const Color border = Color(0xFF2E2940);

  // Estados
  static const Color success = Color(0xFF00C896);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);
  static const Color info = Color(0xFF5B8DEF);

  // Texto
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0A8C0);
  static const Color textTertiary = Color(0xFF6E6780);
  static const Color textOnPink = Color(0xFFFFFFFF);

  static const Color deepPurple = Color(0xFF1A0533);

  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryDark, primary],
  );

  static const LinearGradient vibeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, secondary],
  );

  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [background, deepPurple, background],
    stops: [0.0, 0.55, 1.0],
  );

  static const LinearGradient premiumGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF59E0B), primaryDark],
  );

  static const LinearGradient heroPinkGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF6BCB), Color(0xFFE84DB0)],
  );

  static const LinearGradient softCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF241530), Color(0xFF1A1822)],
  );
}
