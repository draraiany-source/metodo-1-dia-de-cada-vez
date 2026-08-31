import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

/// Tipografia oficial: Poppins (títulos) + Inter (corpo).
/// Escala alinhada ao Design System (Title 1/2/3 + Body).
class AppTypography {
  AppTypography._();

  static TextStyle get display => GoogleFonts.poppins(
      fontSize: 32, fontWeight: FontWeight.w800, color: AppColors.textPrimary);
  static TextStyle get h1 => GoogleFonts.poppins(
      fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textPrimary);
  static TextStyle get h2 => GoogleFonts.poppins(
      fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary);
  static TextStyle get title => GoogleFonts.poppins(
      fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary);
  static TextStyle get body => GoogleFonts.inter(
      fontSize: 14, color: AppColors.textPrimary, height: 1.4);
  static TextStyle get bodySecondary => GoogleFonts.inter(
      fontSize: 14, color: AppColors.textSecondary, height: 1.4);
  static TextStyle get caption => GoogleFonts.inter(
      fontSize: 12, color: AppColors.textSecondary);
  static TextStyle get button => GoogleFonts.poppins(
      fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white);
}
