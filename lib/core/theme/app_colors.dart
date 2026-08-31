import 'package:flutter/material.dart';

/// Design System — Método 1 Dia / LILY FIT (premium dark).
/// Fonte única de cores. Evite hex hardcoded nas telas.
class AppColors {
  AppColors._();

  // —— Fundos ——
  static const Color background = Color(0xFF050509);
  static const Color backgroundAlt = Color(0xFF07070B);
  static const Color surfaceDeep = Color(0xFF0B0B11);
  static const Color surface = Color(0xFF101016);
  static const Color surface2 = Color(0xFF13131A);
  static const Color surfaceElevated = Color(0xFF1A1A22);

  // —— Bordas ——
  static const Color border = Color(0xFF25252E);
  static const Color borderSoft = Color(0xFF1E1E28);

  // —— Marca ——
  static const Color secondary = Color(0xFFF52B8A); // Rosa principal
  static const Color hotPink = Color(0xFFFF3FA4); // Rosa secundário
  static const Color magenta = Color(0xFFC21870);
  static const Color primary = Color(0xFFA855F7); // Lilás
  static const Color primaryDark = Color(0xFF7C3AED); // Roxo
  static const Color accent = Color(0xFFC084FC);

  // —— Texto ——
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFA8A8B3);
  static const Color textTertiary = Color(0xFF6E6E7A);
  static const Color textOnPink = Color(0xFFFFFFFF);

  // —— Semânticas ——
  static const Color success = Color(0xFF7ED957);
  static const Color info = Color(0xFF38A9FF); // Água
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFFF604A); // Calorias / alerta
  static const Color calories = Color(0xFFFF604A);

  // Compat / aliases
  static const Color surfacePink = Color(0xFF1A1018);
  static const Color deepPurple = Color(0xFF12081C);
  static const Color softLilac = Color(0xFFA855F7);

  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryDark, primary],
  );

  static const LinearGradient vibeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondary, hotPink],
  );

  static const LinearGradient heroPinkGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF52B8A), Color(0xFFFF3FA4)],
  );

  static const LinearGradient softCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF13131A), Color(0xFF101016)],
  );

  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [background, Color(0xFF12081C), background],
    stops: [0.0, 0.55, 1.0],
  );

  /// Premium — rosa / lilás (sem amarelo de “ouro genérico”).
  static const LinearGradient premiumGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF52B8A), Color(0xFFA855F7), Color(0xFF7C3AED)],
    stops: [0.0, 0.55, 1.0],
  );

  /// Item selecionado no menu lateral — glow rosa/lilás.
  static const LinearGradient sidebarActiveGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0x66F52B8A), Color(0x44A855F7), Color(0x22F52B8A)],
  );
}
