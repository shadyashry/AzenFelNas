import 'package:dm_packages/src/tuf/tuf_target_custom.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'tuf_target.freezed.dart';
part 'tuf_target.g.dart';

/// A content-addressed package (REQ-DIST-003).
@freezed
abstract class TufTarget with _$TufTarget {
  /// Creates a [TufTarget].
  const factory({
    /// Size in bytes.
    required int length,

    /// Lowercase hex SHA-256.
    required String sha256,

    /// Package metadata.
    required TufTargetCustom custom,
  }) = _TufTarget;

  /// Decodes [json]; throws `CheckedFromJsonException` when it does not
  /// have the schema's shape.
  factory fromJson(Map<String, Object?> json) => _$TufTargetFromJson(json);
}
