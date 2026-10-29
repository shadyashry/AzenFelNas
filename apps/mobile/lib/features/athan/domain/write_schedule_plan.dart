/// A `schedule_plan.v1` document encoded as JSON (§7.7), as the native plan
/// store receives it. Built by `ReconcileSchedulePlan` only.
extension type const EncodedPlan(String json);

/// Hands an encoded plan to the native scheduler (pigeon `reconcile`,
/// §7.8). The host validates it, replaces its stored plan whole (write,
/// then rename) and re-arms from it; a plan older than the stored
/// generation is refused.
abstract interface class WriteSchedulePlan {
  /// True when the host took [plan]; false when it refused it or no host
  /// answered, and its previous plan stays armed. Never throws.
  Future<bool> call(EncodedPlan plan);
}
