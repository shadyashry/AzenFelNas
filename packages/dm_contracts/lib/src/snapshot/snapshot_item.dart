import 'package:dm_contracts/src/snapshot/snapshot_confidence.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:geo_salah_core/geo_salah_core.dart';

part 'snapshot_item.freezed.dart';
part 'snapshot_item.g.dart';

/// One displayed time.
@freezed
abstract class SnapshotItem with _$SnapshotItem {
  /// Creates a [SnapshotItem].
  const factory({
    /// Prayer day, `YYYY-MM-DD`.
    required String day,

    /// Event.
    required PrayerEventCode event,

    /// Displayed instant.
    required int displayedUtcMs,

    /// Pre-rendered `HH:mm`.
    required String displayLocal,

    /// Confidence.
    required SnapshotConfidence confidence,

    /// Local-date offset, −1…1.
    required int dayOffset,
  }) = _SnapshotItem;

  /// Decodes [json]; throws `CheckedFromJsonException` when it does not
  /// have the schema's shape.
  factory fromJson(Map<String, Object?> json) => _$SnapshotItemFromJson(json);
}
