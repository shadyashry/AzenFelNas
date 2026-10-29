import 'package:daily_muslim/features/athan/application/apply_schedule_plan.dart';
import 'package:daily_muslim/features/athan/application/athan_preferences.dart';
import 'package:daily_muslim/features/athan/application/plan_schedule.dart';
import 'package:daily_muslim/features/athan/application/plan_subject.dart';
import 'package:daily_muslim/features/athan/domain/plan_failure.dart';
import 'package:daily_muslim/features/athan/domain/plan_target.dart';
import 'package:daily_muslim/features/contexts/domain/resolved_context.dart';
import 'package:daily_muslim/features/schedule/domain/runtime_data.dart';
import 'package:daily_muslim/features/settings/domain/app_settings.dart';
import 'package:daily_muslim/features/settings/domain/settings_ports.dart';
import 'package:dm_contracts/dm_contracts.dart';
import 'package:dm_core_types/dm_core_types.dart';

/// Arms the Athan for the active place (ADR-002, §7.7, §15 D94): plans the
/// context's next days with the user's [AthanPreferences] under the next
/// generation and hands the plan to the native host. The stored generation
/// moves on only once the host stored the plan, so a refused plan is
/// planned again under the same generation next time.
final class ApplyAthanPlan {
  /// The use case over its collaborators.
  const new({
    required this._plan,
    required this._apply,
    required this._read,
    required this._write,
  });

  final PlanSchedule _plan;
  final ApplySchedulePlan _apply;
  final WatchSetting _read;
  final WriteSetting _write;

  /// The plan the host now holds for [context] over [data], or why none.
  Future<Result<SchedulePlan, Failure>> call(
    RuntimeData data,
    ResolvedContext context, {
    required AthanPreferences preferences,
    required PlanTarget target,
    required int hijriOverrideDays,
  }) async {
    final last = await _read.watch(AppSettings.athanPlanGeneration).first;
    final planned = _plan(
      data,
      PlanSubject(
        context: context,
        preferences: preferences,
        target: target,
        generation: last + 1,
        hijriOverrideDays: hijriOverrideDays,
      ),
    );
    switch (planned) {
      case Err(:final failure):
        return Result.err(failure);
      case Ok(value: final plan):
        if (!await _apply(plan)) {
          return Result.err(PlanFailure.writeRefused(plan.generation));
        }
        await _write.write(AppSettings.athanPlanGeneration, plan.generation);
        return Result.ok(plan);
    }
  }
}
