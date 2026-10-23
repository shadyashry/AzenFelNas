@testable import AthanKit
import Foundation
import Testing

private func runnerPlist(_ name: String) throws -> [String: PlistValue] {
    let url = try repositoryRoot().appendingPathComponent("apps/mobile/ios/Runner/\(name)")
    return try PropertyListDecoder().decode([String: PlistValue].self, from: Data(contentsOf: url))
}

/// A property-list value tree, so a plist can be inspected without `Any`.
private indirect enum PlistValue: Decodable, Equatable {
    case bool(Bool)
    case string(String)
    case array([PlistValue])
    case dict([String: PlistValue])

    init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let value = try? container.decode(Bool.self) {
            self = .bool(value)
        } else if let value = try? container.decode(String.self) {
            self = .string(value)
        } else if let value = try? container.decode([PlistValue].self) {
            self = .array(value)
        } else {
            self = try .dict(container.decode([String: PlistValue].self))
        }
    }
}

@Test("REQ-ALM-036 PrivacyInfo.xcprivacy declares no tracking and the UserDefaults and file-timestamp reasons")
func privacyManifestIsPresent() throws {
    let manifest = try runnerPlist("PrivacyInfo.xcprivacy")

    #expect(manifest["NSPrivacyTracking"] == .bool(false))
    #expect(manifest["NSPrivacyTrackingDomains"] == .array([]))
    guard case let .array(apis)? = manifest["NSPrivacyAccessedAPITypes"] else {
        Issue.record("NSPrivacyAccessedAPITypes missing")
        return
    }
    let declared = apis.compactMap { api -> String? in
        guard case let .dict(entry) = api, case let .string(type)? = entry["NSPrivacyAccessedAPIType"],
              case let .array(reasons)? = entry["NSPrivacyAccessedAPITypeReasons"], !reasons.isEmpty
        else { return nil }
        return type
    }
    #expect(Set(declared) == [
        "NSPrivacyAccessedAPICategoryUserDefaults", "NSPrivacyAccessedAPICategoryFileTimestamp",
    ])
}

@Test("REQ-ALM-036 the privacy manifest is a Runner resource and places.sqlite is excluded from backup")
func privacyManifestIsBundledAndPlacesExcluded() throws {
    let root = try repositoryRoot()
    let project = try String(
        contentsOf: root.appendingPathComponent("apps/mobile/ios/Runner.xcodeproj/project.pbxproj"), encoding: .utf8,
    )
    let delegate = try String(
        contentsOf: root.appendingPathComponent("apps/mobile/ios/Runner/AppDelegate.swift"), encoding: .utf8,
    )

    #expect(project.contains("/* PrivacyInfo.xcprivacy in Resources */,"))
    #expect(delegate.contains("isExcludedFromBackup"))
}

@Test("REQ-ALM-035 Runner is signed with the App Group the plan directory uses")
func runnerHasTheAppGroup() throws {
    let entitlements = try runnerPlist("Runner.entitlements")
    let project = try String(
        contentsOf: repositoryRoot().appendingPathComponent("apps/mobile/ios/Runner.xcodeproj/project.pbxproj"),
        encoding: .utf8,
    )

    #expect(entitlements["com.apple.security.application-groups"] == .array([.string(PlanDirectory.sharedGroup)]))
    #expect(project.components(separatedBy: "CODE_SIGN_ENTITLEMENTS = Runner/Runner.entitlements;").count == 4)
}
