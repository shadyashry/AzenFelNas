/// The platform a `SchedulePlan` is fitted for (ADR-002, §7.7): variation is
/// a sealed type, never a platform flag (§17.1 O).
sealed class PlanTarget {
  const new();

  /// Hours before the horizon end at which `HORIZON_WARNING` fires.
  int get warningLeadHours;
}

/// Android: 30 days of entries, warning 48 h before the end (REQ-ALM-010).
final class AndroidPlanTarget extends PlanTarget {
  /// The Android target.
  const new();

  /// Calendar days of entries from the local today.
  static const int horizonDays = 30;

  @override
  int get warningLeadHours => 48;
}

/// iOS: as many entries as [slotBudget] allows after priority fitting,
/// warning 24 h before the end (REQ-ALM-010, REQ-ALM-032).
final class IosPlanTarget extends PlanTarget {
  /// The iOS target with [slotBudget] pending requests.
  const new({this.slotBudget = defaultSlotBudget});

  /// The iOS pending-notification limit; it stays 64 until the S19 spike
  /// reports GO for AlarmKit (ADR-013, ADR-025, §15 D79).
  static const int defaultSlotBudget = 64;

  /// Pending requests the plan may hold, the horizon warning included.
  final int slotBudget;

  @override
  int get warningLeadHours => 24;
}
