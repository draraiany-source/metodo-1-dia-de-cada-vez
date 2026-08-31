import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Tema global do app — dark mode premium, tipografia Poppins (títulos)
/// e Inter (corpo), replicando o protótipo visual.
class AppTheme {
  AppTheme._();

  static const double radius = 20;
  static const double radiusSm = 12;

  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);

    final textTheme = GoogleFonts.interTextTheme(base.textTheme).copyWith(
      // Refinamento tipográfico premium:
      //  - títulos com letterSpacing levemente negativo (padrão de apps de topo)
      //  - corpo com height 1.45 para respiro e legibilidade
      displayLarge: GoogleFonts.poppins(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.8,
          height: 1.15,
          color: AppColors.textPrimary),
      displayMedium: GoogleFonts.poppins(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.6,
          height: 1.18,
          color: AppColors.textPrimary),
      headlineMedium: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          letterSpacing: -0.4,
          height: 1.2,
          color: AppColors.textPrimary),
      titleLarge: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
          height: 1.25,
          color: AppColors.textPrimary),
      titleMedium: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          letterSpacing: -0.1,
          height: 1.3,
          color: AppColors.textPrimary),
      bodyLarge: GoogleFonts.inter(
          height: 1.45, color: AppColors.textPrimary),
      bodyMedium: GoogleFonts.inter(
          height: 1.45, color: AppColors.textPrimary),
      bodySmall: GoogleFonts.inter(
          height: 1.4, color: AppColors.textSecondary),
    ).apply(
      bodyColor: AppColors.textPrimary,
      displayColor: AppColors.textPrimary,
    );

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.primary,
      textTheme: textTheme,
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
        error: AppColors.danger,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          textStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w600, fontSize: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSm),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        hintStyle: const TextStyle(color: AppColors.textSecondary),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: BorderSide(
            color: AppColors.primary.withOpacity(0.2),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.secondary,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.primary,
        labelStyle: const TextStyle(color: AppColors.textPrimary),
      ),
      dividerColor: Colors.white10,
    );
  }
}
