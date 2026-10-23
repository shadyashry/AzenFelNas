@testable import AthanKit
import Testing

private let now: Int64 = 1_792_659_600_000

/// The probes `DarwinProbes` reports, on both paths.
private let platformNames: [ProbeName] = [
    .alarmKitAuthorization, .notificationAuthorization, .notificationSound, .silentSwitch, .focusStatus,
    .backgroundRefreshStatus, .criticalAlerts,
]

private func allTrue(_ names: [ProbeName]) -> [ProbeResult] {
    names.map { ProbeResult($0, true) }
}

/// Every assignment of {true, false, nil} to `names`.
private func assignments(_ names: [ProbeName]) -> [[ProbeResult]] {
    names.reduce([[]]) { partial, name in
        partial.flatMap { prefix in [true, false, nil].map { prefix + [ProbeResult(name, $0)] } }
    }
}

@Test("REQ-ALM-033 the notification path is never READY, for every probe outcome")
func notificationPathNeverReady() {
    let evaluate = EvaluateHealth()
    let names = platformNames + [.soundAssetPresence, .planPresent, .planHorizon]
    var evaluated = 0
    for probes in assignments(names) + [allTrue(names + [.deliveryVerified])] {
        let report = evaluate(probes, path: .notification, evaluatedAtUtcMs: now)
        #expect(report.state != .ready)
        #expect(report.platformPath == "iosNotification")
        evaluated += 1
    }
    #expect(evaluated == 59050)
}

@Test("REQ-ALM-033 with every probe positive the notification path is LIMITED by unverifiable delivery")
func notificationPathIsLimitedUnverifiable() {
    let report = EvaluateHealth()(
        allTrue(platformNames + [.soundAssetPresence, .planPresent, .planHorizon]),
        path: .notification,
        evaluatedAtUtcMs: now,
    )

    #expect(report.state == .limited)
    #expect(report.reasons == [.unverifiableDelivery])
}

@Test("REQ-ALM-003 AlarmKit is not READY until the S19 device run proves delivery (ADR-013)")
func alarmKitWaitsForDeviceEvidence() {
    let report = EvaluateHealth()(
        allTrue(platformNames + [.soundAssetPresence, .planPresent, .planHorizon]),
        path: .alarmKit,
        evaluatedAtUtcMs: now,
    )

    #expect(AlarmKitEvidence.deliveryProven == false)
    #expect(report.state == .limited)
    #expect(report.reasons == [.unverifiableDelivery])
}

@Test("REQ-ALM-003 the silent switch and Focus cannot be read, so their probes are unknown and gate notifications")
func silentSwitchIsUnknown() {
    for name in [ProbeName.silentSwitch, .focusStatus] {
        #expect(name.severity(on: .notification) == .degrading)
        #expect(name.severity(on: .alarmKit) == .informational)
    }
    // With delivery verified (the AlarmKit GO case), an unknown gating probe makes the state UNKNOWN.
    let probes = allTrue([.alarmKitAuthorization, .notificationAuthorization, .soundAssetPresence, .planPresent])
        + [ProbeResult(.planHorizon, nil)]
    let state = EvaluateHealth()(probes, path: .alarmKit, evaluatedAtUtcMs: now).state
    #expect(state == (AlarmKitEvidence.deliveryProven ? .unknown : .limited))
}

@Test("REQ-ALM-003 a blocking false beats a degrading false, which beats an unknown")
func healthOrdering() {
    let evaluate = EvaluateHealth()
    let base = allTrue([.alarmKitAuthorization, .notificationSound, .soundAssetPresence, .planPresent, .planHorizon])
    let blocked = evaluate(
        base + [ProbeResult(.notificationAuthorization, false), ProbeResult(.silentSwitch, nil)],
        path: .notification,
        evaluatedAtUtcMs: now,
    )
    let denied = evaluate(
        base.filter { $0.name != .alarmKitAuthorization } + [ProbeResult(.alarmKitAuthorization, false)],
        path: .alarmKit,
        evaluatedAtUtcMs: now,
    )

    #expect(blocked.state == .notReady)
    #expect(blocked.reasons == [.needsNotificationPermission, .unverifiableDelivery])
    #expect(denied.state == .notReady)
    #expect(denied.reasons.first == .needsAlarmKitAuthorization)
}

@Test("REQ-ALM-003 on the AlarmKit path missing notification permission degrades but does not block")
func notificationPermissionDegradesOnAlarmKit() {
    #expect(ProbeName.notificationAuthorization.severity(on: .alarmKit) == .degrading)
    #expect(ProbeName.notificationAuthorization.severity(on: .notification) == .blocking)
}

@Test("REQ-ALM-003 plan probes: no plan blocks, a horizon within 24 h degrades, a missing clip blocks")
func planProbes() throws {
    let plan = try iosPlan()
    let probes = PlanProbes(sounds: FakeSounds(installed: []))

    let none = probes.probes(of: nil, nowUtcMs: now)
    let late = probes.probes(of: plan, nowUtcMs: plan.horizonEndUtcMs - PlanProbes.horizonWarningLeadMs)
    let installed = PlanProbes(sounds: FakeSounds(installed: ["athan_makkah_v1"])).probes(of: plan, nowUtcMs: now)

    #expect(none.first { $0.name == .planPresent }?.positive == false)
    #expect(late.first { $0.name == .planHorizon }?.positive == false)
    #expect(late.first { $0.name == .soundAssetPresence }?.positive == false)
    #expect(installed.allSatisfy { $0.positive == true })
}

@Test("REQ-ALM-033 the bridge's report on the notification path is never READY and logs HEALTH_EVALUATED")
func bridgeHealthOnNotificationPath() async {
    let rig = Rig(
        path: .notification,
        now: now,
        probes: allTrue([.notificationAuthorization, .notificationSound])
            + [ProbeResult(.silentSwitch, nil), ProbeResult(.focusStatus, nil)],
    )

    let report = await rig.bridge.health()

    #expect(report.state == .notReady)
    #expect(report.reasons.contains(.stalePlan))
    #expect(report.probes.first { $0.name == .silentSwitch }?.positive == nil)
    #expect(rig.bridge.drainEvents().map(\.code) == [.healthEvaluated])
}
