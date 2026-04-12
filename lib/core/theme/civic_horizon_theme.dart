import 'package:flutter/material.dart';

extension ThemeX on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get text => Theme.of(this).textTheme;
}

class CivicHorizonTheme {
  // Original Brand Colors (Defaults)
  static const Color primary = Color(0xFF00003C);
  static const Color primaryContainer = Color(0xFF000080);

  // Background and Surfaces (Original Light)
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFF8F9FA);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF3F4F5);
  static const Color surfaceContainerHigh = Color(0xFFE7E8E9);
  static const Color surfaceContainerHighest = Color(0xFFE1E3E4);
  static const Color onSurface = Color(0xFF191C1D);
  static const Color onSurfaceVariant = Color(0xFF464653);

  // Accents (Original Light)
  static const Color tertiaryFixedDim = Color(0xFF66DD8B);
  static const Color onTertiaryFixedVariant = Color(0xFF005227);
  static const Color tertiaryFixed = Color(0xFF83FBA5);
  static const Color error = Color(0xFFBA1A1A);
  static const Color outlineVariant = Color(0xFFC6C5D5);

  /// Helper for "Ghost Border"
  static Border ghostBorder(BuildContext context) => Border.all(
        color: context.colors.outlineVariant.withValues(alpha: 0.15),
        width: 1.0,
      );

  static Border ghostBorderBottom(BuildContext context) => Border(
        bottom: BorderSide(
          color: context.colors.outlineVariant.withValues(alpha: 0.15),
          width: 2.0,
        ),
      );

  /// Helper for "Ambient Glow" (floating elements without harsh shadows)
  static List<BoxShadow> ambientGlow(BuildContext context) => [
        BoxShadow(
          color: context.colors.onSurface.withValues(alpha: 0.06),
          blurRadius: 30,
          spreadRadius: 0,
          offset: const Offset(0, 4),
        )
      ];

  /// Static version for onboarding to avoid dynamic seed-color "ugliness"
  static List<BoxShadow> staticAmbientGlow() => [
        const BoxShadow(
          color: Color(0x0F191C1D),
          blurRadius: 30,
          spreadRadius: 0,
          offset: Offset(0, 4),
        )
      ];

  /// Signature CTA Gradient (Ink-on-silk)
  static LinearGradient ctaGradient(BuildContext context) => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          context.colors.primary,
          context.colors.primaryContainer,
        ],
      );

  /// Static version for onboarding to avoid dynamic seed-color "ugliness"
  static LinearGradient staticCtaGradient() => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          primary,
          primaryContainer,
        ],
      );

  /// Get light theme data avec seed color
  static ThemeData light(Color seed) => _build(Brightness.light, seed);

  /// Get dark theme data avec seed color
  static ThemeData dark(Color seed) => _build(Brightness.dark, seed);

  static ThemeData _build(Brightness brightness, Color seed) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: brightness,
      primary: seed,
      onPrimary: Colors.white,
      secondary: const Color(0xFF585B85),
      surface: brightness == Brightness.light ? background : const Color(0xFF101314),
      error: error,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      fontFamily: 'Inter',
      textTheme: _buildTextTheme(colorScheme),
    );
  }

  static TextTheme _buildTextTheme(ColorScheme colors) {
    return TextTheme(
      displayLarge: TextStyle(
        fontFamily: 'Public Sans',
        fontWeight: FontWeight.w900,
        letterSpacing: -0.02,
        color: colors.primary,
      ),
      displayMedium: TextStyle(
        fontFamily: 'Public Sans',
        fontWeight: FontWeight.w800,
        letterSpacing: -0.02,
        color: colors.primary,
      ),
      headlineLarge: TextStyle(
        fontFamily: 'Public Sans',
        fontWeight: FontWeight.w900,
        color: colors.primary,
      ),
      headlineMedium: TextStyle(
        fontFamily: 'Public Sans',
        fontWeight: FontWeight.w800,
        color: colors.primary,
      ),
      bodyLarge: TextStyle(
        fontFamily: 'Inter',
        fontWeight: FontWeight.normal,
        color: colors.onSurface,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'Inter',
        fontWeight: FontWeight.normal,
        color: colors.onSurfaceVariant,
      ),
      labelLarge: TextStyle(
        fontFamily: 'Inter',
        fontWeight: FontWeight.w600,
        color: colors.onSurfaceVariant,
      ),
      labelMedium: TextStyle(
        fontFamily: 'Inter',
        fontWeight: FontWeight.w600,
        color: colors.onSurfaceVariant,
      ),
      labelSmall: TextStyle(
        fontFamily: 'Inter',
        fontWeight: FontWeight.w700,
        letterSpacing: 1.5,
        color: colors.onSurfaceVariant,
      ),
    );
  }
}


