#if canImport(AlarmKit) && os(iOS)
import ActivityKit
import AlarmKit
import AppIntents
import Foundation
import SwiftUI

/// Empty metadata: the spike's alarms carry nothing beyond their id.
@available(iOS 26.0, *)
struct SpikeAlarmMetadata: AlarmMetadata {}

/// AlarmKit side of the S19 spike (ADR-013, REQ-ALM-030): `.fixed(Date)` alarms with a bundled sound, alerting
/// receipts while the app runs, and a Stop intent receipt when it does not. Written against the iOS 26 SDK
/// headers as documented; not compiled in the Linux session that wrote it.
@available(iOS 26.0, *)
enum SpikeAlarmKit {
    /// Schedules [count] alarms [seconds] from now, [spacing] apart, playing [sound] from the main bundle or
    /// `Library/Sounds` (a long clip for the long-audio check; ≤ 29 s is not assumed here).
    static func schedule(scenario: String, seconds: Int, count: Int, spacing: Int, sound: String?) async throws {
        guard let log = SpikeEventLog.shared() else { return }
        let manager = AlarmManager.shared
        guard try await manager.requestAuthorization() == .authorized else { return }
        let now = Date()
        for index in 0..<count {
            let id = UUID()
            let fire = now.addingTimeInterval(TimeInterval(seconds + index * spacing))
            let stop = AlarmButton(text: "Stop", textColor: .white, systemImageName: "stop.circle")
            let alert = AlarmPresentation.Alert(title: "S19 spike", stopButton: stop)
            let attributes = AlarmAttributes<SpikeAlarmMetadata>(
                presentation: AlarmPresentation(alert: alert),
                metadata: SpikeAlarmMetadata(),
                tintColor: .green
            )
            let configuration = AlarmManager.AlarmConfiguration<SpikeAlarmMetadata>(
                schedule: .fixed(fire),
                attributes: attributes,
                stopIntent: StopSpikeAlarmIntent(alarmID: id.uuidString),
                secondaryIntent: nil,
                sound: sound.map { AlertConfiguration.AlertSound.named($0) } ?? .default
            )
            _ = try await manager.schedule(id: id, configuration: configuration)
            log.append(
                .alarmScheduled,
                SpikeEventLog.attrs(
                    entryId: entryId(of: id),
                    state: scenario,
                    reason: SpikeLabels.iosAlarmKit,
                    durationMs: Int64((fire.timeIntervalSince1970 * 1000).rounded()) - SpikeEventLog.nowMs()
                )
            )
        }
    }

    /// Records `alarmkit_alerting` with its lateness for each alarm seen alerting while the app is alive.
    static func observe() async {
        guard let log = SpikeEventLog.shared() else { return }
        var seen = Set<UUID>()
        for await alarms in AlarmManager.shared.alarmUpdates {
            for alarm in alarms where alarm.state == .alerting && !seen.contains(alarm.id) {
                seen.insert(alarm.id)
                let entryId = entryId(of: alarm.id)
                let trigger = log.triggerMs(of: entryId) ?? SpikeEventLog.nowMs()
                log.append(
                    .alarmPresented,
                    SpikeEventLog.attrs(
                        entryId: entryId,
                        reason: SpikeLabels.alarmKitAlerting,
                        durationMs: max(0, SpikeEventLog.nowMs() - trigger)
                    )
                )
            }
        }
    }

    /// The 16-hex entry id the receipts use: the UUID's first 8 bytes.
    static func entryId(of id: UUID) -> String {
        String(id.uuidString.replacingOccurrences(of: "-", with: "").lowercased().prefix(16))
    }
}

/// Runs when the user presses Stop, even if the app is not running: the delivery receipt (`user_stop`, how long
/// it rang).
@available(iOS 26.0, *)
struct StopSpikeAlarmIntent: LiveActivityIntent {
    static let title: LocalizedStringResource = "Stop S19 spike alarm"
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
        guard let log = SpikeEventLog.shared(), let id = UUID(uuidString: alarmID) else { return .result() }
        let entryId = SpikeAlarmKit.entryId(of: id)
        let trigger = log.triggerMs(of: entryId) ?? SpikeEventLog.nowMs()
        log.append(
            .alarmDismissed,
            SpikeEventLog.attrs(
                entryId: entryId,
                reason: SpikeLabels.userStop,
                durationMs: max(0, SpikeEventLog.nowMs() - trigger)
            )
        )
        return .result()
    }
}
#endif
