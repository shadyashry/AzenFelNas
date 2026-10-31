import 'package:flutter/material.dart';

/// The Mushaf reader's colours for one brightness (§15 D123): the reading
/// surface, the ink the frameless pages are drawn in, and the green bars
/// that float over the page while the controls are shown. The owner's
/// tokens: warm ivory with Madinah green by day, a deep green reading
/// surface with warm ivory lettering at night, restrained gold in both.
///
/// Text on [bar] meets WCAG 2.2 AA (4.5:1), [ink] stands at least 7:1 on
/// [surface] and [gold] meets 3:1 on [bar] (pinned by
/// `mushaf_palette_test.dart`).
@immutable
final class MushafPalette {
  /// Creates a palette.
  const new({
    required this.surface,
    required this.ink,
    required this.text,
    required this.textMuted,
    required this.green,
    required this.bar,
    required this.onBar,
    required this.onBarMuted,
    required this.gold,
    required this.track,
    required this.handle,
  });

  /// By day: warm ivory, Madinah green and gold.
  static const MushafPalette light = MushafPalette(
    surface: Color(0xFFFBF8EE),
    ink: Color(0xFF1C1B17),
    text: Color(0xFF25372E),
    textMuted: Color(0xFF657566),
    green: Color(0xFF143F33),
    bar: Color(0xFF143F33),
    onBar: Color(0xFFF3EEDF),
    onBarMuted: Color(0xFFC9D3C3),
    gold: Color(0xFFC3A66B),
    track: Color(0xFFE9E5D8),
    handle: Color(0xFFE6E0CF),
  );

  /// At night: a deep green reading surface, warm ivory lettering.
  static const MushafPalette dark = MushafPalette(
    surface: Color(0xFF083B2D),
    ink: Color(0xFFF1EADA),
    text: Color(0xFFE6DFCF),
    textMuted: Color(0xFFBCC7B3),
    green: Color(0xFF164A38),
    bar: Color(0xFF164A38),
    onBar: Color(0xFFE6DFCF),
    onBarMuted: Color(0xFFBCC7B3),
    gold: Color(0xFFBEA36E),
    track: Color(0xFF3A4A42),
    handle: Color(0xFF1E5541),
  );

  /// The palette for [context]'s theme brightness.
  static MushafPalette of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? dark : light;

  /// The reading surface behind the page.
  final Color surface;

  /// The Quran lettering, its marks and ornaments.
  final Color ink;

  /// Interface text on [surface].
  final Color text;

  /// Secondary interface text on [surface].
  final Color textMuted;

  /// The main green.
  final Color green;

  /// The floating toolbar and page navigation.
  final Color bar;

  /// Text and icons on [bar].
  final Color onBar;

  /// Secondary text on [bar].
  final Color onBarMuted;

  /// Gold accents: the slider's progress, outlines, the selected state.
  final Color gold;

  /// The slider's track before the handle.
  final Color track;

  /// The small *…* handle that brings the controls back.
  final Color handle;
}
