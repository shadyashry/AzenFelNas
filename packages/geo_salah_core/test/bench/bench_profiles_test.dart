import 'package:dm_core_types/dm_core_types.dart';
import 'package:geo_salah_core/geo_salah_core.dart';
import 'package:geo_salah_core/src/bench/bench_profiles.dart';
import 'package:test/test.dart';

import '../support/bench_profile_files.dart';

void main() {
  group('BenchProfiles (§15 D48, D51)', () {
    test('reads the compiled engine.default seed with every S06 event', () {
      final profile = readEngineDefault();
      expect(profile.profileId, BenchProfiles.engineDefaultId);
      expect(profile.status, ProfileStatus.draftUnverified);
      expect(profile.authorityType, AuthorityType.engineDefault);
      expect(profile.countries, ['*']);
      expect(profile.effectiveFrom, CivilDate(1, 1, 1));
      expect(profile.rules.keys, [
        PrayerEvent.fajr,
        PrayerEvent.sunrise,
        PrayerEvent.dhuhr,
        PrayerEvent.asr,
        PrayerEvent.maghrib,
        PrayerEvent.isha,
      ]);
      expect(profile.highLatitudeChain, isNotEmpty);
      expect(profile.ramadanRules, isEmpty);
    });

    test('rejects a document that is not prayer_profile.v1 and a repeated '
        'id', () {
      expect(
        () => BenchProfiles.byId([
          {'profileId': 'engine.default'},
        ]),
        throwsFormatException,
      );
      expect(() => BenchProfiles.byId(['profile']), throwsFormatException);
      final document = readBenchProfileDocuments().single;
      expect(
        () => BenchProfiles.byId([document, document]),
        throwsFormatException,
      );
    });
  });
}
