import 'package:json_annotation/json_annotation.dart';

/// Sky phase (Appendix G).
@JsonEnum()
enum SkyPhaseCode {
  /// Night.
  night,

  /// Astronomical dawn.
  astronomicalDawn,

  /// Nautical dawn.
  nauticalDawn,

  /// Civil dawn.
  civilDawn,

  /// Golden morning.
  goldenMorning,

  /// Day.
  day,

  /// Golden evening.
  goldenEvening,

  /// Civil dusk.
  civilDusk,

  /// Nautical dusk.
  nauticalDusk,

  /// Astronomical dusk.
  astronomicalDusk,
}
