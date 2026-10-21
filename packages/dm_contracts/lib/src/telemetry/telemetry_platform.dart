import 'package:json_annotation/json_annotation.dart';

/// Platform of a telemetry aggregate.
@JsonEnum()
enum TelemetryPlatform {
  /// Android.
  android,

  /// iOS.
  ios,
}
