import 'package:dm_contracts/src/schedule_plan/schedule_plan_entry.dart';
import 'package:dm_contracts/src/schedule_plan/schedule_plan_policy.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'schedule_plan.freezed.dart';
part 'schedule_plan.g.dart';

/// Wire form of `schedule_plan.v1` (Appendix B): the only input of native
/// scheduling (ADR-002), built by the app's `BuildSchedulePlan` (S20).
@freezed
abstract class SchedulePlan with _$SchedulePlan {
  /// Creates a [SchedulePlan].
  const factory({
    /// Schema version; 1.
    required int schemaVersion,

    /// Monotonic plan generation.
    required int generation,

    /// Location context id.
    required String contextId,

    /// IANA zone of the plan (REQ-TIME-001).
    required String zoneId,

    /// Pinned TZDB version (REQ-TIME-001).
    required String tzdbVersion,

    /// When the plan was built.
    required int generatedAtUtcMs,

    /// End of the scheduled horizon (REQ-ALM-010).
    required int horizonEndUtcMs,

    /// Entries.
    required List<SchedulePlanEntry> entries,

    /// Delivery policy.
    required SchedulePlanPolicy policy,
  }) = _SchedulePlan;

  /// Decodes [json]; throws `CheckedFromJsonException` when it does not
  /// have the schema's shape.
  factory fromJson(Map<String, Object?> json) => _$SchedulePlanFromJson(json);
}
