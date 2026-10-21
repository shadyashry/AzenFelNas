import 'package:geo_salah_core/src/bench/bench_time_zones.dart';
import 'package:geo_salah_core/src/model/tz_database.dart';

/// The fixed-offset [TzDatabase] fake of the S05 bench (§13 S05, §15 D40):
/// each supported zone has its constant **standard** UTC offset and no
/// daylight-saving time.
///
/// It stands in for the pinned TZDB until `dm_civil_time` exists (S10) and
/// is used by the bench and the golden corpus only, never by the app. Raw
/// instants do not depend on it (the prayer day's upper transit lies near
/// local noon, more than an hour from midnight, in every supported zone);
/// `dayOffset` can be off by one day near local midnight during DST.
/// [version] is the sentinel `0000a`, which no TZDB release has. Pure.
final class StandardOffsetTzDatabase implements BenchTimeZones {
  /// The fake.
  const new();

  static const int _hour = 3600;

  /// Standard offsets in seconds of the Appendix H cities' zones (and their
  /// common aliases), from the IANA TZDB.
  static const Map<String, int> standardOffsetsSeconds = {
    'UTC': 0,
    'Etc/UTC': 0,
    'Africa/Algiers': _hour,
    'Africa/Cairo': 2 * _hour,
    'Africa/Casablanca': _hour,
    'Africa/Johannesburg': 2 * _hour,
    'Africa/Nairobi': 3 * _hour,
    'Africa/Tunis': _hour,
    'America/Anchorage': -9 * _hour,
    'America/Argentina/Ushuaia': -3 * _hour,
    'America/Chicago': -6 * _hour,
    'America/Guayaquil': -5 * _hour,
    'America/Mexico_City': -6 * _hour,
    'America/New_York': -5 * _hour,
    'America/Sao_Paulo': -3 * _hour,
    'America/Toronto': -5 * _hour,
    'America/Vancouver': -8 * _hour,
    'Arctic/Longyearbyen': _hour,
    'Asia/Amman': 3 * _hour,
    'Asia/Calcutta': 5 * _hour + 1800,
    'Asia/Dhaka': 6 * _hour,
    'Asia/Dubai': 4 * _hour,
    'Asia/Jakarta': 7 * _hour,
    'Asia/Kabul': 4 * _hour + 1800,
    'Asia/Karachi': 5 * _hour,
    'Asia/Kolkata': 5 * _hour + 1800,
    'Asia/Kuala_Lumpur': 8 * _hour,
    'Asia/Kuwait': 3 * _hour,
    'Asia/Muscat': 4 * _hour,
    'Asia/Qatar': 3 * _hour,
    'Asia/Riyadh': 3 * _hour,
    'Asia/Tashkent': 5 * _hour,
    'Asia/Tokyo': 9 * _hour,
    'Atlantic/Reykjavik': 0,
    'Australia/Sydney': 10 * _hour,
    'Europe/Berlin': _hour,
    'Europe/Istanbul': 3 * _hour,
    'Europe/London': 0,
    'Europe/Oslo': _hour,
    'Europe/Paris': _hour,
    'Europe/Stockholm': _hour,
    'Pacific/Auckland': 12 * _hour,
    'Pacific/Fiji': 12 * _hour,
    'Pacific/Kiritimati': 14 * _hour,
  };

  @override
  bool supports(String zoneId) => standardOffsetsSeconds.containsKey(zoneId);

  @override
  String get version => '0000a';

  /// Throws [ArgumentError] for a zone that is not [supports]ed.
  @override
  int offsetSecondsAt(String zoneId, int utcMs) =>
      standardOffsetsSeconds[zoneId] ??
      (throw ArgumentError.value(zoneId, 'zoneId', 'unsupported zone'));
}
