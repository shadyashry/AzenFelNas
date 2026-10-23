#if canImport(AlarmKit) && os(iOS)
    import ActivityKit
    import AlarmKit
    import AppIntents
    import Foundation
    import SwiftUI

    /// Athan alarms carry nothing beyond their id.
    @available(iOS 26.0, *)
    struct AthanAlarmMetadata: AlarmMetadata {}

    /// `AlarmKitPort` over `AlarmManager` (REQ-ALM-030): `Alarm.Schedule.fixed(Date)` from the absolute instant, the
    /// clip from `Library/Sounds/`, a Stop intent that writes the receipt. Written against the iOS 26 SDK as
    /// documented and as the S19 spike uses it; not compiled in the Linux session that wrote it.
    @available(iOS 26.0, *)
    struct AlarmKitAdapter: AlarmKitPort {
        let stopTitle: String

        func scheduledIds() async -> Set<UUID> {
            Set(((try? AlarmManager.shared.alarms) ?? []).map(\.id))
        }

        func schedule(_ alarm: AlarmRequest) async -> ArmResult {
            let stop = AlarmButton(
                text: LocalizedStringResource(String.LocalizationValue(stopTitle)),
                textColor: .white,
                systemImageName: "stop.circle",
            )
            let alert = AlarmPresentation.Alert(
                title: LocalizedStringResource(String.LocalizationValue(alarm.title)),
                stopButton: stop,
            )
            let attributes = AlarmAttributes<AthanAlarmMetadata>(
                presentation: AlarmPresentation(alert: alert),
                metadata: AthanAlarmMetadata(),
                tintColor: .green,
            )
            let sound: AlertConfiguration.AlertSound = switch alarm.sound {
            case let .clip(fileName): .named(fileName)
            case .systemDefault: .default
            }
            let configuration = AlarmManager.AlarmConfiguration<AthanAlarmMetadata>(
                schedule: .fixed(Date(timeIntervalSince1970: TimeInterval(alarm.fireAtUtcMs) / 1000)),
                attributes: attributes,
                stopIntent: StopAthanAlarmIntent(alarmID: alarm.id.uuidString),
                secondaryIntent: nil,
                sound: sound,
            )
            do {
                _ = try await AlarmManager.shared.schedule(id: alarm.id, configuration: configuration)
                return .armed
            } catch {
                return .refused(reason: String(describing: type(of: error)))
            }
        }

        func cancel(id: UUID) async {
            try? AlarmManager.shared.cancel(id: id)
        }

        /// Records `alarmkit_alerting` for each plan alarm seen alerting while the app is alive.
        static func observe(_ receipts: Receipts) async {
            var seen = Set<UUID>()
            for await alarms in AlarmManager.shared.alarmUpdates {
                for alarm in alarms where alarm.state == .alerting && seen.insert(alarm.id).inserted {
                    receipts.presented(PlanIds.entryId(ofAlarm: alarm.id) ?? alarm.id.uuidString, .alarmKitAlerting)
                }
            }
        }
    }

    /// Runs when the user presses Stop, even if the app is not running: the `user_stop` receipt.
    @available(iOS 26.0, *)
    struct StopAthanAlarmIntent: LiveActivityIntent {
        static let title: LocalizedStringResource = "Stop Athan"
        static let isDiscoverable = false

        @Parameter(title: "Alarm")
        var alarmID: String

        init(alarmID: String) {
            self.alarmID = alarmID
        }

        init() {
            alarmID = ""
        }

        func perform() async throws -> some IntentResult {
            if let id = UUID(uuidString: alarmID), let directory = PlanDirectory.appGroup() {
                Receipts(events: EventsStore(directory: directory, clock: SystemClock()))
                    .dismissed(PlanIds.entryId(ofAlarm: id) ?? alarmID, .userStop)
            }
            return .result()
        }
    }
#endif
