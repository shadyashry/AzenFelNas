import Foundation

/// Outcome of `PlanStore.write(planJSON:)`.
enum PlanWriteOutcome: Equatable, Sendable {
    /// The plan of `generation` is now the persisted one.
    case written(generation: Int)
    /// An older generation was offered; the persisted plan of `current` stays.
    case stale(current: Int, offered: Int)
    /// The document is not a `schedule_plan.v1` plan; nothing changed.
    case rejected(reason: String)
    /// The container could not be written; the previous plan, if any, stays.
    case unwritable(reason: String)
}

/// The persisted `SchedulePlan` (ADR-002, DESIGN.md §8.2): `<directory>/plan.json` in the App Group container,
/// replaced atomically (REQ-ALM-035). Native code reads nothing else (§0.2 rule 5).
///
/// Contract: `write(planJSON:)` validates the document and never replaces a plan with an older generation; the
/// same generation is written again (reconcile is idempotent, §7.8). `read()` returns nil for a missing or
/// unreadable file and never throws.
struct PlanStore: Sendable {
    /// File name inside the plan directory.
    static let planFile = "plan.json"
    /// The schema version this reader accepts.
    static let schemaVersion = 1

    private let file: WireFile

    /// A store in `directory`.
    init(directory: URL) {
        file = WireFile(url: directory.appendingPathComponent(Self.planFile))
    }

    /// Persists `planJSON` when it is a plan at least as new as the stored one.
    func write(planJSON: Data) -> PlanWriteOutcome {
        guard let plan = WireFile.decode(SchedulePlan.self, from: planJSON) else {
            return .rejected(reason: "not a schedule_plan.v1 document")
        }
        guard plan.schemaVersion == Self.schemaVersion else {
            return .rejected(reason: "schemaVersion \(plan.schemaVersion)")
        }
        if let current = read(), plan.generation < current.generation {
            return .stale(current: current.generation, offered: plan.generation)
        }
        switch file.replace(with: planJSON) {
        case .success:
            return .written(generation: plan.generation)
        case let .failure(error):
            return .unwritable(reason: error.reason)
        }
    }

    /// The persisted plan, or nil.
    func read() -> SchedulePlan? {
        file.read().flatMap { WireFile.decode(SchedulePlan.self, from: $0) }
    }
}
