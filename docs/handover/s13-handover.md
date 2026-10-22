# S13 hand-over (location contexts + resolver + pinning + clock skew) → S14

Branch `slice/s13-contexts`, cut from `slice/s12-gazetteer` at `7b2a3c6`. Draft PR #2 (https://github.com/shadyashry/AzenFelNas/pull/2, base `slice/s12-gazetteer`). Setup: `docs/handover/cloud-environment.md`; its script worked as written.

## Built (`apps/mobile/lib/features/contexts/`)
- **domain**:
  - `LocationContext` (`ContextKind` current/pinned/manual, `ContextSource`) and `ContextPlace`. `toString` rounds to 0.01°.
  - `LocationFix` (with `isMock`) and the sealed `LocationFailure`: `LOC_PERMISSION_DENIED`, `LOC_SERVICES_OFF`, `LOC_UNAVAILABLE`.
  - `ResolvedContext` (flags, `stale`, `offerPreciseLocation`), the sealed `PlaceChoice` (gazetteer hit, typed coordinates, pin current), `ContextChanged` (no coordinate field), `LocationAccess`, `TimeReference`, and the sealed `ClockIntegrity` (`ClockUnverified` / `ClockConsistent` / `ClockSkewed` = `CLOCK_SKEW`).
  - Ports: `LocateDevice`, `RequestLocationAccess`, `ReadLocationContexts`, `WriteLocationContexts`, `RecordContextEvent`.
- **application**:
  - `ResolveObserverContext` returns a pinned or manual active context untouched. Otherwise it runs `LocateObserver`: a fresh fix (≤ 15 min, ≤ 5 000 m), then the last known fix (< 24 h, stale), then a failure that triggers the manual-place prompt.
  - `PinPlace`, `SelectContext`, and `FollowDeviceLocation` (the user's way back to the device location).
  - `ResolvePlace` is S11 `ResolveZone` + `ResolveCountry`; when no country resolves it adds `noLocalProfile`.
  - `CheckClockIntegrity` flags skew above 60 s and never blocks anything.
- **data**:
  - `PlacesDatabase`: the drift `location_contexts` table from §7.3.
  - `DriftLocationContextStore`.
  - `GeolocatorDeviceLocator`: `LocationAccuracy.low` with a 30 s limit. It checks services and permission first, so it never prompts.
  - `PermissionHandlerLocationAccess`: `locationWhenInUse` only.
  - `EventLogContextEvents`: emits `ContextChanged` as an Appendix J `CONTEXT_CHANGED` entry. A mock fix is WARN `reason=mock_location`; a zone or country change is INFO `reason=resolver`.
- **Platform**: Android has `ACCESS_COARSE_LOCATION` only. iOS has `NSLocationWhenInUseUsageDescription` only.
- **Dependencies**: geolocator 14.1.1, permission_handler 13.0.2 and permission_handler_platform_interface 4.4.1, all MIT. The transitive licences are in the ADR-011 table: three are MPL-2.0 Linux-desktop packages that are not in mobile builds.

## Evidence (this session, Linux)
- **Done-test** `test/features/contexts/contexts_done_test.dart` runs against the real pinned tz/country polygons (2026e / 5.1.2), the drift store and fakes only at the device and event ports:
  - Cairo resolves to `Africa/Cairo`/EG, and a typed Makkah point to `Asia/Riyadh`/SA.
  - Fresh fixes in London (mock) and Cairo leave the manual place active and its row unchanged.
  - After `FollowDeviceLocation`, the mock London fix is recorded as one coordinate-free WARN `CONTEXT_CHANGED`. The current row keeps its id, and the manual row stays as it was.
  - **Green.**
- **REQ-PRIV-002** also has a randomised check: 50 seeds × 10 resolver runs with random fixes, accuracies, ages and mock flags never change a chosen row.
- **Gates**:
  - `melos run ci` SUCCESS. The app has 100 tests (42 before); the other packages are unchanged; arch_lint reports 0 violations and req_index passes.
  - Schemas, Go, the lab and the engine were not touched, so their gates were not run.
  - No Android/iOS build is possible here (no Android SDK, no Xcode).

## REQ IDs proved by named tests
- **REQ-PRIV-002**: resolver, pinning, store contract and done-test.
- **REQ-PRIV-001**: mock-location events and their wire JSON carry no coordinates.
- **REQ-TIME-010**: 60 s passes, 61 s needs attention, and no sample leaves the clock unverified.
- **REQ-TEST-004**: the context store (drift + fake), `LocateDevice` (geolocator adapter over a scripted platform channel + fake) and `RequestLocationAccess` (adapter + fake).

## §15 rows and ADRs
- **D73**: active-context rule, fix acceptance, flags, failure mapping, diagnostics, clock samples, plugin settings and the separate `PlacesDatabase`.
- **ADR-011 table**: the plugin row.
- **ADR-014**: REQ tags and tests.

## Owed / open
- **Device (owner)**: on the Galaxy A50 and an iPhone, check the permission prompt, a coarse fix, and that a mock-location app shows up in diagnostics. A simulator has verified none of this.
- **macOS**: `permission_handler_apple` under Flutter's SwiftPM integration. The `PERMISSION_LOCATION_WHENINUSE` macro is a CocoaPods mechanism, so confirm that the prompt appears on iOS 18/26 and record the fix if it does not.
- **S14**: feed the CDN `Date` header into `CheckClockIntegrity` as a `TimeSource.cdnDate` sample. The GNSS sample comes from `LocationFix.fixUtcMs` at the call site, when the UI wires it.
- **S16**:
  - Open `places.sqlite` with drift_flutter and backup exclusion (REQ-PRIV-003), and fold `PlacesDatabase` into it.
  - Add `elevation_samples`.
  - Bind `EventLogContextEvents` to the event-log ring buffer, and wire everything in `app/di.dart` (`GeolocatorPlatform.instance`, `PermissionHandlerPlatform.instance`).
- **UI slices**: the manual-place prompt, the precise-location offer (it needs `ACCESS_FINE_LOCATION` and the Qibla trigger), the `Needs attention` banner, and localised permission copy (Product).
- **Commit count**: 5 commits including this hand-over, two of them `wip`. They were not squashed, because slice branches are never force-pushed.

## Inputs for S14 (`dm_packages` client: verify/stage/activate/rollback; bundled seed import; sync policy)
- S09 `dm_packages` (TUF-lite verify) and the S12 gazetteer seed at `apps/mobile/assets/packages/gazetteer/3.0.2/` (`ImportGazetteer` is ready to call on activation).
- A clock-skew sample from the CDN `Date` header goes to `CheckClockIntegrity` (`TimeReference(source: TimeSource.cdnDate, …)`). Packages are never rejected by clock (REQ-TIME-010, `REQ-PKG-002`).
