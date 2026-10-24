import 'package:daily_muslim/features/athan/application/build_schedule_plan.dart';
import 'package:daily_muslim/features/athan/application/plan_context_id.dart';
import 'package:daily_muslim/features/athan/application/plan_request.dart';
import 'package:daily_muslim/features/athan/application/plan_subject.dart';
import 'package:daily_muslim/features/athan/domain/plan_texts.dart';
import 'package:daily_muslim/features/schedule/application/calculate_schedule.dart';
import 'package:daily_muslim/features/schedule/domain/runtime_data.dart';
import 'package:dm_contracts/dm_contracts.dart';
import 'package:dm_core_types/dm_core_types.dart';

/// Calculates the plan days of a [PlanSubject] from [RuntimeData] and
/// builds its `SchedulePlan` (§7.7): the same data and subject at the same
/// instant give the same plan, byte for byte.
final class PlanSchedule {
  /// Plans at [_clock] with the copy of [_texts].
  const new(this._clock, this._texts);

  final Clock _clock;
  final PlanTexts _texts;

  /// The plan of [subject] over [data], or the calculation failure.
  Result<SchedulePlan, Failure> call(RuntimeData data, PlanSubject subject) {
    final place = subject.context.context;
    return CalculateSchedule(_clock)(
      subject.context,
      data,
      hijriOverrideDays: subject.hijriOverrideDays,
      dayCount: CalculateSchedule.planDays,
    ).map(
      (schedule) => BuildSchedulePlan(data.tzdb, _texts)(
        PlanRequest(
          contextId: PlanContextId.of(place.id),
          zoneId: place.place.zoneId,
          days: schedule.days,
          generation: subject.generation,
          nowUtcMs: _clock.nowUtcMs(),
          preferences: subject.preferences,
          target: subject.target,
        ),
      ),
    );
  }
}
