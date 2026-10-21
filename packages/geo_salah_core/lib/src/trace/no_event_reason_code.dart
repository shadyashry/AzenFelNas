import 'package:json_annotation/json_annotation.dart';

/// Why an event has no time (`NoEventReason`, §6.2).
@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum NoEventReasonCode {
  /// The sun never sets.
  polarDay,

  /// The sun never rises.
  polarNight,

  /// The target altitude is never reached.
  twilightAbsent,

  /// The Asr shadow condition cannot occur.
  asrUndefined,

  /// Every high-latitude method in the chain failed.
  chainExhausted,
}
