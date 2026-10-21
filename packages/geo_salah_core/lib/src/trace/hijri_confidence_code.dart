import 'package:json_annotation/json_annotation.dart';

/// Wire form of `HijriConfidence` (§6.2).
@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum HijriConfidenceCode {
  /// Month start confirmed by a signed announcement.
  confirmed,

  /// Tabular fallback; not yet announced (ADR-016).
  expected,

  /// Adjusted by the user's ±1 day override.
  userOverride,
}
