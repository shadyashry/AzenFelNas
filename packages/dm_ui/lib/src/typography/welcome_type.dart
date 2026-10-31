import 'package:dm_ui/src/copy/status_locale.dart';
import 'package:dm_ui/src/theme/dm_theme.dart';
import 'package:flutter/painting.dart';
import 'package:meta/meta.dart';

/// The Emerald horizon type scale of the welcome screen and its city picker
/// (§15 D126): size, line height and weight of every role in logical pixels
/// at the default text scale (the platform's text scaling applies on top).
/// English sets display text in Gelasio, a Georgia-metric serif standing in
/// for Georgia, and interface text in DM Sans; Arabic sets the headline in
/// Amiri and everything else in Noto Sans Arabic, never letter-spaced.
/// The compact scale is that of narrow phones: the English headline 30 and the
/// actions 15. Colours come from the component.
@immutable
final class WelcomeType {
  /// A scale; use [of].
  const new({
    required this.headline,
    required this.eyebrow,
    required this.welcome,
    required this.heading,
    required this.paragraph,
    required this.action,
    required this.privacy,
    required this.caption,
    required this.cityName,
  });

  factory _english({
    required double headline,
    required double action,
  }) => WelcomeType(
    headline: _style(
      family: serifFamily,
      fallback: const [DmTheme.arabicFamily],
      size: headline,
      lineHeight: headline * 38.5 / 32,
      weight: FontWeight.w400,
      letterSpacing: -0.8 * headline / 32,
    ),
    eyebrow: _sans(12, 18, FontWeight.w500),
    welcome: _sans(13, 20, FontWeight.w500),
    heading: _style(
      family: serifFamily,
      fallback: const [DmTheme.arabicFamily],
      size: 22,
      lineHeight: 31,
      weight: FontWeight.w400,
    ),
    paragraph: _sans(15, 25.5, FontWeight.w400),
    action: _sans(action, action + 6, FontWeight.w500),
    privacy: _sans(12, 18, FontWeight.w400),
    caption: _sans(12, 17, FontWeight.w400),
    cityName: _sans(16, 22, FontWeight.w500),
  );

  factory _arabic({required double action}) => WelcomeType(
    headline: _style(
      family: arabicDisplayFamily,
      fallback: const [DmTheme.arabicFamily, serifFamily],
      size: 35,
      lineHeight: 47,
      weight: FontWeight.w400,
    ),
    eyebrow: _arabicUi(12, 20, FontWeight.w500),
    welcome: _arabicUi(13, 22, FontWeight.w500),
    heading: _arabicUi(20, 32, FontWeight.w400),
    paragraph: _arabicUi(15, 28.5, FontWeight.w400),
    action: _arabicUi(action, action + 10, FontWeight.w500),
    privacy: _arabicUi(12, 20, FontWeight.w400),
    caption: _arabicUi(12, 19, FontWeight.w400),
    cityName: _arabicUi(16, 26, FontWeight.w500),
  );

  /// DM Sans (OFL), bundled in `dm_ui`.
  static const String sansFamily = 'packages/dm_ui/DM Sans';

  /// Gelasio (OFL), bundled in `dm_ui`: metrically compatible with Georgia,
  /// which may not be redistributed.
  static const String serifFamily = 'packages/dm_ui/Gelasio';

  /// Amiri (OFL), bundled in `dm_ui`: the Arabic headline.
  static const String arabicDisplayFamily = 'packages/dm_ui/Amiri';

  /// The scale of [locale]; [compact] on narrow phones.
  static WelcomeType of(StatusLocale locale, {bool compact = false}) =>
      switch ((locale, compact)) {
        (StatusLocale.en, false) => en,
        (StatusLocale.en, true) => enCompact,
        (StatusLocale.ar, false) => ar,
        (StatusLocale.ar, true) => arCompact,
      };

  /// English.
  static final WelcomeType en = WelcomeType._english(headline: 32, action: 16);

  /// English on narrow phones.
  static final WelcomeType enCompact = WelcomeType._english(
    headline: 30,
    action: 15,
  );

  /// Arabic.
  static final WelcomeType ar = WelcomeType._arabic(action: 16);

  /// Arabic on narrow phones.
  static final WelcomeType arCompact = WelcomeType._arabic(action: 15);

  /// A language's own name in its own script on the language selector:
  /// DM Sans for "English", Noto Sans Arabic for «العربية».
  static TextStyle languageLabel(StatusLocale script) => switch (script) {
    StatusLocale.en => _sans(12, 16, FontWeight.w500),
    StatusLocale.ar => _arabicUi(12, 18, FontWeight.w500),
  };

  /// The large ivory headline.
  final TextStyle headline;

  /// The gold line above the headline.
  final TextStyle eyebrow;

  /// "Welcome" in the header.
  final TextStyle welcome;

  /// The panel's heading and the city picker's title.
  final TextStyle heading;

  /// The panel's paragraph, the picker's line and its search text.
  final TextStyle paragraph;

  /// The labels of the actions.
  final TextStyle action;

  /// The privacy sentence and a city's country line.
  final TextStyle privacy;

  /// The feature captions.
  final TextStyle caption;

  /// A city's name in the picker.
  final TextStyle cityName;

  /// DM Sans with its optical size following the text size, as browsers
  /// set it by default.
  static TextStyle _sans(double size, double lineHeight, FontWeight weight) =>
      _style(
        family: sansFamily,
        fallback: const [DmTheme.arabicFamily],
        size: size,
        lineHeight: lineHeight,
        weight: weight,
        opticalSize: true,
      );

  static TextStyle _arabicUi(
    double size,
    double lineHeight,
    FontWeight weight,
  ) => _style(
    family: DmTheme.arabicFamily,
    fallback: const [sansFamily],
    size: size,
    lineHeight: lineHeight,
    weight: weight,
  );

  static TextStyle _style({
    required String family,
    required List<String> fallback,
    required double size,
    required double lineHeight,
    required FontWeight weight,
    double letterSpacing = 0,
    bool opticalSize = false,
  }) => TextStyle(
    fontFamily: family,
    fontFamilyFallback: fallback,
    fontSize: size,
    height: lineHeight / size,
    leadingDistribution: TextLeadingDistribution.even,
    fontWeight: weight,
    fontStyle: FontStyle.normal,
    letterSpacing: letterSpacing,
    fontVariations: [
      ...DmTheme.weightAxis(weight),
      if (opticalSize) FontVariation.opticalSize(size),
    ],
  );
}
