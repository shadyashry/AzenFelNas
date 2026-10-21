import 'package:dm_core_types/dm_core_types.dart';
import 'package:geo_salah_core/geo_salah_core.dart';
import 'package:geo_salah_profiles/geo_salah_profiles.dart';
import 'package:test/test.dart';

import 'support/profile_files.dart';

const ResolveProfile _resolve = ResolveProfile();

String _resolvedId(ProfileSet set, String? country, CivilDate day) =>
    switch (_resolve(set: set, countryCode: country, day: day)) {
      Ok(:final value) => value.profileId,
      Err(:final failure) => 'Err(${failure.code.wire})',
    };

ProfileSet _setOf(List<PrayerProfile> profiles) =>
    switch (const ValidateProfileSet()(profiles)) {
      Ok(:final value) => value,
      Err(:final failure) => throw StateError(failure.detail),
    };

void main() {
  group('ResolveProfile (ADR-007)', () {
    final set = seedSet();

    test("resolves a country to its authority profile on the profile's "
        'days', () {
      final day = CivilDate(2027, 1, 15);
      expect(_resolvedId(set, 'EG', day), 'eg.egas.standard');
      expect(_resolvedId(set, 'SA', day), 'sa.ummalqura.standard');
      expect(_resolvedId(set, 'AE', day), 'ae.awqaf.standard');
    });

    test('falls back to engine.default for another country, no country, or '
        'a day before the authority profile applies', () {
      expect(
        _resolvedId(set, 'FR', CivilDate(2027, 1, 15)),
        'engine.default',
      );
      expect(
        _resolvedId(set, null, CivilDate(2027, 1, 15)),
        'engine.default',
      );
      expect(
        _resolvedId(set, 'EG', CivilDate(2026, 10, 31)),
        'engine.default',
      );
      expect(
        _resolvedId(set, 'EG', CivilDate(2026, 11, 1)),
        'eg.egas.standard',
      );
    });

    test('returns PROFILE_NOT_FOUND when not even engine.default applies', () {
      final fallback = seedProfiles().singleWhere(
        (profile) => profile.profileId == 'engine.default',
      );
      final late = _setOf([
        fallback.copyWith(effectiveFrom: CivilDate(2030, 1, 1)),
      ]);
      expect(
        _resolvedId(late, 'EG', CivilDate(2027, 1, 1)),
        'Err(PROFILE_NOT_FOUND)',
      );
    });

    test("narrows an authority profile's reference points to the resolved "
        'country (ADR-006)', () {
      final eg = seedProfiles().singleWhere(
        (profile) => profile.profileId == 'eg.egas.standard',
      );
      const egPoint = ReferencePoint(area: 'EG', lat: 30.5, lon: 31.5);
      const sdPoint = ReferencePoint(area: 'SD', lat: 15.6, lon: 32.5);
      final twoCountries = eg.copyWith(
        countries: ['EG', 'SD'],
        referenceMode: ReferenceMode.authorityReferencePoint,
        referencePoints: [egPoint, sdPoint],
      );
      final local = _setOf([
        ...seedProfiles().where((p) => p.profileId != 'eg.egas.standard'),
        twoCountries,
      ]);
      final resolved = _resolve(
        set: local,
        countryCode: 'SD',
        day: CivilDate(2027, 1, 1),
      );
      expect(resolved, isA<Ok<PrayerProfile, ProfileFailure>>());
      if (resolved case Ok(:final value)) {
        expect(value.referencePoints, [sdPoint]);
      }
      final pointless = _setOf([
        ...seedProfiles().where((p) => p.profileId != 'eg.egas.standard'),
        twoCountries.copyWith(referencePoints: [egPoint]),
      ]);
      expect(
        _resolvedId(pointless, 'SD', CivilDate(2027, 1, 1)),
        'Err(PROFILE_INVALID)',
      );
    });
  });
}
