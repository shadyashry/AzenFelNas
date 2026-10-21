import 'package:dm_packages/src/tuf/tuf_role.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'tuf_roles.freezed.dart';
part 'tuf_roles.g.dart';

/// The four TUF-lite roles.
@freezed
abstract class TufRoles with _$TufRoles {
  /// Creates a [TufRoles].
  const factory({
    /// Root role.
    required TufRole root,

    /// Targets role.
    required TufRole targets,

    /// Snapshot role.
    required TufRole snapshot,

    /// Timestamp role.
    required TufRole timestamp,
  }) = _TufRoles;

  /// Decodes [json]; throws `CheckedFromJsonException` when it does not
  /// have the schema's shape.
  factory fromJson(Map<String, Object?> json) => _$TufRolesFromJson(json);
}
