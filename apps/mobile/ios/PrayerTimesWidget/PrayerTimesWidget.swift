// The prayer-times widget extension (DESIGN.md §7.7, §15 D88). It draws the timeline AthanKit builds from the
// snapshot in the App Group container and never calculates a time (REQ-WID-001). The Xcode target (bundle id
// app.azenfelnas.PrayerTimesWidget, App Group group.app.azenfelnas.shared, iOS 18) is added on macOS (S28 OWED).
import AthanKit
import SwiftUI
import WidgetKit

struct PrayerTimesEntry: TimelineEntry {
    let date: Date
    let content: WidgetContent
}

struct PrayerTimesProvider: TimelineProvider {
    func placeholder(in _: Context) -> PrayerTimesEntry {
        PrayerTimesEntry(date: .now, content: .noSnapshot)
    }

    func getSnapshot(in context: Context, completion: @escaping (PrayerTimesEntry) -> Void) {
        completion(entries().first ?? placeholder(in: context))
    }

    func getTimeline(in _: Context, completion: @escaping (Timeline<PrayerTimesEntry>) -> Void) {
        // `.atEnd`: after the last entry (the snapshot is used up) WidgetKit asks again; the app reloads the
        // timelines whenever it writes a new snapshot.
        completion(Timeline(entries: entries(), policy: .atEnd))
    }

    private func entries() -> [PrayerTimesEntry] {
        let now = Int64(Date.now.timeIntervalSince1970 * 1000)
        let entries = WidgetSnapshotSource.appGroup()?.entries(from: now) ?? [WidgetEntry(
            atUtcMs: now,
            content: .noSnapshot,
        )]
        return entries.map {
            PrayerTimesEntry(date: Date(timeIntervalSince1970: TimeInterval($0.atUtcMs) / 1000), content: $0.content)
        }
    }
}

struct PrayerTimesView: View {
    let entry: PrayerTimesEntry

    var body: some View {
        switch entry.content {
        case .noSnapshot, .expired:
            Text("widget.openApp")
        case let .showing(_, next, rows):
            VStack(alignment: .leading, spacing: 2) {
                Text("widget.next \(Text(LocalizedStringKey(next.event.labelKey))) \(next.displayLocal)").bold()
                ForEach(rows, id: \.displayedUtcMs) { row in
                    HStack {
                        Text(LocalizedStringKey(row.event.labelKey))
                        Spacer()
                        Text(row.displayLocal)
                    }
                    .foregroundStyle(row.passed ? .secondary : .primary)
                    .accessibilityElement(children: .combine)
                }
            }
        }
    }
}

extension WidgetEvent {
    /// The `Localizable.xcstrings` key of the event's name.
    var labelKey: String {
        "widget.event.\(rawValue.lowercased())"
    }
}

@main
struct PrayerTimesWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "PrayerTimesWidget", provider: PrayerTimesProvider()) { entry in
            PrayerTimesView(entry: entry).containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("widget.title")
        .description("widget.description")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
