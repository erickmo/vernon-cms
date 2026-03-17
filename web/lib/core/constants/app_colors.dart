import 'package:flutter/material.dart';

/// Warna standar aplikasi — terinspirasi dari MatDash Material Design 3.
/// Selalu gunakan konstanta ini, jangan hardcode hex color.
class AppColors {
  AppColors._();

  // Primary — Purple (#4D2975)
  static const Color primary = Color(0xFF4D2975);
  static const Color primaryLight = Color(0xFFF0EBF8);
  static const Color primaryDark = Color(0xFF3A1E5A);

  // Secondary — MatDash Cyan (#49BEFF)
  static const Color secondary = Color(0xFF49BEFF);
  static const Color secondaryLight = Color(0xFFE8F7FF);
  static const Color secondaryDark = Color(0xFF23AFDB);

  // Neutral
  static const Color background = Color(0xFFF2F6FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color divider = Color(0xFFE5EAF2);

  // Text
  static const Color textPrimary = Color(0xFF2A3547);
  static const Color textSecondary = Color(0xFF5A6A85);
  static const Color textHint = Color(0xFFA0AFC0);

  // Status — MatDash palette
  static const Color success = Color(0xFF13DEB9);
  static const Color successLight = Color(0xFFE6FFFA);
  static const Color warning = Color(0xFFFFAE1F);
  static const Color warningLight = Color(0xFFFEF5E5);
  static const Color error = Color(0xFFFA896B);
  static const Color errorLight = Color(0xFFFDEDE8);
  static const Color info = Color(0xFF539BFF);
  static const Color infoLight = Color(0xFFEBF3FE);

  // Sidebar — White sidebar style (MatDash)
  static const Color sidebarBackground = Color(0xFFFFFFFF);
  static const Color sidebarBorder = Color(0xFFE5EAF2);
  static const Color sidebarItemActive = Color(0xFF4D2975);
  static const Color sidebarItemActiveBg = Color(0xFFF0EBF8);
  static const Color sidebarItemHover = Color(0xFFF7F4FC);
  static const Color sidebarText = Color(0xFF5A6A85);
  static const Color sidebarTextActive = Color(0xFF4D2975);
  static const Color sidebarSectionTitle = Color(0xFFA0AFC0);

  // Chart
  static const Color chartLine = Color(0xFF4D2975);
  static const Color chartFill = Color(0x334D2975);
  static const Color chartGrid = Color(0xFFE5EAF2);

  // Accent card colors (stat cards)
  static const Color cardAccentBlue = Color(0xFF4D2975);
  static const Color cardAccentGreen = Color(0xFF13DEB9);
  static const Color cardAccentOrange = Color(0xFFFFAE1F);
  static const Color cardAccentCyan = Color(0xFF49BEFF);
}
