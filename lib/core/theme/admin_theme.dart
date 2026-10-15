import 'package:deux_lapins_manager/core/theme/admin_typography.dart';
import 'package:flutter/material.dart';

abstract final class AdminTheme {
  static const background = Color(0xFFF3F0E9);
  static const surface = Color(0xFFF8F5EF);
  static const text = Color(0xFF171511);
  static const muted = Color(0xFF6B665E);
  static const line = Color(0xFFCBC5BA);
  static const soft = Color(0xFFE8E3DA);
  static const darkBrown = Color(0xFF2B241E);
  static const danger = Color(0xFF8B3A2E);
  static const success = Color(0xFF526148);

  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: text,
        brightness: Brightness.light,
        surface: surface,
      ),
    );

    return base.copyWith(
      dividerColor: line,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      textTheme: base.textTheme.copyWith(
        displayLarge: AdminTypography.serif(fontSize: 66, height: 0.92),
        displayMedium: AdminTypography.serif(fontSize: 52, height: 0.95),
        headlineLarge: AdminTypography.serif(fontSize: 38),
        headlineMedium: AdminTypography.serif(fontSize: 30),
        bodyLarge: AdminTypography.body(fontSize: 14),
        bodyMedium: AdminTypography.body(fontSize: 13),
        bodySmall: AdminTypography.body(fontSize: 11.5, color: muted),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: false,
        isDense: true,
        contentPadding: EdgeInsets.symmetric(vertical: 13, horizontal: 0),
        hintStyle: TextStyle(
          color: muted,
          fontSize: 12,
          letterSpacing: 0.9,
        ),
        border: UnderlineInputBorder(
          borderSide: BorderSide(color: line),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: line),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: text),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: text,
          foregroundColor: background,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
          shape: const RoundedRectangleBorder(),
          textStyle: const TextStyle(
            fontSize: 11,
            letterSpacing: 1.15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: text,
          side: const BorderSide(color: line),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          shape: const RoundedRectangleBorder(),
          textStyle: const TextStyle(
            fontSize: 11,
            letterSpacing: 1.1,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: text,
          shape: const RoundedRectangleBorder(),
          textStyle: const TextStyle(
            fontSize: 11,
            letterSpacing: 1.1,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: text,
          shape: const RoundedRectangleBorder(),
        ),
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(),
      ),
      drawerTheme: const DrawerThemeData(
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: text,
        contentTextStyle: TextStyle(color: background, fontSize: 12),
        shape: RoundedRectangleBorder(),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
