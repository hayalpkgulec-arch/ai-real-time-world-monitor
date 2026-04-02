import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'aegis_colors.dart';

/// Master ThemeData for AEGIS Intelligence app.
class AegisTheme {
  AegisTheme._();

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AegisColors.background,
      colorScheme: const ColorScheme.dark(
        surface: AegisColors.surface,
        primary: AegisColors.primary,
        secondary: AegisColors.secondary,
        tertiary: AegisColors.tertiary,
        error: AegisColors.error,
        onSurface: AegisColors.onSurface,
        onPrimary: AegisColors.onPrimary,
        onSecondary: AegisColors.onSecondary,
        onError: AegisColors.onError,
        outline: AegisColors.outline,
        outlineVariant: AegisColors.outlineVariant,
        surfaceContainerHighest: AegisColors.surfaceContainerHighest,
        surfaceContainerHigh: AegisColors.surfaceContainerHigh,
        surfaceContainer: AegisColors.surfaceContainer,
        surfaceContainerLow: AegisColors.surfaceContainerLow,
        surfaceContainerLowest: AegisColors.surfaceContainerLowest,
        surfaceBright: AegisColors.surfaceBright,
        surfaceDim: AegisColors.surfaceDim,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AegisColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: AegisColors.background,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AegisColors.background,
        selectedItemColor: AegisColors.primary,
        unselectedItemColor: AegisColors.onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: AegisColors.surfaceContainerLow,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        margin: EdgeInsets.zero,
      ),
      dividerTheme: const DividerThemeData(
        color: Colors.transparent, // "No-Line" rule
        thickness: 0,
      ),
      splashColor: AegisColors.surfaceContainerHigh.withValues(alpha: 0.3),
      highlightColor: AegisColors.surfaceBright.withValues(alpha: 0.2),
    );
  }
}
