# AthanKit (Swift)

Native Athan layer for iOS (`DESIGN.md` §8.2, ADR-002, ADR-013), a local SwiftPM package. It reads the `SchedulePlan` only and never calculates times.

Since S22 it schedules (§15 D82): `Plan/` (plan, snapshot, `events.jsonl`), `Scheduling/` (path choice, window, reconcile, receipts), `Health/`, `Audio/` (clip catalog, `Library/Sounds/` install), `SelfTest/`, `Bridge/` (`AthanBridge`, composition root `AthanGraph`) and `Platform/` (UserNotifications and AlarmKit adapters, OS probes; Darwin only). Swift 6 language mode (complete strict concurrency), iOS 18 deployment target, SwiftLint strict rules in `/.swiftlint.yml`. Linking it into Runner is owed (macOS, see `docs/test-plans/s22-ios-athan-device-suite.md`).

`ci-ios` (`macos-15`) builds and tests everything. On Linux the core (all but `Platform/` and `Spike/`) builds and tests with the `swift:6.2-noble` Docker image: `docker run --rm -v "$PWD":/repo -w /repo/apps/mobile/ios/AthanKit swift:6.2-noble swift test` from the repository root (`docs/handover/cloud-environment.md`).
