#if canImport(UserNotifications)
    #if canImport(AlarmKit) && os(iOS)
        import AlarmKit
    #endif
    import Foundation
    #if canImport(UIKit)
        import UIKit
    #endif
    import UserNotifications

    /// The delivery path from the OS (ADR-013): AlarmKit on iOS 26+ once the user authorised it, else
    /// notifications (the D79 fallback, also while AlarmKit authorisation is not determined).
    struct DarwinPathGate: DeliveryPathGate {
        func current() async -> DeliveryPath {
            #if canImport(AlarmKit) && os(iOS)
                if #available(iOS 26.0, *), AlarmManager.shared.authorizationState == .authorized {
                    return .alarmKit
                }
            #endif
            return .notification
        }
    }

    /// The OS probes of DESIGN.md §8.2. iOS has no public API for the silent switch or the Focus state of
    /// another app's alerts, so both are `positive == nil` (⇒ `UNKNOWN` where they gate); critical alerts are
    /// not requested in the MVP (ADR-013) and report `notApplicable`.
    struct DarwinProbes: PlatformProbes {
        func probes(on _: DeliveryPath) async -> [ProbeResult] {
            let settings = await UNUserNotificationCenter.current().notificationSettings()
            var results = await [
                ProbeResult(.notificationAuthorization, Self.delivers(settings.authorizationStatus)),
                ProbeResult(.notificationSound, settings.soundSetting == .enabled),
                ProbeResult(.silentSwitch, nil, detail: Self.noPublicApi),
                ProbeResult(.focusStatus, nil, detail: Self.noPublicApi),
                ProbeResult(.criticalAlerts, nil, detail: Self.notApplicable),
                ProbeResult(.backgroundRefreshStatus, Self.backgroundRefresh()),
            ]
            #if canImport(AlarmKit) && os(iOS)
                if #available(iOS 26.0, *) {
                    results.insert(
                        ProbeResult(.alarmKitAuthorization, AlarmManager.shared.authorizationState == .authorized),
                        at: 0,
                    )
                }
            #endif
            return results
        }

        /// Whether `status` lets an alert with sound through; provisional delivery is quiet, so it is `false`.
        static func delivers(_ status: UNAuthorizationStatus) -> Bool? {
            switch status {
            case .authorized, .ephemeral: true
            case .denied, .notDetermined, .provisional: false
            @unknown default: nil
            }
        }

        @MainActor
        private static func backgroundRefresh() -> Bool? {
            #if canImport(UIKit)
                switch UIApplication.shared.backgroundRefreshStatus {
                case .available: true
                case .denied, .restricted: false
                @unknown default: nil
                }
            #else
                nil
            #endif
        }

        private static let noPublicApi = "noPublicApi"
        private static let notApplicable = "notApplicable"
    }

    extension AthanGraph {
        /// Asset path of the bundled audio manifest (D82).
        static let audioManifestAsset = "athan/athan_audio_manifest.json"

        /// The live graph over the App Group, `Library/Sounds/` and the OS adapters; nil when the App Group
        /// entitlement or the bundled copy is missing (a build defect Health cannot report without a plan).
        static func live(assets: any AssetSource) -> AthanGraph? {
            guard let directory = PlanDirectory.appGroup(), let library = SoundLibrary.app() else { return nil }
            let plan = PlanStore(directory: directory).read()
            guard let copy = NativeCopy.bundled(plan?.policy.locale ?? .en) else { return nil }
            let manifest = assets.url(ofAsset: audioManifestAsset)
                .flatMap { try? Data(contentsOf: $0) }
                .flatMap { WireFile.decode(AthanAudioManifest.self, from: $0) }
                ?? AthanAudioManifest(sounds: [])
            let catalog = AthanClipCatalog(manifest: manifest, clipSeconds: plan?.policy.iosClipSeconds ?? 29)
            var alarms: any AlarmKitPort = UnavailableAlarmKit()
            #if canImport(AlarmKit) && os(iOS)
                if #available(iOS 26.0, *) {
                    alarms = AlarmKitAdapter(stopTitle: copy.stop)
                }
            #endif
            return AthanGraph(
                directory: directory,
                alarms: alarms,
                notifications: UserNotificationsAdapter(),
                gate: DarwinPathGate(),
                platformProbes: DarwinProbes(),
                sounds: InstalledClips(catalog: catalog, library: library),
                copy: copy,
                clock: SystemClock(),
                widgets: liveWidgetReloader(),
            )
        }
    }
#endif
