/// Re-arms the persisted plan's window (REQ-ALM-002): runs on every launch, foreground and system event, reads
/// only the `SchedulePlan` (§0.2 rule 5) and needs no Dart isolate. It diffs the platform's plan requests against
/// the window: requests the window dropped are removed, notifications are (re-)added with a trigger from the
/// current instant and alarms not yet scheduled are scheduled, so running it twice changes nothing.
struct RearmFromPlan: Sendable {
    let readPlan: @Sendable () -> SchedulePlan?
    let window: DeliveryWindow
    let alarms: any AlarmKitPort
    let notifications: any NotificationPort
    let gate: any DeliveryPathGate
    let clock: any UtcClock
    let events: EventsStore

    func callAsFunction(_ cause: ReconcileCause) async -> ReconcileOutcome {
        guard let plan = readPlan() else {
            let outcome = ReconcileOutcome.noPlan
            record(cause, generation: nil, outcome)
            return outcome
        }
        let path = await gate.current()
        let wanted = window.requests(for: plan, nowUtcMs: clock.nowUtcMs(), path: path)
        var refused = await syncNotifications(wanted.notifications)
        refused += await syncAlarms(wanted.alarms)
        let armed = wanted.alarms.count + wanted.notifications.count - refused.count
        let outcome: ReconcileOutcome = refused.isEmpty
            ? .applied(generation: plan.generation, armed: armed, path: path)
            : .partial(generation: plan.generation, armed: armed, refusedIds: refused)
        record(cause, generation: plan.generation, outcome)
        return outcome
    }

    private func syncNotifications(_ wanted: [NotificationRequest]) async -> [String] {
        let keep = Set(wanted.map(\.id))
        let stale = await notifications.pendingIds().filter { PlanIds.isPlanNotification($0) && !keep.contains($0) }
        if !stale.isEmpty { await notifications.remove(ids: stale) }
        let now = clock.nowUtcMs()
        var refused: [String] = []
        for request in wanted where await notifications.add(request, nowUtcMs: now) != .armed {
            refused.append(request.id)
        }
        return refused
    }

    private func syncAlarms(_ wanted: [AlarmRequest]) async -> [String] {
        let scheduled = await alarms.scheduledIds().filter { PlanIds.entryId(ofAlarm: $0) != nil }
        let keep = Set(wanted.map(\.id))
        for id in scheduled where !keep.contains(id) {
            await alarms.cancel(id: id)
        }
        var refused: [String] = []
        for alarm in wanted where !scheduled.contains(alarm.id) {
            if await alarms.schedule(alarm) != .armed { refused.append(alarm.entryId) }
        }
        return refused
    }

    /// Appends the `PLAN_APPLIED` line of `outcome` (also used by `ApplyPlan`), as Android does (D81).
    func record(_ cause: ReconcileCause, generation: Int?, _ outcome: ReconcileOutcome) {
        switch outcome {
        case let .applied(_, armed, path):
            events.append(
                .planApplied,
                .of(generation: generation, state: path.label, reason: cause.label, count: armed)
            )
        case let .partial(_, armed, refusedIds):
            events.append(.planApplied, .of(generation: generation, reason: cause.label, count: armed), level: .warn)
            for id in refusedIds {
                events.append(
                    .alarmScheduled,
                    .of(code: .alarmScheduleFailed, generation: generation, entryId: id),
                    level: .error
                )
            }
        case .noPlan:
            events.append(.planApplied, .of(state: Self.noPlanState, reason: cause.label), level: .warn)
        case let .stale(_, offered):
            events.append(
                .planApplied,
                .of(generation: offered, state: Self.staleState, reason: cause.label),
                level: .warn
            )
        case let .failed(code, detail):
            events.append(.planApplied, .of(code: code, state: detail, reason: cause.label), level: .error)
        }
    }

    /// `attrs.state` of a reconciliation without a plan.
    static let noPlanState = "noPlan"
    /// `attrs.state` of an offered plan older than the persisted one.
    static let staleState = "stale"
}
