import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Sombras para tema dark premium.
class AppShadows {
  AppShadows._();

  static List<BoxShadow> get card => [
        BoxShadow(
          color: Colors.black.withOpacity(0.45),
          blurRadius: 22,
          offset: const Offset(0, 10),
        ),
      ];

  static List<BoxShadow> get soft => [
        BoxShadow(
          color: Colors.black.withOpacity(0.28),
          blurRadius: 14,
          offset: const Offset(0, 6),
        ),
      ];

  static List<BoxShadow> get glowPurple => [
        BoxShadow(
          color: AppColors.primary.withOpacity(0.35),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> get glowPink => [
        BoxShadow(
          color: AppColors.secondary.withOpacity(0.35),
          blurRadius: 22,
          offset: const Offset(0, 8),
        ),
      ];
}
