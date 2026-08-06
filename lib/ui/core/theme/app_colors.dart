import 'package:flutter/material.dart';

enum ThemePack {
  midnight,
  cyberpunk,
  forest,
  space,
  retro,
  sunset,
  neon,
}

class AppColors {
  AppColors._();

  static ThemePack _activeTheme = ThemePack.midnight;

  static ThemePack get activeTheme => _activeTheme;

  static void setTheme(ThemePack theme) {
    _activeTheme = theme;
  }

  static Color get primary => accent;
  static Color get accent {
    switch (_activeTheme) {
      case ThemePack.midnight: return const Color(0xFF86EF4D);
      case ThemePack.cyberpunk: return const Color(0xFFFF007F);
      case ThemePack.forest: return const Color(0xFF50C878);
      case ThemePack.space: return const Color(0xFFBD93F9);
      case ThemePack.retro: return const Color(0xFFFFB86C);
      case ThemePack.sunset: return const Color(0xFFF9844A);
      case ThemePack.neon: return const Color(0xFF39FF14);
    }
  }

  static Color get headingWhite => const Color(0xFFFFFFFF);
  static Color get subtext => const Color(0xFF808080);

  static Color get bg {
    switch (_activeTheme) {
      case ThemePack.midnight: return const Color(0xFF121212);
      case ThemePack.cyberpunk: return const Color(0xFF0F0B1E);
      case ThemePack.forest: return const Color(0xFF0D140F);
      case ThemePack.space: return const Color(0xFF090A15);
      case ThemePack.retro: return const Color(0xFF17130E);
      case ThemePack.sunset: return const Color(0xFF1E0E25);
      case ThemePack.neon: return const Color(0xFF050505);
    }
  }

  static Color get gridLines => const Color(0xFF222222);

  static Color get darkBg => bg;
  static Color get darkSurface => const Color(0xFF16161C);
  static Color get darkCard => const Color(0xFF1C1C22);
  static Color get darkBorder => accent;

  static Color get lightBg => bg;
  static Color get lightSurface => const Color(0xFF16161C);
  static Color get lightCard => const Color(0xFF1C1C22);
  static Color get lightBorder => accent;

  static const List<Color> waterColors = [
    Color(0xFFE53935),
    Color(0xFF1E88E5),
    Color(0xFF43A047),
    Color(0xFFFDD835),
    Color(0xFFFF8F00),
    Color(0xFF8E24AA),
    Color(0xFFEC407A),
    Color(0xFF00ACC1),
    Color(0xFFB39DDB),
    Color(0xFFFF7043),
    Color(0xFF5C6BC0),
    Color(0xFF009688),
    Color(0xFF8D6E63),
    Color(0xFFB71C1C),
    Color(0xFFAD1457),
    Color(0xFF9E9D24),
  ];
}
