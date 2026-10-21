import 'package:dm_contracts/src/telemetry/telemetry_counters.dart';
import 'package:dm_contracts/src/telemetry/telemetry_platform.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'telemetry_aggregate.freezed.dart';
part 'telemetry_aggregate.g.dart';

/// Wire form of `telemetry_aggregate.v1` (Appendix L): no ids, no coordinates,
/// day granularity (REQ-PRIV-001).
@freezed
abstract class TelemetryAggregate with _$TelemetryAggregate {
  /// Creates a [TelemetryAggregate].
  const factory({
    /// Schema version; 1.
    required int schemaVersion,

    /// Day, `YYYY-MM-DD`.
    required String day,

    /// App version.
    required String appVersion,

    /// Platform.
    required TelemetryPlatform platform,

    /// OS major version.
    required int osMajor,

    /// Counters.
    required TelemetryCounters counters,

    /// Country, when consented.
    String? countryCode,
  }) = _TelemetryAggregate;

  /// Decodes [json]; throws `CheckedFromJsonException` when it does not
  /// have the schema's shape.
  factory fromJson(Map<String, Object?> json) =>
      _$TelemetryAggregateFromJson(json);
}
