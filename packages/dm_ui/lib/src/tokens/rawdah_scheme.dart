import 'package:flutter/material.dart';

/// The content-surface colours for one brightness (§7.9, §15 D89, D102,
/// D119), carried on the theme so every component follows light and dark:
/// cream by day, Horizon Dark at night. Three surface levels stay distinct
/// by colour, not shadow: [ground] (the page), [panel] (content surfaces)
/// and [raised] (cards, dialogs, sheets, menus).
///
/// Text roles meet WCAG 2.2 AA (4.5:1) on [ground], [panel], [raised] and
/// [selection], and [accent] meets 3:1 for icons and marks (REQ-UX-010,
/// pinned by `rawdah_scheme_test.dart`).
@immutable
final class RawdahScheme extends ThemeExtension<RawdahScheme> {
  /// Creates a scheme.
  const new({
    required this.ground,
    required this.panel,
    required this.ink,
    required this.inkMuted,
    required this.primary,
    required this.accent,
    required this.hairline,
    required this.wash,
    required this.error,
    required this.raised,
    required this.navBar,
    required this.caption,
    required this.selection,
    required this.selectionLine,
    required this.switchedOn,
  });

  /// Cream: the day scheme.
  static const RawdahScheme light = RawdahScheme(
    ground: Color(0xFFF4F2E5),
    panel: Color(0xFFFFFCF4),
    ink: Color(0xFF173B30),
    inkMuted: Color(0xFF526359),
    primary: Color(0xFF0B3F32),
    accent: Color(0xFF8E6B2B),
    hairline: Color(0xFFE4DABD),
    wash: Color(0xFFE3EBDD),
    error: Color(0xFF9B2C2C),
    raised: Color(0xFFFFFCF4),
    navBar: Color(0xFF062E25),
    caption: Color(0xFF526359),
    selection: Color(0xFFF4E2B6),
    selectionLine: Color(0x00000000),
    switchedOn: Color(0xFF197A4B),
  );

  /// Horizon Dark (the owner's tokens, §15 D119): a deep green ground, a
  /// lighter content surface and raised cards, warm ivory for what matters,
  /// readable sage for the rest and restrained gold for selection and
  /// important actions.
  static const RawdahScheme night = RawdahScheme(
    ground: Color(0xFF061A15),
    panel: Color(0xFF0C2720),
    ink: Color(0xFFF0EDDF),
    inkMuted: Color(0xFFB6C4B8),
    primary: Color(0xFFF0EDDF),
    accent: Color(0xFFD2B373),
    hairline: Color(0xFF29463B),
    wash: Color(0xFF12382D),
    error: Color(0xFFEE9A8A),
    raised: Color(0xFF12382D),
    navBar: Color(0xFF071F18),
    caption: Color(0xFFA3B5A8),
    selection: Color(0xFF2D3625),
    selectionLine: Color(0xFFD2B373),
    switchedOn: Color(0xFF218C57),
  );

  /// The scheme of [context]'s theme; the day scheme when none is set.
  static RawdahScheme of(BuildContext context) =>
      Theme.of(context).extension<RawdahScheme>() ?? light;

  /// Page ground.
  final Color ground;

  /// Raised panels: sections, cards, fields.
  final Color panel;

  /// Body text.
  final Color ink;

  /// Secondary text.
  final Color inkMuted;

  /// Headings, the next prayer, emerald actions.
  final Color primary;

  /// Gold for icons and small marks.
  final Color accent;

  /// Hairlines between rows and around panels.
  final Color hairline;

  /// The wash of a highlighted row or the tapped Passport entry.
  final Color wash;

  /// Errors and "not ready".
  final Color error;

  /// Raised cards, dialogs, sheets and menus: a step above [panel].
  final Color raised;

  /// The bottom navigation bar.
  final Color navBar;

  /// Muted captions: units, notes, sources.
  final Color caption;

  /// The selected prayer's tile.
  final Color selection;

  /// The fine outline of the selected prayer's tile (none by day).
  final Color selectionLine;

  /// The green of a switch, box or radio that is on (§15 D100): 3:1 off
  /// [panel] in both modes, so a touch brighter at night.
  final Color switchedOn;

  @override
  RawdahScheme copyWith({
    Color? ground,
    Color? panel,
    Color? ink,
    Color? inkMuted,
    Color? primary,
    Color? accent,
    Color? hairline,
    Color? wash,
    Color? error,
    Color? raised,
    Color? navBar,
    Color? caption,
    Color? selection,
    Color? selectionLine,
    Color? switchedOn,
  }) => RawdahScheme(
    ground: ground ?? this.ground,
    panel: panel ?? this.panel,
    ink: ink ?? this.ink,
    inkMuted: inkMuted ?? this.inkMuted,
    primary: primary ?? this.primary,
    accent: accent ?? this.accent,
    hairline: hairline ?? this.hairline,
    wash: wash ?? this.wash,
    error: error ?? this.error,
    raised: raised ?? this.raised,
    navBar: navBar ?? this.navBar,
    caption: caption ?? this.caption,
    selection: selection ?? this.selection,
    selectionLine: selectionLine ?? this.selectionLine,
    switchedOn: switchedOn ?? this.switchedOn,
  );

  @override
  RawdahScheme lerp(RawdahScheme? other, double t) {
    if (other == null) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t) ?? a;
    return RawdahScheme(
      ground: mix(ground, other.ground),
      panel: mix(panel, other.panel),
      ink: mix(ink, other.ink),
      inkMuted: mix(inkMuted, other.inkMuted),
      primary: mix(primary, other.primary),
      accent: mix(accent, other.accent),
      hairline: mix(hairline, other.hairline),
      wash: mix(wash, other.wash),
      error: mix(error, other.error),
      raised: mix(raised, other.raised),
      navBar: mix(navBar, other.navBar),
      caption: mix(caption, other.caption),
      selection: mix(selection, other.selection),
      selectionLine: mix(selectionLine, other.selectionLine),
      switchedOn: mix(switchedOn, other.switchedOn),
    );
  }
}
