import 'package:geo_salah_core/src/model/tz_database.dart';

/// Fake [TzDatabase] port: every zone has a fixed UTC offset, optionally
/// switching once at [switchUtcMs] to [offsetAfterSeconds] (a zone that skips
/// or repeats a calendar day).
final class FakeTzDatabase implements TzDatabase {
  /// Zones with constant offsets, in seconds.
  new(this.offsetsSeconds) : switchUtcMs = null, offsetAfterSeconds = const {};

  /// Zones whose offsets change from [offsetsSeconds] to
  /// [offsetAfterSeconds] at [switchUtcMs].
  new switching(
    this.offsetsSeconds, {
    required int this.switchUtcMs,
    required this.offsetAfterSeconds,
  });

  /// Offsets before the switch (or always).
  final Map<String, int> offsetsSeconds;

  /// Instant of the switch, if any.
  final int? switchUtcMs;

  /// Offsets from the switch on.
  final Map<String, int> offsetAfterSeconds;

  @override
  String get version => 'fake';

  @override
  int offsetSecondsAt(String zoneId, int utcMs) {
    final switchAt = switchUtcMs;
    final table = switchAt != null && utcMs >= switchAt
        ? offsetAfterSeconds
        : offsetsSeconds;
    final offset = table[zoneId];
    if (offset == null) throw ArgumentError.value(zoneId, 'zoneId');
    return offset;
  }
}
