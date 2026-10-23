/// Wire form of `snapshot.v1` (DESIGN.md Appendix I): 48 h of displayed times; widgets never recalculate.
struct Snapshot: Codable, Equatable, Sendable {
    let schemaVersion: Int
    let contextId: String
    let zoneId: String
    let tzdbVersion: String
    let generatedAtUtcMs: Int64
    let locale: PlanLocale
    let items: [SnapshotItem]
    let skyTimeline: [SkySegment]
    let health: SnapshotHealth
}

/// One displayed time.
struct SnapshotItem: Codable, Equatable, Sendable {
    let day: String
    let event: PrayerEvent
    let displayedUtcMs: Int64
    let displayLocal: String
    let confidence: SnapshotConfidence
    let dayOffset: Int
}

/// Confidence label; `detail` is nil exactly for `.calculated` (REQ-UX-001).
struct SnapshotConfidence: Codable, Equatable, Sendable {
    let kind: ConfidenceKind
    let detail: String?
}

/// Confidence label kinds.
enum ConfidenceKind: String, Codable, Sendable {
    case calculated = "CALCULATED"
    case authorityAligned = "AUTHORITY_ALIGNED"
    case verified = "VERIFIED"
    case estimated = "ESTIMATED"
    case observed = "OBSERVED"
    case unknown = "UNKNOWN"
}

/// Start of a sky phase.
struct SkySegment: Codable, Equatable, Sendable {
    let fromUtcMs: Int64
    let phase: SkyPhase
}

/// Sky phases of Appendix G.
enum SkyPhase: String, Codable, Sendable {
    case night
    case astronomicalDawn
    case nauticalDawn
    case civilDawn
    case goldenMorning
    case day
    case goldenEvening
    case civilDusk
    case nauticalDusk
    case astronomicalDusk
}

/// Athan Health summary.
struct SnapshotHealth: Codable, Equatable, Sendable {
    let state: HealthState
    let reasonsCount: Int
}

/// Athan Health states (§8.3).
enum HealthState: String, Codable, Equatable, Sendable {
    case ready = "READY"
    case limited = "LIMITED"
    case notReady = "NOT_READY"
    case unknown = "UNKNOWN"
}
