import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Gradientes oficiais reutilizáveis.
class AppGradients {
  AppGradients._();

  static const LinearGradient brand = AppColors.brandGradient;   // roxo -> lilás
  static const LinearGradient vibe = AppColors.vibeGradient;     // lilás -> rosa
  static const LinearGradient premium = AppColors.premiumGradient;
  static const LinearGradient splash = AppColors.splashGradient;

  static const LinearGradient success = LinearGradient(
    begin: Alignment.topLeft, end: Alignment.bottomRight,
    colors: [Color(0xFF00C896), Color(0xFF0A8F6E)],
  );

  static const LinearGradient glass = LinearGradient(
    begin: Alignment.topLeft, end: Alignment.bottomRight,
    colors: [Color(0x22FFFFFF), Color(0x05FFFFFF)],
  );
}
