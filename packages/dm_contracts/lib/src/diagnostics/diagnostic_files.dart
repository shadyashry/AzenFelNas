import 'package:dm_contracts/src/diagnostics/diagnostic_context.dart';
import 'package:dm_contracts/src/diagnostics/diagnostic_device.dart';
import 'package:dm_contracts/src/diagnostics/diagnostic_health.dart';
import 'package:dm_contracts/src/diagnostics/diagnostic_package.dart';
import 'package:dm_contracts/src/diagnostics/diagnostic_plan.dart';
import 'package:dm_contracts/src/event_log/event_log_entry.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'diagnostic_files.freezed.dart';
part 'diagnostic_files.g.dart';

/// The bundle members, keyed by their §7.2 file names.
@freezed
abstract class DiagnosticFiles with _$DiagnosticFiles {
  /// Creates a [DiagnosticFiles].
  const factory({
    /// The event-log ring, oldest first.
    @JsonKey(name: 'events.jsonl') required List<EventLogEntry> events,

    /// Athan Health as Dart evaluated it.
    @JsonKey(name: 'health.json') required DiagnosticHealth health,

    /// The applied plan without texts or sounds.
    @JsonKey(name: 'plan_redacted.json') required DiagnosticPlan plan,

    /// Active packages.
    @JsonKey(name: 'packages.json') required List<DiagnosticPackage> packages,

    /// Device facts.
    @JsonKey(name: 'device.json') required DiagnosticDevice device,

    /// The active context at 0.01°, or null when there is none.
    @JsonKey(name: 'context.json', includeIfNull: true)
    required DiagnosticContext? context,
  }) = _DiagnosticFiles;

  /// Decodes [json]; throws `CheckedFromJsonException` when it does not
  /// have the schema's shape.
  factory fromJson(Map<String, Object?> json) =>
      _$DiagnosticFilesFromJson(json);
}
