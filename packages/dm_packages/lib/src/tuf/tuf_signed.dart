import 'package:dm_packages/src/tuf/tuf_key.dart';
import 'package:dm_packages/src/tuf/tuf_roles.dart';
import 'package:dm_packages/src/tuf/tuf_snapshot_meta.dart';
import 'package:dm_packages/src/tuf/tuf_target.dart';
import 'package:dm_packages/src/tuf/tuf_timestamp_meta.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'tuf_signed.freezed.dart';
part 'tuf_signed.g.dart';

/// The `signed` document of a TUF-lite metadata file (Appendix C),
/// discriminated by `type`.
@Freezed(unionKey: 'type')
sealed class TufSigned with _$TufSigned {
  /// `root`: trusted keys and role thresholds (REQ-DIST-001).
  const factory root({
    required int version,
    required String expires,
    required Map<String, TufKey> keys,
    required TufRoles roles,
  }) = TufRootSigned;

  /// `targets`: content-addressed packages (REQ-DIST-003).
  const factory targets({
    required int sequence,
    required String expires,
    required Map<String, TufTarget> targets,
  }) = TufTargetsSigned;

  /// `snapshot`: pins `targets.json`.
  const factory snapshot({
    required int sequence,
    required String expires,
    required TufSnapshotMeta meta,
  }) = TufSnapshotSigned;

  /// `timestamp`: pins `snapshot.json`; expires within 7 days.
  const factory timestamp({
    required int sequence,
    required String expires,
    required TufTimestampMeta meta,
  }) = TufTimestampSigned;

  /// Decodes [json]; throws `CheckedFromJsonException` when it does not
  /// have the schema's shape.
  factory fromJson(Map<String, Object?> json) => _$TufSignedFromJson(json);
}
