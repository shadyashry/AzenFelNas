import 'package:daily_muslim/features/athan/domain/write_schedule_plan.dart';
import 'package:dm_contracts/athan_scheduler_api.dart';
import 'package:flutter/services.dart';

/// [WriteSchedulePlan] over pigeon `AthanSchedulerApi.reconcile` (§7.8); a
/// missing or failing host is a refusal.
final class PigeonWriteSchedulePlan implements WriteSchedulePlan {
  /// The adapter over [_api].
  const new(this._api);

  final AthanSchedulerApi _api;

  @override
  Future<bool> call(EncodedPlan plan) async {
    try {
      await _api.reconcile(plan.json);
      return true;
    } on PlatformException {
      return false;
    }
  }
}
