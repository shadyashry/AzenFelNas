import 'package:daily_muslim/features/radio/domain/radio_playback.dart';
import 'package:daily_muslim/features/radio/domain/radio_station.dart';
import 'package:daily_muslim/l10n/app_localizations.dart';
import 'package:dm_ui/dm_ui.dart';
import 'package:flutter/material.dart';

/// The Radio screen's type (§15 D122): Lora and Inter in English, Noto
/// Naskh Arabic and Noto Sans Arabic in Arabic, all bundled. Sizes are
/// logical pixels and follow the system text size.
@immutable
final class RadioType {
  const new _({
    required this.language,
    required this.overline,
    required this.heading,
    required this.compactHeading,
    required this.tagline,
    required this.stationTitle,
    required this.body,
    required this.sectionTitle,
    required this.rowName,
    required this.secondary,
    required this.label,
    required this.miniTitle,
    required this.miniStatus,
  });

  /// The type for [context]'s language.
  static RadioType of(BuildContext context) =>
      Localizations.localeOf(context).languageCode == 'ar' ? _ar : _en;

  static final RadioType _en = RadioType._(
    language: RadioLanguage.en,
    overline: _ui(StatusLocale.en, 11, 16, FontWeight.w600, spacing: 2.4),
    heading: _display(StatusLocale.en, 27, 34),
    compactHeading: _display(StatusLocale.en, 22, 28),
    tagline: _ui(StatusLocale.en, 13, 19, FontWeight.w400),
    stationTitle: _display(StatusLocale.en, 20, 27),
    body: _ui(StatusLocale.en, 13, 19, FontWeight.w400),
    sectionTitle: _ui(StatusLocale.en, 14, 20, FontWeight.w600),
    rowName: _ui(StatusLocale.en, 13, 18, FontWeight.w500),
    secondary: _ui(StatusLocale.en, 11.5, 16, FontWeight.w400),
    label: _ui(StatusLocale.en, 12, 17, FontWeight.w500),
    miniTitle: _ui(StatusLocale.en, 12.5, 17, FontWeight.w600),
    miniStatus: _ui(StatusLocale.en, 11, 15, FontWeight.w400),
  );

  static final RadioType _ar = RadioType._(
    language: RadioLanguage.ar,
    overline: _ui(StatusLocale.ar, 12, 18, FontWeight.w600),
    heading: _display(StatusLocale.ar, 32, 44),
    compactHeading: _display(StatusLocale.ar, 25, 36),
    tagline: _ui(StatusLocale.ar, 13, 21, FontWeight.w400),
    stationTitle: _display(StatusLocale.ar, 25, 36),
    body: _ui(StatusLocale.ar, 13, 21, FontWeight.w400),
    sectionTitle: _ui(StatusLocale.ar, 15, 22, FontWeight.w600),
    rowName: _ui(StatusLocale.ar, 13, 20, FontWeight.w500),
    secondary: _ui(StatusLocale.ar, 11.5, 18, FontWeight.w400),
    label: _ui(StatusLocale.ar, 12, 18, FontWeight.w500),
    miniTitle: _ui(StatusLocale.ar, 12.5, 19, FontWeight.w600),
    miniStatus: _ui(StatusLocale.ar, 11, 17, FontWeight.w400),
  );

  /// The language the names and descriptions are shown in.
  final RadioLanguage language;

  /// The small capitals above the title.
  final TextStyle overline;

  /// The title.
  final TextStyle heading;

  /// The title in the compact (landscape) header.
  final TextStyle compactHeading;

  /// The line under the title.
  final TextStyle tagline;

  /// The chosen station's name on the player.
  final TextStyle stationTitle;

  /// Body text.
  final TextStyle body;

  /// "Your stations".
  final TextStyle sectionTitle;

  /// A station's name in the list.
  final TextStyle rowName;

  /// Secondary lines.
  final TextStyle secondary;

  /// Small labels: status, source, tabs, the sleep timer.
  final TextStyle label;

  /// The mini player's station.
  final TextStyle miniTitle;

  /// The mini player's status line.
  final TextStyle miniStatus;

  static TextStyle _display(StatusLocale locale, double size, double line) =>
      _style(
        locale == StatusLocale.en
            ? DmTheme.displayLatinFamily
            : DmTheme.naskhFamily,
        locale == StatusLocale.en
            ? DmTheme.naskhFamily
            : DmTheme.displayLatinFamily,
        size,
        line,
        FontWeight.w400,
        0,
      );

  static TextStyle _ui(
    StatusLocale locale,
    double size,
    double line,
    FontWeight weight, {
    double spacing = 0,
  }) => _style(
    locale == StatusLocale.en ? DmTheme.latinFamily : DmTheme.arabicFamily,
    locale == StatusLocale.en ? DmTheme.arabicFamily : DmTheme.latinFamily,
    size,
    line,
    weight,
    spacing,
  );

  static TextStyle _style(
    String family,
    String fallback,
    double size,
    double line,
    FontWeight weight,
    double spacing,
  ) => TextStyle(
    fontFamily: family,
    fontFamilyFallback: [fallback],
    fontSize: size,
    height: line / size,
    leadingDistribution: TextLeadingDistribution.even,
    fontWeight: weight,
    fontVariations: DmTheme.weightAxis(weight),
    letterSpacing: spacing,
  );
}

/// The words for a player state (§18.5 style: what is true, nothing more).
String radioStatusLabel(AppLocalizations l, RadioPhase phase) =>
    switch (phase) {
      RadioPhase.ready => l.radioStatusReady,
      RadioPhase.connecting => l.radioStatusConnecting,
      RadioPhase.playing => l.radioStatusLive,
      RadioPhase.paused => l.radioStatusPaused,
      RadioPhase.reconnecting => l.radioStatusReconnecting,
      RadioPhase.stopped => l.radioStatusStopped,
      RadioPhase.unavailable => l.radioStatusUnavailable,
    };

/// The line under a station's name.
String radioDescription(
  AppLocalizations l,
  RadioStation station,
  RadioLanguage language,
) => switch (station.description) {
  final RadioCuratedDescription d => d.of(language),
  RadioVariantDescription(variant: RadioVariant.plain) => l.radioVariantPlain,
  RadioVariantDescription(variant: RadioVariant.mujawwad) =>
    l.radioVariantMujawwad,
  RadioVariantDescription(variant: RadioVariant.warsh) => l.radioVariantWarsh,
};

/// The sleep timer's choice in words.
String radioSleepValue(AppLocalizations l, RadioSleepOption option) =>
    switch (option) {
      RadioSleepOption.off => l.radioSleepOff,
      RadioSleepOption.minutes15 ||
      RadioSleepOption.minutes30 ||
      RadioSleepOption.minutes60 => l.radioSleepMinutes(option.minutes),
    };
