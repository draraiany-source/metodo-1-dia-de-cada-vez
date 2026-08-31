import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Sombras padronizadas (elevação suave + glow roxo premium).
class AppShadows {
  AppShadows._();

  static List<BoxShadow> get card => [
        BoxShadow(
          color: Colors.black.withOpacity(0.35),
          blurRadius: 18,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> get glowPurple => [
        BoxShadow(
          color: AppColors.primary.withOpacity(0.45),
          blurRadius: 30,
          spreadRadius: 2,
        ),
      ];

  static List<BoxShadow> get glowPink => [
        BoxShadow(
          color: AppColors.secondary.withOpacity(0.40),
          blurRadius: 26,
          spreadRadius: 1,
        ),
      ];
}
