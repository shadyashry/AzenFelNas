import 'package:daily_muslim/features/athan/application/apply_schedule_plan.dart';
import 'package:dm_contracts/dm_contracts.dart';

/// The native plan store as the [ApplySchedulePlan] contract describes it
/// (`PlanStore`, §7.8): the stored plan is replaced whole, an older
/// generation is refused. Fake at the port only (§17.7).
final class FakePlanHost implements ApplySchedulePlan {
  /// A host that stores plans while [accepts] is true.
  new({this.accepts = true});

  /// False makes the host refuse every plan, as a missing host does.
  bool accepts;

  /// The stored plan; null before the first one.
  SchedulePlan? stored;

  /// Every plan offered, stored or not.
  final offered = <SchedulePlan>[];

  @override
  Future<bool> call(SchedulePlan plan) async {
    offered.add(plan);
    final current = stored;
    if (!accepts || (current != null && plan.generation < current.generation)) {
      return false;
    }
    stored = plan;
    return true;
  }
}
