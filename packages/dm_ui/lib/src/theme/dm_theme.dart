import 'package:dm_ui/src/copy/status_locale.dart';
import 'package:dm_ui/src/tokens/dm_scales.dart';
import 'package:dm_ui/src/tokens/static_palette.dart';
import 'package:flutter/material.dart';

/// The static Material theme of content surfaces (§7.9, Appendix G).
abstract final class DmTheme {
  /// Latin family (OFL); bundled with the app shell (§15 D75).
  static const String latinFamily = 'Inter';

  /// Arabic family (OFL); bundled with the app shell (§15 D75).
  static const String arabicFamily = 'IBM Plex Sans Arabic';

  /// The theme for [brightness] and [locale].
  static ThemeData of(Brightness brightness, StatusLocale locale) {
    final p = switch (brightness) {
      Brightness.light => StaticPalette.light,
      Brightness.dark => StaticPalette.dark,
    };
    final scheme =
        ColorScheme.fromSeed(
          seedColor: p.primary,
          brightness: brightness,
        ).copyWith(
          surface: p.surface,
          onSurface: p.onSurface,
          primary: p.primary,
          secondary: p.secondary,
          error: p.error,
        );
    final extra = switch (locale) {
      StatusLocale.en => 0.0,
      StatusLocale.ar => DmScales.arabicExtraLine,
    };
    TextStyle step(TypeStep s) => TextStyle(
      fontSize: s.size,
      height: (s.lineHeight + extra) / s.size,
      color: p.onSurface,
    );
    return ThemeData(
      colorScheme: scheme,
      scaffoldBackgroundColor: p.surface,
      fontFamily: switch (locale) {
        StatusLocale.en => latinFamily,
        StatusLocale.ar => arabicFamily,
      },
      fontFamilyFallback: const [arabicFamily, latinFamily],
      materialTapTargetSize: MaterialTapTargetSize.padded,
      textTheme: TextTheme(
        displayLarge: step(DmScales.display),
        headlineMedium: step(DmScales.headline),
        titleLarge: step(DmScales.title),
        bodyLarge: step(DmScales.body),
        labelMedium: step(DmScales.label),
      ),
    );
  }
}
