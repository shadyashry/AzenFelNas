import 'package:json_annotation/json_annotation.dart';

/// Download priority (§7.4).
@JsonEnum()
enum TargetPriorityCode {
  /// Normal.
  normal,

  /// Download on any network.
  urgent,
}
