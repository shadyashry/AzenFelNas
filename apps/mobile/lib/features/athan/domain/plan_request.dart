import 'package:daily_muslim/features/athan/domain/athan_preferences.dart';
import 'package:daily_muslim/features/athan/domain/plan_target.dart';
import 'package:geo_salah_core/geo_salah_core.dart';
import 'package:meta/meta.dart';

/// Everything `BuildSchedulePlan` reads (§7.7): engine days of one context,
/// the user's preferences and the target platform.
@immutable
final class PlanRequest {
  /// A request for [days] of [contextId] in [zoneId].
  const new({
    required this.contextId,
    required this.zoneId,
    required this.days,
    required this.generation,
    required this.nowUtcMs,
    required this.preferences,
    required this.target,
  });

  /// Location context id; part of every entry id.
  final String contextId;

  /// IANA zone the days were calculated in (REQ-TIME-001).
  final String zoneId;

  /// Consecutive prayer days from the local today.
  final List<DayResult> days;

  /// Plan generation, strictly above the last applied one.
  final int generation;

  /// The build instant; entries at or before it are not scheduled.
  final int nowUtcMs;

  /// The user's Athan choices.
  final AthanPreferences preferences;

  /// The platform the plan is fitted for.
  final PlanTarget target;
}
