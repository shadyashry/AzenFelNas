import 'dart:convert';
import 'dart:io';

import 'package:dm_core_types/dm_core_types.dart';
import 'package:geo_salah_core/geo_salah_core.dart';
import 'package:test/test.dart';

import '../support/fixtures.dart';

/// A valid `prayer_profile.v1` fixture as a decoded JSON object (shape test
/// data, never loaded as a profile, `schemas/README.md`).
Map<String, Object?> _fixture(String name) => asJsonObject(
  jsonDecode(
    File(
      '../../schemas/fixtures/prayer_profile/valid/$name.json',
    ).readAsStringSync(),
  ),
);

Result<PrayerProfile, EngineFailure> _map(Map<String, Object?> json) =>
    PrayerProfileMapper.map(PrayerProfileDocument.fromJson(json));

PrayerProfile _ok(Result<PrayerProfile, EngineFailure> result) =>
    switch (result) {
      Ok(:final value) => value,
      Err(:final failure) => throw StateError('Unexpected $failure'),
    };

void main() {
  group('PrayerProfileMapper (§6.2, Appendix A)', () {
    test('maps every member of the full fixture to the §6.2 profile', () {
      final profile = _ok(_map(_fixture('full')));
      expect(profile.profileId, 'zz.fixture.full');
      expect(profile.version, '2026.10.1');
      expect(profile.status, ProfileStatus.draftUnverified);
      expect(profile.effectiveFrom, CivilDate(2026, 11, 1));
      expect(profile.effectiveTo, isNull);
      expect(profile.countries, ['ZZ']);
      expect(profile.authorityType, AuthorityType.communityConvention);
      expect(profile.referenceMode, ReferenceMode.authorityReferencePoint);
      expect(profile.referencePoints, [
        const ReferencePoint(area: 'ZZ', lat: 1.5, lon: 2.5),
      ]);
      expect(profile.rules, {
        PrayerEvent.imsak: const EventRule.intervalBefore(
          base: PrayerEvent.fajr,
          duration: Duration(minutes: 10),
        ),
        PrayerEvent.fajr: const EventRule.solarAltitude(degrees: 12.5),
        PrayerEvent.sunrise: const EventRule.horizon(),
        PrayerEvent.dhuhr: const EventRule.transit(
          offset: Duration(minutes: 2),
        ),
        PrayerEvent.asr: const EventRule.shadowFactor(k: 2),
        PrayerEvent.maghrib: const EventRule.horizon(
          refractionArcmin: 30,
          semidiameterArcmin: 15,
        ),
        PrayerEvent.isha: const EventRule.intervalAfter(
          base: PrayerEvent.maghrib,
          duration: Duration(minutes: 45),
        ),
      });
      expect(profile.highLatitudeChain, const [
        HighLatitudeMethod.anglePortion(),
        HighLatitudeMethod.middleOfNight(),
        HighLatitudeMethod.seventhOfNight(),
        HighLatitudeMethod.nearestLatitude(latDeg: 45.5),
        HighLatitudeMethod.nearestValidDay(maxDays: 7),
      ]);
      expect(profile.roundingDefault, RoundingMode.ceil);
      expect(profile.roundingOverrides, {
        PrayerEvent.sunrise: RoundingMode.floor,
        PrayerEvent.dhuhr: RoundingMode.nearest,
      });
      expect(profile.perEventMinutes, {
        PrayerEvent.asr: 1,
        PrayerEvent.maghrib: -1,
      });
      expect(profile.maxAbsMinutes, 2);
      expect(profile.ramadanRules, {
        PrayerEvent.isha: const EventRule.intervalAfter(
          base: PrayerEvent.maghrib,
          duration: Duration(minutes: 60),
        ),
      });
      expect(profile.elevationPolicy, HorizonElevationPolicy.none);
      expect(profile.hasReligiousApproval, isFalse);
      expect(profile.benchmarkReportId, isNull);
      expect(profile.minEngineSchema, 1);
    });

    test('maps approvals, an end date and a benchmark report', () {
      final profile = _ok(_map(_fixture('candidate_with_approvals')));
      expect(profile.status, ProfileStatus.candidate);
      expect(profile.effectiveTo, CivilDate(2027, 12, 31));
      expect(profile.hasReligiousApproval, isTrue);
      expect(profile.benchmarkReportId, 'zz-report-1');
      expect(profile.rules.containsKey(PrayerEvent.imsak), isFalse);
    });

    test('returns invalidProfile for a member that names no event, a bad '
        'date or a missing rounding default (REQ-ERR-001)', () {
      final full = _fixture('full');
      for (final json in <Map<String, Object?>>[
        {
          ...full,
          'rounding': {'default': 'ceil', 'noon': 'floor'},
        },
        {
          ...full,
          'rounding': {'sunrise': 'floor'},
        },
        {...full, 'effectiveFrom': '2026-13-01'},
        {
          ...full,
          'adjustments': {
            'maxAbsMinutes': 2,
            'perEventMinutes': {'midnight': 1},
          },
        },
      ]) {
        final result = _map(json);
        expect(result, isA<Err<PrayerProfile, EngineFailure>>());
        if (result case Err(:final failure)) {
          expect(failure.code, FailureCode.profileInvalid);
        }
      }
    });
  });
}
