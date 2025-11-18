import 'package:flutter/material.dart';

/// Centralized color definitions for the app.
class AppColors {
  // ==================== DARK THEME ====================
  
  // Core Theme - Dark
  static const Color background = Color(0xFF0E0E10);
  static const Color surface = Color(0xFF1A1C1E);
  static const Color primary = Color(0xFF00BFA6);
  static const Color secondary = Color(0xFF00C4B4);
  static const Color error = Color(0xFFE74C3C);

  // Useful semantic colors - Dark
  static const Color onPrimary = Color(0xFF000000);
  static const Color onSurface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFF222426);

  // Text - Dark
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF9E9E9E);

  // Borders / Dividers - Dark
  static const Color divider = Color(0xFF2C2C2E);

  // Icons - Dark
  static const Color icon = Color(0xFF00C4B4);

  // ==================== LIGHT THEME ====================
  
  // Core Theme - Light (Enhanced for better visual appeal)
  static const Color backgroundLight = Color(0xFFF8F9FA); // Lighter, softer background
  static const Color surfaceLight = Color(0xFFFFFFFF); // Pure white surface
  static const Color primaryLight = Color(0xFF00BFA6); // Same primary for consistency
  static const Color secondaryLight = Color(0xFF00C4B4); // Same secondary for consistency
  static const Color errorLight = Color(0xFFDC3545); // Enhanced error color for better contrast

  // Useful semantic colors - Light (Enhanced)
  static const Color onPrimaryLight = Color(0xFFFFFFFF); // White text on primary
  static const Color onSurfaceLight = Color(0xFF1A1A1A); // Near-black text on surface
  static const Color surfaceVariantLight = Color(0xFFF1F3F5); // Subtle surface variant

  // Text - Light (Enhanced for better readability)
  static const Color textPrimaryLight = Color(0xFF1A1A1A); // Near-black for better contrast
  static const Color textSecondaryLight = Color(0xFF6C757D); // Better secondary text color

  // Borders / Dividers - Light (Enhanced)
  static const Color dividerLight = Color(0xFFE9ECEF); // Softer divider color

  // Icons - Light
  static const Color iconLight = Color(0xFF00BFA6); // Primary color for icons
}


extension AppColorsExtension on BuildContext {
  /// Returns theme-aware AppColors based on the current theme
  AppColorsTheme get appColors {
    final brightness = Theme.of(this).brightness;
    return brightness == Brightness.dark
        ? AppColorsTheme.dark
        : AppColorsTheme.light;
  }
}

class AppColorsTheme {
  final Color background;
  final Color surface;
  final Color primary;
  final Color secondary;
  final Color error;
  final Color onPrimary;
  final Color onSurface;
  final Color surfaceVariant;
  final Color textPrimary;
  final Color textSecondary;
  final Color divider;
  final Color icon;

  const AppColorsTheme({
    required this.background,
    required this.surface,
    required this.primary,
    required this.secondary,
    required this.error,
    required this.onPrimary,
    required this.onSurface,
    required this.surfaceVariant,
    required this.textPrimary,
    required this.textSecondary,
    required this.divider,
    required this.icon,
  });

  /// Dark theme colors
  static const dark = AppColorsTheme(
    background: AppColors.background,
    surface: AppColors.surface,
    primary: AppColors.primary,
    secondary: AppColors.secondary,
    error: AppColors.error,
    onPrimary: AppColors.onPrimary,
    onSurface: AppColors.onSurface,
    surfaceVariant: AppColors.surfaceVariant,
    textPrimary: AppColors.textPrimary,
    textSecondary: AppColors.textSecondary,
    divider: AppColors.divider,
    icon: AppColors.icon,
  );

  /// Light theme colors
  static const light = AppColorsTheme(
    background: AppColors.backgroundLight,
    surface: AppColors.surfaceLight,
    primary: AppColors.primaryLight,
    secondary: AppColors.secondaryLight,
    error: AppColors.errorLight,
    onPrimary: AppColors.onPrimaryLight,
    onSurface: AppColors.onSurfaceLight,
    surfaceVariant: AppColors.surfaceVariantLight,
    textPrimary: AppColors.textPrimaryLight,
    textSecondary: AppColors.textSecondaryLight,
    divider: AppColors.dividerLight,
    icon: AppColors.iconLight,
  );
}
