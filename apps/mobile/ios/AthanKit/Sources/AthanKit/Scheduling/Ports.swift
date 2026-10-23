import Foundation

/// Wall-clock UTC epoch milliseconds.
protocol UtcClock: Sendable {
    func nowUtcMs() -> Int64
}

/// The device clock.
struct SystemClock: UtcClock {
    func nowUtcMs() -> Int64 {
        Int64((Date().timeIntervalSince1970 * 1000).rounded())
    }
}

/// Result of handing one request to the platform.
enum ArmResult: Equatable, Sendable {
    /// The platform accepted it.
    case armed
    /// The platform refused it; `reason` is an error type name, never content (REQ-PRIV-001).
    case refused(reason: String)
}

/// The sound of an alert (REQ-ALM-034).
enum AlertSound: Equatable, Sendable {
    /// A ≤ 29 s clip in `Library/Sounds/`, by file name.
    case clip(fileName: String)
    /// The system's default alert sound.
    case systemDefault
}

/// One local notification. It fires at the absolute instant `fireAtUtcMs`; adapters turn it into a time-interval
/// trigger from now (`TriggerInterval`), never into `DateComponents` (REQ-ALM-031).
struct NotificationRequest: Equatable, Sendable {
    let id: String
    let fireAtUtcMs: Int64
    let title: String
    let body: String
    let sound: AlertSound
    /// `UNNotificationInterruptionLevel.timeSensitive` instead of `.active`.
    let timeSensitive: Bool
}

/// The pending local notifications of the app (`UNUserNotificationCenter`).
///
/// Contract: `add` replaces a pending request with the same id; `remove` ignores unknown ids; `pendingIds` lists
/// every pending request, including ones this module did not add.
protocol NotificationPort: Sendable {
    func pendingIds() async -> [String]
    func add(_ request: NotificationRequest, nowUtcMs: Int64) async -> ArmResult
    func remove(ids: [String]) async
}

/// One AlarmKit alarm with a fixed date (REQ-ALM-030).
struct AlarmRequest: Equatable, Sendable {
    let id: UUID
    let entryId: String
    let fireAtUtcMs: Int64
    let title: String
    let sound: AlertSound
}

/// The scheduled AlarmKit alarms of the app (`AlarmManager`, iOS 26+). Below iOS 26 the adapter has none.
///
/// Contract: `schedule` of an id that is already scheduled is refused, so callers diff against `scheduledIds`;
/// `cancel` ignores unknown ids.
protocol AlarmKitPort: Sendable {
    func scheduledIds() async -> Set<UUID>
    func schedule(_ alarm: AlarmRequest) async -> ArmResult
    func cancel(id: UUID) async
}

/// Which path Athan entries take now (ADR-013).
enum DeliveryPath: Equatable, Sendable, CaseIterable {
    /// iOS 26+ with AlarmKit authorised: Athan entries are AlarmKit alarms, the others notifications.
    case alarmKit
    /// iOS 18–25, or AlarmKit not authorised: every entry is a local notification.
    case notification

    /// `AthanHealthReport.platformPath` (§7.8).
    var label: String {
        switch self {
        case .alarmKit: "iosAlarmKit"
        case .notification: "iosNotification"
        }
    }
}

/// Decides the delivery path from the OS version and the AlarmKit authorisation.
protocol DeliveryPathGate: Sendable {
    func current() async -> DeliveryPath
}

/// The interval of a time-interval trigger for an absolute instant (REQ-ALM-031).
enum TriggerInterval {
    /// Seconds from `nowUtcMs` to `fireAtUtcMs`, or nil when the instant is not in the future
    /// (`UNTimeIntervalNotificationTrigger` needs a positive interval).
    static func seconds(fireAtUtcMs: Int64, nowUtcMs: Int64) -> TimeInterval? {
        fireAtUtcMs > nowUtcMs ? TimeInterval(fireAtUtcMs - nowUtcMs) / 1000 : nil
    }
}
