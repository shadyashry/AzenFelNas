import 'package:freezed_annotation/freezed_annotation.dart';

part 'tuf_role.freezed.dart';
part 'tuf_role.g.dart';

/// Keys and threshold of a role (REQ-DIST-001).
@freezed
abstract class TufRole with _$TufRole {
  /// Creates a [TufRole].
  const factory({
    /// Key ids allowed to sign.
    required List<String> keyIds,

    /// Signatures required.
    required int threshold,
  }) = _TufRole;

  /// Decodes [json]; throws `CheckedFromJsonException` when it does not
  /// have the schema's shape.
  factory fromJson(Map<String, Object?> json) => _$TufRoleFromJson(json);
}
