import 'package:dm_core_types/dm_core_types.dart';
import 'package:geo_salah_core/geo_salah_core.dart';
import 'package:geo_salah_profiles/geo_salah_profiles.dart';
import 'package:test/test.dart';

import 'support/profile_files.dart';

const ParsePrayerProfile _parse = ParsePrayerProfile();

/// The candidate fixture, scoped to ZZ as an authority profile (the fixture
/// itself is scoped `*`, which only `engine.default` may be), with [changes]
/// applied. Shape test data.
Map<String, Object?> _candidate([Map<String, Object?> changes = const {}]) => {
  ...schemaFixture('candidate_with_approvals'),
  'scope': {
    'countries': ['ZZ'],
    'adminAreas': <String>[],
    'polygonsRef': null,
  },
  'authority': {'name': 'Fixture', 'type': 'COMMUNITY_CONVENTION'},
  ...changes,
};

Map<String, Object?> _member(String key) => switch (_candidate()[key]) {
  final Map<String, Object?> object => object,
  _ => throw StateError('$key is not an object'),
};

void _expectInvalid(Map<String, Object?> json, String rule) {
  final result = _parse(json);
  expect(result, isA<Err<PrayerProfile, ProfileFailure>>(), reason: rule);
  if (result case Err(:final failure)) {
    expect(failure.code, FailureCode.profileInvalid, reason: rule);
  }
}

void main() {
  group('ParsePrayerProfile (§6.5, ADR-008)', () {
    test('accepts a schema-valid profile and maps it (Appendix A)', () {
      final profile = okProfile(_parse(_candidate()), 'candidate');
      expect(profile.profileId, 'zz.fixture.candidate');
      expect(profile.status, ProfileStatus.candidate);
    });

    test('refuses a document the prayer_profile.v1 model rejects', () {
      _expectInvalid({..._candidate(), 'colour': 'green'}, 'unknown member');
      _expectInvalid(
        {..._candidate()}..remove('rules'),
        'missing rules',
      );
      expect(_parse('profile'), isA<Err<PrayerProfile, ProfileFailure>>());
    });

    test('refuses APPROVED without both approvals and a holdout report '
        '(REQ-GOV-001, REQ-GOV-003)', () {
      final approvals = _member('approvals');
      _expectInvalid(
        _candidate({
          'status': 'APPROVED',
          'evidence': {..._member('evidence'), 'holdoutReport': null},
        }),
        'no holdout report',
      );
      _expectInvalid(
        _candidate({
          'status': 'APPROVED',
          'approvals': {...approvals, 'accuracy': null},
        }),
        'no accuracy approval',
      );
      expect(
        _parse(_candidate({'status': 'APPROVED'})),
        isA<Ok<PrayerProfile, ProfileFailure>>(),
      );
    });

    test('refuses nearest rounding of an entry event unless the religious '
        'approval covers rounding (§9.2)', () {
      final rounding = {'default': 'floor', 'dhuhr': 'nearest'};
      expect(
        _parse(_candidate({'rounding': rounding})),
        isA<Ok<PrayerProfile, ProfileFailure>>(),
      );
      final approvals = _member('approvals');
      _expectInvalid(
        _candidate({
          'rounding': rounding,
          'approvals': {
            ...approvals,
            'religious': {
              'reviewer': 'Fixture reviewer',
              'qualification': 'Fixture qualification',
              'date': '2026-10-02',
              'scope': ['rules'],
            },
          },
        }),
        'rounding outside the approval scope',
      );
      _expectInvalid(
        {
          ...schemaFixture('full'),
          'scope': {
            'countries': ['ZZ'],
            'adminAreas': <String>[],
            'polygonsRef': null,
          },
        },
        'nearest Dhuhr without any religious approval',
      );
    });

    test('refuses offsets beyond maxAbsMinutes and Ramadan rules for events '
        'other than Imsak, Fajr and Isha (§9.2, §6.4 ¶6)', () {
      _expectInvalid(
        _candidate({
          'adjustments': {
            'perEventMinutes': {'asr': 3},
            'maxAbsMinutes': 2,
            'ramadan': <String, Object?>{},
          },
        }),
        'offset over the bound',
      );
      _expectInvalid(
        _candidate({
          'adjustments': {
            'maxAbsMinutes': 0,
            'ramadan': {
              'asr': {'type': 'shadowFactor', 'k': 2},
            },
          },
        }),
        'Ramadan Asr',
      );
    });

    test('refuses reversed dates, misplaced scope * or ENGINE_DEFAULT, and '
        '[DEFERRED V1] admin areas', () {
      _expectInvalid(
        schemaFixture('candidate_with_approvals'),
        'scope * outside engine.default',
      );
      _expectInvalid(
        _candidate({'effectiveFrom': '2028-01-01'}),
        'effectiveTo before effectiveFrom',
      );
      _expectInvalid(
        _candidate({
          'authority': {'name': 'Fixture', 'type': 'ENGINE_DEFAULT'},
        }),
        'ENGINE_DEFAULT outside engine.default',
      );
      _expectInvalid(
        _candidate({
          'scope': {
            'countries': ['ZZ', 'ZZ'],
            'adminAreas': <String>[],
            'polygonsRef': null,
          },
        }),
        'a repeated country',
      );
      _expectInvalid(
        _candidate({'profileId': 'engine.default'}),
        'engine.default scoped to a country',
      );
      _expectInvalid(schemaFixture('full'), 'admin areas');
    });

    test('refuses reference points that do not fit the reference mode '
        '(ADR-006)', () {
      _expectInvalid(
        _candidate({
          'referencePoints': [
            {'area': 'ZZ', 'lat': 1.5, 'lon': 2.5},
          ],
        }),
        'EXACT_COORDINATE with a point',
      );
      _expectInvalid(
        _candidate({'referenceMode': 'AUTHORITY_REFERENCE_POINT'}),
        'AUTHORITY_REFERENCE_POINT without a point',
      );
      _expectInvalid(
        _candidate({
          'referenceMode': 'AUTHORITY_REFERENCE_POINT',
          'referencePoints': [
            {'area': 'YY', 'lat': 1.5, 'lon': 2.5},
          ],
        }),
        'a point outside the scope',
      );
      expect(
        _parse(
          _candidate({
            'referenceMode': 'AUTHORITY_REFERENCE_POINT',
            'referencePoints': [
              {'area': 'ZZ', 'lat': 1.5, 'lon': 2.5},
            ],
          }),
        ),
        isA<Ok<PrayerProfile, ProfileFailure>>(),
      );
    });

    test('refuses a profile that needs a newer engine schema '
        '(REQ-PKG-006)', () {
      _expectInvalid(
        _candidate({
          'compatibility': {'minEngineSchema': 2, 'minAppVersion': '1.0.0'},
        }),
        'minEngineSchema 2',
      );
    });
  });
}
