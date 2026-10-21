import 'package:geo_salah_core/src/model/tz_database.dart';

/// The time zones the bench calculates in: a [TzDatabase] that also says
/// which zones it knows, so an unknown one is answered `TZ_UNRESOLVED`
/// instead of reaching the engine (consumer-defined port, §17.1 I).
abstract interface class BenchTimeZones implements TzDatabase {
  /// Whether [offsetSecondsAt] is defined for [zoneId].
  bool supports(String zoneId);
}
