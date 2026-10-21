import 'package:json_annotation/json_annotation.dart';

/// Severity of an event-log entry (§15 D21).
@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum EventLogLevel {
  /// Debug.
  debug,

  /// Info.
  info,

  /// Warning.
  warn,

  /// Error.
  error,
}
