import 'package:dm_contracts/src/snapshot/health_state_code.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'snapshot_health.freezed.dart';
part 'snapshot_health.g.dart';

/// Athan Health summary.
@freezed
abstract class SnapshotHealth with _$SnapshotHealth {
  /// Creates a [SnapshotHealth].
  const factory({
    /// State.
    required HealthStateCode state,

    /// Number of reasons.
    required int reasonsCount,
  }) = _SnapshotHealth;

  /// Decodes [json]; throws `CheckedFromJsonException` when it does not
  /// have the schema's shape.
  factory fromJson(Map<String, Object?> json) => _$SnapshotHealthFromJson(json);
}
