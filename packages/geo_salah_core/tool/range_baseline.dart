// Measures the REQ-PERF-001 baseline (DESIGN.md §6.4 ¶2, §18.7): a one-year
// `calculateRange` with the `engine.default` bench stand-in, median of 5 timed
// runs after three warm-up runs, per city. REQ-PERF-001 is judged in a release
// build, so compile it ahead of time and run the executable from
// packages/geo_salah_core:
//
//   dart compile exe tool/range_baseline.dart -o <out>/range_baseline.exe
//   <out>/range_baseline.exe
//
// Prints one JSON object per city (with the same year calculated day by day
// through `CalculateDay`, which shares no samples, for comparison) and a
// summary line. The device target
// (Galaxy A50, < 500 ms) needs the same measurement on the device (§15 D49).
import 'dart:convert';
import 'dart:io';

import 'package:dm_core_types/dm_core_types.dart';
import 'package:geo_salah_core/geo_salah_core.dart';
import 'package:geo_salah_core/src/bench/bench_profiles.dart';
import 'package:geo_salah_core/src/bench/standard_offset_tz_database.dart';

/// Appendix H cities of different latitude and zone offset.
const List<(String, double, double, String)> _cities = [
  ('Makkah', 21.42, 39.83, 'Asia/Riyadh'),
  ('Cairo', 30.04, 31.24, 'Africa/Cairo'),
  ('London', 51.51, -0.13, 'Europe/London'),
  ('Oslo', 59.91, 10.75, 'Europe/Oslo'),
  ('Reykjavik', 64.15, -21.94, 'Atlantic/Reykjavik'),
  ('Kiritimati', 1.87, -157.43, 'Pacific/Kiritimati'),
];

const int _runs = 5;

/// Shape-only Hijri state: engine.default has no Ramadan rules (§6.5), so it
/// only enters the Calculation ID.
HijriState _hijri(CivilDate day) => const HijriState(
  dateAtDawn: HijriDate(year: 1448, month: 1, day: 1),
  dateAtNight: HijriDate(year: 1448, month: 1, day: 2),
  confidence: HijriConfidence.expected,
);

void main() {
  final profile = _engineDefault();
  const tzdb = StandardOffsetTzDatabase();
  final from = CivilDate(2026, 1, 1);
  final medians = <int>[];
  for (final (name, lat, lon, zoneId) in _cities) {
    final observer = Observer(
      latitudeDeg: lat,
      longitudeDeg: lon,
      zoneId: zoneId,
      source: ObserverSource.benchmark,
    );
    int runOnce() {
      final watch = Stopwatch()..start();
      final result = const CalculateRange()(
        observer: observer,
        profile: profile,
        from: from,
        days: 365,
        tzdb: tzdb,
        hijriFor: _hijri,
      );
      watch.stop();
      if (result case Err(:final failure)) {
        throw StateError('$name: ${failure.detail}');
      }
      return watch.elapsedMicroseconds;
    }

    int dayByDayOnce() {
      final watch = Stopwatch()..start();
      for (var i = 0; i < 365; i++) {
        final day = CivilDate.fromEpochDay(from.epochDay + i);
        final result = const CalculateDay()(
          observer: observer,
          profile: profile,
          day: day,
          tzdb: tzdb,
          hijri: _hijri(day),
        );
        if (result case Err(:final failure)) {
          throw StateError('$name $day: ${failure.detail}');
        }
      }
      watch.stop();
      return watch.elapsedMicroseconds;
    }

    for (var i = 0; i < 3; i++) {
      runOnce(); // warm-up
    }
    final timings = [for (var i = 0; i < _runs; i++) runOnce()]..sort();
    final dayByDay = [for (var i = 0; i < _runs; i++) dayByDayOnce()]..sort();
    final median = timings[_runs ~/ 2];
    medians.add(median);
    stdout.writeln(
      jsonEncode({
        'city': name,
        'days': 365,
        'runsUs': timings,
        'medianMs': median / 1000,
        'dayByDayMedianMs': dayByDay[_runs ~/ 2] / 1000,
      }),
    );
  }
  medians.sort();
  stdout.writeln(
    jsonEncode({
      'summary': 'one-year calculateRange, median of $_runs per city',
      'worstMedianMs': medians.last / 1000,
      'engineVersion': EngineVersion.current,
      'dart': Platform.version,
      'os': Platform.operatingSystemVersion,
      'cpus': Platform.numberOfProcessors,
    }),
  );
}

/// The `engine.default` stand-in data (§15 D48).
PrayerProfile _engineDefault() {
  final files =
      Directory(BenchProfiles.directory)
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.json'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));
  final profiles = BenchProfiles.byId([
    for (final file in files) jsonDecode(file.readAsStringSync()),
  ]);
  return switch (profiles[BenchProfiles.engineDefaultId]) {
    final PrayerProfile profile => profile,
    null => throw StateError('bench/profiles has no engine.default'),
  };
}
