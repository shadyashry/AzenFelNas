import 'package:json_annotation/json_annotation.dart';

/// Status of a Hijri month start (ADR-016).
@JsonEnum()
enum HijriMonthStatusCode {
  /// Officially announced.
  confirmed,

  /// Not yet announced.
  expected,
}
