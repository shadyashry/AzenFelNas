import Foundation

/// Debug-only URL entry point of the S19 spike (plan: `docs/adr/ADR-025-s19-native-spike.md`), opened from
/// Safari or Notes on the device:
///
/// - `dailymuslim://spike/schedule?scenario=locked_killed&in=120&count=1&spacing=60&sound=spike_long.caf`
/// - `dailymuslim://spike/answer?reason=heard|not_heard|long_audio_full|long_audio_cut&entry=<id>&heard=<s>`
/// - `dailymuslim://spike/budget?requested=70`
/// - `dailymuslim://spike/observe` (records `alarmkit_alerting` while the app stays open)
public enum S19Spike {
    /// Handles [url] when it is a spike URL; `false` lets the app route it normally.
    public static func handle(url: URL) -> Bool {
        guard url.scheme == "dailymuslim", url.host == "spike" else { return false }
        let items = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems ?? []
        let query = Dictionary(items.map { ($0.name, $0.value ?? "") }, uniquingKeysWith: { _, last in last })
        let int = { (key: String, fallback: Int) in query[key].flatMap(Int.init) ?? fallback }
        switch url.path {
        case "/schedule":
            #if canImport(AlarmKit) && os(iOS)
                if #available(iOS 26.0, *) {
                    let scenario = query["scenario"] ?? "foreground"
                    let sound = query["sound"]
                    Task {
                        try? await SpikeAlarmKit.schedule(
                            scenario: scenario,
                            seconds: int("in", 120),
                            count: int("count", 1),
                            spacing: int("spacing", 60),
                            sound: sound
                        )
                    }
                }
            #endif
        case "/observe":
            #if canImport(AlarmKit) && os(iOS)
                if #available(iOS 26.0, *) {
                    Task { await SpikeAlarmKit.observe() }
                }
            #endif
        case "/budget":
            let requested = int("requested", 70)
            Task { try? await SpikeNotificationBudget.probe(requested: requested) }
        case "/answer":
            answer(query)
        default:
            return false
        }
        return true
    }

    private static func answer(_ query: [String: String]) {
        guard let reason = query["reason"], SpikeLabels.answers.contains(reason) else { return }
        let heardMs = query["heard"].flatMap(Int64.init).map { $0 * 1000 }
        SpikeEventLog.shared()?.append(
            .testResult,
            SpikeEventLog.attrs(entryId: query["entry"], reason: reason, durationMs: heardMs)
        )
    }
}
