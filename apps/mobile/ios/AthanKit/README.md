# AthanKit (Swift)

Native Athan layer for iOS (`DESIGN.md` §8.2, ADR-002, ADR-013), a local SwiftPM package. It reads the `SchedulePlan` only and never calculates times.

Empty until slice S22. Fixed now: Swift 6 language mode (complete strict concurrency), iOS 18 deployment target, SwiftLint strict rules in `/.swiftlint.yml`. It is linked into Runner through Flutter's SwiftPM integration in S22.

Built and tested only on macOS (`ci-ios`, `macos-15`): `swift test` cannot run on the Windows development machine.
