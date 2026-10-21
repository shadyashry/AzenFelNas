// swift-tools-version: 6.2
// AthanKit: native Athan layer for iOS (DESIGN.md §8.2). Reads SchedulePlan only; never calculates times (ADR-002).
import PackageDescription

let package = Package(
    name: "AthanKit",
    platforms: [.iOS(.v18)],
    products: [
        .library(name: "AthanKit", targets: ["AthanKit"])
    ],
    targets: [
        .target(
            name: "AthanKit",
            swiftSettings: [.enableUpcomingFeature("ExistentialAny")]
        ),
        .testTarget(name: "AthanKitTests", dependencies: ["AthanKit"]),
    ],
    swiftLanguageModes: [.v6]
)
