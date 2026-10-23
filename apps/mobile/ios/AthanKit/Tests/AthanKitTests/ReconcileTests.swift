@testable import AthanKit
import Foundation
import Testing

private let planStart: Int64 = 1_792_659_600_000

@Test("REQ-ALM-030 on the AlarmKit path every future Athan is a fixed-date alarm at its plan instant")
func alarmKitPathSchedulesAthansAsFixedAlarms() async throws {
    let rig = Rig(path: .alarmKit, now: planStart)
    let plan = try iosPlan()

    let outcome = try await rig.bridge.reconcile(iosPlanJSON())

    let alarms = await rig.alarms.alarms
    let athans = plan.entries.filter { $0.kind == .athan && $0.fireAtUtcMs > planStart }
    #expect(alarms.count == athans.count)
    for entry in athans {
        let alarm = try #require(PlanIds.alarmId(of: entry.id).flatMap { alarms[$0] })
        #expect(alarm.fireAtUtcMs == entry.fireAtUtcMs)
        #expect(alarm.title == entry.title.ar)
    }
    let pending = await rig.notifications.pending
    #expect(pending.values.allSatisfy { request in plan.entries.first { $0.id == request.id }?.kind != .athan })
    #expect(outcome == .applied(generation: 1, armed: alarms.count + pending.count, path: .alarmKit))
}

@Test("REQ-ALM-030 an AlarmKit id carries its entry id in its first 16 hex digits and round-trips")
func alarmIdsRoundTrip() throws {
    let id = try #require(PlanIds.alarmId(of: "610044d967b0417e"))
    #expect(PlanIds.entryId(ofAlarm: id) == "610044d967b0417e")
    #expect(PlanIds.alarmId(of: "test_1") == nil)
    #expect(PlanIds.entryId(ofAlarm: UUID()) == nil)
}

@Test("REQ-ALM-031 a notification trigger is the interval from now to the absolute instant")
func triggerIntervalFromAbsoluteInstant() async throws {
    let now = planStart + 1234
    let rig = Rig(path: .notification, now: now)

    _ = try await rig.bridge.reconcile(iosPlanJSON())

    let pending = await rig.notifications.pending
    let intervals = await rig.notifications.intervals
    #expect(!pending.isEmpty)
    for (id, request) in pending {
        #expect(intervals[id] == TimeInterval(request.fireAtUtcMs - now) / 1000)
    }
    #expect(TriggerInterval.seconds(fireAtUtcMs: now, nowUtcMs: now) == nil)
}

@Test("REQ-ALM-031 no source schedules with DateComponents or a calendar trigger")
func noCalendarTriggers() throws {
    let sources = try repositoryRoot().appendingPathComponent("apps/mobile/ios/AthanKit/Sources")
    let files = try #require(FileManager.default.enumerator(at: sources, includingPropertiesForKeys: nil))
    var scanned = 0
    for case let url as URL in files where url.pathExtension == "swift" {
        let text = try String(contentsOf: url, encoding: .utf8)
        scanned += 1
        #expect(!text.contains("UNCalendarNotificationTrigger"), "\(url.lastPathComponent)")
        #expect(!text.contains("DateComponents("), "\(url.lastPathComponent)")
        #expect(!text.contains(".relative("), "\(url.lastPathComponent)")
    }
    #expect(scanned > 10)
}

@Test("REQ-ALM-032 pending requests never exceed 64 whatever the plan holds, on both paths")
func pendingNeverExceedsBudget() async throws {
    let base = try iosPlan()
    // A plan of 4× the fixture's entries with fresh ids: far over the budget.
    let entries = (0 ..< 4).flatMap { copy in
        base.entries.enumerated().map { index, entry in
            SchedulePlanEntry(
                id: String(format: "%016x", copy * 1000 + index + 1), day: entry.day, event: entry.event,
                kind: entry.kind, fireAtUtcMs: entry.fireAtUtcMs + Int64(copy) * 60000,
                displayLocal: entry.displayLocal, title: entry.title, body: entry.body, soundId: entry.soundId,
                priority: entry.priority,
            )
        }
    }
    let big = SchedulePlan(
        schemaVersion: 1, generation: 2, contextId: base.contextId, zoneId: base.zoneId,
        tzdbVersion: base.tzdbVersion, generatedAtUtcMs: base.generatedAtUtcMs,
        horizonEndUtcMs: base.horizonEndUtcMs, entries: entries, policy: base.policy,
    )
    for path in DeliveryPath.allCases {
        let rig = Rig(path: path, now: planStart)
        _ = try await rig.bridge.reconcile(planJSON(big))
        _ = await rig.bridge.startTest(testId: "t1", fireInSeconds: 60, soundId: "athan_makkah_v1")

        #expect(await rig.notifications.pending.count <= DeliveryWindow.budget)
        #expect(await rig.alarms.alarms.count <= DeliveryWindow.budget)
    }
}

@Test("REQ-ALM-032 the cut keeps the horizon warning and drops the farthest of the lowest priority first")
func budgetDropsByPriorityThenFarthest() throws {
    let plan = try iosPlan()
    let kept = DeliveryWindow.fit(plan.entries)
    let dropped = plan.entries.filter { entry in !kept.contains { $0.id == entry.id } }

    #expect(kept.count == DeliveryWindow.budget - DeliveryWindow.testSlots)
    #expect(kept.contains { $0.kind == .horizonWarning } == plan.entries.contains { $0.kind == .horizonWarning })
    for gone in dropped {
        #expect(kept.allSatisfy { kept in
            kept.kind == .horizonWarning || (kept.priority, kept.fireAtUtcMs) <= (gone.priority, gone.fireAtUtcMs)
        })
    }
}

