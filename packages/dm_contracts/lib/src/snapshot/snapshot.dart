import 'package:dm_contracts/src/schedule_plan/plan_locale.dart';
import 'package:dm_contracts/src/snapshot/sky_segment.dart';
import 'package:dm_contracts/src/snapshot/snapshot_health.dart';
import 'package:dm_contracts/src/snapshot/snapshot_item.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'snapshot.freezed.dart';
part 'snapshot.g.dart';

/// Wire form of `snapshot.v1` (Appendix I): 48 h of displayed times for
/// widgets, which never recalculate.
@freezed
abstract class Snapshot with _$Snapshot {
  /// Creates a [Snapshot].
  const factory({
    /// Schema version; 1.
    required int schemaVersion,

    /// Location context id.
    required String contextId,

    /// IANA zone.
    required String zoneId,

    /// Pinned TZDB version.
    required String tzdbVersion,

    /// When it was written.
    required int generatedAtUtcMs,

    /// Locale of pre-rendered text.
    required PlanLocale locale,

    /// Displayed times.
    required List<SnapshotItem> items,

    /// Sky-phase timeline.
    required List<SkySegment> skyTimeline,

    /// Athan Health summary.
    required SnapshotHealth health,
  }) = _Snapshot;

  /// Decodes [json]; throws `CheckedFromJsonException` when it does not
  /// have the schema's shape.
  factory fromJson(Map<String, Object?> json) => _$SnapshotFromJson(json);
}
