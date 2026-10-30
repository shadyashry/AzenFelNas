import 'package:flutter/painting.dart';

/// The Madinah palette (§7.9, §15 D89, D102): forest and emerald greens of
/// the Prophet's Mosque at dusk, a restrained gold, and cream reading
/// surfaces. Content surfaces use these; the Home hero uses `HourLight`
/// only as a faint tint over its deep-green field.
abstract final class RawdahPalette {
  /// Cream ground of light pages.
  static const Color pearl = Color(0xFFF4F2E5);

  /// Light content surface: cards, sheets, fields.
  static const Color pearlDeep = Color(0xFFFFFCF4);

  /// Primary forest green: headings, filled actions, the Home hero.
  static const Color forest = Color(0xFF0B3F32);

  /// Secondary emerald; text-safe on [pearl] (6.6:1).
  static const Color emerald = Color(0xFF17634D);

  /// Deep green of the navigation bar and strong-contrast fields.
  static const Color emeraldDeep = Color(0xFF062E25);

  /// Pale sage surface, for selection washes and quiet tiles.
  static const Color sage = Color(0xFFE3EBDD);

  /// Fluorescent green of the Qibla alignment line (§15 D98): a signal,
  /// never text, always beside the words "You are facing the Qibla".
  static const Color qiblaAligned = Color(0xFF39FF14);

  /// The green of anything switched on (§15 D100): a switch's track, a
  /// ticked box, the chosen segment. Ivory on it reads at 4.6:1; it stands
  /// 3:1 off the night panel.
  static const Color enabled = Color(0xFF1A7F4E);

  /// Light gold for selected details on green: the active tab, the next
  /// prayer's label. Never text on cream.
  static const Color goldLight = Color(0xFFE8C778);

  /// Primary gold; marks, thin borders and icons on green, never text on
  /// [pearl].
  static const Color gold = Color(0xFFC9A45C);

  /// Burnished gold: gold icons and marks on cream (4.6:1 on [pearlDeep]).
  static const Color goldDeep = Color(0xFF8E6B2B);

  /// Hairline between rows and around cards on cream.
  static const Color hairline = Color(0xFFE4DABD);

  /// Main dark text on cream (11.7:1 on [pearl]).
  static const Color ink = Color(0xFF173B30);

  /// Secondary text on cream (5.9:1 on [pearl]).
  static const Color muted = Color(0xFF526359);

  /// Primary text on green fields and the navigation bar.
  static const Color ivory = Color(0xFFFFF9E9);

  /// Secondary text on green fields (8.4:1 on [emeraldDeep]).
  static const Color ivoryMuted = Color(0xFFD5DED3);

  /// Carpet red, errors only.
  static const Color carpetRed = Color(0xFF9B2C2C);

  /// The gilded gradient of thin rules, the progress line and the arc.
  static const LinearGradient gilded = LinearGradient(
    colors: [goldLight, gold, goldDeep, goldLight],
    stops: [0, 0.45, 0.72, 1],
  );
}
