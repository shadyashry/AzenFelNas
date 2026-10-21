import 'package:dm_contracts/src/snapshot/health_state_code.dart';
import 'package:dm_contracts/src/telemetry/package_type_code.dart';
import 'package:dm_contracts/src/telemetry/sync_outcome_counts.dart';
import 'package:dm_contracts/src/telemetry/test_result_counts.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'telemetry_counters.freezed.dart';
part 'telemetry_counters.g.dart';

/// Daily counters.
@freezed
abstract class TelemetryCounters with _$TelemetryCounters {
  /// Creates a [TelemetryCounters].
  const factory({
    /// Activations per package type.
    required Map<PackageTypeCode, int> packageActivations,

    /// Evaluations per health state.
    required Map<HealthStateCode, int> healthState,

    /// Athan Test outcomes.
    required TestResultCounts testResults,

    /// Sync outcomes.
    required SyncOutcomeCounts syncOutcome,
  }) = _TelemetryCounters;

  /// Decodes [json]; throws `CheckedFromJsonException` when it does not
  /// have the schema's shape.
  factory fromJson(Map<String, Object?> json) =>
      _$TelemetryCountersFromJson(json);
}
