import 'package:dm_contracts/src/event_log/event_code_converter.dart';
import 'package:dm_contracts/src/event_log/event_log_attrs.dart';
import 'package:dm_contracts/src/event_log/event_log_level.dart';
import 'package:dm_core_types/dm_core_types.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'event_log_entry.freezed.dart';
part 'event_log_entry.g.dart';

/// Wire form of `event_log.v1` (Appendix J): one events.jsonl line or event_log
/// row.
@freezed
abstract class EventLogEntry with _$EventLogEntry {
  /// Creates a [EventLogEntry].
  const factory({
    /// When it happened.
    required int utcMs,

    /// Severity.
    required EventLogLevel level,

    /// Event code.
    @EventCodeConverter() required EventCode code,

    /// Attributes.
    required EventLogAttrs attrs,
  }) = _EventLogEntry;

  /// Decodes [json]; throws `CheckedFromJsonException` when it does not
  /// have the schema's shape.
  factory fromJson(Map<String, Object?> json) => _$EventLogEntryFromJson(json);
}
