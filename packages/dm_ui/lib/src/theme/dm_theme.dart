import 'package:dm_ui/src/copy/status_locale.dart';
import 'package:dm_ui/src/tokens/dm_scales.dart';
import 'package:dm_ui/src/tokens/rawdah_palette.dart';
import 'package:dm_ui/src/tokens/rawdah_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// The static Material theme of content surfaces (§7.9, Appendix G).
abstract final class DmTheme {
  /// Latin family (OFL), bundled in `dm_ui` (§15 D75, D89).
  static const String latinFamily = 'packages/dm_ui/Inter';

  /// Arabic family (OFL), bundled in `dm_ui` (§15 D75, D89).
  static const String arabicFamily = 'packages/dm_ui/IBM Plex Sans Arabic';

  /// The Naskh of prayer names and times (Amiri, OFL), bundled in `dm_ui`
  /// (§15 D89).
  static const String naskhFamily = 'packages/dm_ui/Amiri';

  /// The status bar over a ground of [ground] brightness (§15 D101):
  /// dark icons on cream, light icons on night, forest green and the Home
  /// hero. Transparent, since the app is drawn edge to edge.
  static SystemUiOverlayStyle statusBarOn(Brightness ground) =>
      switch (ground) {
        Brightness.light => SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Colors.transparent,
        ),
        Brightness.dark => SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Colors.transparent,
        ),
      };

  /// Amiri at [size] in [color], bold for the next prayer and titles.
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

  /// The theme for [brightness] and [locale]: the scheme for that
  /// brightness (cream by day, Nabawi Night in dark mode, §15 D89, D102),
  /// carried as a [RawdahScheme] extension so components follow it. Gold is
  /// kept for thin borders, key icons and the selected tab; filled actions
  /// are forest green with ivory text.
  static ThemeData of(Brightness brightness, StatusLocale locale) {
    final r = switch (brightness) {
      Brightness.light => RawdahScheme.light,
      Brightness.dark => RawdahScheme.night,
    };
    // Filled actions stay green in both modes, ivory on top.
    final action = switch (brightness) {
      Brightness.light => RawdahPalette.forest,
      Brightness.dark => RawdahPalette.emerald,
    };
    final scheme =
        ColorScheme.fromSeed(
          seedColor: RawdahPalette.forest,
          brightness: brightness,
        ).copyWith(
          surface: r.ground,
          onSurface: r.ink,
          onSurfaceVariant: r.inkMuted,
          surfaceContainerLowest: r.panel,
          surfaceContainerLow: r.panel,
          surfaceContainer: r.panel,
          surfaceContainerHigh: r.panel,
          surfaceContainerHighest: r.wash,
          primary: r.primary,
          onPrimary: switch (brightness) {
            Brightness.light => RawdahPalette.ivory,
            Brightness.dark => RawdahPalette.emeraldDeep,
          },
          secondary: r.accent,
          secondaryContainer: r.wash,
          onSecondaryContainer: r.ink,
          outline: r.inkMuted,
          outlineVariant: r.hairline,
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
    final control = BorderRadius.circular(DmScales.radiusControl);
    const sheet = Radius.circular(DmScales.radiusSheet);
    WidgetStateProperty<T> selected<T>(T on, T off) =>
        WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? on : off,
        );
    return ThemeData(
      colorScheme: scheme,
      scaffoldBackgroundColor: r.ground,
      fontFamily: family,
      fontFamilyFallback: const [arabicFamily, latinFamily],
      materialTapTargetSize: MaterialTapTargetSize.padded,
      extensions: [r],
      // Focus and press washes that read on cream and on night.
      focusColor: r.primary.withValues(alpha: 0.14),
      hoverColor: r.primary.withValues(alpha: 0.06),
      splashColor: r.primary.withValues(alpha: 0.10),
      highlightColor: r.primary.withValues(alpha: 0.06),
      iconTheme: IconThemeData(color: r.ink, size: DmScales.iconLarge),
      textTheme: TextTheme(
        displayLarge: step(DmScales.display),
        headlineMedium: step(DmScales.headline),
        titleLarge: step(DmScales.title),
        titleMedium: step(DmScales.body).copyWith(fontWeight: FontWeight.w600),
        bodyLarge: step(DmScales.body),
        labelMedium: step(DmScales.label).copyWith(color: r.inkMuted),
      ),
      // Secondary screens are quiet: cream ground, a Naskh title in forest
      // green, a hairline instead of a shadow.
      appBarTheme: AppBarTheme(
        backgroundColor: r.ground,
        foregroundColor: r.ink,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: r.primary, size: DmScales.iconLarge),
        titleTextStyle: naskh(size: 24, color: r.primary, bold: true),
        systemOverlayStyle: statusBarOn(brightness),
        shape: Border(bottom: hairline.copyWith(width: 0.8)),
      ),
      cardTheme: CardThemeData(
        color: r.panel,
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DmScales.radiusCard),
          side: hairline,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: action,
          foregroundColor: RawdahPalette.ivory,
          disabledBackgroundColor: r.wash,
          disabledForegroundColor: r.inkMuted,
          minimumSize: const Size(64, 52),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          shape: const StadiumBorder(),
          textStyle: buttonText,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: r.primary,
          disabledForegroundColor: r.inkMuted,
          minimumSize: const Size(64, 52),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          side: BorderSide(color: r.primary, width: 1.2),
          shape: const StadiumBorder(),
          textStyle: buttonText,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: r.primary,
          minimumSize: const Size(48, 48),
          textStyle: buttonText,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: r.primary,
          minimumSize: const Size(48, 48),
        ),
      ),
      // Anything switched on is green, in both modes (§15 D100).
      switchTheme: SwitchThemeData(
        thumbColor: selected(RawdahPalette.ivory, r.inkMuted),
        trackColor: selected(RawdahPalette.enabled, r.wash),
        trackOutlineColor: selected(RawdahPalette.enabled, r.inkMuted),
        thumbIcon: selected<Icon?>(
          const Icon(Icons.check, color: RawdahPalette.enabled),
          null,
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: selected(RawdahPalette.enabled, Colors.transparent),
        checkColor: const WidgetStatePropertyAll(RawdahPalette.ivory),
        side: BorderSide(color: r.inkMuted, width: 1.6),
      ),
      radioTheme: RadioThemeData(
        fillColor: selected(RawdahPalette.enabled, r.inkMuted),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: selected(RawdahPalette.enabled, r.panel),
          foregroundColor: selected(RawdahPalette.ivory, r.ink),
          iconColor: selected(RawdahPalette.ivory, r.ink),
          side: WidgetStatePropertyAll(BorderSide(color: r.hairline)),
          minimumSize: const WidgetStatePropertyAll(Size(48, 48)),
          textStyle: WidgetStatePropertyAll(buttonText),
        ),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: r.primary,
        unselectedLabelColor: r.inkMuted,
        indicatorColor: RawdahPalette.gold,
        dividerColor: r.hairline,
        labelStyle: buttonText,
        unselectedLabelStyle: buttonText.copyWith(fontWeight: FontWeight.w500),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: r.wash,
        selectedColor: r.wash,
        side: BorderSide(color: r.hairline),
        labelStyle: TextStyle(color: r.ink),
        shape: const StadiumBorder(),
      ),
      dividerTheme: DividerThemeData(color: r.hairline, thickness: 0.8),
      listTileTheme: ListTileThemeData(
        iconColor: r.accent,
        textColor: r.ink,
        selectedColor: r.primary,
        selectedTileColor: r.wash,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: r.primary,
        linearTrackColor: r.wash,
        circularTrackColor: r.wash,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: r.panel,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DmScales.radiusSheet),
          side: hairline,
        ),
        titleTextStyle: naskh(size: 22, color: r.primary, bold: true),
        contentTextStyle: step(DmScales.body),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: r.panel,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        dragHandleColor: r.hairline,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: sheet),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: r.panel,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: control, side: hairline),
      ),
      menuTheme: MenuThemeData(style: _menu(r, control, hairline)),
      dropdownMenuTheme: DropdownMenuThemeData(
        menuStyle: _menu(r, control, hairline),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: RawdahPalette.emeraldDeep,
        contentTextStyle: buttonText.copyWith(
          color: RawdahPalette.ivory,
          fontWeight: FontWeight.w400,
        ),
        actionTextColor: RawdahPalette.goldLight,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: control),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: RawdahPalette.emeraldDeep,
          borderRadius: BorderRadius.circular(DmScales.radius[0]),
        ),
        textStyle: const TextStyle(color: RawdahPalette.ivory, fontSize: 13),
      ),
      canvasColor: r.panel,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: r.panel,
        prefixIconColor: r.accent,
        suffixIconColor: r.inkMuted,
        hintStyle: TextStyle(color: r.inkMuted),
        border: OutlineInputBorder(borderRadius: control, borderSide: hairline),
        enabledBorder: OutlineInputBorder(
          borderRadius: control,
          borderSide: hairline,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: control,
          borderSide: BorderSide(color: r.primary, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: control,
          borderSide: BorderSide(color: r.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: control,
          borderSide: BorderSide(color: r.error, width: 1.6),
        ),
      ),
    );
  }

  static MenuStyle _menu(
    RawdahScheme r,
    BorderRadius radius,
    BorderSide hairline,
  ) => MenuStyle(
    backgroundColor: WidgetStatePropertyAll(r.panel),
    surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
    shape: WidgetStatePropertyAll(
      RoundedRectangleBorder(borderRadius: radius, side: hairline),
    ),
  );
}
