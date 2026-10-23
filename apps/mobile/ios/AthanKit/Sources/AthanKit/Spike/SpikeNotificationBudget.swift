#if canImport(UserNotifications)
import Foundation
import UserNotifications

/// Notification side of the S19 spike (ADR-013, REQ-ALM-031/032): asks for more than 64 requests with
/// time-interval triggers computed from absolute instants, records how many iOS kept, then removes them.
enum SpikeNotificationBudget {
    static let prefix = "spike_s19_budget_"

    static func probe(requested: Int) async throws {
        guard let log = SpikeEventLog.shared() else { return }
        let center = UNUserNotificationCenter.current()
        guard try await center.requestAuthorization(options: [.alert, .sound]) else { return }
        let start = Date()
        let ids = (0..<requested).map { "\(prefix)\($0)" }
        for (index, id) in ids.enumerated() {
            let content = UNMutableNotificationContent()
            content.title = "S19 budget \(index)"
            // One per hour from tomorrow: an absolute instant turned into an interval, never DateComponents.
            let fire = start.addingTimeInterval(TimeInterval(86_400 + 3600 * index))
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: fire.timeIntervalSinceNow, repeats: false)
            try await center.add(UNNotificationRequest(identifier: id, content: content, trigger: trigger))
        }
        let pending = await center.pendingNotificationRequests().filter { $0.identifier.hasPrefix(prefix) }
        log.append(.testResult, SpikeEventLog.attrs(reason: SpikeLabels.pendingBudget, count: pending.count))
        center.removePendingNotificationRequests(withIdentifiers: ids)
    }
}
#endif
