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
      primary: Color(0xFF7F30C3),
      primaryContainer: Color(0xFFC484FF),
      primaryFixed: Color(0xFF9A70FF),
      secondary: Color(0xFFFFCA4D),
      tertiary: Color(0xFFFF9475),
      background: Color(0xFFF9F0FF),
      backgroundSoft: Color(0xFFFFF7FC),
      surfaceLowest: Color(0xFFFFFFFF),
      surfaceLow: Color(0xFFFEEBFF),
      surfaceHigh: Color(0xFFF9D8FF),
      outline: Color(0xFFE6C7EE),
      mutedText: Color(0xFF7C6A86),
      textOnPrimary: Color(0xFFFFFFFF),
      textOnSurface: Color(0xFF1E1E1E),
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