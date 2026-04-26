import 'package:flutter/material.dart';

/// Design Tokens (Core)
/// Mendefinisikan kontrak warna untuk aplikasi.
@immutable
class ColorsConfig extends ThemeExtension<ColorsConfig> {
  final Color primary;
  final Color primaryContainer;
  final Color primaryFixed;
  final Color secondary;
  final Color tertiary;
  final Color background;
  final Color backgroundSoft;
  final Color surfaceLowest;
  final Color surfaceLow;
  final Color surfaceHigh;
  final Color outline;
  final Color mutedText;
  final Color textOnPrimary;
  final Color textOnSurface;

  const ColorsConfig({
    required this.primary,
    required this.primaryContainer,
    required this.primaryFixed,
    required this.secondary,
    required this.tertiary,
    required this.background,
    required this.backgroundSoft,
    required this.surfaceLowest,
    required this.surfaceLow,
    required this.surfaceHigh,
    required this.outline,
    required this.mutedText,
    required this.textOnPrimary,
    required this.textOnSurface,
  });

  factory ColorsConfig.light() {
    return const ColorsConfig(
      primary: Color(0xFF3072A6), // Main Blue
      primaryContainer: Color(0xFF6CA6DD), // Light Blue
      primaryFixed: Color(0xFF4A8BBE), // Slightly lighter blue for active states
      secondary: Color(0xFFE19E20), // Orange/Yellow accent
      tertiary: Color(0xFFF3B744), // Lighter orange
      background: Color(0xFFF0F9FF), // Very soft blue-ish white
      backgroundSoft: Color(0xFFD7F3FF), // Provided light blue background
      surfaceLowest: Color(0xFFFFFFFF), // White
      surfaceLow: Color(0xFFEAF6FF), // Soft blue for cards
      surfaceHigh: Color(0xFFCBE9FE), // Slightly darker soft blue
      outline: Color(0xFFB3D8F5), // Blue outline
      mutedText: Color(0xFF637C90), // Grey-blue for text
      textOnPrimary: Color(0xFFFFFFFF),
      textOnSurface: Color(0xFF1E2A34), // Dark blue-grey text
    );
  }

  @override
  ColorsConfig copyWith({
    Color? primary,
    Color? primaryContainer,
    Color? primaryFixed,
    Color? secondary,
    Color? tertiary,
    Color? background,
    Color? backgroundSoft,
    Color? surfaceLowest,
    Color? surfaceLow,
    Color? surfaceHigh,
    Color? outline,
    Color? mutedText,
    Color? textOnPrimary,
    Color? textOnSurface,
  }) {
    return ColorsConfig(
      primary: primary ?? this.primary,
      primaryContainer: primaryContainer ?? this.primaryContainer,
      primaryFixed: primaryFixed ?? this.primaryFixed,
      secondary: secondary ?? this.secondary,
      tertiary: tertiary ?? this.tertiary,
      background: background ?? this.background,
      backgroundSoft: backgroundSoft ?? this.backgroundSoft,
      surfaceLowest: surfaceLowest ?? this.surfaceLowest,
      surfaceLow: surfaceLow ?? this.surfaceLow,
      surfaceHigh: surfaceHigh ?? this.surfaceHigh,
      outline: outline ?? this.outline,
      mutedText: mutedText ?? this.mutedText,
      textOnPrimary: textOnPrimary ?? this.textOnPrimary,
      textOnSurface: textOnSurface ?? this.textOnSurface,
    );
  }

  @override
  ColorsConfig lerp(ThemeExtension<ColorsConfig>? other, double t) {
    if (other is! ColorsConfig) return this;
    return ColorsConfig(
      primary: Color.lerp(primary, other.primary, t)!,
      primaryContainer: Color.lerp(primaryContainer, other.primaryContainer, t)!,
      primaryFixed: Color.lerp(primaryFixed, other.primaryFixed, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      tertiary: Color.lerp(tertiary, other.tertiary, t)!,
      background: Color.lerp(background, other.background, t)!,
      backgroundSoft: Color.lerp(backgroundSoft, other.backgroundSoft, t)!,
      surfaceLowest: Color.lerp(surfaceLowest, other.surfaceLowest, t)!,
      surfaceLow: Color.lerp(surfaceLow, other.surfaceLow, t)!,
      surfaceHigh: Color.lerp(surfaceHigh, other.surfaceHigh, t)!,
      outline: Color.lerp(outline, other.outline, t)!,
      mutedText: Color.lerp(mutedText, other.mutedText, t)!,
      textOnPrimary: Color.lerp(textOnPrimary, other.textOnPrimary, t)!,
      textOnSurface: Color.lerp(textOnSurface, other.textOnSurface, t)!,
    );
  }
}