import 'package:flutter/material.dart';

/// The content-surface colours for one brightness (§7.9, §15 D89, D102),
/// carried on the theme so every component follows light and dark: cream
/// by day, Nabawi Night in dark mode. The Home hero, the navigation bar and
/// the gold of rules and ornaments are the same in both.
///
/// Text roles meet WCAG 2.2 AA (4.5:1) on [panel] and [ground], and
/// [accent] meets 3:1 for icons and marks (REQ-UX-010, pinned by
/// `rawdah_scheme_test.dart`).
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
  );

  /// Nabawi Night: deep forest ground, raised green panels, ivory ink,
  /// light emerald headings and gold marks.
  static const RawdahScheme night = RawdahScheme(
    ground: Color(0xFF041C16),
    panel: Color(0xFF08221C),
    ink: Color(0xFFF3EEDD),
    inkMuted: Color(0xFFA9BAAF),
    primary: Color(0xFF9AD8B5),
    accent: Color(0xFFE0BD6E),
    hairline: Color(0xFF24463B),
    wash: Color(0xFF123B30),
    error: Color(0xFFEE9A8A),
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
    );
  }
}
