@testable import AthanKit
import Foundation
import Testing

@Test("REQ-ALM-033 the public host reports the notification path with labels and never ready")
func hostHealthUsesLabels() async {
    let rig = Rig(path: .notification, now: 10000)
    let host = AthanHost(bridge: rig.bridge)

    let health = await host.health()

    #expect(health.platformPath == "iosNotification")
    #expect(health.state != "ready")
    #expect(health.probes.contains { $0.name == "deliveryVerified" && $0.positive == false })
}

@Test("REQ-ALM-040 the public host arms the Test and REQ-ALM-041 drains it as event_log.v1 JSON")
func hostTestAndDrain() async throws {
    let rig = Rig(path: .alarmKit, now: 10000)
    let host = AthanHost(bridge: rig.bridge)

    let armed = await host.startTest(testId: "t9", fireInSeconds: 60, soundId: "athan_makkah_v1")
    let lines = host.drainEvents()

    #expect(armed)
    let first = try #require(lines.first)
    let json = try #require(JSONSerialization.jsonObject(with: Data(first.utf8)) as? [String: Any])
    #expect(json["code"] as? String == "TEST_STARTED")
    #expect(host.drainEvents().isEmpty)
}
