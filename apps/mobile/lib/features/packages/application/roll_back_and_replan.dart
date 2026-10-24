import 'package:daily_muslim/features/athan/application/apply_schedule_plan.dart';
import 'package:daily_muslim/features/athan/application/plan_schedule.dart';
import 'package:daily_muslim/features/athan/application/plan_subject.dart';
import 'package:daily_muslim/features/athan/domain/plan_failure.dart';
import 'package:daily_muslim/features/schedule/application/load_runtime_data.dart';
import 'package:dm_contracts/dm_contracts.dart';
import 'package:dm_core_types/dm_core_types.dart';
import 'package:dm_packages/dm_packages.dart';

/// Returns a package type to its previous version on the device and re-arms
/// the schedule that version gives (§19.4 package rollback, §15 D87).
///
/// Prepare, then commit: the plan is built from the previous file before
/// anything changes, so a previous version that cannot be loaded or
/// planned leaves the pointer and the armed plan as they were
/// (REQ-PKG-001). Then the pointer flips in one transaction
/// ([RollBackPackage]) and the plan is handed over whole
/// ([ApplySchedulePlan]). When the host refuses it, the pointer is already
/// back and the host keeps its old plan whole; the next start re-plans
/// from the active pointer.
final class RollBackAndReplan {
  /// The use case over its ports and the two use cases it sequences.
  const new({
    required this._read,
    required this._runtime,
    required this._plan,
    required this._rollBack,
    required this._apply,
  });

  final ReadPackageCatalog _read;
  final LoadRuntimeData _runtime;
  final PlanSchedule _plan;
  final RollBackPackage _rollBack;
  final ApplySchedulePlan _apply;

  /// The applied plan after [type] went back, at [nowUtcMs].
  Future<Result<SchedulePlan, Failure>> call(
    PackageType type,
    PlanSubject subject, {
    required int nowUtcMs,
  }) async {
    final previous = [
      for (final file in await _read.files(type))
        if (file.state == PackageFileState.previous) file,
    ];
    if (previous.isEmpty) {
      return Result.err(
        PackageFailure.storage('${type.wire} has no previous version'),
      );
    }
    final data = await _runtime(candidate: previous.first);
    final planned = data.flatMap((data) => _plan(data, subject));
    switch (planned) {
      case Err(:final failure):
        return Result.err(failure);
      case Ok(value: final plan):
        if (await _rollBack(type, nowUtcMs: nowUtcMs) case Err(
          :final failure,
        )) {
          return Result.err(failure);
        }
        return await _apply(plan)
            ? Result.ok(plan)
            : Result.err(PlanFailure.writeRefused(plan.generation));
    }
  }
}
