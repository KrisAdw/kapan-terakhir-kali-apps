import 'package:flutter/material.dart';

import '../../core/design/app_tokens.dart';

/// Global [ThemeData] — Caveat display / DM Sans body (design.md §3),
/// cream canvas, ink controls. Widgets still use [AppT] tokens directly
/// for borders/shadows; this theme covers text styles and material chrome.
final class AppTheme {
  const AppTheme._();

  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppT.yellow,
        brightness: Brightness.light,
        surface: AppT.cream,
      ),
      scaffoldBackgroundColor: AppT.cream,
    );

    return base.copyWith(
      textTheme: base.textTheme.apply(
        bodyColor: AppT.ink,
        displayColor: AppT.ink,
        fontFamily: AppT.fontBody,
      ),
      splashFactory: InkSparkle.splashFactory,
      dividerTheme: const DividerThemeData(color: AppT.divider),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppT.cream,
        foregroundColor: AppT.ink,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontFamily: AppT.fontDisplay,
          fontSize: 26,
          fontWeight: FontWeight.w700,
          color: AppT.ink,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppT.surface,
        hintStyle: const TextStyle(fontFamily: AppT.fontBody),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 13,
        ),
        border: _inputBorder(AppT.ink),
        enabledBorder: _inputBorder(AppT.ink),
        focusedBorder: _inputBorder(AppT.ink),
      ),
    );
  }

  static OutlineInputBorder _inputBorder(Color color) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppT.radius),
    borderSide: BorderSide(color: color, width: AppT.borderW),
  );
}
