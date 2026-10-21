import 'package:geo_salah_core/src/bench/bench_profile_reader.dart';
import 'package:geo_salah_core/src/model/prayer_profile.dart';

/// The profiles the bench knows (§13 S06, §15 D48): the stand-in profile
/// **data** in `bench/profiles/*.json`, read by [BenchProfileReader].
///
/// Until S07 loads `profiles/engine/engine.default.yaml`, `engine.default`
/// is the stand-in `bench/profiles/engine.default.json`, whose values cite
/// §6.5, ADR-003 and ADR-005 (`bench/profiles/README.md`). No value is
/// written here (§0.2 rule 1). The callers (`bin/bench.dart`, the golden
/// tool and the tests) read the files; this class does no I/O.
abstract final class BenchProfiles {
  /// The stand-in directory, relative to the package root.
  static const String directory = 'bench/profiles';

  /// The id of the engine's fallback profile (ADR-007).
  static const String engineDefaultId = 'engine.default';

  /// The profiles of the decoded JSON [documents], by id.
  ///
  /// Throws [FormatException] for an invalid document or a repeated id.
  static Map<String, PrayerProfile> byId(Iterable<Object?> documents) {
    final profiles = <String, PrayerProfile>{};
    for (final document in documents) {
      final profile = BenchProfileReader.read(document);
      if (profiles.containsKey(profile.profileId)) {
        throw FormatException('Profile ${profile.profileId} appears twice');
      }
      profiles[profile.profileId] = profile;
    }
    return Map.unmodifiable(profiles);
  }
}
