import 'package:dm_packages/src/tuf/tuf_meta_ref.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'tuf_snapshot_meta.freezed.dart';
part 'tuf_snapshot_meta.g.dart';

/// Metadata referenced by the snapshot role.
@freezed
abstract class TufSnapshotMeta with _$TufSnapshotMeta {
  /// Creates a [TufSnapshotMeta].
  const factory({
    /// `targets.json`.
    @JsonKey(name: 'targets.json') required TufMetaRef targetsJson,
  }) = _TufSnapshotMeta;

  /// Decodes [json]; throws `CheckedFromJsonException` when it does not
  /// have the schema's shape.
  factory fromJson(Map<String, Object?> json) =>
      _$TufSnapshotMetaFromJson(json);
}
