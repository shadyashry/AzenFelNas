import Foundation

/// The widget content of a snapshot (DESIGN.md §7.7, §15 D88). Pure; the same rules as the Kotlin
/// `SelectWidgetContent` and `schemas/vectors/widget_content.v1.json`:
/// - next = the first Fajr, Dhuhr, Asr, Maghrib or Isha whose displayed instant is after now (Imsak and sunrise
///   are listed but are not prayers, as on Home);
/// - rows = every item of next's prayer day in time order, so the list rolls to the next day once its Isha has
///   passed and needs no zone rules at local midnight (REQ-WID-002);
/// - a new entry at every displayed instant after now; no prayer ahead = `.expired`.
struct WidgetTimeline: Sendable {
    private static let prayers: Set<PrayerEvent> = [.fajr, .dhuhr, .asr, .maghrib, .isha]

    /// The content of `snapshot` (nil: none written yet) at `nowUtcMs`.
    func content(of snapshot: Snapshot?, at nowUtcMs: Int64) -> WidgetContent {
        guard let snapshot else { return .noSnapshot }
        let items = snapshot.items.sorted { $0.displayedUtcMs < $1.displayedUtcMs }
        guard let next = items.first(where: { Self.prayers.contains($0.event) && $0.displayedUtcMs > nowUtcMs }) else {
            return .expired(generatedAtUtcMs: snapshot.generatedAtUtcMs)
        }
        let rows = items.filter { $0.day == next.day }.map { Self.row($0, passed: $0.displayedUtcMs <= nowUtcMs) }
        return .showing(day: next.day, next: Self.row(next, passed: false), rows: rows)
    }

    /// The WidgetKit timeline from `nowUtcMs`: one entry now and one at each later displayed instant, the last
    /// of which is `.expired`; WidgetKit asks again after it.
    func entries(of snapshot: Snapshot?, from nowUtcMs: Int64) -> [WidgetEntry] {
        let instants = (snapshot?.items ?? []).map(\.displayedUtcMs).filter { $0 > nowUtcMs }
        return ([nowUtcMs] + Set(instants).sorted()).map { WidgetEntry(atUtcMs: $0, content: content(of: snapshot, at: $0)) }
    }

    private static func row(_ item: SnapshotItem, passed: Bool) -> WidgetRow {
        WidgetRow(event: event(item.event), displayedUtcMs: item.displayedUtcMs, displayLocal: item.displayLocal, passed: passed)
    }

    private static func event(_ event: PrayerEvent) -> WidgetEvent {
        switch event {
        case .imsak: .imsak
        case .fajr: .fajr
        case .sunrise: .sunrise
        case .dhuhr: .dhuhr
        case .asr: .asr
        case .maghrib: .maghrib
        case .isha: .isha
        }
    }
}

/// The widget extension's read side (DESIGN.md §7.7): the snapshot in the shared App Group container, turned into
/// timeline entries. Reads only; the app is the only writer.
public struct WidgetSnapshotSource: Sendable {
    private let store: SnapshotStore

    /// A source over the snapshot in `directory`.
    public init(directory: URL) {
        store = SnapshotStore(directory: directory)
    }

    /// The source over the App Group container; nil without the entitlement.
    public static func appGroup() -> WidgetSnapshotSource? {
        PlanDirectory.appGroup().map { WidgetSnapshotSource(directory: $0) }
    }

    /// The timeline entries from `nowUtcMs`.
    public func entries(from nowUtcMs: Int64) -> [WidgetEntry] {
        WidgetTimeline().entries(of: store.read(), from: nowUtcMs)
    }
}

/// Asks WidgetKit to reload the prayer-times widget after the app wrote a new snapshot. Never throws.
protocol WidgetReloader: Sendable {
    func reloadAll()
}

/// No widgets: the default for graphs built in tests and on hosts without WidgetKit.
struct NoWidgetReloader: WidgetReloader {
    func reloadAll() {}
}
