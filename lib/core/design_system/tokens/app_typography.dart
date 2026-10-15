import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

abstract final class AppTypography {
  /// Hero Balance on Dashboard (32px, Bold, -0.5px letter spacing)
  static TextStyle get displayBalance => GoogleFonts.plusJakartaSans(
        fontSize: 32.0,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: AppColors.textPrimary,
      );

  /// Section Titles, Screen Headers (18px, SemiBold, -0.2px letter spacing)
  static TextStyle get headlineMedium => GoogleFonts.plusJakartaSans(
        fontSize: 18.0,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        color: AppColors.textPrimary,
      );

  /// Transaction item names, subtitles (16px, SemiBold, 0px letter spacing)
  static TextStyle get titleSmall => GoogleFonts.plusJakartaSans(
        fontSize: 16.0,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.0,
        color: AppColors.textPrimary,
      );

  /// Medium title (16px, Bold, -0.1px letter spacing)
  static TextStyle get titleMedium => GoogleFonts.plusJakartaSans(
        fontSize: 16.0,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.1,
        color: AppColors.textPrimary,
      );

  /// Form input fields, button texts (14px, Medium, 0px letter spacing)
  static TextStyle get bodyMedium => GoogleFonts.plusJakartaSans(
        fontSize: 14.0,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.0,
        color: AppColors.textPrimary,
      );

  /// Date subtext, microcopy (12px, Regular, +0.2px letter spacing)
  static TextStyle get bodySmall => GoogleFonts.plusJakartaSans(
        fontSize: 12.0,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.2,
        color: AppColors.textSecondary,
      );

  /// Status chips, all-caps category tags (11px, SemiBold, +0.5px letter spacing)
  static TextStyle get labelSmall => GoogleFonts.plusJakartaSans(
        fontSize: 11.0,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        color: AppColors.textSecondary,
      );
}
