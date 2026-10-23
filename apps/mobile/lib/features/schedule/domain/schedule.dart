import 'package:daily_muslim/features/contexts/domain/resolved_context.dart';
import 'package:geo_salah_core/geo_salah_core.dart';
import 'package:meta/meta.dart';

/// Consecutive prayer days for the active context (`CalculateSchedule`):
/// what Home and the day timeline show. Times are UTC epoch ms; local time is
/// derived with [tzdbVersion]'s database at the edge (REQ-TIME-001).
@immutable
final class Schedule {
  /// [days] for [context] under profile [profileId].
  const new({
    required this.context,
    required this.profile,
    required this.engineDefault,
    required this.tzdbVersion,
    required this.days,
    required this.inputs,
  });

  /// The context calculated for.
  final ResolvedContext context;

  /// The profile that applied (`ResolveProfile`, ADR-007).
  final PrayerProfile profile;

  /// The id of [profile].
  String get profileId => profile.profileId;

  /// No local profile: `engine.default` applied (US-06, `noLocalProfile`).
  final bool engineDefault;

  /// The TZDB release local times are derived with.
  final String tzdbVersion;

  /// The days from the local today, in order; never empty.
  final List<DayResult> days;

  /// The Calculation ID inputs of each of [days], index for index (§6.4
  /// ¶11): what the Accuracy Passport shows and shares.
  final List<CalculationInputs> inputs;

  /// The zone of [context].
  String get zoneId => context.context.place.zoneId;
}
