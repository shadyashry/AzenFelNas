import 'package:geo_salah_core/geo_salah_core.dart';
import 'package:meta/meta.dart';

/// Where a Passport entry's day came from.
enum PassportOrigin {
  /// This device's own schedule.
  local,

  /// Recomputed on this device from a shared link's inputs; the IDs match.
  importedMatch,
}

/// One Accuracy Passport entry (§6.4, US-08): a calculated day with
/// everything needed to explain each of its times.
@immutable
final class PassportEntry {
  /// Creates a [PassportEntry].
  const new({
    required this.day,
    required this.inputs,
    required this.zoneId,
    required this.profile,
    required this.sensitivityMs,
    required this.origin,
    this.focus,
  });

  /// The calculated day (times, flags, provenance, adjustment trace).
  final DayResult day;

  /// The inputs [day]'s Calculation ID hashes.
  final CalculationInputs inputs;

  /// The observer's zone, for local times.
  final String zoneId;

  /// The profile the day was calculated with (rounding modes).
  final PrayerProfile profile;

  /// Per event, the largest change of the raw instant, in ms, when the
  /// observer moves 1 km north, south, east or west (§6.7 perturbation);
  /// absent when an event has no time or a perturbed day failed.
  final Map<PrayerEvent, int> sensitivityMs;

  /// Local schedule or a matching import.
  final PassportOrigin origin;

  /// The addressed event (`<calcId>#<event>`), or `null`.
  final PrayerEvent? focus;

  /// The rounding mode applied to [event] (`rounding.<event>` override, else
  /// `rounding.default`).
  RoundingMode roundingOf(PrayerEvent event) =>
      profile.roundingOverrides[event] ?? profile.roundingDefault;
}
