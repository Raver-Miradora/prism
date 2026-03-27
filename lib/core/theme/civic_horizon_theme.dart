import 'package:flutter/material.dart';

class CivicHorizonTheme {
  // Brand Colors
  static const Color primary = Color(0xFF00003C);
  static const Color primaryContainer = Color(0xFF000080);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFF777EEA);

  // Background and Surfaces
  static const Color background = Color(0xFFF8F9FA);
  static const Color onBackground = Color(0xFF191C1D);
  static const Color surface = Color(0xFFF8F9FA);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF3F4F5);
  static const Color surfaceContainer = Color(0xFFEDEEEF);
  static const Color surfaceContainerHigh = Color(0xFFE7E8E9);
  static const Color surfaceContainerHighest = Color(0xFFE1E3E4);
  static const Color onSurface = Color(0xFF191C1D);
  static const Color onSurfaceVariant = Color(0xFF464653);

  // Accents and Semantic
  static const Color tertiaryFixedDim = Color(0xFF66DD8B);
  static const Color onTertiaryFixedVariant = Color(0xFF005227);
  static const Color tertiaryFixed = Color(0xFF83FBA5);
  static const Color error = Color(0xFFBA1A1A);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onError = Color(0xFFFFFFFF);

  // Ghost Border
  static const Color outlineVariant = Color(0xFFC6C5D5);

  /// Helper for "Ghost Border"
  static Border get ghostBorder => Border.all(
        color: outlineVariant.withOpacity(0.15),
        width: 1.0,
      );

  static Border get ghostBorderBottom => Border(
        bottom: BorderSide(
          color: outlineVariant.withOpacity(0.15),
          width: 2.0,
        ),
      );

  /// Helper for "Ambient Glow" (floating elements without harsh shadows)
  static List<BoxShadow> get ambientGlow => [
        BoxShadow(
          color: onSurface.withOpacity(0.06),
          blurRadius: 30,
          spreadRadius: 0,
          offset: const Offset(0, 4),
        )
      ];

  /// Signature CTA Gradient (Ink-on-silk)
  static LinearGradient get ctaGradient => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [primary, primaryContainer],
      );

  /// Get the full Flutter ThemeData
  static ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.light(
        primary: primary,
        primaryContainer: primaryContainer,
        secondary: Color(0xFF585B85),
        tertiary: Color(0xFF000E03),
        surface: surface,
        error: error,
        onPrimary: onPrimary,
        onSecondary: Color(0xFFFFFFFF),
        onSurface: onSurface,
        onSurfaceVariant: onSurfaceVariant,
        onError: onError,
      ),
      fontFamily: 'Inter', // Default Body Font
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'Public Sans',
          fontWeight: FontWeight.w900,
          letterSpacing: -0.02,
          color: primary,
        ),
        displayMedium: TextStyle(
          fontFamily: 'Public Sans',
          fontWeight: FontWeight.w800,
          letterSpacing: -0.02,
          color: primary,
        ),
        headlineLarge: TextStyle(
          fontFamily: 'Public Sans',
          fontWeight: FontWeight.w900,
          color: primary,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'Public Sans',
          fontWeight: FontWeight.w800,
          color: primary,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.normal,
          color: onSurface,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.normal,
          color: onSurfaceVariant,
        ),
        labelLarge: TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.w600,
          color: onSurfaceVariant,
        ),
        labelMedium: TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.w600,
          color: onSurfaceVariant,
        ),
        labelSmall: TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
          color: onSurfaceVariant,
        ),
      ),
    );
  }
}
