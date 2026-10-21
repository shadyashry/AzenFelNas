import 'package:dm_contracts/src/schedule_plan/plan_locale.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'schedule_plan_policy.freezed.dart';
part 'schedule_plan_policy.g.dart';

/// Delivery policy of a plan.
@freezed
abstract class SchedulePlanPolicy with _$SchedulePlanPolicy {
  /// Creates a [SchedulePlanPolicy].
  const factory({
    /// Locale of the pre-rendered text.
    required PlanLocale locale,

    /// Whether Do Not Disturb silences the Athan.
    required bool respectDnd,

    /// Whether to vibrate.
    required bool vibrate,

    /// Whether Android plays the full Athan.
    required bool fullAthanAndroid,

    /// iOS clip length, at most 29 s (REQ-ALM-034).
    required int iosClipSeconds,

    /// Pre-reminder offset ∈ {0, 5, 10, 15, 30} (REQ-ALM-042).
    required int preReminderMinutes,

    /// Snooze length; 5 (REQ-ALM-042).
    required int snoozeMinutes,
  }) = _SchedulePlanPolicy;

  /// Decodes [json]; throws `CheckedFromJsonException` when it does not
  /// have the schema's shape.
  factory fromJson(Map<String, Object?> json) =>
      _$SchedulePlanPolicyFromJson(json);
}
