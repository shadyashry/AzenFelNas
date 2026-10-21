import 'package:json_annotation/json_annotation.dart';

/// Kind of a plan entry (§7.7).
@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum ScheduleEntryKind {
  /// Athan alarm.
  athan,

  /// Reminder before an Athan.
  preReminder,

  /// Imsak reminder.
  imsak,

  /// Warns that the plan horizon is ending.
  horizonWarning,
}
