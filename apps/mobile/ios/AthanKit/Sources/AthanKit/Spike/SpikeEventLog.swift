import Foundation

/// Appends `event_log.v1` lines to `<App Group>/plan/events.jsonl` (DESIGN.md §8.2), the file an App Intent can
/// reach while the app's UI is not running.
struct SpikeEventLog: Sendable {
    let url: URL

    /// The App Group log, or `nil` when the entitlement is missing (the spike then cannot record receipts).
    static func shared() -> SpikeEventLog? {
        PlanDirectory.appGroup().map { SpikeEventLog(url: $0.appendingPathComponent(EventsStore.eventsFile)) }
    }

    func append(_ code: EventCode, _ attrs: EventAttrs, level: EventLevel = .info) {
        let entry = EventLogEntry(utcMs: Self.nowMs(), level: level, code: code, attrs: attrs)
        guard var line = try? JSONEncoder().encode(entry) else { return }
        line.append(0x0A)
        let manager = FileManager.default
        try? manager.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        if !manager.fileExists(atPath: url.path) {
            _ = manager.createFile(atPath: url.path, contents: nil)
        }
        guard let handle = try? FileHandle(forWritingTo: url) else { return }
        defer { try? handle.close() }
        _ = try? handle.seekToEnd()
        try? handle.write(contentsOf: line)
    }

    func readAll() -> [EventLogEntry] {
        guard let text = try? String(contentsOf: url, encoding: .utf8) else { return [] }
        let decoder = JSONDecoder()
        return text.split(separator: "\n").compactMap { try? decoder.decode(EventLogEntry.self, from: Data($0.utf8)) }
    }

    /// The trigger instant of [entryId] from its `ALARM_SCHEDULED` line (`utcMs + durationMs`).
    func triggerMs(of entryId: String) -> Int64? {
        readAll().last { $0.code == .alarmScheduled && $0.attrs.entryId == entryId }
            .flatMap { entry in entry.attrs.durationMs.map { entry.utcMs + $0 } }
    }

    static func nowMs() -> Int64 {
        Int64((Date().timeIntervalSince1970 * 1000).rounded())
    }

    static func attrs(
        entryId: String? = nil,
        state: String? = nil,
        reason: String? = nil,
        durationMs: Int64? = nil,
        count: Int? = nil,
    ) -> EventAttrs {
        EventAttrs(
            code: nil, generation: nil, entryId: entryId, packageType: nil, version: nil, state: state,
            reason: reason, durationMs: durationMs, count: count, zoneId: nil, countryCode: nil,
        )
    }
}
