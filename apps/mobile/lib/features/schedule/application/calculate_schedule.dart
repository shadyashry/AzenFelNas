import 'package:daily_muslim/features/contexts/domain/resolved_context.dart';
import 'package:daily_muslim/features/schedule/domain/observer_of.dart';
import 'package:daily_muslim/features/schedule/domain/runtime_data.dart';
import 'package:daily_muslim/features/schedule/domain/schedule.dart';
import 'package:dm_core_types/dm_core_types.dart';
import 'package:dm_hijri/dm_hijri.dart';
import 'package:geo_salah_core/geo_salah_core.dart';
import 'package:geo_salah_profiles/geo_salah_profiles.dart';

/// Calculates the prayer days from the local today for a resolved context
/// (§7.2 `schedule`, US-01, US-04).
///
/// "Today" is the context zone's civil date at [Clock.nowUtcMs] under the
/// pinned TZDB (REQ-TIME-020). The profile is resolved by the context's
/// country, falling back to `engine.default` (ADR-007, US-06). Every value
/// that shapes a time comes from the profile or the engine; nothing here
/// chooses one (§0.2 rule 1).
final class CalculateSchedule {
  /// Calculates with [_clock].
  const new(this._clock);

  final Clock _clock;

  /// Days one schedule holds: today, tomorrow (the next prayer after Isha)
  /// and the rest of the week for the timeline (§15 D77).
  static const int days = 7;

  /// The fallback profile's id (ADR-007).
  static const String engineDefaultProfileId = 'engine.default';

  static const CalculateRange _range = CalculateRange();
  static const ResolveProfile _resolveProfile = ResolveProfile();
  static const BuildHijriState _hijri = BuildHijriState();

  /// The schedule of [resolved] with the user's Hijri [hijriOverrideDays].
  Result<Schedule, Failure> call(
    ResolvedContext resolved,
    RuntimeData data, {
    int hijriOverrideDays = 0,
  }) {
    final place = resolved.context.place;
    final today = data.tzdb
        .localDateTimeOf(place.zoneId, _clock.nowUtcMs())
        .date;
    final profile = _resolveProfile(
      set: data.profiles,
      countryCode: place.country,
      day: today,
    );
    final PrayerProfile chosen;
    switch (profile) {
      case Err(:final failure):
        return Err(failure);
      case Ok(:final value):
        chosen = value;
    }
    final observer = ObserverOf.context(resolved);
    return _range(
      observer: observer,
      profile: chosen,
      from: today,
      days: days,
      tzdb: data.tzdb,
      hijriFor: (day) => _hijri(day: day, overrideDays: hijriOverrideDays),
    ).map(
      (results) => Schedule(
        context: resolved,
        profileId: chosen.profileId,
        engineDefault: chosen.profileId == engineDefaultProfileId,
        tzdbVersion: data.tzdb.version,
        days: results,
      ),
    );
  }
}
