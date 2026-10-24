import Foundation

/// The public face of AthanKit for Runner's pigeon host (DESIGN.md §7.8, §15 D83): plain types only, so every model
/// stays internal. Runner maps these to the generated pigeon types.
public struct AthanHost: Sendable {
    let bridge: AthanBridge

    /// Persists and arms a `schedule_plan.v1` document; the outcome is a `PLAN_APPLIED` event.
    public func reconcile(_ schedulePlanJson: String) async {
        _ = await bridge.reconcile(schedulePlanJson)
    }

    /// Disarms entries of plans older than `generation`.
    public func cancelGenerationsBelow(_ generation: Int) async {
        await bridge.cancelGenerationsBelow(generation)
    }

    /// Evaluates every probe now.
    public func health() async -> AthanHostHealth {
        let report = await bridge.health()
        return AthanHostHealth(
            state: report.state.label,
            reasons: report.reasons.map(\.rawValue),
            probes: report.probes.map {
                AthanHostProbe(name: $0.name.rawValue, positive: $0.positive, detail: $0.detail)
            },
            evaluatedAtUtcMs: report.evaluatedAtUtcMs,
            platformPath: report.platformPath,
        )
    }

    /// Arms the Athan Test (REQ-ALM-040); false when the platform refused.
    public func startTest(testId: String, fireInSeconds: Int, soundId: String) async -> Bool {
        await bridge.startTest(testId: testId, fireInSeconds: fireInSeconds, soundId: soundId) == .armed
    }

    /// Drains `events.jsonl` as `event_log.v1` JSON documents (REQ-ALM-041).
    public func drainEvents() -> [String] {
        let encoder = JSONEncoder()
        return bridge.drainEvents().compactMap { entry in
            (try? encoder.encode(entry)).flatMap { String(bytes: $0, encoding: .utf8) }
        }
    }

    /// Persists a `snapshot.v1` document and reloads the widgets; false when it was refused.
    public func writeSnapshot(_ snapshotJson: String) -> Bool {
        bridge.writeSnapshot(snapshotJson)
    }
}

/// `AthanHealthReport` of §7.8 with labels in place of enums.
public struct AthanHostHealth: Equatable, Sendable {
    public let state: String
    public let reasons: [String]
    public let probes: [AthanHostProbe]
    public let evaluatedAtUtcMs: Int64
    public let platformPath: String
}

/// `ProbeResult` of §7.8; `positive` is nil when the platform cannot tell.
public struct AthanHostProbe: Equatable, Sendable {
    public let name: String
    public let positive: Bool?
    public let detail: String?
}
