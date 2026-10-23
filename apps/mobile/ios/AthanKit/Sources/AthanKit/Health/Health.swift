/// `HealthState` of DESIGN.md §7.8; `rawValue` is the pigeon/Dart enum name.
enum HealthState: String, Equatable, Sendable {
    case ready
    case limited
    case notReady
    case unknown
}

/// The `HealthReason`s of DESIGN.md §7.8 that iOS can report; `rawValue` is the pigeon/Dart enum name.
enum HealthReason: String, Equatable, Sendable {
    case needsNotificationPermission
    case needsAlarmKitAuthorization
    case mutedChannel
    case stalePlan
    case horizonEnding
    case noSoundAsset
    case unverifiableDelivery
}

/// How a failing probe moves the state (§8.3, D81).
enum Severity: Equatable, Sendable {
    /// `false` ⇒ `NOT_READY`.
    case blocking
    /// `false` ⇒ `LIMITED`.
    case degrading
    /// Shown as evidence only.
    case informational
}

/// The iOS probes of DESIGN.md §8.2; `rawValue` is `ProbeResult.name`, shared with Android where the meaning is
/// the same (`soundAssetPresence`, `planPresent`, `planHorizon`).
enum ProbeName: String, Equatable, Sendable, CaseIterable {
    case alarmKitAuthorization
    case notificationAuthorization
    case notificationSound
    case soundAssetPresence
    case planPresent
    case planHorizon
    case deliveryVerified
    case silentSwitch
    case focusStatus
    case backgroundRefreshStatus
    case criticalAlerts

    /// The probe's effect on `path` (D82). AlarmKit alarms sound through the silent switch and Focus, so those
    /// probes gate only the notification path; notifications carry only reminders on the AlarmKit path.
    func severity(on path: DeliveryPath) -> Severity {
        switch (self, path) {
        case (.alarmKitAuthorization, _), (.soundAssetPresence, _), (.planPresent, _),
             (.notificationAuthorization, .notification):
            .blocking
        case (.notificationAuthorization, .alarmKit), (.notificationSound, _), (.planHorizon, _),
             (.deliveryVerified, _), (.silentSwitch, .notification), (.focusStatus, .notification):
            .degrading
        case (.silentSwitch, .alarmKit), (.focusStatus, .alarmKit), (.backgroundRefreshStatus, _),
             (.criticalAlerts, _):
            .informational
        }
    }

    /// The reason a `false` result adds.
    var reason: HealthReason? {
        switch self {
        case .alarmKitAuthorization: .needsAlarmKitAuthorization
        case .notificationAuthorization: .needsNotificationPermission
        case .notificationSound: .mutedChannel
        case .soundAssetPresence: .noSoundAsset
        case .planPresent: .stalePlan
        case .planHorizon: .horizonEnding
        case .deliveryVerified: .unverifiableDelivery
        case .silentSwitch, .focusStatus, .backgroundRefreshStatus, .criticalAlerts: nil
        }
    }
}

/// One probe; `positive` is nil when the platform cannot tell (§7.8). `detail` never holds an identifier.
struct ProbeResult: Equatable, Sendable {
    let name: ProbeName
    let positive: Bool?
    let detail: String?

    init(_ name: ProbeName, _ positive: Bool?, detail: String? = nil) {
        self.name = name
        self.positive = positive
        self.detail = detail
    }
}

/// `AthanHealthReport` of §7.8.
struct HealthReport: Equatable, Sendable {
    let state: HealthState
    let reasons: [HealthReason]
    let probes: [ProbeResult]
    let evaluatedAtUtcMs: Int64
    let platformPath: String
}

/// Probes only the OS can answer (authorisations, settings, silent switch, Focus).
protocol PlatformProbes: Sendable {
    func probes(on path: DeliveryPath) async -> [ProbeResult]
}
