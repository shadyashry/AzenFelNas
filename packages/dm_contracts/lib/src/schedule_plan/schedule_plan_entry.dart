import 'package:dm_contracts/src/schedule_plan/localized_text.dart';
import 'package:dm_contracts/src/schedule_plan/schedule_entry_kind.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:geo_salah_core/geo_salah_core.dart';

part 'schedule_plan_entry.freezed.dart';
part 'schedule_plan_entry.g.dart';

/// One scheduled alarm or notification. [event] is absent exactly for
/// `horizonWarning` entries.
@freezed
abstract class SchedulePlanEntry with _$SchedulePlanEntry {
  /// Creates a [SchedulePlanEntry].
  const factory({
    /// Deterministic id: hex of sha256(`contextId|day|event|kind`)[0:16].
    required String id,

    /// Prayer day, `YYYY-MM-DD`.
    required String day,

    /// Entry kind.
    required ScheduleEntryKind kind,

    /// Fire instant = displayedUtcMs (REQ-ALM-001).
    required int fireAtUtcMs,

    /// Pre-rendered `HH:mm` in the plan's zone.
    required String displayLocal,

    /// Title.
    required LocalizedText title,

    /// Body.
    required LocalizedText body,

    /// Sound id.
    required String soundId,

    /// iOS fitting priority, 1–3.
    required int priority,

    /// Event, absent for horizon warnings.
    PrayerEventCode? event,
  }) = _SchedulePlanEntry;

  /// Decodes [json]; throws `CheckedFromJsonException` when it does not
  /// have the schema's shape.
  factory fromJson(Map<String, Object?> json) =>
      _$SchedulePlanEntryFromJson(json);
}
