import 'package:geo_salah_core/geo_salah_core.dart';

/// Fake [TzDatabase] port: each zone at a constant offset, no DST (the
/// pinned TZDB arrives in S10). Raw instants do not depend on it.
final class FixedOffsetTzDatabase implements TzDatabase {
  /// Zones with constant offsets, in seconds.
  new(this.offsetsSeconds);

  /// Offset per zone, seconds.
  final Map<String, int> offsetsSeconds;

  @override
  String get version => 'fake';

  @override
  int offsetSecondsAt(String zoneId, int utcMs) =>
      offsetsSeconds[zoneId] ??
      (throw ArgumentError.value(zoneId, 'zoneId', 'unknown zone'));
}
