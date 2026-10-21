import 'package:freezed_annotation/freezed_annotation.dart';

part 'tuf_meta_ref.freezed.dart';
part 'tuf_meta_ref.g.dart';

/// Reference to another metadata file.
@freezed
abstract class TufMetaRef with _$TufMetaRef {
  /// Creates a [TufMetaRef].
  const factory({
    /// Referenced sequence.
    required int version,

    /// Lowercase hex SHA-256 of the file.
    required String sha256,
  }) = _TufMetaRef;

  /// Decodes [json]; throws `CheckedFromJsonException` when it does not
  /// have the schema's shape.
  factory fromJson(Map<String, Object?> json) => _$TufMetaRefFromJson(json);
}
