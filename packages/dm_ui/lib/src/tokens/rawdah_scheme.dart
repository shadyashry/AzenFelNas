import 'package:flutter/material.dart';

/// The content-surface colours of the Rawdah world for one brightness
/// (§7.9, §15 D89), carried on the theme so every component follows light
/// and dark: pearl marble by day, Nabawi Night after Isha. The hour-light
/// field and the gold of rules and ornaments are the same in both.
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

  /// Pearl marble: the day scheme.
  static const RawdahScheme light = RawdahScheme(
    ground: Color(0xFFFBF9F3),
    panel: Color(0xFFFFFEFA),
    ink: Color(0xFF1B2620),
    inkMuted: Color(0xFF55615A),
    primary: Color(0xFF145A3E),
    accent: Color(0xFF8E6B2B),
    hairline: Color(0xFFDCCDA4),
    wash: Color(0xFFE3EEE2),
    error: Color(0xFF9B2C2C),
  );

  /// Nabawi Night: deep emerald-black ground, raised panels, ivory ink,
  /// light emerald headings and gold marks.
  static const RawdahScheme night = RawdahScheme(
    ground: Color(0xFF0B1712),
    panel: Color(0xFF13261D),
    ink: Color(0xFFECE7DA),
    inkMuted: Color(0xFFA7B5AC),
    primary: Color(0xFF86D3A8),
    accent: Color(0xFFD4AF63),
    hairline: Color(0xFF34503F),
    wash: Color(0xFF1D3F2E),
    error: Color(0xFFE89384),
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
