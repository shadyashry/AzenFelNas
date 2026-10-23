import Foundation

/// Outcome of `SnapshotStore.write(snapshotJSON:)`.
enum SnapshotWriteOutcome: Equatable, Sendable {
    /// The snapshot is now the persisted one.
    case written
    /// The document is not a `snapshot.v1` snapshot; nothing changed.
    case rejected(reason: String)
    /// The container could not be written; the previous snapshot, if any, stays.
    case unwritable(reason: String)
}

/// The persisted widget `Snapshot` (DESIGN.md §7.7, Appendix I): `<directory>/snapshot.json` beside the plan,
/// replaced atomically; widgets read it and never recalculate.
///
/// Contract: `write(snapshotJSON:)` validates the document first; `read()` returns nil for a missing or
/// unreadable file and never throws.
struct SnapshotStore: Sendable {
    /// File name inside the plan directory.
    static let snapshotFile = "snapshot.json"

    private let file: WireFile

    /// A store in `directory`.
    init(directory: URL) {
        file = WireFile(url: directory.appendingPathComponent(Self.snapshotFile))
    }

    /// Persists `snapshotJSON` when it is a `snapshot.v1` document.
    func write(snapshotJSON: Data) -> SnapshotWriteOutcome {
        guard let snapshot = WireFile.decode(Snapshot.self, from: snapshotJSON) else {
            return .rejected(reason: "not a snapshot.v1 document")
        }
        guard snapshot.schemaVersion == PlanStore.schemaVersion else {
            return .rejected(reason: "schemaVersion \(snapshot.schemaVersion)")
        }
        switch file.replace(with: snapshotJSON) {
        case .success:
            return .written
        case let .failure(error):
            return .unwritable(reason: error.reason)
        }
    }

    /// The persisted snapshot, or nil.
    func read() -> Snapshot? {
        file.read().flatMap { WireFile.decode(Snapshot.self, from: $0) }
    }
}
