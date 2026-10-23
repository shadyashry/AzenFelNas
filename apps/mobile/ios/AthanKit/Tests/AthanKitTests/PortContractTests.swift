@testable import AthanKit
import Foundation
import Testing

/// The `NotificationPort` contract (§17.1 L): every implementation runs it. The UserNotifications adapter runs it
/// on a device (owed, D82); the fake runs it here.
func notificationPortContract(_ port: some NotificationPort) async {
    let request = NotificationRequest(
        id: "610044d967b0417e", fireAtUtcMs: 2000, title: "a", body: "b", sound: .systemDefault, timeSensitive: true,
    )
    #expect(await port.add(request, nowUtcMs: 1000) == .armed)
    #expect(await port.add(request, nowUtcMs: 1000) == .armed)
    #expect(await port.pendingIds() == [request.id])
    #expect(await port.add(request, nowUtcMs: 2000) != .armed)
    await port.remove(ids: ["unknown", request.id])
    #expect(await port.pendingIds().isEmpty)
}

/// The `AlarmKitPort` contract: a scheduled id is listed, scheduling it again is refused, cancel is idempotent.
func alarmKitPortContract(_ port: some AlarmKitPort) async throws {
    let id = try #require(PlanIds.alarmId(of: "610044d967b0417e"))
    let alarm = AlarmRequest(id: id, entryId: "610044d967b0417e", fireAtUtcMs: 2000, title: "a", sound: .systemDefault)
    #expect(await port.schedule(alarm) == .armed)
    #expect(await port.scheduledIds() == [id])
    #expect(await port.schedule(alarm) != .armed)
    await port.cancel(id: id)
    await port.cancel(id: id)
    #expect(await port.scheduledIds().isEmpty)
}

@Test("REQ-ALM-031 the fake notification port honours the NotificationPort contract")
func fakeNotificationsHonourContract() async {
    await notificationPortContract(FakeNotifications())
}

@Test("REQ-ALM-030 the fake AlarmKit port honours the AlarmKitPort contract")
func fakeAlarmKitHonoursContract() async throws {
    try await alarmKitPortContract(FakeAlarmKit())
}

@Test("REQ-ALM-030 below iOS 26 the AlarmKit port holds nothing and refuses every alarm")
func unavailableAlarmKitRefuses() async throws {
    let port = UnavailableAlarmKit()
    let id = try #require(PlanIds.alarmId(of: "610044d967b0417e"))

    let result = await port.schedule(
        AlarmRequest(id: id, entryId: "610044d967b0417e", fireAtUtcMs: 1, title: "", sound: .systemDefault),
    )

    #expect(result != .armed)
    #expect(await port.scheduledIds().isEmpty)
}
