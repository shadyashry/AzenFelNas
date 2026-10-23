import Foundation
import Synchronization

/// Serialises appends and drains of every `EventsStore` in the process (app, App Intents and bridge).
private let eventsLock = Mutex(())

/// `<plan directory>/events.jsonl` (DESIGN.md §8.2): native code appends `event_log.v1` lines and Dart drains them
/// on every start (REQ-ALM-041). `drain()` moves the file aside before reading, so a line is returned once and
/// never lost; a drain interrupted after the move leaves its lines in `events.jsonl.draining` for the next one.
struct EventsStore: Sendable {
    /// File name inside the plan directory.
    static let eventsFile = "events.jsonl"

    private let file: URL
    private let draining: URL
    private let clock: any UtcClock

    /// A store in `directory` stamping lines with `clock`.
    init(directory: URL, clock: any UtcClock) {
        file = directory.appendingPathComponent(Self.eventsFile)
        draining = directory.appendingPathComponent(Self.eventsFile + ".draining")
        self.clock = clock
    }

    /// Appends one line; an unwritable container drops it (receipts are best-effort evidence, never a crash).
    func append(_ code: EventCode, _ attrs: EventAttrs, level: EventLevel = .info) {
        let entry = EventLogEntry(utcMs: clock.nowUtcMs(), level: level, code: code, attrs: attrs)
        guard var line = try? JSONEncoder().encode(entry) else { return }
        line.append(0x0A)
        eventsLock.withLock { _ in
            let manager = FileManager.default
            try? manager.createDirectory(at: file.deletingLastPathComponent(), withIntermediateDirectories: true)
            guard manager.fileExists(atPath: file.path) else {
                try? line.write(to: file)
                return
            }
            guard let handle = try? FileHandle(forWritingTo: file) else { return }
            defer { try? handle.close() }
            _ = try? handle.seekToEnd()
            try? handle.write(contentsOf: line)
        }
    }

    /// Every parseable line not drained before, oldest first; the store is empty afterwards.
    func drain() -> [EventLogEntry] {
        eventsLock.withLock { _ in
            let manager = FileManager.default
            var data = (try? Data(contentsOf: draining)) ?? Data()
            if manager.fileExists(atPath: file.path) {
                let moving = file.appendingPathExtension("moving")
                try? manager.removeItem(at: moving)
                if (try? manager.moveItem(at: file, to: moving)) != nil {
                    data.append((try? Data(contentsOf: moving)) ?? Data())
                    try? manager.removeItem(at: moving)
                }
            }
            try? manager.removeItem(at: draining)
            let decoder = JSONDecoder()
            return data.split(separator: 0x0A).compactMap { try? decoder.decode(EventLogEntry.self, from: Data($0)) }
        }
    }
}

extension EventAttrs {
    /// Attributes with every absent one nil (the closed allow-list of REQ-PRIV-001).
    static func of(
        code: FailureCode? = nil,
        generation: Int? = nil,
        entryId: String? = nil,
        state: String? = nil,
        reason: String? = nil,
        durationMs: Int64? = nil,
        count: Int? = nil,
    ) -> EventAttrs {
        EventAttrs(
            code: code, generation: generation, entryId: entryId, packageType: nil, version: nil, state: state,
            reason: reason, durationMs: durationMs, count: count, zoneId: nil, countryCode: nil,
        )
    }
}
