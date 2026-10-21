import 'package:dm_core_types/dm_core_types.dart';
import 'package:geo_salah_core/geo_salah_core.dart';
import 'package:geo_salah_profiles/src/profile_failure.dart';
import 'package:geo_salah_profiles/src/profile_set.dart';

/// Checks that parsed profiles form a usable set (ADR-007, §9.2
/// "non-overlap"): exactly one profile per (place, date).
///
/// Retired profiles take part in no check and no resolution. For the others:
/// - `profileId@version` is unique; otherwise `ProfileFailure.invalid`.
/// - Two profiles that share a scope country (or are both `*`) must not share
///   a day of their `[effectiveFrom, effectiveTo]` ranges (an open end runs
///   to the end of the engine's domain); otherwise `ProfileFailure.overlap`.
///   An overlap is a pipeline build error, never resolved by preference.
/// - At least one `engine.default` exists, the fallback when no authority
///   profile covers a place (ADR-007); otherwise `ProfileFailure.invalid`.
///
/// Pure and deterministic; the first problem found, in input order, is
/// reported.
final class ValidateProfileSet {
  /// The use case.
  const new();

  /// The validated set of [profiles], or the first problem.
  Result<ProfileSet, ProfileFailure> call(List<PrayerProfile> profiles) {
    final live = [
      for (final profile in profiles)
        if (profile.status != ProfileStatus.retired) profile,
    ];
    final seen = <String>{};
    for (final profile in profiles) {
      if (!seen.add(_key(profile))) {
        return Result.err(
          ProfileFailure.invalid('${_key(profile)} appears twice'),
        );
      }
    }
    for (var i = 0; i < live.length; i++) {
      for (var j = i + 1; j < live.length; j++) {
        final shared = _sharedCountry(live[i], live[j]);
        if (shared != null && _datesMeet(live[i], live[j])) {
          return Result.err(
            ProfileFailure.overlap(
              first: _key(live[i]),
              second: _key(live[j]),
              country: shared,
            ),
          );
        }
      }
    }
    if (!live.any((profile) => profile.profileId == 'engine.default')) {
      return const Result.err(
        ProfileFailure.invalid('the set has no live engine.default'),
      );
    }
    return Result.ok(ProfileSet.validated(List.unmodifiable(profiles)));
  }

  static String _key(PrayerProfile profile) =>
      '${profile.profileId}@${profile.version}';

  static String? _sharedCountry(PrayerProfile a, PrayerProfile b) {
    for (final country in a.countries) {
      if (b.countries.contains(country)) return country;
    }
    return null;
  }

  static bool _datesMeet(PrayerProfile a, PrayerProfile b) =>
      a.effectiveFrom.epochDay <= _lastDay(b) &&
      b.effectiveFrom.epochDay <= _lastDay(a);

  /// The last epoch day of [profile]'s range; an open end is unbounded.
  static int _lastDay(PrayerProfile profile) => switch (profile.effectiveTo) {
    final CivilDate to => to.epochDay,
    null => 1 << 40,
  };
}
