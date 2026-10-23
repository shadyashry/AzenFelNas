import Foundation

/// Delivery stage written to `attrs.reason` of a receipt; labels match the S19 spike and Android (ADR-025, D79,
/// D81). `userOpen` is iOS-only (D82).
enum ReceiptStage: String, Sendable, CaseIterable {
    /// AlarmKit reported the alarm alerting while the app was alive.
    case alarmKitAlerting = "alarmkit_alerting"
    /// iOS presented a notification while the app was in the foreground.
    case notificationPosted = "notification_posted"
    /// The user pressed Stop on an AlarmKit alarm.
    case userStop = "user_stop"
    /// The user opened a notification.
    case userOpen = "user_open"
}

/// Alarm receipts in `events.jsonl` (REQ-ALM-041): `ALARM_PRESENTED` lines become `ReceiptState.presented` and
/// `ALARM_DISMISSED` lines `dismissed` when Dart drains them. Only ids, stages and durations are written
/// (REQ-PRIV-001). The notification path has no receipt while the app is not running (ADR-013).
struct Receipts: Sendable {
    let events: EventsStore

    /// `entryId` reached `stage`; `lateMs` is how long after its fire instant, when known.
    func presented(_ entryId: String, _ stage: ReceiptStage, lateMs: Int64? = nil) {
        events.append(.alarmPresented, .of(entryId: entryId, reason: stage.rawValue, durationMs: lateMs))
    }

    /// `entryId` ended at `stage`, `afterMs` after its fire instant when known.
    func dismissed(_ entryId: String, _ stage: ReceiptStage, afterMs: Int64? = nil) {
        events.append(.alarmDismissed, .of(entryId: entryId, reason: stage.rawValue, durationMs: afterMs))
    }
}

/// `AlarmKitPort` below iOS 26 and on hosts without AlarmKit: no alarms, every schedule refused.
struct UnavailableAlarmKit: AlarmKitPort {
    func scheduledIds() async -> Set<UUID> { [] }
    func schedule(_: AlarmRequest) async -> ArmResult { .refused(reason: "alarmKitUnavailable") }
    func cancel(id _: UUID) async {}
}
