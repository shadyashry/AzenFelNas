import 'package:flutter/painting.dart';

/// The Emerald horizon palette of the welcome screen (§15 D126): a deep
/// emerald hero over a warm ivory panel. These colours belong to the first
/// run only; every other page keeps `RawdahScheme` and its dark mode.
abstract final class EmeraldPalette {
  /// The hero and the status bar area.
  static const Color hero = Color(0xFF073C2F);

  /// The radial glow behind the logo, drawn at [glowOpacity].
  static const Color glow = Color(0xFF20714D);

  /// The glow's opacity at its centre.
  static const double glowOpacity = 0.42;

  /// The hero headline.
  static const Color headline = Color(0xFFFFF5DF);

  /// The gold eyebrow above the headline.
  static const Color eyebrow = Color(0xFFD0BB82);

  /// The "Welcome" label of the header.
  static const Color welcome = Color(0xFFC7D7CA);

  /// The language selector's track.
  static const Color selectorTrack = Color(0xFF144C3D);

  /// The language selector's border, drawn at [selectorBorderOpacity].
  static const Color selectorBorder = Color(0xFFBDA465);

  /// The opacity of [selectorBorder].
  static const double selectorBorderOpacity = 0.3;

  /// The selected language segment.
  static const Color selectorSelected = Color(0xFFF4EDDB);

  /// The text of the selected language segment.
  static const Color selectorSelectedText = Color(0xFF103F32);

  /// The text of an unselected language segment.
  static const Color selectorText = Color(0xFFDDDCC6);

  /// The curved horizon line, drawn at [horizonOpacity].
  static const Color horizon = Color(0xFFC9AC60);

  /// The opacity of [horizon].
  static const double horizonOpacity = 0.55;

  /// The ivory panel and the city picker's page.
  static const Color panel = Color(0xFFF7F4E9);

  /// Headings and main text on the panel.
  static const Color ink = Color(0xFF0B4034);

  /// Secondary text and quiet icons on the panel.
  static const Color inkMuted = Color(0xFF596D63);

  /// The primary action.
  static const Color action = Color(0xFF0A4939);

  /// Text and icons on [action].
  static const Color onAction = Color(0xFFFFFDF5);

  /// The secondary action and the search field.
  static const Color surface = Color(0xFFFFFDF7);

  /// The thin warm border of [surface].
  static const Color surfaceBorder = Color(0xFFDED7C4);

  /// The quiet divider of the panel.
  static const Color divider = Color(0xFFDFDDCD);

  /// The soft supporting green: a selected city, a notice, a status pill.
  static const Color wash = Color(0xFFE9EEE4);

  /// The setup-completion glow (§15 D127), drawn at [glowOpacity].
  static const Color confirmGlow = Color(0xFF23744E);

  /// The fine outline of the completion check (§15 D127).
  static const Color confirmRing = Color(0xFFBFA567);

  /// Supporting paragraphs on the panel (§15 D127).
  static const Color support = Color(0xFF435D50);
}
