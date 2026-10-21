import Foundation
import Testing

/// Errors raised by the fixture helpers.
enum FixtureError: Error {
    case repositoryRootNotFound
    case noValidFixtures(String)
    case sectionNotFound(String)
}

/// The repository root: the nearest ancestor of this file that contains DESIGN.md.
func repositoryRoot(from file: String = #filePath) throws -> URL {
    var directory = URL(fileURLWithPath: file).deletingLastPathComponent()
    for _ in 0 ..< 12 {
        if FileManager.default.fileExists(atPath: directory.appendingPathComponent("DESIGN.md").path) {
            return directory
        }
        directory = directory.deletingLastPathComponent()
    }
    throw FixtureError.repositoryRootNotFound
}

/// `schemas/fixtures/<schema>/<kind>/<name>`.
func fixtureURL(_ schema: String, _ kind: String, _ name: String) throws -> URL {
    try repositoryRoot().appendingPathComponent("schemas/fixtures/\(schema)/\(kind)/\(name)")
}

/// The JSON files of `schemas/fixtures/<schema>/valid`, sorted by name.
func validFixtures(_ schema: String) throws -> [URL] {
    let directory = try repositoryRoot().appendingPathComponent("schemas/fixtures/\(schema)/valid")
    let files = try FileManager.default
        .contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)
        .filter { $0.pathExtension == "json" }
        .sorted { $0.lastPathComponent < $1.lastPathComponent }
    guard !files.isEmpty else {
        throw FixtureError.noValidFixtures(schema)
    }
    return files
}

/// A decoded JSON tree, so two documents can be compared without `Any`.
indirect enum JSONValue: Decodable, Equatable {
    case null
    case bool(Bool)
    case number(Double)
    case string(String)
    case array([JSONValue])
    case object([String: JSONValue])

    init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() {
            self = .null
        } else if let value = try? container.decode(Bool.self) {
            self = .bool(value)
        } else if let value = try? container.decode(Double.self) {
            self = .number(value)
        } else if let value = try? container.decode(String.self) {
            self = .string(value)
        } else if let value = try? container.decode([JSONValue].self) {
            self = .array(value)
        } else {
            self = try .object(container.decode([String: JSONValue].self))
        }
    }
}

/// Decodes every valid fixture of `schema` into `T`, encodes it again and expects the same JSON tree
/// (ADR-023 round-trip).
func expectValidFixturesRoundTrip<T: Codable>(_: T.Type, schema: String) throws {
    for file in try validFixtures(schema) {
        let original = try Data(contentsOf: file)

        let encoded = try JSONEncoder().encode(JSONDecoder().decode(T.self, from: original))

        let want = try JSONDecoder().decode(JSONValue.self, from: original)
        let got = try JSONDecoder().decode(JSONValue.self, from: encoded)
        #expect(got == want, "\(schema) \(file.lastPathComponent) changed on round-trip")
    }
}
