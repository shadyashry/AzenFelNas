import 'dart:convert';
import 'dart:io';

import 'package:dm_core_types/dm_core_types.dart';
import 'package:geo_salah_core/geo_salah_core.dart';
import 'package:geo_salah_profiles/geo_salah_profiles.dart';

import '../../tool/yaml_json.dart';

/// The repository's profile files, `profiles/*/*.yaml`, sorted by path
/// (tests run from the package root).
List<File> seedProfileFiles() =>
    Directory('../../profiles')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.yaml'))
        .toList()
      ..sort((a, b) => a.path.compareTo(b.path));

/// The YAML profiles in [directory], sorted by path.
List<File> yamlFilesIn(String directory) =>
    Directory(directory)
        .listSync()
        .whereType<File>()
        .where((file) => file.path.endsWith('.yaml'))
        .toList()
      ..sort((a, b) => a.path.compareTo(b.path));

/// A decoded `prayer_profile.v1` schema fixture (shape test data).
Map<String, Object?> schemaFixture(String name) => switch (jsonDecode(
  File(
    '../../schemas/fixtures/prayer_profile/valid/$name.json',
  ).readAsStringSync(),
)) {
  final Map<String, Object?> object => object,
  final Object? other => throw FormatException('Not an object: $other'),
};

/// [file] parsed by [ParsePrayerProfile], expecting success.
PrayerProfile parseOk(File file) => okProfile(
  const ParsePrayerProfile()(readYamlAsJson(file)),
  file.path,
);

/// The profile of [result], or a [StateError] naming [what].
PrayerProfile okProfile(
  Result<PrayerProfile, ProfileFailure> result,
  String what,
) => switch (result) {
  Ok(:final value) => value,
  Err(:final failure) => throw StateError('$what: ${failure.detail}'),
};

/// The seed profiles, parsed.
List<PrayerProfile> seedProfiles() => [
  for (final file in seedProfileFiles()) parseOk(file),
];

/// The validated seed set.
ProfileSet seedSet() => switch (const ValidateProfileSet()(seedProfiles())) {
  Ok(:final value) => value,
  Err(:final failure) => throw StateError(failure.detail),
};
