import 'package:dm_core_types/dm_core_types.dart';
import 'package:geo_salah_core/src/model/engine_failure.dart';
import 'package:geo_salah_core/src/model/prayer_profile.dart';

/// The additive per-event offsets of a profile (§6.4 ¶8): whole minutes
/// from `adjustments.perEventMinutes`, each within `maxAbsMinutes`.
///
/// They apply after the rule (and, from S08, the high-latitude chain) and
/// before rounding; the raw instant stays the rule's own (§15 D29, D43).
/// Pure and deterministic.
final class PerEventOffsets {
  /// The adjustment step.
  const new();

  /// [profile] when its offsets are within bounds, otherwise
  /// `EngineFailure.invalidProfile` (REQ-ERR-001).
  Result<PrayerProfile, EngineFailure> check(PrayerProfile profile) {
    final bound = profile.maxAbsMinutes;
    if (bound < 0) {
      return Result.err(
        EngineFailure.invalidProfile('adjustments.maxAbsMinutes $bound < 0'),
      );
    }
    for (final MapEntry(key: event, value: minutes)
        in profile.perEventMinutes.entries) {
      if (minutes.abs() > bound) {
        return Result.err(
          EngineFailure.invalidProfile(
            'adjustments.perEventMinutes.${event.name} $minutes exceeds '
            'maxAbsMinutes $bound',
          ),
        );
      }
    }
    return Result.ok(profile);
  }
}
