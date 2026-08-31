import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Gradientes oficiais reutilizáveis.
class AppGradients {
  AppGradients._();

  static const LinearGradient brand = AppColors.brandGradient;
  static const LinearGradient vibe = AppColors.vibeGradient;
  static const LinearGradient premium = AppColors.premiumGradient;
  static const LinearGradient splash = AppColors.splashGradient;
  static const LinearGradient heroPink = AppColors.heroPinkGradient;

  static const LinearGradient success = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF7ED957), Color(0xFF4CAF50)],
  );

  static const LinearGradient glass = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x22FFFFFF), Color(0x05FFFFFF)],
  );
}
