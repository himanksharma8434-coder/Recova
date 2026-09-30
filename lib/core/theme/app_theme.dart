import 'package:flutter/material.dart';
import 'design_tokens.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Tok.canvasBase,
      useMaterial3: true,
      colorScheme: const ColorScheme.dark(
        surface: Tok.canvasBase,
        onSurface: Tok.textPrimary,
        onSurfaceVariant: Tok.textSecondary,
        primary: Tok.neonAccent,
        onPrimary: Color(0xFF0A0A0A),
        primaryContainer: Tok.neonAccentSurface,
        secondary: Tok.accentBlue,
        onSecondary: Color(0xFF0A0A0A),
        secondaryContainer: Tok.accentBlueSurface,
        tertiary: Tok.textSecondary,
        error: Tok.recoverySuppressed,
        outline: Tok.glassBorder,
        outlineVariant: Tok.glassBorder,
      ),
      cardTheme: CardThemeData(
        color: Tok.glassFill,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(Radius.circular(Tok.radiusMd)),
          side: BorderSide(color: Tok.glassBorder),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
          color: Tok.textPrimary,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: Tok.glassFillElevated,
        behavior: SnackBarBehavior.floating,
        insetPadding: const EdgeInsets.only(bottom: 96, left: 20, right: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Tok.radiusSm),
          side: BorderSide(color: Tok.glassBorder),
        ),
      ),
      fontFamily: 'Inter',
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.w300,
          letterSpacing: -1.5,
          color: Tok.textPrimary,
        ),
        displayMedium: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w400,
          letterSpacing: -1.0,
          color: Tok.textPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
          color: Tok.textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
          color: Tok.textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
          color: Tok.textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Tok.textSecondary,
        ),
        bodyMedium: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: Tok.textSecondary,
        ),
        bodySmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w400,
          color: Tok.textTertiary,
        ),
        labelLarge: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.0,
          color: Tok.textSecondary,
        ),
        labelSmall: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
          color: Tok.textTertiary,
        ),
      ),
    );
  }
}
