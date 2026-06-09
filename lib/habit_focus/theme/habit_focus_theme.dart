import 'package:flutter/material.dart';

class HabitFocusTheme {
  HabitFocusTheme._();

  static const _primary = Color(0xFF0f5238);
  static const _onPrimary = Color(0xFFffffff);
  static const _primaryContainer = Color(0xFF2d6a4f);
  static const _onPrimaryContainer = Color(0xFFa8e7c5);
  static const _secondary = Color(0xFF2a6485);
  static const _onSecondary = Color(0xFFffffff);
  static const _secondaryContainer = Color(0xFFa2d8ff);
  static const _onSecondaryContainer = Color(0xFF245f80);
  static const _tertiary = Color(0xFF634019);
  static const _onTertiary = Color(0xFFffffff);
  static const _tertiaryContainer = Color(0xFF7e572e);
  static const _onTertiaryContainer = Color(0xFFffd1a7);
  static const _error = Color(0xFFba1a1a);
  static const _background = Color(0xFFf8f9fa);
  static const _onBackground = Color(0xFF191c1d);
  static const _surface = Color(0xFFf8f9fa);
  static const _onSurface = Color(0xFF191c1d);
  static const _surfaceContainerLowest = Color(0xFFffffff);
  static const _surfaceContainerLow = Color(0xFFf3f4f5);
  static const _surfaceContainer = Color(0xFFedeeef);
  static const _surfaceContainerHigh = Color(0xFFe7e8e9);
  static const _surfaceContainerHighest = Color(0xFFe1e3e4);
  static const _outline = Color(0xFF707973);
  static const _outlineVariant = Color(0xFFbfc9c1);

  static const double spacingBase = 8.0;
  static const double mobilePadding = 20.0;
  static const double stackGap = 16.0;
  static const double sectionGap = 40.0;
  static const double defaultRadius = 8.0;
  static const double cardRadius = 12.0;

  static final BoxShadow ambientShadow = BoxShadow(
    offset: const Offset(0, 4),
    blurRadius: 40,
    color: Colors.black.withValues(alpha: 0.04),
  );

  static ColorScheme get colorScheme => const ColorScheme(
        brightness: Brightness.light,
        primary: _primary,
        onPrimary: _onPrimary,
        primaryContainer: _primaryContainer,
        onPrimaryContainer: _onPrimaryContainer,
        secondary: _secondary,
        onSecondary: _onSecondary,
        secondaryContainer: _secondaryContainer,
        onSecondaryContainer: _onSecondaryContainer,
        tertiary: _tertiary,
        onTertiary: _onTertiary,
        tertiaryContainer: _tertiaryContainer,
        onTertiaryContainer: _onTertiaryContainer,
        error: _error,
        onError: _onPrimary,
        surface: _surface,
        onSurface: _onSurface,
        surfaceContainerLowest: _surfaceContainerLowest,
        surfaceContainerLow: _surfaceContainerLow,
        surfaceContainer: _surfaceContainer,
        surfaceContainerHigh: _surfaceContainerHigh,
        surfaceContainerHighest: _surfaceContainerHighest,
        outline: _outline,
        outlineVariant: _outlineVariant,
      );

  static TextTheme get textTheme => const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.64,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w400,
        ),
        bodyMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        labelMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        labelSmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      );

  static ThemeData get themeData => ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        textTheme: textTheme,
        scaffoldBackgroundColor: _background,
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(cardRadius),
          ),
          color: _surfaceContainerLowest,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: _background,
          foregroundColor: _onBackground,
          elevation: 0,
        ),
      );
}
