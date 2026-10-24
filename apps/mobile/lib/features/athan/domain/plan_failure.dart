import 'package:dm_core_types/dm_core_types.dart';
import 'package:meta/meta.dart';

/// Why a built `SchedulePlan` did not reach the native scheduler (§7.7).
@immutable
sealed class PlanFailure implements Failure {
  const new();

  /// The host refused the plan or did not answer: `PLAN_WRITE_FAILED`. Its
  /// previous plan is still armed.
  const factory writeRefused(int generation) = PlanWriteRefused;
}

/// [PlanFailure.writeRefused].
final class PlanWriteRefused extends PlanFailure {
  /// The refused plan's [generation].
  const new(this.generation);

  /// Generation of the plan the host did not store.
  final int generation;

  @override
  FailureCode get code => FailureCode.planWriteFailed;

  @override
  bool operator ==(Object other) =>
      other is PlanWriteRefused && other.generation == generation;

  @override
  int get hashCode => Object.hash(PlanWriteRefused, generation);

  @override
  String toString() => 'PlanWriteRefused($generation)';
}
