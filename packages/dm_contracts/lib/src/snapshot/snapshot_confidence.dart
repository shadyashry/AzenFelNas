import 'package:dm_contracts/src/snapshot/confidence_kind_code.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'snapshot_confidence.freezed.dart';
part 'snapshot_confidence.g.dart';

/// Confidence of a snapshot item; [detail] is absent exactly for `calculated`.
@freezed
abstract class SnapshotConfidence with _$SnapshotConfidence {
  /// Creates a [SnapshotConfidence].
  const factory({
    /// Label kind.
    required ConfidenceKindCode kind,

    /// Report id, source, range, count or reason (REQ-UX-001).
    String? detail,
  }) = _SnapshotConfidence;

  /// Decodes [json]; throws `CheckedFromJsonException` when it does not
  /// have the schema's shape.
  factory fromJson(Map<String, Object?> json) =>
      _$SnapshotConfidenceFromJson(json);
}
