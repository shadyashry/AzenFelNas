/// Wire form of `athan_audio_manifest.v1` (DESIGN.md §9.5), read from the bundled Flutter asset.
struct AthanAudioManifest: Codable, Equatable, Sendable {
    let sounds: [AthanSound]
}

/// One bundled Athan sound; `iosClip` is what iOS may play (REQ-ALM-034).
struct AthanSound: Codable, Equatable, Sendable {
    let soundId: String
    let file: String
    let durationMs: Int
    let fajrVariantOf: String?
    let licenceRef: String
    let sha256: String
    let iosClip: AthanIosClip?
    /// The name the voices page shows (D124); AthanKit only carries it.
    var name: AthanSoundName?
}

/// The English and Arabic name of a bundled sound (D124).
struct AthanSoundName: Codable, Equatable, Sendable {
    let en: String
    let ar: String
}

/// A `.caf` clip of at most 29 s.
struct AthanIosClip: Codable, Equatable, Sendable {
    let file: String
    let durationMs: Int
    let sha256: String
}
