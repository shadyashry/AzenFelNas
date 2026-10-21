import 'package:dm_packages/src/tuf/payload_format_code.dart';
import 'package:dm_packages/src/tuf/target_priority_code.dart';
import 'package:dm_packages/src/tuf/tuf_change_note.dart';
import 'package:dm_packages/src/tuf/tuf_compat.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'tuf_target_custom.freezed.dart';
part 'tuf_target_custom.g.dart';

/// Package metadata carried by a target (§9.1).
@freezed
abstract class TufTargetCustom with _$TufTargetCustom {
  /// Creates a [TufTargetCustom].
  const factory({
    /// Payload schema version.
    required int schemaVersion,

    /// Payload format.
    required PayloadFormatCode payloadFormat,

    /// Compatibility gate.
    required TufCompat compat,

    /// Effective date, `YYYY-MM-DD`.
    required String effectiveFrom,

    /// Download priority.
    required TargetPriorityCode priority,

    /// Change note.
    required TufChangeNote changeNote,

    /// Version this target rolls back from.
    String? rollbackOf,

    /// Attribution text.
    String? attribution,
  }) = _TufTargetCustom;

  /// Decodes [json]; throws `CheckedFromJsonException` when it does not
  /// have the schema's shape.
  factory fromJson(Map<String, Object?> json) =>
      _$TufTargetCustomFromJson(json);
}
