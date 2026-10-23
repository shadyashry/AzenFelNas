import Foundation

/// The sound an alert of `soundId` plays.
protocol SoundCatalog: Sendable {
    func sound(for soundId: String) -> AlertSound
    /// Whether `soundId` has an installed clip (the `soundAssetPresence` probe).
    func isInstalled(_ soundId: String) -> Bool
}

/// The clips iOS may play (DESIGN.md §8.2 `AthanClipCatalog`, REQ-ALM-034): the `iosClip` of a manifest sound
/// whose duration is at most `policy.iosClipSeconds` and never above 29 s. A sound without such a clip plays
/// the system default.
struct AthanClipCatalog: Sendable {
    /// The hard ceiling: `UNNotificationSound` plays at most 30 s (ADR-013).
    static let maxClipMs = 29000

    private let clips: [String: AthanIosClip]

    init(manifest: AthanAudioManifest, clipSeconds: Int = 29) {
        let limit = min(Self.maxClipMs, max(0, clipSeconds) * 1000)
        clips = Dictionary(
            manifest.sounds.compactMap { sound in
                sound.iosClip.flatMap { $0.durationMs <= limit ? (sound.soundId, $0) : nil }
            },
            uniquingKeysWith: { first, _ in first }
        )
    }

    /// The clip of `soundId`, or nil.
    func clip(for soundId: String) -> AthanIosClip? {
        clips[soundId]
    }

    /// Every listed clip by sound id.
    var all: [String: AthanIosClip] { clips }

    /// The `Library/Sounds/` file name of `soundId`'s clip.
    static func fileName(of soundId: String) -> String {
        "\(soundId).caf"
    }
}

/// `Library/Sounds/`, where iOS looks up notification and AlarmKit sounds by name.
struct SoundLibrary: Sendable {
    let directory: URL

    /// The app's `Library/Sounds/`, or nil when the host has no library directory.
    static func app() -> SoundLibrary? {
        FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first
            .map { SoundLibrary(directory: $0.appendingPathComponent("Sounds", isDirectory: true)) }
    }

    func url(of soundId: String) -> URL {
        directory.appendingPathComponent(AthanClipCatalog.fileName(of: soundId))
    }

    func contains(_ soundId: String) -> Bool {
        FileManager.default.fileExists(atPath: url(of: soundId).path)
    }

    /// Copies `source` to the clip of `soundId`, replacing it atomically (copy to a temporary name, then move).
    func install(_ soundId: String, from source: URL) -> Result<Void, WireFileError> {
        let manager = FileManager.default
        let target = url(of: soundId)
        let temporary = directory.appendingPathComponent(".\(soundId).caf.partial")
        do {
            try manager.createDirectory(at: directory, withIntermediateDirectories: true)
            try? manager.removeItem(at: temporary)
            try manager.copyItem(at: source, to: temporary)
            if manager.fileExists(atPath: target.path) {
                _ = try manager.replaceItemAt(target, withItemAt: temporary)
            } else {
                try manager.moveItem(at: temporary, to: target)
            }
            return .success(())
        } catch {
            try? manager.removeItem(at: temporary)
            return .failure(WireFileError(reason: "install failed: \(type(of: error))"))
        }
    }
}

/// Catalog clips that are installed in the library; anything else plays the system default.
struct InstalledClips: SoundCatalog {
    let catalog: AthanClipCatalog
    let library: SoundLibrary

    func sound(for soundId: String) -> AlertSound {
        isInstalled(soundId) ? .clip(fileName: AthanClipCatalog.fileName(of: soundId)) : .systemDefault
    }

    func isInstalled(_ soundId: String) -> Bool {
        catalog.clip(for: soundId) != nil && library.contains(soundId)
    }
}

/// Where bundled assets are (the Flutter asset lookup on device, a directory in tests).
protocol AssetSource: Sendable {
    /// The file of asset `path` (relative to `assets/`), or nil when it is not bundled.
    func url(ofAsset path: String) -> URL?
}

/// Copies every catalog clip into `Library/Sounds/` (DESIGN.md §8.2 Audio). A clip missing from the bundle is an
/// `AUDIO_ASSET_MISSING` warning and leaves that sound on the system default.
struct InstallClips: Sendable {
    let catalog: AthanClipCatalog
    let library: SoundLibrary
    let assets: any AssetSource
    let events: EventsStore

    /// Returns the number of clips installed.
    @discardableResult
    func callAsFunction() -> Int {
        var installed = 0
        for (soundId, clip) in catalog.all.sorted(by: { $0.key < $1.key }) {
            guard let source = assets.url(ofAsset: clip.file),
                  case .success = library.install(soundId, from: source)
            else {
                events.append(.alarmScheduled, .of(code: .audioAssetMissing, reason: soundId), level: .warn)
                continue
            }
            installed += 1
        }
        return installed
    }
}
