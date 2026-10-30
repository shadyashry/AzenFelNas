import 'package:dm_ui/src/copy/status_locale.dart';
import 'package:dm_ui/src/theme/dm_theme.dart';
import 'package:flutter/painting.dart';
import 'package:meta/meta.dart';

/// The Horizon type scale for one interface language (§15 D109): size,
/// line height and weight of every text role on Home, in logical pixels at
/// the default text scale (the platform's text scaling applies once, on
/// top). English sets display text in Lora and interface text in Inter;
/// Arabic in Noto Naskh Arabic and Noto Sans Arabic, with the taller line
/// heights Arabic marks need. No letter spacing anywhere; changing digits
/// use tabular figures. Colours come from the component.
@immutable
final class DmType {
  /// A scale; use [of].
  const new({
    required this.location,
    required this.nextName,
    required this.nextTime,
    required this.nextPeriod,
    required this.countdown,
    required this.arcLabel,
    required this.sectionHeading,
    required this.rowName,
    required this.rowTime,
    required this.rowPeriod,
    required this.quranLabel,
    required this.quranTitle,
    required this.offline,
    required this.resume,
    required this.navLabel,
    required this.supporting,
  });

  /// The scale of [locale].
  static DmType of(StatusLocale locale) => switch (locale) {
    StatusLocale.en => en,
    StatusLocale.ar => ar,
  };

  /// English.
  static final DmType en = DmType(
    location: _display(StatusLocale.en, 20, 28, FontWeight.w500),
    nextName: _display(StatusLocale.en, 40, 52, FontWeight.w600),
    nextTime: _display(StatusLocale.en, 56, 66, FontWeight.w500, digits: true),
    nextPeriod: _ui(StatusLocale.en, 18, 26, FontWeight.w500),
    countdown: _ui(StatusLocale.en, 17, 26, FontWeight.w400, digits: true),
    arcLabel: _display(StatusLocale.en, 13, 20, FontWeight.w500),
    sectionHeading: _display(StatusLocale.en, 22, 30, FontWeight.w600),
    rowName: _display(StatusLocale.en, 14, 22, FontWeight.w500),
    rowTime: _display(StatusLocale.en, 20, 28, FontWeight.w500, digits: true),
    rowPeriod: _ui(StatusLocale.en, 12, 18, FontWeight.w500),
    quranLabel: _ui(StatusLocale.en, 14, 22, FontWeight.w500),
    quranTitle: _display(StatusLocale.en, 20, 30, FontWeight.w600),
    offline: _ui(StatusLocale.en, 12, 18, FontWeight.w400),
    resume: _ui(StatusLocale.en, 14, 22, FontWeight.w600),
    navLabel: _ui(StatusLocale.en, 12, 18, FontWeight.w500),
    supporting: _ui(StatusLocale.en, 14, 22, FontWeight.w400),
  );

  /// Arabic.
  static final DmType ar = DmType(
    location: _display(StatusLocale.ar, 22, 34, FontWeight.w600),
    nextName: _display(StatusLocale.ar, 42, 63, FontWeight.w600),
    nextTime: _display(StatusLocale.ar, 60, 80, FontWeight.w600, digits: true),
    nextPeriod: _ui(StatusLocale.ar, 18, 28, FontWeight.w500),
    countdown: _ui(StatusLocale.ar, 17, 29, FontWeight.w400, digits: true),
    arcLabel: _display(StatusLocale.ar, 15, 25, FontWeight.w500),
    sectionHeading: _display(StatusLocale.ar, 24, 36, FontWeight.w600),
    rowName: _display(StatusLocale.ar, 16, 27, FontWeight.w500),
    rowTime: _display(StatusLocale.ar, 22, 32, FontWeight.w600, digits: true),
    rowPeriod: _ui(StatusLocale.ar, 12, 21, FontWeight.w500),
    quranLabel: _ui(StatusLocale.ar, 14, 24, FontWeight.w500),
    quranTitle: _display(StatusLocale.ar, 22, 35, FontWeight.w600),
    offline: _ui(StatusLocale.ar, 12, 21, FontWeight.w400),
    resume: _ui(StatusLocale.ar, 14, 24, FontWeight.w600),
    navLabel: _ui(StatusLocale.ar, 12, 21, FontWeight.w500),
    supporting: _ui(StatusLocale.ar, 14, 24, FontWeight.w400),
  );

  /// Place name in the header.
  final TextStyle location;

  /// The next prayer's name.
  final TextStyle nextName;

  /// The next prayer's time digits.
  final TextStyle nextTime;

  /// The AM/PM marker beside [nextTime].
  final TextStyle nextPeriod;

  /// The time left.
  final TextStyle countdown;

  /// The prayer arc's labels.
  final TextStyle arcLabel;

  /// A section heading on cream ("Today").
  final TextStyle sectionHeading;

  /// A prayer's name in the day's row.
  final TextStyle rowName;

  /// A prayer's time digits in the day's row.
  final TextStyle rowTime;

  /// The AM/PM marker under [rowTime].
  final TextStyle rowPeriod;

  /// "Continue Quran".
  final TextStyle quranLabel;

  /// The saved surah and page.
  final TextStyle quranTitle;

  /// "Available offline".
  final TextStyle offline;

  /// The resume action's label.
  final TextStyle resume;

  /// Bottom navigation labels.
  final TextStyle navLabel;

  /// General supporting text.
  final TextStyle supporting;

  static TextStyle _display(
    StatusLocale locale,
    double size,
    double lineHeight,
    FontWeight weight, {
    bool digits = false,
  }) => _style(
    family: switch (locale) {
      StatusLocale.en => DmTheme.displayLatinFamily,
      StatusLocale.ar => DmTheme.naskhFamily,
    },
    fallback: switch (locale) {
      StatusLocale.en => const [DmTheme.naskhFamily],
      StatusLocale.ar => const [DmTheme.displayLatinFamily],
    },
    size: size,
    lineHeight: lineHeight,
    weight: weight,
    digits: digits,
  );

  static TextStyle _ui(
    StatusLocale locale,
    double size,
    double lineHeight,
    FontWeight weight, {
    bool digits = false,
  }) => _style(
    family: switch (locale) {
      StatusLocale.en => DmTheme.latinFamily,
      StatusLocale.ar => DmTheme.arabicFamily,
    },
    fallback: switch (locale) {
      StatusLocale.en => const [DmTheme.arabicFamily],
      StatusLocale.ar => const [DmTheme.latinFamily],
    },
    size: size,
    lineHeight: lineHeight,
    weight: weight,
    digits: digits,
  );

  static TextStyle _style({
    required String family,
    required List<String> fallback,
    required double size,
    required double lineHeight,
    required FontWeight weight,
    required bool digits,
  }) => TextStyle(
    fontFamily: family,
    fontFamilyFallback: fallback,
    fontSize: size,
    height: lineHeight / size,
    // Extra line height is shared above and below the glyphs, so Arabic
    // marks keep their room on both sides.
    leadingDistribution: TextLeadingDistribution.even,
    fontWeight: weight,
    fontStyle: FontStyle.normal,
    letterSpacing: 0,
    fontVariations: DmTheme.weightAxis(weight),
    fontFeatures: [
      if (digits) const FontFeature.tabularFigures(),
    ],
  );
}
