import 'package:dm_core_types/dm_core_types.dart';
import 'package:geo_salah_core/geo_salah_core.dart';
import 'package:geo_salah_profiles/src/profile_failure.dart';
import 'package:geo_salah_profiles/src/profile_set.dart';

/// Resolves a place and a day to the one profile that applies (ADR-007).
///
/// MVP resolves by **country** (ISO 3166-1 alpha-2): the caller passes the
/// country the offline `country_polygons` package gives for the observer
/// (S11), or `null` at sea or when it is unknown (§15 D52). Steps:
/// 1. The live (not retired) profile whose scope holds `countryCode` and
///    whose `[effectiveFrom, effectiveTo]` holds `day`. The validated set
///    has at most one.
/// 2. Otherwise the live `engine.default` effective on `day`, which the
///    engine flags `noLocalProfile`; otherwise `ProfileFailure.notFound`.
/// 3. Under `AUTHORITY_REFERENCE_POINT` the profile's reference points are
///    narrowed to the one for `countryCode` (ADR-006), which the engine then
///    calculates at; a country without a point is `ProfileFailure.invalid`.
///
/// Pure and deterministic.
final class ResolveProfile {
  /// The use case.
  const new();

  /// The profile for [countryCode] on [day] in [set].
  Result<PrayerProfile, ProfileFailure> call({
    required ProfileSet set,
    required String? countryCode,
    required CivilDate day,
  }) {
    bool effective(PrayerProfile profile) =>
        profile.status != ProfileStatus.retired &&
        profile.effectiveFrom.epochDay <= day.epochDay &&
        switch (profile.effectiveTo) {
          final CivilDate to => day.epochDay <= to.epochDay,
          null => true,
        };
    final local = [
      if (countryCode != null)
        for (final profile in set.profiles)
          if (effective(profile) && profile.countries.contains(countryCode))
            profile,
    ];
    if (local case [final profile, ...]) {
      return _bound(profile, countryCode);
    }
    for (final profile in set.profiles) {
      if (profile.profileId == 'engine.default' && effective(profile)) {
        return Result.ok(profile);
      }
    }
    return Result.err(ProfileFailure.notFound(day));
  }

  static Result<PrayerProfile, ProfileFailure> _bound(
    PrayerProfile profile,
    String? countryCode,
  ) => switch (profile.referenceMode) {
    ReferenceMode.exactCoordinate => Result.ok(profile),
    ReferenceMode.authorityReferencePoint => switch ([
      for (final point in profile.referencePoints)
        if (point.area == countryCode) point,
    ]) {
      [final ReferencePoint point] => Result.ok(
        profile.copyWith(referencePoints: [point]),
      ),
      _ => Result.err(
        ProfileFailure.invalid(
          '${profile.profileId} has no reference point for $countryCode',
        ),
      ),
    },
  };
}
