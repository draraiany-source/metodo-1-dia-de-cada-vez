import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Tipografia premium — Poppins (títulos) + Inter (corpo).
class AppTextStyles {
  AppTextStyles._();

  static TextStyle display({Color? color, double size = 36}) =>
      GoogleFonts.poppins(
        fontWeight: FontWeight.w800,
        fontSize: size,
        height: 1.1,
        letterSpacing: -0.8,
        color: color ?? AppColors.textPrimary,
      );

  static TextStyle h1({Color? color}) => GoogleFonts.poppins(
        fontWeight: FontWeight.w800,
        fontSize: 28,
        height: 1.15,
        letterSpacing: -0.5,
        color: color ?? AppColors.textPrimary,
      );

  static TextStyle h2({Color? color}) => GoogleFonts.poppins(
        fontWeight: FontWeight.w700,
        fontSize: 22,
        height: 1.2,
        letterSpacing: -0.3,
        color: color ?? AppColors.textPrimary,
      );

  static TextStyle h3({Color? color}) => GoogleFonts.poppins(
        fontWeight: FontWeight.w700,
        fontSize: 18,
        height: 1.25,
        color: color ?? AppColors.textPrimary,
      );

  static TextStyle title({Color? color}) => GoogleFonts.poppins(
        fontWeight: FontWeight.w700,
        fontSize: 16,
        height: 1.3,
        color: color ?? AppColors.textPrimary,
      );

  static TextStyle body({Color? color}) => GoogleFonts.inter(
        fontWeight: FontWeight.w500,
        fontSize: 14,
        height: 1.45,
        color: color ?? AppColors.textPrimary,
      );

  static TextStyle bodySecondary({Color? color}) => GoogleFonts.inter(
        fontWeight: FontWeight.w500,
        fontSize: 13,
        height: 1.4,
        color: color ?? AppColors.textSecondary,
      );

  static TextStyle caption({Color? color}) => GoogleFonts.inter(
        fontWeight: FontWeight.w500,
        fontSize: 12,
        height: 1.35,
        color: color ?? AppColors.textSecondary,
      );

  static TextStyle button({Color? color}) => GoogleFonts.poppins(
        fontWeight: FontWeight.w700,
        fontSize: 15,
        height: 1.2,
        color: color ?? Colors.white,
      );
}

/// Tema dark premium global.
class AppTheme {
  AppTheme._();

  static const double radius = 20;
  static const double radiusSm = 14;
  static const double radiusLg = 24;

  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);
    final textTheme = GoogleFonts.interTextTheme(base.textTheme).copyWith(
      displayLarge: AppTextStyles.display(size: 40),
      displayMedium: AppTextStyles.display(size: 32),
      headlineMedium: AppTextStyles.h2(),
      titleLarge: AppTextStyles.h3(),
      titleMedium: AppTextStyles.title(),
      bodyLarge: AppTextStyles.body(),
      bodyMedium: AppTextStyles.body(),
      bodySmall: AppTextStyles.caption(),
    );

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.secondary,
      textTheme: textTheme,
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.secondary,
        secondary: AppColors.primary,
        surface: AppColors.surface,
        error: AppColors.danger,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        foregroundColor: AppColors.textPrimary,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          textStyle: AppTextStyles.button(),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSm),
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.secondary,
          foregroundColor: Colors.white,
          textStyle: AppTextStyles.button(),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSm),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface2,
        hintStyle: AppTextStyles.bodySecondary(color: AppColors.textTertiary),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: const BorderSide(color: AppColors.secondary, width: 1.4),
        ),
      ),
      dividerColor: AppColors.border,
      iconTheme: const IconThemeData(color: AppColors.textSecondary),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: AppColors.surface2,
        selectedColor: AppColors.secondary,
        side: const BorderSide(color: AppColors.border),
        labelStyle: AppTextStyles.caption(color: AppColors.textPrimary),
      ),
    );
  }

  static ThemeData get light => dark;
}
