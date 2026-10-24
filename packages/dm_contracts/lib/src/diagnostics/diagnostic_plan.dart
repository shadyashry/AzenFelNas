import 'package:freezed_annotation/freezed_annotation.dart';

part 'diagnostic_plan.freezed.dart';
part 'diagnostic_plan.g.dart';

/// Whether a plan has been handed to the native layer.
enum DiagnosticPlanStatus {
  /// No plan applied yet.
  notApplied,

  /// A plan was applied.
  applied,
}

/// `plan_redacted.json`: the applied plan's shape, without texts or sounds.
@freezed
abstract class DiagnosticPlan with _$DiagnosticPlan {
  /// Creates a [DiagnosticPlan].
  const factory({
    /// Status.
    required DiagnosticPlanStatus status,

    /// Plan generation, when applied.
    int? generation,

    /// Number of entries, when applied.
    int? entryCount,
  }) = _DiagnosticPlan;

  /// Decodes [json]; throws `CheckedFromJsonException` when it does not
  /// have the schema's shape.
  factory fromJson(Map<String, Object?> json) => _$DiagnosticPlanFromJson(json);
}
