import Foundation

/// The `AthanSchedulerApi` operations of DESIGN.md §7.8 for iOS; the pigeon host generated in S23 delegates to
/// it. Every operation works from the persisted plan and the platform state, with no Dart isolate (§0.2 rule 5).
struct AthanBridge: Sendable {
    let graph: AthanGraph

    /// Persists `schedulePlanJson` and arms its window; idempotent by entry id + generation.
    func reconcile(_ schedulePlanJson: String) async -> ReconcileOutcome {
        await graph.applyPlan(planJSON: Data(schedulePlanJson.utf8))
    }

    /// Re-arms the persisted plan after a system event or on launch.
    func rearm(_ cause: ReconcileCause) async -> ReconcileOutcome {
        await graph.rearm(cause)
    }

    /// Removes every plan request when the persisted plan is older than `generation`.
    func cancelGenerationsBelow(_ generation: Int) async {
        await graph.cancelBelow(generation)
    }

    /// Evaluates the Athan Health probes now (§8.3).
    func health() async -> HealthReport {
        let now = graph.clock.nowUtcMs()
        let path = await graph.gate.current()
        let probes = await graph.platformProbes.probes(on: path)
            + graph.planProbes.probes(of: graph.planStore.read(), nowUtcMs: now)
        let report = graph.evaluateHealth(probes, path: path, evaluatedAtUtcMs: now)
        graph.events.append(.healthEvaluated, .of(state: report.state.rawValue, reason: path.label))
        return report
    }

    /// Schedules the Athan Test (REQ-ALM-040).
    func startTest(testId: String, fireInSeconds: Int, soundId: String) async -> ArmResult {
        await graph.startTest(testId: testId, fireInSeconds: fireInSeconds, soundId: soundId)
    }

    /// Receipts and system events since the last drain (REQ-ALM-041); Dart drains on every start.
    func drainEvents() -> [EventLogEntry] {
        graph.events.drain()
    }
}
