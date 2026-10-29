import 'dart:convert';

import 'package:daily_muslim/features/athan/application/apply_schedule_plan.dart';
import 'package:daily_muslim/features/athan/domain/write_schedule_plan.dart';
import 'package:dm_contracts/dm_contracts.dart';

/// [ApplySchedulePlan] over the native [WriteSchedulePlan] port: encodes
/// the plan as its `schedule_plan.v1` JSON and hands it over (§7.8).
final class ReconcileSchedulePlan implements ApplySchedulePlan {
  /// Writes through [_write].
  const new(this._write);

  final WriteSchedulePlan _write;

  @override
  Future<bool> call(SchedulePlan plan) =>
      _write(EncodedPlan(jsonEncode(plan.toJson())));
}
