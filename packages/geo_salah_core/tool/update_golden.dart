// Writes the golden corpus (DESIGN.md §6.7, ADR-019):
// `test/golden/<city>/<profileId>/<year>.json`, the engine's own raw instants
// and origins for the Appendix H cities on the 15th of every month of
// 2026–2028 (the lab's `DAY_OF_MONTH` set, §15 D30), with the S05 bench
// profile and fixed-offset zones.
//
// Run from packages/geo_salah_core only after `uv run --frozen lab benchmark
// --engine dart --tags DAY_OF_MONTH` reports 0 blocking discrepancies, and
// commit the result as its own `golden-update` change with the numeric diff
// and its cause (§0.2 rule 3):
//
//   dart run tool/update_golden.dart
import 'dart:convert';
import 'dart:io';

import 'package:dm_core_types/dm_core_types.dart';
import 'package:geo_salah_core/geo_salah_core.dart';
import 'package:geo_salah_core/src/bench/bench_profiles.dart';
import 'package:geo_salah_core/src/bench/standard_offset_tz_database.dart';

/// Appendix H: slug, name, latitude, longitude, and the city's IANA zone.
const List<(String, String, double, double, String)> _cities = [
  ('dubai', 'Dubai', 25.20, 55.27, 'Asia/Dubai'),
  ('abu_dhabi', 'Abu Dhabi', 24.45, 54.38, 'Asia/Dubai'),
  ('makkah', 'Makkah', 21.42, 39.83, 'Asia/Riyadh'),
  ('riyadh', 'Riyadh', 24.71, 46.68, 'Asia/Riyadh'),
  ('jeddah', 'Jeddah', 21.49, 39.19, 'Asia/Riyadh'),
  ('muscat', 'Muscat', 23.59, 58.38, 'Asia/Muscat'),
  ('doha', 'Doha', 25.29, 51.53, 'Asia/Qatar'),
  ('kuwait_city', 'Kuwait City', 29.38, 47.99, 'Asia/Kuwait'),
  ('amman', 'Amman', 31.95, 35.93, 'Asia/Amman'),
  ('istanbul', 'Istanbul', 41.01, 28.98, 'Europe/Istanbul'),
  ('cairo', 'Cairo', 30.04, 31.24, 'Africa/Cairo'),
  ('alexandria', 'Alexandria', 31.20, 29.92, 'Africa/Cairo'),
  ('aswan', 'Aswan', 24.09, 32.90, 'Africa/Cairo'),
  ('casablanca', 'Casablanca', 33.57, -7.59, 'Africa/Casablanca'),
  ('tunis', 'Tunis', 36.81, 10.17, 'Africa/Tunis'),
  ('algiers', 'Algiers', 36.75, 3.06, 'Africa/Algiers'),
  ('london', 'London', 51.51, -0.13, 'Europe/London'),
  ('paris', 'Paris', 48.86, 2.35, 'Europe/Paris'),
  ('berlin', 'Berlin', 52.52, 13.41, 'Europe/Berlin'),
  ('oslo', 'Oslo', 59.91, 10.75, 'Europe/Oslo'),
  ('stockholm', 'Stockholm', 59.33, 18.07, 'Europe/Stockholm'),
  ('reykjavik', 'Reykjavik', 64.15, -21.94, 'Atlantic/Reykjavik'),
  ('tromso', 'Tromsø', 69.65, 18.96, 'Europe/Oslo'),
  ('longyearbyen', 'Longyearbyen', 78.22, 15.63, 'Arctic/Longyearbyen'),
  ('karachi', 'Karachi', 24.86, 67.01, 'Asia/Karachi'),
  ('delhi', 'Delhi', 28.61, 77.21, 'Asia/Kolkata'),
  ('dhaka', 'Dhaka', 23.81, 90.41, 'Asia/Dhaka'),
  ('kuala_lumpur', 'Kuala Lumpur', 3.14, 101.69, 'Asia/Kuala_Lumpur'),
  ('jakarta', 'Jakarta', -6.21, 106.85, 'Asia/Jakarta'),
  ('tokyo', 'Tokyo', 35.68, 139.69, 'Asia/Tokyo'),
  ('tashkent', 'Tashkent', 41.30, 69.24, 'Asia/Tashkent'),
  ('kabul', 'Kabul', 34.53, 69.17, 'Asia/Kabul'),
  ('new_york', 'New York', 40.71, -74.01, 'America/New_York'),
  ('toronto', 'Toronto', 43.65, -79.38, 'America/Toronto'),
  ('chicago', 'Chicago', 41.88, -87.63, 'America/Chicago'),
  ('vancouver', 'Vancouver', 49.28, -123.12, 'America/Vancouver'),
  ('anchorage', 'Anchorage', 61.22, -149.90, 'America/Anchorage'),
  ('utqiagvik', 'Utqiaġvik', 71.29, -156.79, 'America/Anchorage'),
  ('mexico_city', 'Mexico City', 19.43, -99.13, 'America/Mexico_City'),
  ('sao_paulo', 'São Paulo', -23.55, -46.63, 'America/Sao_Paulo'),
  ('cape_town', 'Cape Town', -33.92, 18.42, 'Africa/Johannesburg'),
  ('johannesburg', 'Johannesburg', -26.20, 28.05, 'Africa/Johannesburg'),
  ('sydney', 'Sydney', -33.87, 151.21, 'Australia/Sydney'),
  ('auckland', 'Auckland', -36.85, 174.76, 'Pacific/Auckland'),
  ('ushuaia', 'Ushuaia', -54.80, -68.30, 'America/Argentina/Ushuaia'),
  ('quito', 'Quito', -0.18, -78.47, 'America/Guayaquil'),
  ('kiritimati', 'Kiritimati', 1.87, -157.43, 'Pacific/Kiritimati'),
  ('suva', 'Suva', -18.14, 178.44, 'Pacific/Fiji'),
  ('nairobi', 'Nairobi', -1.29, 36.82, 'Africa/Nairobi'),
];

