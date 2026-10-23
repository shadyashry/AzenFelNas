import Foundation

/// Copy native code shows that the plan does not carry (Test alert, Stop button), in both shipped locales. The
/// text is product copy (drafts, D82) kept in `Resources/native_copy.json`, not in code.
struct NativeCopy: Codable, Equatable, Sendable {
    let testTitle: String
    let testBody: String
    let stop: String

    /// The copy of `locale` from the bundled resource, or nil when the resource is missing or malformed.
    static func bundled(_ locale: PlanLocale) -> NativeCopy? {
        guard let url = Bundle.module.url(forResource: "native_copy", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let table = try? JSONDecoder().decode([String: NativeCopy].self, from: data)
        else { return nil }
        return table[locale.rawValue]
    }
}
