import Foundation

/// The bridge's `startTest(testId, fireInSeconds, soundId)` (DESIGN.md §7.8, §8.3): schedules the Athan Test
/// through the path a real Athan takes now, an AlarmKit alarm or a notification (REQ-ALM-040). Its ids are not
/// plan ids, so reconciliation never removes it; it uses the slot `DeliveryWindow.testSlots` holds back.
/// `heardByUser` is Dart's to record from the user's answer.
struct StartAthanTest: Sendable {
    let alarms: any AlarmKitPort
    let notifications: any NotificationPort
    let gate: any DeliveryPathGate
    let sounds: any SoundCatalog
    let copy: NativeCopy
    let clock: any UtcClock
    let events: EventsStore
    let newId: @Sendable () -> UUID

    func callAsFunction(testId: String, fireInSeconds: Int, soundId: String) async -> ArmResult {
        let now = clock.nowUtcMs()
        let fireAt = now + Int64(max(1, fireInSeconds)) * 1000
        let entryId = Self.entryId(of: testId)
        let path = await gate.current()
        let result: ArmResult = switch path {
        case .alarmKit:
            await alarms.schedule(
                AlarmRequest(
                    id: newId(), entryId: entryId, fireAtUtcMs: fireAt, title: copy.testTitle,
                    sound: sounds.sound(for: soundId)
                )
            )
        case .notification:
            await notifications.add(
                NotificationRequest(
                    id: entryId, fireAtUtcMs: fireAt, title: copy.testTitle, body: copy.testBody,
                    sound: sounds.sound(for: soundId), timeSensitive: true
                ),
                nowUtcMs: now
            )
        }
        events.append(
            .testStarted,
            .of(entryId: entryId, state: path.label, durationMs: fireAt - now),
            level: result == .armed ? .info : .error
        )
        return result
    }

    /// The Test's entry and notification id.
    static func entryId(of testId: String) -> String {
        "test_\(testId)"
    }
}
