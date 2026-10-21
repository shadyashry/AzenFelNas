import 'dart:convert';
import 'dart:io';

import 'package:geo_salah_core/geo_salah_core.dart';
import 'package:geo_salah_core/src/bench/bench_profiles.dart';

/// The decoded `bench/profiles/*.json` documents: the compiled seed profiles
/// (§15 D48, D51; tests run from the package root).
List<Object?> readBenchProfileDocuments() {
  final files =
      Directory(BenchProfiles.directory)
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.json'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));
  return [for (final file in files) jsonDecode(file.readAsStringSync())];
}

/// The bench profiles, by id.
Map<String, PrayerProfile> readBenchProfiles() =>
    BenchProfiles.byId(readBenchProfileDocuments());

/// The `engine.default` seed profile.
PrayerProfile readEngineDefault() =>
    switch (readBenchProfiles()[BenchProfiles.engineDefaultId]) {
      final PrayerProfile profile => profile,
      null => throw StateError('bench/profiles has no engine.default'),
    };
