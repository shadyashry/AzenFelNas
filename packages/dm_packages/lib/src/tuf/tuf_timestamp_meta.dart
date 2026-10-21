import 'package:dm_packages/src/tuf/tuf_meta_ref.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'tuf_timestamp_meta.freezed.dart';
part 'tuf_timestamp_meta.g.dart';

/// Metadata referenced by the timestamp role.
@freezed
abstract class TufTimestampMeta with _$TufTimestampMeta {
  /// Creates a [TufTimestampMeta].
  const factory({
    /// `snapshot.json`.
    @JsonKey(name: 'snapshot.json') required TufMetaRef snapshotJson,
  }) = _TufTimestampMeta;

  /// Decodes [json]; throws `CheckedFromJsonException` when it does not
  /// have the schema's shape.
  factory fromJson(Map<String, Object?> json) =>
      _$TufTimestampMetaFromJson(json);
}
