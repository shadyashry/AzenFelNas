import 'package:dm_core_types/dm_core_types.dart';
import 'package:geo_salah_core/geo_salah_core.dart';
import 'package:geo_salah_profiles/geo_salah_profiles.dart';
import 'package:test/test.dart';

import 'support/profile_files.dart';

const ValidateProfileSet _validate = ValidateProfileSet();

PrayerProfile _engineDefault() => seedProfiles().singleWhere(
  (profile) => profile.profileId == 'engine.default',
);

List<PrayerProfile> _overlapFixture() => [
  for (final file in yamlFilesIn('test/fixtures/overlap')) parseOk(file),
];

void main() {
  group('ValidateProfileSet (ADR-007, §9.2 non-overlap)', () {
    test('refuses the overlap fixture: two profiles cover ZZ in June 2027 '
        '(PROFILE_OVERLAP)', () {
      final result = _validate([_engineDefault(), ..._overlapFixture()]);
      expect(
        result,
        const Result<ProfileSet, ProfileFailure>.err(
          ProfileFailure.overlap(
            first: 'zz.fixture.first@2026.10.1',
            second: 'zz.fixture.second@2026.10.1',
            country: 'ZZ',
          ),
        ),
      );
      if (result case Err(:final failure)) {
        expect(failure.code, FailureCode.profileOverlap);
      }
    });

    test('accepts consecutive ranges of one country and a retired overlap', () {
      final [first, second] = _overlapFixture();
      final consecutive = _validate([
        _engineDefault(),
        first,
        second.copyWith(effectiveFrom: CivilDate(2027, 7, 1)),
      ]);
      expect(consecutive, isA<Ok<ProfileSet, ProfileFailure>>());
      final retired = _validate([
        _engineDefault(),
        first,
        second.copyWith(status: ProfileStatus.retired),
      ]);
      expect(retired, isA<Ok<ProfileSet, ProfileFailure>>());
    });

    test('refuses two engine.default versions in force on one day', () {
      final fallback = _engineDefault();
      final result = _validate([
        fallback,
        fallback.copyWith(version: '2026.10.2'),
      ]);
      expect(result, isA<Err<ProfileSet, ProfileFailure>>());
      if (result case Err(:final failure)) {
        expect(failure, isA<ProfileOverlap>());
      }
    });

    test('refuses a repeated profileId@version and a set without '
        'engine.default (PROFILE_INVALID)', () {
      final fallback = _engineDefault();
      for (final profiles in [
        [fallback, fallback],
        _overlapFixture().take(1).toList(),
        [fallback.copyWith(status: ProfileStatus.retired)],
      ]) {
        final result = _validate(profiles);
        expect(result, isA<Err<ProfileSet, ProfileFailure>>());
        if (result case Err(:final failure)) {
          expect(failure.code, FailureCode.profileInvalid);
        }
      }
    });
  });
}
