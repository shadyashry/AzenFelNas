import Foundation

/// Why a wire file could not be replaced.
struct WireFileError: Error, Equatable, Sendable {
    /// What failed, without paths or content (REQ-PRIV-001).
    let reason: String
}

/// A wire document on disk, replaced with `Data.WritingOptions.atomic` (a temporary file and a rename), so a
/// reader sees the previous or the new content and never a torn write (REQ-ALM-035).
struct WireFile: Sendable {
    /// Where the document lives.
    let url: URL

    /// The bytes, or nil when the file is missing or unreadable.
    func read() -> Data? {
        try? Data(contentsOf: url)
    }

    /// Replaces the document with `data`, creating the directory first.
    func replace(with data: Data) -> Result<Void, WireFileError> {
        do {
            try FileManager.default.createDirectory(
                at: url.deletingLastPathComponent(),
                withIntermediateDirectories: true,
            )
            try data.write(to: url, options: .atomic)
            return .success(())
        } catch {
            return .failure(WireFileError(reason: "write failed: \(type(of: error))"))
        }
    }

    /// `data` decoded as `type`, or nil when it does not have the schema's shape.
    static func decode<T: Decodable>(_ type: T.Type, from data: Data) -> T? {
        try? JSONDecoder().decode(type, from: data)
    }
}

/// Where plan, snapshot and events live: the `plan/` directory of the App Group container (DESIGN.md §8.2).
enum PlanDirectory {
    /// The App Group shared by Runner, App Intents and widgets (REQ-ALM-035).
    static let sharedGroup = "group.app.azenfelnas.shared"

    /// The plan directory of the App Group `identifier`, or nil when the entitlement is missing or the host has
    /// no App Groups (the Linux test host).
    static func appGroup(_ identifier: String = sharedGroup) -> URL? {
        #if canImport(Darwin)
            FileManager.default
                .containerURL(forSecurityApplicationGroupIdentifier: identifier)?
                .appendingPathComponent("plan", isDirectory: true)
        #else
            nil
        #endif
    }
}
