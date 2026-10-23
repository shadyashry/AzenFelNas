import Foundation

/// The bridge's `reconcile(schedulePlanJson)` (DESIGN.md §7.8): persists a new plan atomically in the App Group
/// (REQ-ALM-035) and re-arms its window; the re-arm removes what the new plan dropped. Idempotent by entry id +
/// generation: the same plan again changes nothing, an older generation is `stale` (REQ-ALM-002).
struct ApplyPlan: Sendable {
    let store: PlanStore
    let rearm: RearmFromPlan

    func callAsFunction(planJSON: Data) async -> ReconcileOutcome {
        switch store.write(planJSON: planJSON) {
        case .written:
            return await rearm(.planApplied)
        case let .stale(current, offered):
            let outcome = ReconcileOutcome.stale(current: current, offered: offered)
            rearm.record(.planApplied, generation: current, outcome)
            return outcome
        case .rejected:
            return failed(.planSchemaUnsupported, detail: nil)
        case let .unwritable(reason):
            return failed(.planWriteFailed, detail: reason)
        }
    }

    private func failed(_ code: FailureCode, detail: String?) -> ReconcileOutcome {
        let outcome = ReconcileOutcome.failed(code: code, detail: detail)
        rearm.record(.planApplied, generation: nil, outcome)
        return outcome
    }
}

/// The bridge's `cancelGenerationsBelow(generation)`: removes every plan request when the persisted plan is
/// older than `generation` (Dart is about to apply a newer one, or Athan was switched off).
struct CancelGenerationsBelow: Sendable {
    let store: PlanStore
    let alarms: any AlarmKitPort
    let notifications: any NotificationPort

    func callAsFunction(_ generation: Int) async {
        guard let plan = store.read(), plan.generation < generation else { return }
        let pending = await notifications.pendingIds().filter(PlanIds.isPlanNotification)
        if !pending.isEmpty { await notifications.remove(ids: pending) }
        for id in await alarms.scheduledIds() where PlanIds.entryId(ofAlarm: id) != nil {
            await alarms.cancel(id: id)
        }
    }
}
