import 'package:dm_contracts/dm_contracts.dart';

/// Fits plan entries into an iOS pending-request budget (REQ-ALM-032):
/// entries are dropped by priority (3 before 2 before 1) and, within a
/// priority, from the farthest instant first. Pure and deterministic.
final class FitSlotBudget {
  /// The fitter.
  const new();

  /// At most [budget] of [entries], in their original order.
  List<SchedulePlanEntry> call(List<SchedulePlanEntry> entries, int budget) {
    if (entries.length <= budget) return List.unmodifiable(entries);
    final keepFirst = [...entries]..sort(_keepOrder);
    final kept = keepFirst.take(budget < 0 ? 0 : budget).toSet();
    return List.unmodifiable(entries.where(kept.contains));
  }

  /// Most important first: lower priority number, then earlier, then id.
  static int _keepOrder(SchedulePlanEntry a, SchedulePlanEntry b) {
    final byPriority = a.priority.compareTo(b.priority);
    if (byPriority != 0) return byPriority;
    final byInstant = a.fireAtUtcMs.compareTo(b.fireAtUtcMs);
    return byInstant != 0 ? byInstant : a.id.compareTo(b.id);
  }
}
