// S19 native spike (DESIGN.md §13, docs/adr/ADR-025-s19-native-spike.md). Debug tooling, not product code.

/// Receipt labels of the S19 spike; mirrors `SpikeLabels` in
/// `apps/mobile/lib/features/delivery_spike/domain/spike_protocol.dart` verbatim.
enum SpikeLabels {
    static let iosAlarmKit = "ios_alarmkit"
    static let alarmKitAlerting = "alarmkit_alerting"
    static let userStop = "user_stop"
    static let pendingBudget = "pending_budget"
    /// `TEST_RESULT` reasons a tester may record (`heard`, `not_heard`, `long_audio_full`, `long_audio_cut`).
    static let answers: Set<String> = ["heard", "not_heard", "long_audio_full", "long_audio_cut"]
}
