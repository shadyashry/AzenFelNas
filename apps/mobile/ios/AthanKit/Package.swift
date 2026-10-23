// swift-tools-version: 6.2
// AthanKit: native Athan layer for iOS (DESIGN.md §8.2). Reads SchedulePlan only; never calculates times (ADR-002).
import PackageDescription

let package = Package(
    name: "AthanKit",
    // macOS is only the host for `swift test` in ci-ios; the package ships on iOS 18+.
    platforms: [.iOS(.v18), .macOS(.v15)],
    products: [
        .library(name: "AthanKit", targets: ["AthanKit"]),
    ],
    targets: [
        .target(
            name: "AthanKit",
            resources: [.process("Resources")],
            swiftSettings: [.enableUpcomingFeature("ExistentialAny")],
        ),
        .testTarget(name: "AthanKitTests", dependencies: ["AthanKit"]),
    ],
    swiftLanguageModes: [.v6],
)