@Test("REQ-ALM-002 reconciling the same plan twice leaves the same requests and schedules no alarm twice")
func reconcileIsIdempotent() async throws {
    let rig = Rig(path: .alarmKit, now: planStart)
    let json = try iosPlanJSON()

    let first = await rig.bridge.reconcile(json)
    let pendingAfterFirst = await rig.notifications.pending
    let alarmsAfterFirst = await rig.alarms.alarms
    let second = await rig.bridge.reconcile(json)

    #expect(first == second)
    #expect(await rig.notifications.pending == pendingAfterFirst)
    #expect(await rig.alarms.alarms == alarmsAfterFirst)
    #expect(await rig.alarms.schedules == alarmsAfterFirst.count)
}

@Test("REQ-ALM-002 an older generation is stale and changes nothing")
func olderGenerationChangesNothing() async throws {
    let rig = Rig(path: .notification, now: planStart)
    _ = try await rig.bridge.reconcile(iosPlanJSON(generation: 5))
    let before = await rig.notifications.pending

    let outcome = try await rig.bridge.reconcile(iosPlanJSON(generation: 4))

    #expect(outcome == .stale(current: 5, offered: 4))
    #expect(await rig.notifications.pending == before)
}

@Test("REQ-ALM-002 a new plan removes the requests it dropped and never touches Test or spike requests")
func newPlanRemovesDroppedRequestsOnly() async throws {
    let rig = Rig(path: .notification, now: planStart)
    _ = try await rig.bridge.reconcile(iosPlanJSON(generation: 1))
    _ = await rig.bridge.startTest(testId: "t1", fireInSeconds: 60, soundId: "athan_makkah_v1")
    let spike = NotificationRequest(
        id: "spike_s19_budget_0", fireAtUtcMs: planStart + 1, title: "", body: "", sound: .systemDefault,
        timeSensitive: false,
    )
    await rig.notifications.seed(spike)
    let base = try iosPlan()
    let smaller = SchedulePlan(
        schemaVersion: 1, generation: 2, contextId: base.contextId, zoneId: base.zoneId,
        tzdbVersion: base.tzdbVersion, generatedAtUtcMs: base.generatedAtUtcMs,
        horizonEndUtcMs: base.horizonEndUtcMs, entries: Array(base.entries.prefix(3)), policy: base.policy,
    )

    _ = try await rig.bridge.reconcile(planJSON(smaller))

    let ids = await Set(rig.notifications.pending.keys)
    #expect(ids == Set(smaller.entries.map(\.id) + [StartAthanTest.entryId(of: "t1"), spike.id]))
}

@Test("REQ-ALM-002 a refused request is a partial outcome with an ALARM_SCHEDULE_FAILED line")
func refusedRequestIsPartial() async throws {
    let rig = Rig(path: .notification, now: planStart)
    let plan = try iosPlan()
    let refused = try #require(plan.entries.first { $0.fireAtUtcMs > planStart })
    await rig.notifications.refuse([refused.id])

    let outcome = try await rig.bridge.reconcile(iosPlanJSON())

    guard case let .partial(_, _, refusedIds) = outcome else {
        Issue.record("expected partial, got \(outcome)")
        return
    }
    #expect(refusedIds == [refused.id])
    let failed = rig.bridge.drainEvents().filter { $0.attrs.code == .alarmScheduleFailed }
    #expect(failed.map(\.attrs.entryId) == [refused.id])
}

@Test("REQ-ALM-002 a document that is not a plan fails with PLAN_SCHEMA_UNSUPPORTED and arms nothing")
func invalidPlanFails() async {
    let rig = Rig(path: .notification, now: planStart)

    let outcome = await rig.bridge.reconcile("{}")

    #expect(outcome == .failed(code: .planSchemaUnsupported, detail: nil))
    #expect(await rig.notifications.pending.isEmpty)
    #expect(await rig.bridge.rearm(.appActive) == .noPlan)
}

@Test("REQ-ALM-002 cancelGenerationsBelow removes every plan request of an older plan")
func cancelGenerationsBelowRemovesPlanRequests() async throws {
    let rig = Rig(path: .alarmKit, now: planStart)
    _ = try await rig.bridge.reconcile(iosPlanJSON(generation: 3))

    await rig.bridge.cancelGenerationsBelow(3)
    #expect(await !rig.alarms.alarms.isEmpty)
    await rig.bridge.cancelGenerationsBelow(4)

    #expect(await rig.alarms.alarms.isEmpty)
    #expect(await rig.notifications.pending.isEmpty)
}

@Test("REQ-ALM-041 each reconcile appends one PLAN_APPLIED line naming its cause and path")
func reconcileRecordsPlanApplied() async throws {
    let rig = Rig(path: .notification, now: planStart)
    _ = try await rig.bridge.reconcile(iosPlanJSON())
    _ = await rig.bridge.rearm(.timezoneChanged)

    let lines = rig.bridge.drainEvents().filter { $0.code == .planApplied }

    #expect(lines.map(\.attrs.reason) == ["planApplied", "timezoneChanged"])
    #expect(lines.map(\.attrs.state) == ["iosNotification", "iosNotification"])
    #expect(rig.bridge.drainEvents().isEmpty)
}
