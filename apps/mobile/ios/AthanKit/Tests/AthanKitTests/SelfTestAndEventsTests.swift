@testable import AthanKit
import Foundation
import Testing

@Test("REQ-ALM-040 the Athan Test takes the AlarmKit path when Athans do, firing after the asked delay")
func testTakesAlarmKitPath() async throws {
    let rig = Rig(path: .alarmKit, now: 10000)

    let result = await rig.bridge.startTest(testId: "t9", fireInSeconds: 60, soundId: "athan_makkah_v1")

    let alarms = await rig.alarms.alarms.values
    #expect(result == .armed)
    #expect(alarms.map(\.fireAtUtcMs) == [70000])
    #expect(alarms.map(\.entryId) == ["test_t9"])
    #expect(await rig.notifications.pending.isEmpty)
    let started = try #require(rig.bridge.drainEvents().first)
    #expect(started.code == .testStarted)
    #expect(started.attrs.state == "iosAlarmKit")
    #expect(started.attrs.durationMs == 60000)
}

@Test("REQ-ALM-040 the Athan Test is a time-sensitive notification on the notification path")
func testTakesNotificationPath() async throws {
    let rig = Rig(path: .notification, now: 10000)

    _ = await rig.bridge.startTest(testId: "t9", fireInSeconds: 60, soundId: "athan_makkah_v1")

    let request = try #require(await rig.notifications.pending["test_t9"])
    #expect(request.timeSensitive)
    #expect(request.title == testCopy.testTitle)
    #expect(await rig.notifications.intervals["test_t9"] == 60)
}

@Test("REQ-ALM-041 drained events come back once, oldest first, and survive an interrupted drain")
func eventsDrainOnce() throws {
    let directory = temporaryDirectory()
    let store = EventsStore(directory: directory, clock: FixedClock(now: 5))
    let receipts = Receipts(events: store)
    receipts.presented("610044d967b0417e", .alarmKitAlerting, lateMs: 300)
    receipts.dismissed("610044d967b0417e", .userStop)
    // A drain that moved the file aside and stopped before reading it.
    try FileManager.default.moveItem(
        at: directory.appendingPathComponent(EventsStore.eventsFile),
        to: directory.appendingPathComponent(EventsStore.eventsFile + ".draining"),
    )
    receipts.presented("91fbfdf04e20d17f", .notificationPosted)

    let drained = store.drain()

    #expect(drained.map(\.code) == [.alarmPresented, .alarmDismissed, .alarmPresented])
    #expect(drained.map(\.attrs.reason) == ["alarmkit_alerting", "user_stop", "notification_posted"])
    #expect(drained.first?.attrs.durationMs == 300)
    #expect(store.drain().isEmpty)
}

@Test("REQ-ALM-041 receipt stages match the S19 labels shared with Dart and Android")
func receiptLabelsMatchSpike() throws {
    let dart = try String(
        contentsOf: repositoryRoot()
            .appendingPathComponent("apps/mobile/lib/features/delivery_spike/domain/spike_protocol.dart"),
        encoding: .utf8,
    )
    for stage in ReceiptStage.allCases where stage != .userOpen {
        #expect(dart.contains("'\(stage.rawValue)'"), "\(stage.rawValue)")
    }
}

@Test("REQ-DOM-040 the native copy has the same keys in Arabic and English")
func nativeCopyInBothLocales() throws {
    let english = try #require(NativeCopy.bundled(.en))
    let arabic = try #require(NativeCopy.bundled(.ar))

    #expect(english != arabic)
    #expect([english.testTitle, english.testBody, english.stop, arabic.testTitle, arabic.testBody, arabic.stop]
        .allSatisfy { !$0.isEmpty })
}
