/// Wire form of `schedule_plan.v1` (DESIGN.md §7.7, Appendix B): the only input of native scheduling (ADR-002).
/// Reading, reconciliation and the N / N−1 schema gate arrive in S22.
struct SchedulePlan: Codable, Equatable, Sendable {
    let schemaVersion: Int
    let generation: Int
    let contextId: String
    let zoneId: String
    let tzdbVersion: String
    let generatedAtUtcMs: Int64
    let horizonEndUtcMs: Int64
    let entries: [SchedulePlanEntry]
    let policy: SchedulePlanPolicy
}

/// One scheduled alarm or notification; `event` is nil exactly for `.horizonWarning`.
struct SchedulePlanEntry: Codable, Equatable, Sendable {
    let id: String
    let day: String
    let event: PrayerEvent?
    let kind: EntryKind
    /// Absolute fire instant = displayedUtcMs (REQ-ALM-001).
    let fireAtUtcMs: Int64
    let displayLocal: String
    let title: LocalizedText
    let body: LocalizedText
    let soundId: String
    let priority: Int
}

/// Delivery policy of a plan.
struct SchedulePlanPolicy: Codable, Equatable, Sendable {
    let locale: PlanLocale
    let respectDnd: Bool
    let vibrate: Bool
    let fullAthanAndroid: Bool
    /// At most 29 s (REQ-ALM-034).
    let iosClipSeconds: Int
    /// One of 0, 5, 10, 15, 30 (REQ-ALM-042).
    let preReminderMinutes: Int
    /// Always 5 (REQ-ALM-042).
    let snoozeMinutes: Int
}

/// Text in both shipped locales; native renders `policy.locale`, falling back to `en`.
struct LocalizedText: Codable, Equatable, Sendable {
    let ar: String
    let en: String
}

/// Prayer event wire names.
enum PrayerEvent: String, Codable, Sendable {
    case imsak = "IMSAK"
    case fajr = "FAJR"
    case sunrise = "SUNRISE"
    case dhuhr = "DHUHR"
    case asr = "ASR"
    case maghrib = "MAGHRIB"
    case isha = "ISHA"
}

/// Kind of a plan entry.
enum EntryKind: String, Codable, Sendable {
    case athan = "ATHAN"
    case preReminder = "PRE_REMINDER"
    case imsak = "IMSAK"
    case horizonWarning = "HORIZON_WARNING"
}

/// Locale of pre-rendered text.
enum PlanLocale: String, Codable, Sendable {
    case ar
    case en
}
