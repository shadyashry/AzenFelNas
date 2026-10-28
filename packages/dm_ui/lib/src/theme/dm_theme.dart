import 'package:dm_ui/src/copy/status_locale.dart';
import 'package:dm_ui/src/tokens/dm_scales.dart';
import 'package:dm_ui/src/tokens/rawdah_palette.dart';
import 'package:dm_ui/src/tokens/rawdah_scheme.dart';
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

  /// The theme for [brightness] and [locale]: the Rawdah scheme for that
  /// brightness (pearl by day, Nabawi Night in dark mode, §15 D89), carried
  /// as a [RawdahScheme] extension so components follow it.
  static ThemeData of(Brightness brightness, StatusLocale locale) {
    final r = switch (brightness) {
      Brightness.light => RawdahScheme.light,
      Brightness.dark => RawdahScheme.night,
    };
    // Filled actions stay emerald in both modes, ivory on top.
    final action = switch (brightness) {
      Brightness.light => r.primary,
      Brightness.dark => const Color(0xFF1F7A55),
    };
    final scheme =
        ColorScheme.fromSeed(
          seedColor: r.primary,
          brightness: brightness,
        ).copyWith(
          surface: r.ground,
          onSurface: r.ink,
          primary: r.primary,
          secondary: r.accent,
          error: r.error,
        );
    final extra = switch (locale) {
      StatusLocale.en => 0.0,
      StatusLocale.ar => DmScales.arabicExtraLine,
    };
    TextStyle step(TypeStep s) => TextStyle(
      fontSize: s.size,
      height: (s.lineHeight + extra) / s.size,
      color: r.ink,
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
    final hairline = BorderSide(color: r.hairline);
    return ThemeData(
      colorScheme: scheme,
      scaffoldBackgroundColor: r.ground,
      fontFamily: family,
      fontFamilyFallback: const [arabicFamily, latinFamily],
      materialTapTargetSize: MaterialTapTargetSize.padded,
      extensions: [r],
      textTheme: TextTheme(
        displayLarge: step(DmScales.display),
        headlineMedium: step(DmScales.headline),
        titleLarge: step(DmScales.title),
        bodyLarge: step(DmScales.body),
        labelMedium: step(DmScales.label).copyWith(color: r.inkMuted),
      ),
      // Rawdah component language (§15 D89): illuminated titles, gold
      // hairlines instead of shadows, emerald actions.
      appBarTheme: AppBarTheme(
        backgroundColor: r.ground,
        foregroundColor: r.ink,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: naskh(size: 24, color: r.primary, bold: true),
        shape: Border(bottom: hairline.copyWith(width: 0.8)),
      ),
      cardTheme: CardThemeData(
        color: r.panel,
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: hairline,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: action,
          foregroundColor: RawdahPalette.ivory,
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
          foregroundColor: r.primary,
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
              : r.accent,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? action : r.wash,
        ),
        trackOutlineColor: const WidgetStatePropertyAll(RawdahPalette.gold),
      ),
      dividerTheme: DividerThemeData(color: r.hairline, thickness: 0.8),
      listTileTheme: ListTileThemeData(iconColor: r.accent),
      dropdownMenuTheme: DropdownMenuThemeData(
        menuStyle: MenuStyle(backgroundColor: WidgetStatePropertyAll(r.panel)),
      ),
      canvasColor: r.panel,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: r.panel,
        prefixIconColor: r.accent,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: hairline,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: hairline,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: r.primary, width: 1.6),
        ),
      ),
    );
  }
}
