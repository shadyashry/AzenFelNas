# S28 hand-over (V1: widgets, Travel Mode, Ramadan card, ops dashboard): last slice

Branch `slice/s28-v1`, cut from `slice/s27-beta-readiness` at `0a454c2`. No PR, per the owner rule of 2026-10-22 (S17 hand-over). Setup: `docs/handover/cloud-environment.md`; its script worked as written. A new section there covers Kotlin without Gradle. The mechanics and defaults are in §15 **D88**. Appendix F gains `REQ-WID-001…003`, `REQ-TRV-001` and `REQ-RAM-001`.

## Built
- **Widget snapshot path:**
  - A new pigeon method `writeSnapshot`, regenerated for Dart, Kotlin and Swift.
  - The domain port `WriteWidgetSnapshot(EncodedSnapshot)`, with the adapter `PigeonWriteWidgetSnapshot`.
  - `RefreshWidgetSnapshot`, run by `widgetSnapshotProvider`, which Home keeps alive.
  - Both native hosts store the snapshot through `SnapshotStore` and then redraw: Android broadcasts `APPWIDGET_UPDATE`, iOS calls `reloadAllTimelines`.
- **Widget content rule:** one rule with three implementations, all held to the shared vectors in `schemas/vectors/widget_content.v1.json`. The vectors run over a new valid fixture, `snapshot/valid/REQ-WID-002_across_midnight.json`, which is Cairo output from the draft seed data.
  - **Kotlin:** `widget/SelectWidgetContent`, the Glance `PrayerTimesWidget` and its receiver, and a `setWindow` redraw alarm. The manifest, `res/xml` and en/ar strings are updated. The compose plugin and Glance are wired in Gradle.
  - **Swift:** `Widgets/WidgetTimeline` and `WidgetSnapshotSource` (public), a WidgetKit reloader, and the extension source in `apps/mobile/ios/PrayerTimesWidget/` (Swift, entitlements, xcstrings).
- **Travel Mode:** the `travel` feature, with `HandleZoneChange`.
  - It compares the zone of the cached fix with the zone of the pinned or manual context. Fixes older than 6 h and mock fixes are ignored.
  - A `TravelBanner` on Home offers "Switch" (`FollowDeviceLocation`) or "Not now" (remembered for the session).
- **Ramadan card:** `BuildFastingDay` and a `FastingCard` on Home.
  - The window is the profile's own Fajr → Maghrib, with Imsak when the profile defines it. If either time is missing, the card shows Unknown.
  - The badge is Expected or the user's adjustment, and a ±1 control writes `hijriOverrideDays`.
- **Ops dashboard:** `infra/terraform/control-plane/dashboard.tf`.
  - It adds the dashboard, two log-based metrics, and alerts for an attestation failure rate above 20 % and Postgres disk above 80 %.
  - Two D87 open alerts are now closed; `docs/runbooks/README.md` is updated.

## Evidence (this session, Linux)
- `dart run melos run ci`: **SUCCESS**. App: **491 passed + 1 skipped** (was 470 + 1). arch_lint found 0 violations in 648 files; req_index found 0 problems in 1 756 files.
- `schemas/tools/validate_fixtures.sh`: exit 0, 168 ok (+1 fixture).
- **Swift** (`swift:6.2-noble` in Docker): `swift test` passed 54/54, including the 4 new widget tests. SwiftLint `--strict` and SwiftFormat `--lint` are clean.
- **Kotlin** (standalone kotlinc 2.4.21, `-Xexplicit-api=strict -Werror`, all sources except the Glance UI): JUnit **84/84**, including the vector suite and the manifest rules. ktlint 1.8.0 and detekt 1.23.8 are clean.
- **Terraform** 1.16.5 with google 8.6.0 from the mirror: `terraform fmt` and `validate` pass for `control-plane`. Nothing was applied.
- Go, the engine and the lab are untouched, so they were not re-run.

## REQ IDs proved
- **REQ-WID-001:** port contract (fake and pigeon), no-snapshot states.
- **REQ-WID-002:** Dart midnight continuity and the local-time check, plus the Kotlin and Swift vectors.
- **REQ-WID-003:** a profile-set update rewrites the snapshot whole; a refusal keeps the previous one; the native host stores and reloads.
- **REQ-TRV-001:** check states and banner states.
- **REQ-RAM-001:** window, after-iftar, override, outside Ramadan, polar Unknown, card states.
- **REQ-PRIV-002:** the travel check changes no context.

## Done-test status ("widget correctness across midnight / profile update")
- **Automated:** Dart, Kotlin and Swift pass.
- **OWED:** rendering on real launchers and home screens, which needs a Gradle build and Xcode.

## OWED (owner)
- **Android:** a Gradle build compiles `widget/glance/` for the first time. Then add the widget to a launcher; check the midnight and post-prayer redraws and that the app redraws it after a profile update.
- **macOS:** add the `PrayerTimesWidget` extension target (App Group `group.app.dailymuslim.shared`, iOS 18), embed it in Runner, then build and place the widget.
- **Sharia board:** Fajr → Maghrib as the fast, with Imsak as a marker, per launch country (D88).
- **Product / Content:** the travel prompt policy (6 h fix age, session dismissal) and the Arabic copy.
- **Cloud:** `terraform apply` for the dashboard and alerts. Check the PromQL alert in the console.
- **Carried:** everything in S27 OWED.

## Open (engineering)
- A native tz-change trigger for the travel prompt; today it runs on open only.
- Arabic-Indic digits on the ±1 segment labels.
- Still open from D87: the IANA tag watch, the scheduled verification canary, the Hijri-boundary alert (needs the `hijri` package type), and the SBOM.

## §17.8 self-review
1. **One reason to change per type:** yes. Build, refresh and write are separate. Content selection is pure, apart from the platform redraw.
2. **Layer boundaries:** the arch lint caught data → application, and the port moved to domain behind `EncodedSnapshot`. Wiring is only in `di.dart`.
3. **Typing:** no `dynamic`, `!` or `!!`. Test JSON is narrowed with patterns.
4. **Failures:** typed. Travel and Ramadan states are sealed; Unknown is shown, never invented.
5. **Contracts:** new ports are documented and contract-tested. The vectors are shared by the three implementations.
6. **Hard-coded values:** nothing religious. The fast bounds use the profile's events, recorded as a Sharia item.
7. **Test names:** named by REQ, with fakes only at ports.
8. **Contract changes:** the pigeon contract was regenerated. REQs, D88 and the ADR-011 table (Glance in use, compose plugin, both Apache-2.0) are updated.

## Next
None: S28 is the last slice of §13. See `docs/handover/final-status.md`.
