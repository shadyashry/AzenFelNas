import 'dart:convert';
import 'dart:io';

import 'package:geo_salah_core/geo_salah_core.dart';
import 'package:geo_salah_core/src/bench/bench_profiles.dart';

/// The bench stand-in profiles, read from `bench/profiles/*.json` (profile
/// data, §15 D48; tests run from the package root).
Map<String, PrayerProfile> readBenchProfiles() {
  final files =
      Directory(BenchProfiles.directory)
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.json'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));
  return BenchProfiles.byId([
    for (final file in files) jsonDecode(file.readAsStringSync()),
  ]);
}

/// The `engine.default` stand-in.
PrayerProfile readEngineDefault() =>
    switch (readBenchProfiles()[BenchProfiles.engineDefaultId]) {
      final PrayerProfile profile => profile,
      null => throw StateError('bench/profiles has no engine.default'),
    };
