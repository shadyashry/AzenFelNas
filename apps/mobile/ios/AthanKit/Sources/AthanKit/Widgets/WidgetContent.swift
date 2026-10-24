import Foundation

/// The events a widget lists; the wire names of `snapshot.v1`.
public enum WidgetEvent: String, Equatable, Sendable {
    case imsak = "IMSAK"
    case fajr = "FAJR"
    case sunrise = "SUNRISE"
    case dhuhr = "DHUHR"
    case asr = "ASR"
    case maghrib = "MAGHRIB"
    case isha = "ISHA"
}

/// One displayed time on the widget; `passed` once its instant is not after the entry's.
public struct WidgetRow: Equatable, Sendable {
    public let event: WidgetEvent
    public let displayedUtcMs: Int64
    public let displayLocal: String
    public let passed: Bool
}

/// What a prayer-times widget shows at an instant (DESIGN.md §7.7, §15 D88), selected from the persisted
/// `Snapshot`; the widget never recalculates (REQ-WID-001).
public enum WidgetContent: Equatable, Sendable {
    /// The app has not written a snapshot yet: the widget asks the user to open the app.
    case noSnapshot
    /// No prayer of the snapshot lies ahead: the widget asks the user to open the app.
    case expired(generatedAtUtcMs: Int64)
    /// The next prayer and every displayed time of its prayer `day`.
    case showing(day: String, next: WidgetRow, rows: [WidgetRow])
}

/// One WidgetKit timeline entry: the content from `atUtcMs` until the next entry.
public struct WidgetEntry: Equatable, Sendable {
    public let atUtcMs: Int64
    public let content: WidgetContent
}