/// Shape-only Hijri state: S05 events do not read it.
const HijriState _hijri = HijriState(
  dateAtDawn: HijriDate(year: 1447, month: 1, day: 1),
  dateAtNight: HijriDate(year: 1447, month: 1, day: 2),
  confidence: HijriConfidence.expected,
);

void main() {
  const profile = BenchProfiles.engineDefault;
  const tzdb = StandardOffsetTzDatabase();
  const encoder = JsonEncoder.withIndent('  ');
  for (final (slug, name, lat, lon, zoneId) in _cities) {
    final observer = Observer(
      latitudeDeg: lat,
      longitudeDeg: lon,
      zoneId: zoneId,
      source: ObserverSource.benchmark,
    );
    for (var year = 2026; year <= 2028; year++) {
      final days = [
        for (var month = 1; month <= 12; month++)
          _day(observer, profile, CivilDate(year, month, 15), tzdb),
      ];
      final golden = encoder.convert({
        'schemaVersion': 1,
        'city': name,
        'profileId': profile.profileId,
        'profileVersion': profile.version,
        'observer': {
          'latitudeDeg': lat,
          'longitudeDeg': lon,
          'zoneId': zoneId,
          'offsetSeconds': tzdb.offsetSecondsAt(zoneId, 0),
        },
        'days': days,
      });
      File('test/golden/$slug/${profile.profileId}/$year.json')
        ..createSync(recursive: true)
        ..writeAsStringSync('$golden\n');
    }
  }
}

Map<String, Object?> _day(
  Observer observer,
  PrayerProfile profile,
  CivilDate day,
  TzDatabase tzdb,
) {
  final result = switch (const CalculateDay()(
    observer: observer,
    profile: profile,
    day: day,
    tzdb: tzdb,
    hijri: _hijri,
  )) {
    Ok(:final value) => value,
    Err(:final failure) => throw StateError('$day: ${failure.detail}'),
  };
  return {
    'day': day.toJson(),
    'times': [
      for (final time in result.times)
        {
          'event': time.event.name.toUpperCase(),
          'origin': switch (time.origin) {
            Primary() => {'kind': 'PRIMARY'},
            Fallback() => throw StateError('S05 has no fallback'),
            NoEvent(:final reason) => {
              'kind': 'NO_EVENT',
              'reason': reason.code,
            },
          },
          if (time.rawUtcMs case final int raw) 'rawUtcMs': raw,
        },
    ],
  };
}
