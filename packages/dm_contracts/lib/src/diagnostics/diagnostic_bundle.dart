import 'package:dm_contracts/src/diagnostics/diagnostic_files.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'diagnostic_bundle.freezed.dart';
part 'diagnostic_bundle.g.dart';

/// Wire form of `diagnostic_bundle.v1` (§7.2, REQ-PRIV-005): the redacted
/// bundle the user sees in full before exporting it (§15 D84).
@freezed
abstract class DiagnosticBundle with _$DiagnosticBundle {
  /// Creates a [DiagnosticBundle].
  const factory({
    /// Always [currentSchemaVersion].
    required int schemaVersion,

    /// When the bundle was assembled.
    required int createdUtcMs,

    /// The §7.2 members.
    required DiagnosticFiles files,
  }) = _DiagnosticBundle;

  /// Decodes [json]; throws `CheckedFromJsonException` when it does not
  /// have the schema's shape.
  factory fromJson(Map<String, Object?> json) =>
      _$DiagnosticBundleFromJson(json);

  /// The schema version this model writes.
  static const currentSchemaVersion = 1;
}
