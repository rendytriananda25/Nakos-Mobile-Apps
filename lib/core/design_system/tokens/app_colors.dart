import 'package:flutter/material.dart';

abstract final class AppColors {
  // Pure Black & Dark OLED Theme (Zero Blue)
  static const Color bgCanvas = Color(0xFF000000);
  static const Color surfaceCard = Color(0xFF121216);
  static const Color surfaceCardElevated = Color(0xFF1A1A20);
  static const Color surfaceInteractive = Color(0xFF24242C);
  static const Color borderHairline = Color(0xFF26262E);

  static const Color brandPrimary = Color(0xFFFF653F);
  static const Color brandPrimaryMuted = Color(0xFFE0522E);
  static const Color brandPrimarySurface = Color(0x26FF653F);

  static const Color brandAccentGold = Color(0xFFFFC85C);
  static const Color brandAccentGoldSurface = Color(0x26FFC85C);

  static const Color textHighContrast = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFA1A1AA);
  static const Color textPlaceholder = Color(0xFF71717A);

  static const Color incomeGreen = Color(0xFFFFC85C);
  static const Color incomeSurface = Color(0x26FFC85C);
  static const Color expenseRed = Color(0xFFFF653F);
  static const Color expenseSurface = Color(0x26FF653F);

  static const Color background = bgCanvas;
  static const Color surface = surfaceCard;
  static const Color surfaceMuted = surfaceCardElevated;
  static const Color primary = brandPrimary;
  static const Color primaryDark = brandPrimaryMuted;
  static const Color primaryLight = brandPrimary;
  static const Color primaryContainer = brandPrimarySurface;
  static const Color textPrimary = textHighContrast;
  static const Color textDisabled = textPlaceholder;
  static const Color income = incomeGreen;
  static const Color expense = expenseRed;
  static const Color border = borderHairline;

  static const Color darkBackground = bgCanvas;
  static const Color darkSurface = surfaceCard;
  static const Color darkSurfaceVariant = surfaceInteractive;
  static const Color darkHeroBg = brandPrimary;
  static const Color darkHeroText = textHighContrast;
  static const Color darkHeroPill = brandPrimarySurface;
  static const Color darkTextPrimary = textHighContrast;
  static const Color darkTextSecondary = textSecondary;
  static const Color darkIncomeBadgeBg = incomeSurface;
  static const Color darkIncomeText = incomeGreen;
  static const Color darkWarningText = brandAccentGold;
  static const Color darkExpenseBadgeBg = expenseSurface;
  static const Color darkExpenseText = expenseRed;
  static const Color darkNavBg = Color(0xF208080A);
}
