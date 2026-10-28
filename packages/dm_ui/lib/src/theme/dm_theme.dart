import 'package:dm_ui/src/copy/status_locale.dart';
import 'package:dm_ui/src/tokens/dm_scales.dart';
import 'package:dm_ui/src/tokens/rawdah_palette.dart';
import 'package:dm_ui/src/tokens/static_palette.dart';
import 'package:flutter/material.dart';

/// The static Material theme of content surfaces (§7.9, Appendix G).
abstract final class DmTheme {
  /// Latin family (OFL), bundled in `dm_ui` (§15 D75, D89).
  static const String latinFamily = 'packages/dm_ui/Inter';

  /// Arabic family (OFL), bundled in `dm_ui` (§15 D75, D89).
  static const String arabicFamily = 'packages/dm_ui/IBM Plex Sans Arabic';

  /// The Naskh of prayer names and times (Amiri, OFL), bundled in `dm_ui`
  /// (§15 D89).
  static const String naskhFamily = 'packages/dm_ui/Amiri';

  /// Amiri at [size] in [color], bold for the next prayer and the niche.
  static TextStyle naskh({
    required double size,
    required Color color,
    bool bold = false,
  }) => TextStyle(
    fontFamily: naskhFamily,
    fontSize: size,
    height: 1.35,
    color: color,
    fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
  );

  /// The theme for [brightness] and [locale].
  static ThemeData of(Brightness brightness, StatusLocale locale) {
    // Light content surfaces are the Rawdah Garden palette (§15 D89);
    // dark keeps the Appendix G static roles.
    final p = switch (brightness) {
      Brightness.light => const StaticPalette(
        surface: RawdahPalette.pearl,
        onSurface: RawdahPalette.ink,
        primary: RawdahPalette.emerald,
        secondary: RawdahPalette.goldDeep,
        error: RawdahPalette.carpetRed,
      ),
      Brightness.dark => StaticPalette.dark,
    };
    final secondaryInk = switch (brightness) {
      Brightness.light => RawdahPalette.muted,
      Brightness.dark => p.onSurface,
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
    final family = switch (locale) {
      StatusLocale.en => latinFamily,
      StatusLocale.ar => arabicFamily,
    };
    final buttonText = TextStyle(
      fontFamily: family,
      fontFamilyFallback: const [arabicFamily, latinFamily],
      fontSize: 16,
      fontWeight: FontWeight.w600,
    );
    return ThemeData(
      colorScheme: scheme,
      scaffoldBackgroundColor: p.surface,
      fontFamily: family,
      fontFamilyFallback: const [arabicFamily, latinFamily],
      materialTapTargetSize: MaterialTapTargetSize.padded,
      textTheme: TextTheme(
        displayLarge: step(DmScales.display),
        headlineMedium: step(DmScales.headline),
        titleLarge: step(DmScales.title),
        bodyLarge: step(DmScales.body),
        labelMedium: step(DmScales.label).copyWith(color: secondaryInk),
      ),
      // Rawdah component language (§15 D89): illuminated titles, gold
      // hairlines instead of shadows, emerald actions.
      appBarTheme: AppBarTheme(
        backgroundColor: p.surface,
        foregroundColor: p.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: naskh(size: 24, color: p.primary, bold: true),
        shape: const Border(
          bottom: BorderSide(color: RawdahPalette.hairline, width: 0.8),
        ),
      ),
      cardTheme: CardThemeData(
        color: brightness == Brightness.light
            ? const Color(0xFFFFFEFA)
            : p.surface,
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: RawdahPalette.hairline),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: p.primary,
          foregroundColor: brightness == Brightness.light
              ? RawdahPalette.ivory
              : p.surface,
          minimumSize: const Size(64, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: RawdahPalette.gold),
          ),
          textStyle: buttonText,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: p.primary,
          minimumSize: const Size(64, 52),
          side: const BorderSide(color: RawdahPalette.gold, width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: buttonText,
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? RawdahPalette.ivory
              : RawdahPalette.goldDeep,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? p.primary
              : RawdahPalette.sage,
        ),
        trackOutlineColor: const WidgetStatePropertyAll(RawdahPalette.gold),
      ),
      dividerTheme: const DividerThemeData(
        color: RawdahPalette.hairline,
        thickness: 0.8,
      ),
      listTileTheme: ListTileThemeData(iconColor: p.secondary),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: brightness == Brightness.light
            ? const Color(0xFFFFFEFA)
            : p.surface,
        prefixIconColor: p.secondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: RawdahPalette.hairline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: RawdahPalette.hairline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: p.primary, width: 1.6),
        ),
      ),
    );
  }
}
