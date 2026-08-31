import 'package:flutter/material.dart';

/// Paleta oficial do "Método 1 Dia de Cada Vez".
/// Cores da identidade visual definidas no PRD / Design System (MasterBook Vol.19):
///   Preto #111111 · Lilás #9B5DE5 · Roxo #5A189A · Rosa #F15BB5 · Verde #00C896
class AppColors {
  AppColors._();

  // Identidade da marca
  static const Color primary = Color(0xFF9B5DE5); // Lilás
  static const Color primaryDark = Color(0xFF5A189A); // Roxo
  static const Color secondary = Color(0xFFF15BB5); // Rosa
  static const Color accent = Color(0xFFC4A7F0);

  // Superfícies (dark premium)
  static const Color background = Color(0xFF111111);
  static const Color surface = Color(0xFF1C1B24);
  static const Color surface2 = Color(0xFF241F35);

  // Estados
  static const Color success = Color(0xFF00C896); // Verde progresso
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Texto
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFA1A1AA);
  static const Color textTertiary = Color(0xFF52525B);

  static const Color deepPurple = Color(0xFF1A0533);

  /// Gradiente principal da marca (logo, botões, destaques).
  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryDark, primary],
  );

  /// Rosa intenso (CTA / botões principais) — alinhado ao mockup premium.
  static const Color hotPink = Color(0xFFFF2D9A);

  /// Gradiente lilás → rosa (cards de destaque, Amanda).
  static const LinearGradient vibeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, secondary],
  );

  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [background, deepPurple, background],
    stops: [0.0, 0.6, 1.0],
  );

  static const LinearGradient premiumGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF59E0B), primaryDark],
  );

  /// Rosa intenso (variante mais saturada do [secondary]) para o cartão de
  /// "Meta do dia" — mesma família de cor da marca, só com mais peso visual.
  static const LinearGradient heroPinkGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF4377F), Color(0xFFC81F63)],
  );
}
