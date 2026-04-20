import 'package:flutter/material.dart';
import 'package:py_4/theme/colors_config.dart';

/// Konfigurasi Utama Tema
/// Bertindak sebagai Single Source of Truth untuk inject extension dan text theme.
class ThemeConfig {
  static ThemeData get lightTheme {
    final colors = ColorsConfig.light();

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: colors.surfaceLowest,
      extensions: [colors],
      
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontSize: 56,
          fontWeight: FontWeight.w700,
          color: colors.primary,
          letterSpacing: 0,
        ),
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: colors.textOnSurface,
          letterSpacing: -0.32,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: colors.textOnSurface.withValues(alpha:0.8),
          letterSpacing: 0,
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: colors.primary,
          letterSpacing: 0.55,
        ),
      ),
      
      colorScheme: ColorScheme.light(
        primary: colors.primary,
        secondary: colors.secondary,
        surface: colors.surfaceLowest,
      ),
    );
  }
}