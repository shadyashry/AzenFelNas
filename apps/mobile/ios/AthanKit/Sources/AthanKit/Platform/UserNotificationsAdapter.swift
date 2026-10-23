#if canImport(UserNotifications)
    import Foundation
    import UserNotifications

    /// `NotificationPort` over `UNUserNotificationCenter`. The trigger is a `UNTimeIntervalNotificationTrigger`
    /// computed from the absolute instant, never a calendar trigger (REQ-ALM-031). Written against the iOS 26 SDK
    /// headers; compiled only on macOS (`ci-ios`).
    struct UserNotificationsAdapter: NotificationPort {
        func pendingIds() async -> [String] {
            await UNUserNotificationCenter.current().pendingNotificationRequests().map(\.identifier)
        }

        func add(_ request: NotificationRequest, nowUtcMs: Int64) async -> ArmResult {
            guard let seconds = TriggerInterval.seconds(fireAtUtcMs: request.fireAtUtcMs, nowUtcMs: nowUtcMs) else {
                return .refused(reason: "notInFuture")
            }
            let content = UNMutableNotificationContent()
            content.title = request.title
            content.body = request.body
            content.sound = switch request.sound {
            case let .clip(fileName): UNNotificationSound(named: UNNotificationSoundName(fileName))
            case .systemDefault: .default
            }
            content.interruptionLevel = request.timeSensitive ? .timeSensitive : .active
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: seconds, repeats: false)
            do {
                try await UNUserNotificationCenter.current()
                    .add(UNNotificationRequest(identifier: request.id, content: content, trigger: trigger))
                return .armed
            } catch {
                return .refused(reason: String(describing: type(of: error)))
            }
        }

        func remove(ids: [String]) async {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ids)
        }
    }

    /// Notification receipts while the app runs (REQ-ALM-041): a presentation in the foreground and the user
    /// opening one. Runner installs it as the `UNUserNotificationCenter` delegate (owed with the Runner link, D82).
    final class NotificationReceipts: NSObject, UNUserNotificationCenterDelegate, Sendable {
        private let receipts: Receipts

        init(receipts: Receipts) {
            self.receipts = receipts
        }

        func userNotificationCenter(
            _: UNUserNotificationCenter,
            willPresent notification: UNNotification,
        ) async -> UNNotificationPresentationOptions {
            receipts.presented(notification.request.identifier, .notificationPosted)
            return [.banner, .sound, .list]
        }

        func userNotificationCenter(_: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
            receipts.dismissed(response.notification.request.identifier, .userOpen)
        }
    }
#endif
