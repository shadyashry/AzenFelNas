@testable import AthanKit
import Foundation
import Testing

/// One case of `schemas/vectors/widget_content.v1.json`.
private struct WidgetVector: Decodable {
    struct Row: Decodable {
        let event: String
        let displayLocal: String
        let passed: Bool
    }

    struct Expect: Decodable {
        let kind: String
        let day: String?
        let nextEvent: String?
        let nextUtcMs: Int64?
        let nextLocal: String?
        let refreshAtUtcMs: Int64?
        let rows: [Row]?
    }

    let name: String
    let nowUtcMs: Int64
    let expect: Expect
}

private struct WidgetVectors: Decodable {
    let snapshot: String
    let cases: [WidgetVector]
}

private func vectors() throws -> (WidgetVectors, Snapshot) {
    let root = try repositoryRoot()
    let vectors = try JSONDecoder().decode(
        WidgetVectors.self,
        from: Data(contentsOf: root.appendingPathComponent("schemas/vectors/widget_content.v1.json")),
    )
    let snapshot = try JSONDecoder().decode(
        Snapshot.self,
        from: Data(contentsOf: root.appendingPathComponent("schemas/\(vectors.snapshot)")),
    )
    return (vectors, snapshot)
}

@Test("REQ-WID-002 widget content follows the shared vectors across midnight")
func widgetContentVectors() throws {
    let (vectors, snapshot) = try vectors()
    let timeline = WidgetTimeline()
    #expect(vectors.cases.count >= 6)
    for vector in vectors.cases {
        let content = timeline.content(of: snapshot, at: vector.nowUtcMs)
        switch content {
        case .noSnapshot:
            Issue.record("\(vector.name): no snapshot")
        case let .expired(generatedAtUtcMs):
            #expect(vector.expect.kind == "expired", "\(vector.name)")
            #expect(generatedAtUtcMs == snapshot.generatedAtUtcMs)
        case let .showing(day, next, rows):
            #expect(vector.expect.kind == "showing", "\(vector.name)")
            #expect(day == vector.expect.day, "\(vector.name)")
            #expect(next.event.rawValue == vector.expect.nextEvent, "\(vector.name)")
            #expect(next.displayedUtcMs == vector.expect.nextUtcMs, "\(vector.name)")
            #expect(next.displayLocal == vector.expect.nextLocal, "\(vector.name)")
            let expected = (vector.expect.rows ?? []).map { "\($0.event) \($0.displayLocal) \($0.passed)" }
            #expect(rows.map { "\($0.event.rawValue) \($0.displayLocal) \($0.passed)" } == expected, "\(vector.name)")
            let entries = timeline.entries(of: snapshot, from: vector.nowUtcMs)
            #expect(entries.count > 1 ? entries[1].atUtcMs == vector.expect.refreshAtUtcMs : false, "\(vector.name)")
        }
    }
}

@Test("REQ-WID-002 the timeline has an entry at every later displayed time and ends expired")
func widgetTimelineEntries() throws {
    let (_, snapshot) = try vectors()
    let entries = WidgetTimeline().entries(of: snapshot, from: snapshot.generatedAtUtcMs)

    #expect(entries.first?.atUtcMs == snapshot.generatedAtUtcMs)
    #expect(entries.count == snapshot.items.count + 1)
    #expect(entries.last?.content == .expired(generatedAtUtcMs: snapshot.generatedAtUtcMs))
    #expect(zip(entries, entries.dropFirst()).allSatisfy { $0.atUtcMs < $1.atUtcMs })
}

@Test("REQ-WID-001 no snapshot asks for the app")
func widgetWithoutSnapshot() {
    #expect(WidgetTimeline().entries(of: nil, from: 5) == [WidgetEntry(atUtcMs: 5, content: .noSnapshot)])
}

@Test("REQ-WID-003 the host stores a snapshot.v1 document whole and reloads the widgets; a refused one changes nothing")
func hostWritesSnapshot() throws {
    let rig = Rig(path: .notification, now: 10000)
    let host = AthanHost(bridge: rig.bridge)
    let text = try String(
        contentsOf: fixtureURL("snapshot", "valid", "REQ-WID-002_across_midnight.json"),
        encoding: .utf8,
    )

    #expect(host.writeSnapshot(text))
    #expect(rig.widgets.reloads == 1)
    #expect(!host.writeSnapshot("{\"schemaVersion\": 1}"))
    #expect(rig.widgets.reloads == 1)
    let source = WidgetSnapshotSource(directory: rig.directory)
    #expect(source.entries(from: 0).count > 1)
}
