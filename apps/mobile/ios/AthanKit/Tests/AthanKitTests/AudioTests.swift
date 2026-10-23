@testable import AthanKit
import Foundation
import Testing

private func manifest(_ clips: [(String, Int)]) -> AthanAudioManifest {
    AthanAudioManifest(
        sounds: clips.map { soundId, durationMs in
            AthanSound(
                soundId: soundId, file: "athan/\(soundId).m4a", durationMs: 180_000, fajrVariantOf: nil,
                licenceRef: "fixture", sha256: String(repeating: "1", count: 64),
                iosClip: AthanIosClip(
                    file: "athan/ios/\(soundId).caf", durationMs: durationMs, sha256: String(repeating: "2", count: 64),
                ),
            )
        },
    )
}

/// Assets in a directory.
private struct DirectoryAssets: AssetSource {
    let root: URL
    func url(ofAsset path: String) -> URL? {
        let url = root.appendingPathComponent(path)
        return FileManager.default.fileExists(atPath: url.path) ? url : nil
    }
}

@Test("audio manifest fixtures round-trip unchanged (ADR-023)")
func audioManifestRoundTrips() throws {
    try expectValidFixturesRoundTrip(AthanAudioManifest.self, schema: "athan_audio_manifest")
}

@Test("REQ-ALM-034 only manifest clips of at most 29 s and at most the policy's seconds are playable")
func catalogKeepsShortClipsOnly() {
    let sounds = manifest([("a", 29000), ("b", 29001), ("c", 20000)])

    let full = AthanClipCatalog(manifest: sounds, clipSeconds: 29)
    let shorter = AthanClipCatalog(manifest: sounds, clipSeconds: 20)
    let wider = AthanClipCatalog(manifest: sounds, clipSeconds: 60)

    #expect(Set(full.all.keys) == ["a", "c"])
    #expect(Set(shorter.all.keys) == ["c"])
    #expect(Set(wider.all.keys) == ["a", "c"])
}

@Test("REQ-ALM-034 an alert plays a clip only when it is listed and installed, else the system default")
func installedClipsOnly() throws {
    let library = SoundLibrary(directory: temporaryDirectory())
    let source = temporaryDirectory()
    try FileManager.default.createDirectory(at: source, withIntermediateDirectories: true)
    let clip = source.appendingPathComponent("x.caf")
    try Data("caf".utf8).write(to: clip)
    _ = library.install("stray", from: clip)
    let sounds = InstalledClips(catalog: AthanClipCatalog(manifest: manifest([("a", 1000)])), library: library)

    #expect(sounds.sound(for: "a") == .systemDefault)
    _ = library.install("a", from: clip)

    #expect(sounds.sound(for: "a") == .clip(fileName: "a.caf"))
    #expect(sounds.sound(for: "stray") == .systemDefault)
}

@Test("REQ-ALM-034 InstallClips copies every listed clip to Library/Sounds and logs a missing one")
func installClipsCopiesBundledClips() throws {
    let root = temporaryDirectory()
    let ios = root.appendingPathComponent("athan/ios", isDirectory: true)
    try FileManager.default.createDirectory(at: ios, withIntermediateDirectories: true)
    try Data("one".utf8).write(to: ios.appendingPathComponent("a.caf"))
    let library = SoundLibrary(directory: temporaryDirectory())
    let events = EventsStore(directory: temporaryDirectory(), clock: FixedClock(now: 1))
    let install = InstallClips(
        catalog: AthanClipCatalog(manifest: manifest([("a", 1000), ("b", 1000)])),
        library: library,
        assets: DirectoryAssets(root: root),
        events: events,
    )

    #expect(install() == 1)
    try Data("two".utf8).write(to: ios.appendingPathComponent("a.caf"))
    #expect(install() == 1)

    #expect(try Data(contentsOf: library.url(of: "a")) == Data("two".utf8))
    #expect(try FileManager.default.contentsOfDirectory(atPath: library.directory.path) == ["a.caf"])
    let missing = events.drain().filter { $0.attrs.code == .audioAssetMissing }
    #expect(missing.map(\.attrs.reason) == ["b", "b"])
}

@Test("REQ-ALM-034 a Test alert carries the installed clip of its sound")
func testUsesClip() async throws {
    let rig = Rig(path: .notification, now: 1000)

    #expect(await rig.bridge.startTest(testId: "t", fireInSeconds: 60, soundId: "athan_makkah_v1") == .armed)

    let request = try #require(await rig.notifications.pending[StartAthanTest.entryId(of: "t")])
    #expect(request.sound == .clip(fileName: "athan_makkah_v1.caf"))
}
