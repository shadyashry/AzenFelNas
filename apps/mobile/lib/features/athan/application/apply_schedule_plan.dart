import 'package:dm_contracts/dm_contracts.dart';

/// Hands a `SchedulePlan` to the native scheduler (ADR-002, §7.7
/// `applyPlan`). The host replaces its stored plan whole (write, then
/// rename) and re-arms from it, so it holds either the old plan or the new
/// one, never a mix. A plan older than the stored generation is refused;
/// the same generation is written again (`PlanStore`, §7.8).
abstract interface class ApplySchedulePlan {
  /// True when the host stored and armed [plan]; false when it refused or
  /// no host answered, and its previous plan is still armed. Never throws.
  Future<bool> call(SchedulePlan plan);
}
