import 'package:flutter/painting.dart';

/// The Rawdah Garden palette (§7.9, §15 D89): pearl marble, Rawdah emerald
/// and illumination gold of the Madinah Mushaf. Content surfaces use these;
/// the hour-light field above them uses `HourLight`.
abstract final class RawdahPalette {
  /// Pearl marble ground.
  static const Color pearl = Color(0xFFFBF9F3);

  /// Raised pearl, e.g. the navigation-free page bottoms.
  static const Color pearlDeep = Color(0xFFF3F7F1);

  /// Rawdah emerald; text-safe on [pearl] (8.3:1).
  static const Color emerald = Color(0xFF145A3E);

  /// Deepest emerald, the navigation bar's lower edge.
  static const Color emeraldDeep = Color(0xFF0E3B2A);

  /// Soft Rawdah carpet green, for selection washes.
  static const Color sage = Color(0xFFE3EEE2);

  /// Fluorescent green of the Qibla alignment line (§15 D98): a signal,
  /// never text, always beside the words "You are facing the Qibla".
  static const Color qiblaAligned = Color(0xFF39FF14);

  /// The green of anything switched on (§15 D100): a switch's track, a
  /// ticked box, the chosen segment. Ivory on it reads at 4.6:1; it stands
  /// 3.2:1 off the night panel.
  static const Color enabled = Color(0xFF1A7F4E);

  /// Pale illumination gold, highlights only.
  static const Color goldLight = Color(0xFFEAD596);

  /// Illumination gold; marks and rules only, never text on [pearl].
  static const Color gold = Color(0xFFC29C4A);

  /// Burnished gold, the shadow side of gilded rules.
  static const Color goldDeep = Color(0xFF8E6B2B);

  /// Gold hairline between rows.
  static const Color hairline = Color(0xFFDCCDA4);

  /// Ink on [pearl] (14.9:1).
  static const Color ink = Color(0xFF1B2620);

  /// Secondary ink on [pearl] (5.6:1).
  static const Color muted = Color(0xFF55615A);

  /// Ivory text on the hour-light fields and the emerald bar.
  static const Color ivory = Color(0xFFFBF6E6);

  /// Carpet red, errors only.
  static const Color carpetRed = Color(0xFF9B2C2C);

  /// The gilded gradient of frames, cartouche rims and the active tab.
  static const LinearGradient gilded = LinearGradient(
    colors: [goldLight, gold, goldDeep, goldLight],
    stops: [0, 0.45, 0.72, 1],
  );
}
