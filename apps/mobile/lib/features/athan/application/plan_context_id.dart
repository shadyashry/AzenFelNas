/// The wire id of a location context in plans and snapshots (§7.7).
abstract final class PlanContextId {
  /// `ctx_<id>` of the stored context [id]; stable while the context lives.
  static String of(int id) => 'ctx_$id';
}
