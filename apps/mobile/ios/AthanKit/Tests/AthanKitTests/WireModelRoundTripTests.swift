@testable import AthanKit
import Foundation
import Testing

@Test("schedule plan fixtures round-trip unchanged")
func schedulePlanFixturesRoundTrip() throws {
    try expectValidFixturesRoundTrip(SchedulePlan.self, schema: "schedule_plan")
}

@Test("snapshot fixtures round-trip unchanged")
func snapshotFixturesRoundTrip() throws {
    try expectValidFixturesRoundTrip(Snapshot.self, schema: "snapshot")
}

@Test("event log fixtures round-trip unchanged")
func eventLogFixturesRoundTrip() throws {
    try expectValidFixturesRoundTrip(EventLogEntry.self, schema: "event_log")
}

@Test("an unknown event code is rejected (REQ-ERR-002)")
func unknownEventCodeIsRejected() throws {
    let data = try Data(contentsOf: fixtureURL("event_log", "invalid", "unknown_event_code.json"))

    #expect(throws: DecodingError.self) {
        try JSONDecoder().decode(EventLogEntry.self, from: data)
    }
}

@Test("a horizon warning decodes without an event")
func horizonWarningHasNoEvent() throws {
    let data = try Data(contentsOf: fixtureURL("schedule_plan", "valid", "full.json"))

    let plan = try JSONDecoder().decode(SchedulePlan.self, from: data)

    let warnings = plan.entries.filter { $0.kind == .horizonWarning }
    #expect(warnings.count == 1)
    #expect(warnings.allSatisfy { $0.event == nil })
}
