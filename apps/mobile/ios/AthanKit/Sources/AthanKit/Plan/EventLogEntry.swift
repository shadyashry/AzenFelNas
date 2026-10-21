/// Wire form of `event_log.v1` (DESIGN.md Appendix J): one line of `events.jsonl`, drained by Dart (REQ-ALM-041).
/// `EventAttrs` is a closed allow-list, so no coordinate can be logged (REQ-PRIV-001).
struct EventLogEntry: Codable, Equatable, Sendable {
    let utcMs: Int64
    let level: EventLevel
    let code: EventCode
    let attrs: EventAttrs
}

/// Severity of an event-log entry.
enum EventLevel: String, Codable, Sendable {
    case debug = "DEBUG"
    case info = "INFO"
    case warn = "WARN"
    case error = "ERROR"
}

/// Allowed event attributes; absent ones are nil.
struct EventAttrs: Codable, Equatable, Sendable {
    let code: FailureCode?
    let generation: Int?
    let entryId: String?
    let packageType: String?
    let version: String?
    let state: String?
    let reason: String?
    let durationMs: Int64?
    let count: Int?
    let zoneId: String?
    let countryCode: String?
}
