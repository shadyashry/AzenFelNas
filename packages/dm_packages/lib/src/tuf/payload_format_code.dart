import 'package:json_annotation/json_annotation.dart';

/// Payload format of a package (§9.5).
@JsonEnum()
enum PayloadFormatCode {
  /// JSON.
  json,

  /// Binary.
  bin,

  /// SQLite.
  sqlite,
}
