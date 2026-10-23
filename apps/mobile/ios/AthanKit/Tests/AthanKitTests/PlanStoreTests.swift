@testable import AthanKit
import Foundation
import Testing

private func temporaryDirectory() -> URL {
    FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
}

private func builtPlan(generation: Int) throws -> Data {
    let text = try String(contentsOf: fixtureURL("schedule_plan", "valid", "built_ios.json"), encoding: .utf8)
    let replaced = text.replacingOccurrences(of: "\"generation\": 1,", with: "\"generation\": \(generation),")
    return Data(replaced.utf8)
}

@Test("REQ-ALM-035 a written plan reads back and no temporary file is left")
func planWritesAtomically() throws {
    let directory = temporaryDirectory()
    let store = PlanStore(directory: directory)
    let plan = try builtPlan(generation: 1)
    #expect(store.write(planJSON: plan) == .written(generation: 1))
    #expect(try store.read() == (JSONDecoder().decode(SchedulePlan.self, from: plan)))
    let names = try FileManager.default.contentsOfDirectory(atPath: directory.path)
    #expect(names == [PlanStore.planFile])
}

@Test("REQ-ALM-002 an older generation never replaces the persisted plan")
func olderGenerationIsStale() throws {
    let store = PlanStore(directory: temporaryDirectory())
    _ = try store.write(planJSON: builtPlan(generation: 5))
    #expect(try store.write(planJSON: builtPlan(generation: 4)) == .stale(current: 5, offered: 4))
    #expect(store.read()?.generation == 5)
    #expect(try store.write(planJSON: builtPlan(generation: 5)) == .written(generation: 5))
}

@Test("REQ-ALM-002 a malformed document is rejected and a missing plan reads as nil")
func malformedPlanIsRejected() {
    let store = PlanStore(directory: temporaryDirectory())
    #expect(store.read() == nil)
    let malformed = Data("{\"generation\":9}".utf8)
    #expect(store.write(planJSON: malformed) == .rejected(reason: "not a schedule_plan.v1 document"))
    #expect(store.read() == nil)
}

@Test("REQ-ALM-035 a snapshot is validated, written atomically and read back")
func snapshotRoundTrips() throws {
    let store = SnapshotStore(directory: temporaryDirectory())
    let snapshot = try Data(contentsOf: fixtureURL("snapshot", "valid", "built.json"))
    #expect(store.write(snapshotJSON: snapshot) == .written)
    #expect(try store.read() == (JSONDecoder().decode(Snapshot.self, from: snapshot)))
    #expect(store.write(snapshotJSON: Data("[]".utf8)) == .rejected(reason: "not a snapshot.v1 document"))
}
