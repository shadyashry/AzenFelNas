# Daily Muslim — Solution & Engineering Design Specification

| Field | Value |
|---|---|
| Document | `DESIGN.md` — **normative** solution and engineering design (single source of truth for build) |
| Version | **1.1** — 21 October 2026 (v1.0 + independent cold-read audit: 88 implementation blockers and 22 end-to-end gaps resolved) |
| Audience | Claude Code (primary implementer), engineers, product, Sharia board, operations, reviewers |
| Supersedes | Conflicts between `Daily_Muslim_Solution_Architecture_EN.md`, `…_AR_EG.md` and the Red Team review are resolved **here** (ADR-000) |
| Working engine name | **Geo Salah Engine** |
| Product | Offline-first prayer times + Athan + Qibla for iOS and Android. Free, no account, no ads, no paid runtime dependency. |
| Change control | §23.3 — changes to this file require an ADR entry and Architect approval; religious-semantics changes also require the Sharia board |

---

## 0. How to use this document

### 0.1 Precedence and status tags

1. `DESIGN.md` is the SSOT for *what* is built and *how*. The EN architecture document is background; the AR document is a controlled translation; the Red Team review is input. Where they disagree, this file wins.
2. Status tags:
   - `[DECIDED]` — build it. `[DECIDED · revisit Dn]` — build it; a human may revisit later (§15), but a change is a code/ADR change, not data.
   - `[DEFAULT · Dn]` — engineering default behind a **profile or package data field**; a human may override via data, never via code. Build the default.
   - `[DRAFT_UNVERIFIED]` — illustrative data (seed profile angles). Never shipped on `beta`/`production` channels.
   - `[DEFERRED vX]` — out of scope until release X. Keep the extension point; do not implement.
3. Requirements are tagged `[REQ-AREA-nnn]`. **Every ID has exactly one normative sentence in Appendix F**; tests cite the ID in their names. `grep -R "REQ-"` is the index; a CI check fails if an ID appears in code/tests but not in Appendix F.

### 0.2 Eleven rules for Claude Code (non-negotiable)

1. **Never invent, tune, or "fix" a religious parameter in code** — no angle, offset, rounding direction, high-latitude method, Iqama interval or Ramadan rule in Dart/Kotlin/Swift/Go/Python. They live only in profile data (§6.5, §9.2). If a task seems to need one, add a row to §15 with the engineering default and continue.
2. The **pure Dart set** — `dm_core_types`, `geo_salah_core`, `geo_salah_profiles`, `dm_civil_time`, `dm_hijri`, `dm_packages` — imports nothing from Flutter or the platform. CI enforces this with the import lint in `dm_lints`.
3. Engine changes keep the **golden corpus** green. A golden update is its own PR labelled `golden-update`, with the numeric diff and a written cause.
4. Never persist a local wall-clock time as a behaviour driver. Persist `utcMs` + `zoneId` + `tzdbVersion`; derive local at the edge with the **app's pinned TZDB**, never the OS TZDB. `[REQ-TIME-001]` `[REQ-TIME-020]`
5. Native alarm code (Kotlin/Swift) functions with **no Dart isolate alive**. It reads `SchedulePlan` (§7.7) and nothing else.
6. No raw coordinate (> 2 decimals) or persistent identifier in logs, telemetry, crash reports or analytics. `[REQ-PRIV-001]`
7. Confidence labels are **sealed types** (§6.2 `ConfidenceLabel`), never strings or display flags. `[REQ-DOM-010]`
8. Prefer the boring option. A new dependency needs a license check (§10.4), a maintenance check, and a line in §4 or `docs/adr/`.
9. Every PR: tests for the `REQ` it touches, ADR update if a contract changed, docs updated. No `TODO` without a tracked issue ID.
10. **Unknown beats invented.** When no defensible value exists, the UI shows `Unknown` with the reason.
11. **Write code at the bar in §17** (SOLID as concrete rules, strict typing per language, lint configs in CI). Disabling a lint rule requires a justification comment and a reviewer.

### 0.3 Reading paths

| Reader | Sections |
|---|---|
| Developer starting today | §0, §5.3–§5.4, §13 (ordered slices), §6–§9, §17, Appendices A–M |
| Product / BA | §1–§2, §18, §20–§22, §15 |
| Sharia board | §2, §6.4–§6.5, §9.2, §15, §23.2 |
| Operations / security | §9, §10, §11, §19, §25, §26 |

---

## 1. Context and problem statement

Users need three answers, offline, from a phone that actively fights background work: **when does the next prayer begin exactly here, why is that the displayed minute, and will this device actually alert me.** The architecture baseline got the shape right (local deterministic engine, native alarm layer, signed data packages, typed provenance) but left the dangerous details undefined — horizon/refraction semantics, day-boundary window, elevation usage, rounding direction, iOS scheduling horizon, Sharia governance. Those are where prayer apps are wrong by minutes. v1.1 closes them with testable decisions and provides the full solution context (users, operations, release, support, legal, cost) so a team can build and run it without further discovery.

### 1.1 Business model and stakeholders `[DECIDED · revisit D14]`

The app is free, ad-free and account-free. Funding assumption: sponsor/waqf-style funding by the owning organisation; optional voluntary donation `[DEFERRED V2]`; no monetisation that requires identity or data. Stakeholders: Business sponsor (scope, funding), Product owner, Architect (owns this document), Accuracy lead, Sharia board (§23.2), Mobile lead, Backend/data lead, QA lead, Security owner, Data-protection owner, Legal counsel, Support lead. Sign-off block: §23.4.

---

## 2. Product definition — what makes this app unique

The app competes on **verifiable trust**, not content. Five pillars; every feature must serve one.

| Pillar | User promise | Engineering expression |
|---|---|---|
| **P1 Explainable minute** | "Tap any time and see exactly how it was computed." | `Accuracy Passport`: each day resolves to a `CalculationId`; a time is addressed `<calcId>#<event>`. A shareable deep link carries the inputs so another device recomputes and compares (§6.4 ¶11). |
| **P2 Honest alarm** | "The app never says Ready when the OS might silence it." | `Athan Health` state machine with an `Unknown` state; `Athan Test` ends by asking "did you hear it?"; `HORIZON_ENDING` before the scheduled window runs out. |
| **P3 Typed truth** | "Estimated never looks like Verified." | Sealed `ConfidenceLabel` with a fixed mapping from engine output (§6.2); separate DB tables; prohibited-copy tests. Unknown Iqama is `Unknown`, not a made-up range. |
| **P4 Sky-synced theme** | "The app looks like the sky outside your window." | The same engine emits `SolarState` (altitude, 10 sky phases) that drives the design tokens (Appendix G). Reduced-motion / high-contrast / battery-saver fall back to static tokens. |
| **P5 Local-first privacy** | "No account, no ads, your location never leaves the phone." | Approximate location by default, country-level packages, separate backup-excluded places database, no advertising SDKs, egress allow-list test in CI. |

Non-goals: social feed, Quran reader (MVP), paid API dependency, user accounts, household coordination (ADR-021), map tile picker (MVP).

---

## 3. Governing invariants

Each is a requirement in Appendix F with at least one automated test: `REQ-DOM-001` ordering · `REQ-DOM-002` typed origin · `REQ-DOM-003` rounding once · `REQ-DOM-004` 1 ms determinism · `REQ-TIME-001` UTC storage · `REQ-TIME-002` culmination day · `REQ-TIME-020` app TZDB · `REQ-ALM-001` displayed minute · `REQ-ALM-002` no-Dart rescheduling · `REQ-ALM-003` Ready evidence · `REQ-PKG-001` atomic activation · `REQ-PKG-002` soft expiry · `REQ-PRIV-001` no coords/ids · `REQ-PRIV-002` pinning · `REQ-UX-001` labels · `REQ-GOV-001` religious approval gate.

---

## 4. Decision register (ADRs)

Format: context → decision → win / lose → status. Full ADRs in `docs/adr/` (template Appendix D); this index is binding.

### ADR-000 · DESIGN.md is normative `[DECIDED]`
EN/AR diverged on 26 engineering points. This document resolves them; AR becomes a controlled translation carrying `REQ` IDs; CI diffs `REQ` tags between the two. Win: one truth. Lose: translation upkeep.

### ADR-001 · Engine: pure Dart, FFI-shaped API, Rust only on trigger `[DECIDED]`
`geo_salah_core` is pure Dart; the public API takes/returns plain serialisable records (no object graphs, no callbacks). Native layers never calculate (ADR-002). Rust port trigger: standalone-watch (LTE) requirement, or a measured need to calculate inside a native extension; the golden corpus makes the port safe. Win: one hot-loop language, fast iteration, trivial desktop lab runs (`dart run`). Lose: engine cannot run in extensions — mitigated by the precomputed plan.

### ADR-002 · Native alarm layer consumes a precomputed `SchedulePlan` `[DECIDED]`
The application layer generates a 30-day plan (platform-fitted) and writes it to native-readable storage (§8). Kotlin/Swift schedule from it and re-read it on every system event. Win: survives reboot, direct boot, weeks unopened. Lose: a plan can go stale after travel or a profile change between opens — mitigated by `STALE_PLAN`, zone-change receivers and the horizon warning.

### ADR-003 · Altitude semantics: geometric topocentric altitude everywhere; dip = 0 default `[DECIDED] + [DEFAULT · D3]`
Sunrise/sunset solve `h_geo = −(refractionArcmin + semidiameterArcmin)/60 − dip`, defaults 34′ + 16′ = 0.8333°, `dip = 0`. Fajr/Isha solve `h_geo = −α` with no refraction and no dip. Elevation is recorded in provenance only. Profile-level `horizon.elevationPolicy ∈ {NONE, ABOVE_LOCAL_TERRAIN, AUTHORITY_TABLE}`, default `NONE`; the other two are `[DEFERRED V2]` and the engine returns `EngineFailure.unsupportedPolicy` for them. A property test asserts no refraction model is ever combined with the 34′ constant. Win: matches authority tables; no DEM. Lose: no terrain dip until V2.

### ADR-004 · Prayer-day boundary by solar culmination segments `[DECIDED]`
Day `D`: upper transit `T₀` with `localDate(T₀, zone) == D`; lower transits `A₋ < T₀ < A₊`. Ascending events (Imsak, Fajr, Sunrise) in `[A₋, T₀]`; Dhuhr = `T₀` + offset; descending (Asr, Maghrib, Isha) in `[T₀, A₊]`. Isha may have `localDate == D+1` (shown `+1`). Win: correct at high latitude in summer and in zones like `Pacific/Kiritimati`. Lose: slightly more code than civil-day search.

### ADR-005 · Per-event rounding, asymmetric error budget, alarm on displayed minute `[DEFAULT · D4]`
Default `rounding.default = ceil`, `rounding.sunrise = floor`. Entry-event budget `−0 s / +60 s`. Flag `nearRoundingBoundary` when `|raw − minute boundary| < 500 ms`. Win: never shows an entry before it has entered. Lose: up to 59 s later than nearest-minute tables; disclosed in Passport.

### ADR-006 · Reference mode is a profile field `[DEFAULT · D2]`
`referenceMode ∈ {EXACT_COORDINATE, AUTHORITY_REFERENCE_POINT}`, default `EXACT_COORDINATE`. With `AUTHORITY_REFERENCE_POINT` the engine calculates at the profile's reference point for the resolved area; MVP resolves by **country** (admin-1 polygons `[DEFERRED V1]`). The UI always shows the mode; the alarm follows the displayed mode.

### ADR-007 · `PrayerProfile` replaces `CountryProfile` `[DECIDED]`
Scope: `countries[]` (ISO 3166-1 alpha-2) resolved offline via the `country_polygons` package; `adminAreas[]` (ISO 3166-2) and `polygonsRef` `[DEFERRED V1]`. `authorityType ∈ {GOVERNMENT, RECOGNIZED_BODY, COMMUNITY_CONVENTION, ENGINE_DEFAULT}`. `Authority aligned` only for the first two with a `benchmarkReportId`. Non-overlap: exactly one profile per (point, date); overlap is a pipeline build error; no match ⇒ `engine.default` (`ENGINE_DEFAULT`, labelled `Calculated`, user told no local authority profile exists).

### ADR-008 · Sharia approval is a signed field; profiles are GitOps `[DECIDED]`
Profiles are YAML in `profiles/` with CODEOWNERS `@accuracy-lead` + `@sharia-reviewer`; the compiled `profiles.json` is signed as a TUF target. CI refuses `production` promotion without `approvals.religious` and a holdout report. Win: governance by construction, no authoring UI. Lose: reviewers use a Git PR flow (templates + a one-page guide in `profiles/README-for-reviewers.md`).

### ADR-009 · Distribution: static, signed, TUF-lite; no runtime prayer API `[DECIDED]`
Object storage + CDN; four metadata roles; monotonic `sequence`; signature envelope over JCS-canonical JSON (Appendix C). Rollback = new manifest with a higher sequence pointing at old content. Win: cheap, cacheable, resists freeze/rollback/CDN compromise. Lose: client-side verification code (small, specified).

### ADR-010 · Control plane: Go + Postgres, hexagonal, three endpoints `[DECIDED]`
Only non-static writes: corrections, aggregate telemetry, evidence summaries. Device attestation replaces accounts for rate limiting (`REQ-PRIV-007`). Win: boring, one binary. Lose: a fourth language (Go server/CLI only; Python lab/pipelines only).

### ADR-011 · Flutter architecture: feature-first Clean Architecture, Riverpod 3, drift, pigeon, go_router `[DECIDED]`
See §7 and §5.4. Win: typed platform contracts, reactive SQLite, testable use cases. Lose: code-gen steps (accepted).

### ADR-012 · Android: `SCHEDULE_EXACT_ALARM` + `setAlarmClock` + foreground media service; direct-boot aware `[DECIDED · revisit D5]`
No `USE_EXACT_ALARM` / `USE_FULL_SCREEN_INTENT`. Runtime `canScheduleExactAlarms()`; `POST_NOTIFICATIONS` runtime permission (API 33+). Inexact fallback is `Limited`. The exact-alarm → foreground-service start path is validated in slice S19 with its fallback.

### ADR-013 · iOS: AlarmKit on iOS 26+, local notifications on iOS 18; absolute-instant triggers; 64-slot budget `[DECIDED · revisit D6]`
Support matrix iOS 18 / 26 / 27. The notification path reports `Scheduled (unverifiable)` and never `Ready`. iOS notification Athan is a ≤ 29 s clip; AlarmKit long-audio behaviour validated in S19. Critical-alerts entitlement is **not** requested for MVP.

### ADR-014 · Location: approximate by default; context pinning beats the resolver `[DECIDED]`
Accept a fix if `horizontalAccuracyM ≤ 5000` and age ≤ 15 min. Offer precise location only when (a) the point is within 10 km of a tz or country boundary, or (b) the user opens Qibla with `horizontalAccuracyM > 1000`. Pinned/manual contexts are never auto-replaced.

### ADR-015 · Data sources: no DEM; tz polygons from timezone-boundary-builder; countries from Natural Earth; gazetteer from GeoNames `[DECIDED]`
`tz_polygons` (ODbL, attribution), `country_polygons` (Natural Earth admin-0 1:10m, public domain), `gazetteer` (GeoNames `cities15000` + Arabic/English alternate names, CC BY 4.0). Manual place = gazetteer search or typed coordinates; map picker `[DEFERRED V1]`.

### ADR-016 · Hijri: signed per-country announcements + tabular fallback flagged `Expected` `[DECIDED]`
Fallback = tabular ("Kuwaiti") Islamic calendar: 30-year cycle, leap years {2,5,7,10,13,16,18,21,24,26,29}, astronomical epoch (1 Muharram 1 AH = 15 July 622 CE Julian, JDN 1948439). The Umm al-Qura table itself is not shipped in MVP. Confirmed month starts arrive in the `hijri` package. Ramadan rules for launch countries are in MVP.

### ADR-017 · Privacy controls are mechanical `[DECIDED]`
Places in a separate `places.sqlite` excluded from backup; country-level packages; CDN logs without IP retention > 24 h; diagnostics round coordinates to 0.01°; CI egress allow-list test (`cdn.dailymuslim.app`, `api.dailymuslim.app` only); no crash SDK by default.

### ADR-018 · Sky-synced theme engine `[DECIDED]`
`dm_ui.SkyTheme.fromSolarState(SolarState)`; 10 sky phases with altitude bands and token values in Appendix G; WCAG 2.2 AA contrast enforced by a golden test per phase × light/dark × LTR/RTL.

### ADR-019 · Determinism and verification policy `[DECIDED]`
Cross-platform conformance: raw instants truncated to 1 ms must be identical. Golden corpus = the **engine's own outputs**, frozen after the lab confirms each within tolerance of Skyfield + JPL `de440s.bsp`: altitude 0.001°.
- **Altitude-defined events** (sunrise, sunset): time `tol_s = clamp(0.001° / |dh/dt|, 0.2 s, 60 s)`, with `dh/dt` in °/s at the event. It applies only where `|dh/dt| ≥ 0.001° / 60 s`. A slower crossing is *near-tangent*: the reference reports it as such, and it is graded explicitly, never with a capped tolerance.
- **Transit (Dhuhr):** not altitude-defined, so it has a fixed time tolerance of 0.2 s, set by the required accuracy and the reference's precision rather than by an angle rate. A configured Dhuhr offset is verified separately from the transit instant.

*(Amended 2026-10-21, §15 D26.)* SPA (Reda & Andreas 2008) is implemented **from the paper** — no NREL source code is ported. ΔT = Espenak–Meeus (2006) polynomials (`deltaTModel = "espenak-meeus-2006"`); UT1−UTC ignored (≤ 0.9 s, documented).

### ADR-020 · Iqama: sealed types; default Unknown `[DEFERRED V1.5]`
`IqamaInfo = Verified | RuleBased | Observed | Unknown`; no generic default.

### ADR-021 · Household coordination removed from roadmap `[DECIDED]`

### ADR-022 · Hosting: Cloudflare R2 + CDN for distribution; Google Cloud Run + Cloud SQL (Postgres 16) for the control plane; Terraform IaC `[DECIDED · revisit D13]`
Win: zero-egress object storage for a global free app; managed Postgres; one container. Lose: two vendors (acceptable — distribution and control plane are independent by design). Region `europe-west1`; no identity is stored, so residency concerns are limited to transient IP (§24).

### ADR-023 · Schema-first models with hand-written serializers, validated by fixtures `[DECIDED]`
JSON Schema in `schemas/` is the contract. Dart: hand-written `freezed` + `json_serializable`; Kotlin: `kotlinx.serialization`; Swift: `Codable`; Go: generated by `go-jsonschema`. CI round-trips `schemas/fixtures/*.json` through every language and validates with `ajv`. Win: idiomatic code everywhere. Lose: four model sets kept in sync (fixtures catch drift).

### ADR-024 · No TLS pinning; no SQLCipher `[DECIDED]`
TUF signatures make integrity independent of TLS; pinning causes outages. Local databases rely on platform file encryption (Android credential-encrypted storage, iOS Data Protection `complete`); no secrets stored. Win: fewer outages, no local key management. Lose: none material under the threat model.

---

## 5. System architecture

### 5.1 Context

```
                  ┌────────────────────────────────────────────────────────────────┐
                  │                      USER'S PHONE (trust: user)                │
                  │  ┌──────────────┐   ┌───────────────┐   ┌───────────────────┐  │
  OS location ───▶│  │ Flutter App  │──▶│ Geo Salah     │   │ Native Athan      │  │
  OS clock/tz ───▶│  │ (UI, use     │   │ Engine (Dart) │   │ Kotlin | Swift    │──┼─▶ Alarm / Notification
  Sensors ───────▶│  │ cases, store)│◀──│ pure, offline │   │ reads SchedulePlan│  │   Widgets (V1) / Watch (V1.5)
                  │  └──────┬───────┘   └───────────────┘   └─────────▲─────────┘  │
                  │         │ writes SchedulePlan + Snapshot          │            │
                  │         └──────────────────────────────────────────┘            │
                  └───────────────┬───────────────────────────────┬────────────────┘
          verify sig, stage, swap │ GET cdn.dailymuslim.app        │ POST api.dailymuslim.app (attested, consented)
                  ┌───────────────▼───────────────┐   ┌───────────▼────────────────┐
                  │ DISTRIBUTION PLANE (static)   │   │ CONTROL PLANE (Go)         │
                  │ R2 + CDN, TUF-lite metadata   │   │ corrections, telemetry agg │
                  └───────────────▲───────────────┘   └────────────────────────────┘
                                  │ publish (signed)
     ┌───────────────┐   ┌────────┴────────┐   ┌───────────────────┐   ┌──────────────────┐
     │ profiles/ Git │──▶│ gsctl (Go CLI)  │◀──│ Accuracy Lab (Py) │   │ data-pipelines   │
     │ YAML+evidence │   │ build·sign·push │   │ Skyfield/de440s   │   │ tz·country·gaz·  │
     │ CODEOWNERS    │   └─────────────────┘   │ benchmarks·holdout│   │ hijri·tzdata     │
     └───────────────┘                         └───────────────────┘   └──────────────────┘
```

### 5.2 Containers and ownership

| Container | Language | Owns | Must not |
|---|---|---|---|
| `apps/mobile` | Flutter/Dart | UX, use cases, orchestration, storage, package client, **plan building and `reconcile()` calls** | contain astronomy; call `AlarmManager`/`AlarmKit` directly |
| `packages/dm_core_types` | pure Dart | `Result<T,F>`, `Failure` base, `Clock`, `CivilDate`, failure/event codes | anything else |
| `packages/geo_salah_core` | pure Dart | ephemeris, solver, rules, rounding, Qibla, `SolarState`, provenance, **all `PrayerProfile` value types** | import Flutter, do I/O, read clocks |
| `packages/geo_salah_profiles` | pure Dart (depends on core) | YAML/JSON → `PrayerProfile` parsing, validation, resolver (point + date → profile) | contain rule values |
| `packages/dm_civil_time` | pure Dart | `TzDatabase` implementation over `package:timezone` with pinned data; tz polygon index; country polygon index | use OS tz |
| `packages/dm_hijri` | pure Dart | tabular calendar, announcements model, `HijriState` builder | — |
| `packages/dm_packages` | pure Dart | TUF-lite client, verify, stage, activate, rollback (network/file ports injected) | network implementation |
| `packages/dm_contracts` | Flutter | pigeon definitions + generated Dart/Kotlin/Swift; shared JSON models | logic |
| `packages/dm_ui` | Flutter | design system, tokens, SkyTheme, RTL-aware components | business logic |
| `packages/dm_lints` | Dart | shared `analysis_options.yaml`, custom import/layer lint | — |
| `apps/mobile/android/athan-core` | Kotlin | exact alarms, receivers, FGS audio, channels, probes, Glance widgets (V1), plan reader | calculate times |
| `apps/mobile/ios/AthanKit` | Swift (local SwiftPM package) | AlarmKit/UN adapters, probes, App Group snapshot, WidgetKit (V1), plan reader | calculate times |
| `profiles/` | YAML | profiles, evidence, approvals (extract to own repo before beta) | executable expressions |
| `profiles-holdout` (separate private repo) | JSON | frozen holdout benchmark set | be readable by the profile authors' CI job |
| `tools/gsctl` | Go | build/validate/sign/publish/promote packages, key ceremonies | — |
| `services/control-plane` | Go | corrections, telemetry aggregates, evidence summaries | prayer calculation, user identity |
| `lab/` | Python | reference harness, benchmark runner, discrepancy reports | write to production except approved artifacts |
| `data-pipelines/` | Python | `tz_polygons`, `country_polygons`, `gazetteer`, `hijri`, `tzdata` packages; `mosques` (V1.5) | — |

### 5.3 Monorepo layout `[DECIDED]`

```
daily_muslim/
├─ DESIGN.md · CLAUDE.md · README.md · melos.yaml · .tool-versions · LICENSES.md · SECURITY.md
├─ docs/
│  ├─ adr/                      # ADR-000..024 (template Appendix D)
│  ├─ runbooks/                 # §19.4 contents
│  ├─ release/                  # store checklists, declarations (§20)
│  ├─ governance/               # sharia-board.md, signoff.md, pia.md
│  └─ solution-architecture/    # baseline docs (background)
├─ schemas/                     # JSON Schema SSOT + fixtures/ (ADR-023)
│  ├─ prayer_profile.v1.schema.json         (Appendix A)
│  ├─ schedule_plan.v1.schema.json          (Appendix B)
│  ├─ snapshot.v1.schema.json               (Appendix I)
│  ├─ tuf_metadata.v1.schema.json           (Appendix C)
│  ├─ calculation_trace.v1.schema.json      (Appendix M)
│  ├─ telemetry_aggregate.v1.schema.json    (Appendix L)
│  ├─ event_log.v1.schema.json              (Appendix J)
│  ├─ hijri_package.v1.schema.json · gazetteer_package.v1.schema.json · athan_audio_manifest.v1.schema.json   (§9.5)
│  ├─ tz_polygons.v1.ksy · country_polygons.v1.ksy   (binary layouts, §9.5)
│  └─ fixtures/
├─ packages/  dm_core_types/ geo_salah_core/ geo_salah_profiles/ dm_civil_time/ dm_hijri/ dm_packages/ dm_contracts/ dm_ui/ dm_lints/
├─ apps/mobile/
│  ├─ lib/ app/ (bootstrap, di.dart, router, theme host)  core/ (env, logging adapters)  features/<feature>/{domain,application,data,presentation}  l10n/ (ARB ar, en)
│  ├─ assets/ packages/ (bundled seed packages)  athan/ (audio .m4a)  oem_guidance.json
│  ├─ android/athan-core/   ios/AthanKit/
│  └─ test/  integration_test/ (patrol)
├─ profiles/ eg/ sa/ ae/ engine/  README-for-reviewers.md  CODEOWNERS
├─ tools/gsctl/   services/control-plane/   lab/   data-pipelines/   infra/ (terraform)
└─ .github/workflows/  ci-dart  ci-android  ci-ios  ci-go  ci-lab  ci-schemas  profiles-gate  release-package  deploy-control-plane
```

### 5.4 Toolchain and dependency versions `[DECIDED]`

Rule: the values below are **floors**. In slice S01 the implementer pins the exact latest stable ≥ floor into `.tool-versions`, `pubspec.lock`, the Gradle version catalog, `Package.resolved`, `go.sum`, `uv.lock`, and never floats afterwards. Upgrades are their own PR.

| Area | Tool / library | Floor |
|---|---|---|
| Mobile | Flutter stable / Dart | 3.35 / 3.9 |
| Dart deps | riverpod + riverpod_generator 3.0 · drift 2.28 · pigeon 26 · go_router 16 · freezed 3 · json_serializable 6.9 · timezone 0.10 · cryptography 2.7 · crypto 3 · archive 4 · geolocator 14 · permission_handler 12 · intl 0.20 · patrol 3 · very_good_analysis 9 · melos 7 · glados 1 | as listed |
| Android | Kotlin 2.2 · AGP 8.11 · Gradle 8.14 · compileSdk/targetSdk 36 · minSdk 26 · kotlinx.serialization 1.9 · coroutines 1.10 · WorkManager 2.10 · Glance 1.1 · detekt 1.23 · ktlint 1.5 · JUnit 5.13 · Robolectric 4.15 | as listed |
| iOS | Xcode 26 · Swift 6.2 · deployment target 18.0 · SwiftLint 0.59 · SwiftFormat 0.56 | as listed |
| Go | Go 1.25 · sqlc 1.29 · goose 3.24 · zerolog 1.34 · otel-go 1.37 · golangci-lint 2.4 · go-jsonschema 0.20 | as listed |
| Python | Python 3.13 · uv 0.8 · skyfield 1.53 · jplephem 2.22 · `de440s.bsp` (1849–2150) · ruff 0.13 · mypy 1.17 · pydantic 2.11 · hypothesis 6 · shapely 2.1 | as listed |
| Schemas | ajv-cli 5 · check-jsonschema 0.33 | as listed |
| CI | GitHub Actions; `macos-15` runners for iOS; own device lab (§18.9) + Firebase Test Lab for Android smoke | — |

---

## 6. Domain layer — Geo Salah Engine (`packages/geo_salah_core`)

### 6.1 Package structure

```
lib/geo_salah_core.dart           # public API only
lib/src/
  api/        engine.dart (GeoSalahEngine impl)  qibla.dart  solar_state.dart
  model/      observer.dart  event.dart  rule.dart  profile.dart  result.dart  provenance.dart  flags.dart  confidence.dart  failure.dart
  astro/      spa.dart  delta_t.dart  interpolation.dart  topocentric.dart  transit.dart
  solver/     brent.dart  bracket.dart  culmination_segments.dart
  rules/      altitude_rule.dart  transit_rule.dart  shadow_rule.dart  horizon_rule.dart  interval_rule.dart  high_latitude.dart
  policy/     rounding.dart  adjustments.dart  ordering_guard.dart  confidence_mapper.dart
  geo/        geodesic.dart (Karney, WGS84)  kaaba.dart (versioned)
  trace/      calculation_id.dart  trace_builder.dart
bin/bench.dart                    # stdin JSONL {observer, profileId, day} → stdout JSONL DayResult (lab contract)
```

### 6.2 Core types (contract — `freezed`, immutable, JSON-serialisable)

```dart
// ── dm_core_types ─────────────────────────────────────────────────────────────
sealed class Result<T, F> { const factory Result.ok(T value) = Ok; const factory Result.err(F failure) = Err; }
abstract interface class Clock { int nowUtcMs(); }
final class CivilDate { final int year, month, day; /* interpreted in Observer.zoneId; JSON "YYYY-MM-DD" */ }

// ── geo_salah_core/model ──────────────────────────────────────────────────────
enum ObserverSource { device, pinned, manual, mosque, benchmark }
enum ElevationDatum { wgs84Ellipsoid, egm2008, unknown }
enum ElevationSource { gnss, manual }            // dem [DEFERRED V2]
final class ElevationSample { final double valueM; final ElevationDatum datum; final ElevationSource source;
  final double? verticalAccuracyM; final String? datasetVersion; final int observedUtcMs; }

final class Observer { final double latitudeDeg, longitudeDeg; final double? horizontalAccuracyM;
  final ElevationSample? elevation;              // provenance only (ADR-003)
  final String zoneId; final ObserverSource source; }

/// Port implemented by dm_civil_time. The engine depends on this interface only.
abstract interface class TzDatabase { String get version; int offsetSecondsAt(String zoneId, int utcMs); }

enum PrayerEvent { imsak, fajr, sunrise, dhuhr, asr, maghrib, isha }   // duha/midnight/lastThird [DEFERRED V1.5]

sealed class EventRule {
  const factory EventRule.solarAltitude({required double degrees}) = SolarAltitudeRule;          // geometric; no refraction, no dip
  const factory EventRule.transit({Duration offset}) = TransitRule;
  const factory EventRule.shadowFactor({required int k}) = ShadowFactorRule;                      // k ∈ {1,2}
  const factory EventRule.horizon({double refractionArcmin = 34, double semidiameterArcmin = 16}) = HorizonRule; // dip from profile.elevationPolicy
  const factory EventRule.intervalAfter({required PrayerEvent base, required Duration duration}) = IntervalAfterRule;   // base: maghrib
  const factory EventRule.intervalBefore({required PrayerEvent base, required Duration duration}) = IntervalBeforeRule; // base: fajr (imsak)
}
enum RoundingMode { ceil, floor, nearest }
enum HorizonElevationPolicy { none, aboveLocalTerrain /*V2*/, authorityTable /*V2*/ }
enum ReferenceMode { exactCoordinate, authorityReferencePoint }
enum AuthorityType { government, recognizedBody, communityConvention, engineDefault }
enum ProfileStatus { draftUnverified, candidate, approved, retired }

sealed class HighLatitudeMethod {
  const factory HighLatitudeMethod.anglePortion() = AnglePortion;                         // α/60 × night
  const factory HighLatitudeMethod.middleOfNight() = MiddleOfNight;
  const factory HighLatitudeMethod.seventhOfNight() = SeventhOfNight;
  const factory HighLatitudeMethod.nearestLatitude({required double latDeg}) = NearestLatitude;
  const factory HighLatitudeMethod.nearestValidDay({required int maxDays}) = NearestValidDay;
  // authorityTable [DEFERRED V2]
}

final class ReferencePoint { final String area /* ISO 3166-1 alpha-2 (MVP) or ISO 3166-2 */; final double lat, lon; }
final class PrayerProfile {
  final String profileId, version; final ProfileStatus status; final CivilDate effectiveFrom; final CivilDate? effectiveTo;
  final List<String> countries; final String authorityName; final AuthorityType authorityType; final ReferenceMode referenceMode;
  final List<ReferencePoint> referencePoints; final Map<PrayerEvent, EventRule> rules; final HorizonElevationPolicy elevationPolicy;
  final List<HighLatitudeMethod> highLatitudeChain; final RoundingMode roundingDefault; final Map<PrayerEvent, RoundingMode> roundingOverrides;
  final Map<PrayerEvent, int> perEventMinutes; final int maxAbsMinutes; final Map<PrayerEvent, EventRule> ramadanRules;
  final String? benchmarkReportId; final bool hasReligiousApproval; final int minEngineSchema; }

enum HijriConfidence { confirmed, expected, userOverride }
final class HijriDate { final int year, month, day; }
/// A Hijri day begins at Maghrib. For prayer day D: dateAtDawn = hijri(D) governs Imsak/Fajr (the fasting day);
/// dateAtNight = hijri(D+1) governs Isha (the night following sunset(D)).
final class HijriState { final HijriDate dateAtDawn, dateAtNight; final HijriConfidence confidence; final String? packageVersion;
  bool get ramadanAtDawn => dateAtDawn.month == 9; bool get ramadanAtNight => dateAtNight.month == 9; }

enum NoEventReason { polarDay, polarNight, twilightAbsent, asrUndefined, chainExhausted }
sealed class EventOrigin {
  const factory EventOrigin.primary() = Primary;
  const factory EventOrigin.fallback(HighLatitudeMethod method) = Fallback;
  const factory EventOrigin.noEvent(NoEventReason reason) = NoEvent;
}
enum ResultFlag { nearRoundingBoundary, highLatitudeFallback, lowLocationAccuracy, dstTransitionDay, staleTzdb, hijriExpected,
  referenceModeAuthorityPoint, manualCoordinateResolution, zoneBoundaryProximity, noLocalProfile }

/// Fixed mapping (confidence_mapper.dart) — REQ-DOM-050:
///  primary ∧ status==approved ∧ authorityType∈{government,recognizedBody} ∧ benchmarkReportId≠null → authorityAligned(reportId)
///  primary (otherwise)                                                                      → calculated
///  fallback(method)                                                                         → estimated(rangeMinutes = max(5, perturbationMinutes(method)))
///  noEvent(reason)                                                                          → unknown(reason)
///  verified / observed are produced only by V1.5 data types (mosque, Iqama), never by the engine.
sealed class ConfidenceLabel {
  const factory ConfidenceLabel.calculated() = Calculated;
  const factory ConfidenceLabel.authorityAligned({required String benchmarkReportId}) = AuthorityAligned;
  const factory ConfidenceLabel.verified({required String sourceRef, required int freshUntilUtcMs}) = Verified;
  const factory ConfidenceLabel.estimated({required int rangeMinutes}) = Estimated;
  const factory ConfidenceLabel.observed({required int count, required int lastSeenUtcMs}) = Observed;
  const factory ConfidenceLabel.unknown({required String reasonCode}) = Unknown;
}

final class PrayerTime { final PrayerEvent event; final int rawUtcMs; final int displayedUtcMs; final int dayOffset;
  final EventOrigin origin; final ConfidenceLabel confidence; final Set<ResultFlag> flags; }

enum AdjustmentKind { perEventOffset, ramadanRuleReplacement, highLatitudeFallback, rounding }
final class AdjustmentStep { final PrayerEvent event; final AdjustmentKind kind; final int deltaMs; final String reason; final String? evidenceId; }
final class Provenance { final String engineVersion; final String deltaTModel; final String profileId, profileVersion; final String tzdbVersion;
  final String inputsHash; final HijriConfidence hijriConfidence; final List<AdjustmentStep> adjustmentTrace; }
final class DayResult { final CivilDate day; final String calculationId; final List<PrayerTime> times; final Provenance provenance; }

sealed class EngineFailure {
  const factory EngineFailure.orderingViolation(String traceJson) = OrderingViolation;
  const factory EngineFailure.invalidProfile(String reason) = InvalidProfile;
  const factory EngineFailure.unsupportedPolicy(String field) = UnsupportedPolicy;
  const factory EngineFailure.unsupportedZone(String zoneId) = UnsupportedZone;
}

final class QiblaResult { final double bearingTrueDeg; final double distanceKm; final String kaabaRefVersion; }
enum SkyPhase { night, astronomicalDawn, nauticalDawn, civilDawn, goldenMorning, day, goldenEvening, civilDusk, nauticalDusk, astronomicalDusk }
final class SolarState { final double altitudeDeg, azimuthDeg; final bool rising; final SkyPhase phase; final double phaseProgress; }
```

### 6.3 Public API `[REQ-DOM-020]`

```dart
abstract interface class GeoSalahEngine {
  Result<DayResult, EngineFailure> calculateDay({required Observer observer, required PrayerProfile profile, required CivilDate day,
      required TzDatabase tzdb, required HijriState hijri});
  Result<List<DayResult>, EngineFailure> calculateRange({required Observer observer, required PrayerProfile profile, required CivilDate from,
      required int days /* 1..400 */, required TzDatabase tzdb, required HijriState Function(CivilDate) hijriFor});
  QiblaResult calculateQibla(Observer observer);
  SolarState solarState({required Observer observer, required int utcMs});
}
```
No I/O, clocks or randomness inside; `nowUtcMs` is always a parameter.

### 6.4 Algorithm specification

1. **Ephemeris** — SPA (Reda & Andreas 2008) implemented from the paper: apparent geocentric RA/δ, equation of time. ΔT from Espenak–Meeus 2006 polynomials; both recorded in provenance.
2. **Performance** `[REQ-PERF-001]` — δ and EoT sampled at −12 h, 0 h, +12 h, +24 h, +36 h UTC around each day; cubic Hermite with central-difference derivatives inside the solver; the converged root is refined with one exact SPA evaluation. One-year `calculateRange` < 500 ms (release, median of 5) on **Samsung Galaxy A50 / Android 11**; < 150 ms on Pixel 8.
3. **Topocentric correction** — observer latitude / hour angle / δ → geometric altitude; solar parallax applied for consistency.
4. **Culmination segments** (ADR-004) — transit from EoT and longitude, Newton-refined; lower transits ±12 h, refined.
5. **Root solver** — bracketed Brent on `altitude(t) − target`, internal tolerance 100 ms; result truncated to 1 ms. No sign change ⇒ `NoEvent`; never extrapolate.
6. **Rules** — per §6.2. Asr: `h = arccot(k + tan|φ − δ(T₀)|)` solved in `[T₀, A₊]`; if `90 − |φ − δ| ≤ 0` ⇒ `NoEvent(asrUndefined)`. **Ramadan rule replacement**: when the governing flag is true (`ramadanAtNight` for Isha; `ramadanAtDawn` for Imsak/Fajr), `profile.ramadanRules[event]` **replaces** the event's rule at this step; logged as `ramadanRuleReplacement`.
7. **High latitude** — ordered chain. **Night for Fajr(D)/Imsak(D) = sunset(D−1) → sunrise(D); night for Isha(D) = sunset(D) → sunrise(D+1)**, both in UTC. Methods that need a night are skipped when sunrise/sunset are absent; `NoEvent(chainExhausted)` when the chain ends. `[REQ-DOM-002]`
8. **Additive adjustments** — `perEventMinutes` (|value| ≤ `maxAbsMinutes`), logged as `perEventOffset` with evidence ID.
9. **Rounding** — per-event mode, applied last; near-boundary flag. `[REQ-DOM-003]`
10. **Ordering guard** — asserts `REQ-DOM-001` on displayed instants (ties allowed only between polar fallbacks and flagged); violation ⇒ `Err(orderingViolation)`.
11. **Calculation ID** — `inputsHash = sha256(canonicalJson({lat: round6, lon: round6, zoneId, day, profileId, profileVersion, hijri: {dateAtDawn, dateAtNight, confidence}}))` (JCS canonical JSON); `calculationId = "GS-" + base32(RFC 4648, upper, no padding, first 10 bytes of sha256(inputsHash|engineVersion|deltaTModel|tzdbVersion))` → 16 characters. One ID per `DayResult`; a time is addressed `<calcId>#<event>`. Deep link `dailymuslim://calc/<calcId>?i=<base64url(inputs JSON)>`: the receiver recomputes locally, compares IDs and shows "computed with a different engine/profile/TZDB version" on mismatch — it never trusts remote values.
12. **SolarState** — SPA altitude at `utcMs`; `rising = altitude(t + 60 s) > altitude(t)`; phase from Appendix G bands; `phaseProgress = clamp((alt − from)/(to − from), 0, 1)`; polar: `day` if altitude never < −0.833° that date, `night` if never > −18°.

### 6.5 Prayer profile (data, not code)

```yaml
profileId: eg.egas.standard            # <iso2>.<authority>.<variant>; engine.default is the fallback profile
schemaVersion: 1
version: 2026.10.1
status: DRAFT_UNVERIFIED
effectiveFrom: 2026-11-01
effectiveTo: null
scope: { countries: [EG], adminAreas: [], polygonsRef: null }
authority: { name: "Egyptian General Authority of Survey convention", type: GOVERNMENT }
referenceMode: EXACT_COORDINATE
referencePoints: []
rules:
  fajr:    { type: solarAltitude, degrees: 19.5 }          # illustrative — DRAFT_UNVERIFIED
  sunrise: { type: horizon }
  dhuhr:   { type: transit, offsetMinutes: 0 }
  asr:     { type: shadowFactor, k: 1 }
  maghrib: { type: horizon }
  isha:    { type: solarAltitude, degrees: 17.5 }          # illustrative — DRAFT_UNVERIFIED
  imsak:   null
horizon: { elevationPolicy: NONE }
highLatitude: { chain: [anglePortion, { nearestLatitude: { latDeg: 48.5 } }] }
rounding: { default: ceil, sunrise: floor }
adjustments: { perEventMinutes: {}, maxAbsMinutes: 3, ramadan: {} }
evidence: { sources: [{ title: "...", url: "...", retrievedOn: 2026-10-01, sha256: "..." }], benchmarkSet: eg-2026-q4, holdoutReport: null, benchmarkReportId: null }
approvals: { religious: null, accuracy: null }
compatibility: { minEngineSchema: 1, minAppVersion: "1.0.0" }
```
Seed profiles created in S07 as `DRAFT_UNVERIFIED`: `eg.egas.standard`, `sa.ummalqura.standard` (Isha `intervalAfter maghrib 90 min`, Ramadan `120 min`), `ae.awqaf.standard`, and `engine.default` (`ENGINE_DEFAULT`, Fajr/Isha 18°, k = 1, scope: all). Values are **illustrative** until evidence and approvals exist; they load only on `dev`/`lab` channels. Formal schema: Appendix A. No executable expressions.

### 6.6 Qibla `[REQ-DOM-030]`
Karney geodesic on WGS84 (port of GeographicLib core, MIT); Kaaba `21.422487°N, 39.826206°E`, `kaabaRefVersion = "2026.1"`. Bearing relative to **true north**. Heading, true-north conversion and declination are native (§8): iOS `CLHeading.trueHeading`; Android rotation vector + `GeomagneticField.declination` (WMM shipped by the OS). Tolerance vs reference 0.01°.

### 6.7 Testing the domain `[REQ-TEST-001..005]`

| Kind | What |
|---|---|
| Golden | `test/golden/<city>/<profileId>/<year>.json`: engine outputs frozen after lab confirmation (ADR-019) for the Appendix H cities × dates. Exact `rawUtcMs` equality. |
| Property | ordering; continuity across adjacent days (< 3 min jump except fallback switch); longitude-shift equivalence; zone-independence of raw instants; `NoEvent` chain exhaustiveness; refraction/dip exclusivity; rounding idempotence. |
| Differential | lab compares engine output to Skyfield/de440s nightly within ADR-019 tolerance. |
| Perturbation | runtime ±1 km N/E perturbation per event → Passport sensitivity line ("±1 km changes this by ≤ N s"). |
| Edge | Tromsø, Longyearbyen, Utqiaġvik, Reykjavik, Kiritimati, Quito, Suva/date line; polar day/night transitions; Casablanca Ramadan DST. |

Discrepancy report fields: `{caseId, city, lat, lon, day, event, engineVersion, profileId, profileVersion, tzdbVersion, referenceUtcMs, engineRawUtcMs, deltaMs, toleranceMs, classification ∈ {ENGINE_BUG, PROFILE_ERROR, REFERENCE_AMBIGUITY, TOLERANCE_NOISE, CIVIL_TIME, UNKNOWN}, decision, owner, linkedChange}`; `UNKNOWN` above tolerance blocks promotion.

---

## 7. Mobile application (`apps/mobile`)

### 7.1 Layering and dependency direction

```
presentation ──▶ application ──▶ domain ◀── data
   (widgets,        (use cases,     (entities,     (repositories impl,
    riverpod         orchestration,  sealed types,  drift, package client,
    providers)       policies)       interfaces)    pigeon platform adapters)
```
- A feature's `domain` may depend on the pure Dart packages; never on Flutter.
- `application` returns `Result<T, Failure>` (`dm_core_types`); no exceptions cross layer boundaries. `[REQ-ERR-001]`
- `presentation` state = sealed `UiState` classes (§18.4) rendered exhaustively (`switch` without `default`).
- DI: Riverpod providers per feature; platform adapters bound in `app/di.dart` with `overrideWith` for tests.
- Routing: `go_router` typed routes; deep-link allow-list (`/calc/<id>`, `/health`, `/qibla`) validated before navigation; custom scheme `dailymuslim://` only (HTTPS links `[DEFERRED V1]`). `[REQ-SEC-010]`

### 7.2 Feature modules (MVP unless marked)

| Feature | Responsibility | Key use cases |
|---|---|---|
| `onboarding` | consent, location choice (approximate/precise/manual), profile resolution, first calculation | `CompleteFirstRun` |
| `contexts` | location contexts (current, pinned, manual), resolver, zone + country + profile resolution | `ResolveObserverContext`, `PinPlace`, `SearchGazetteer` |
| `schedule` | day/range calculation, caching, `SchedulePlan` + `Snapshot` generation, `reconcile()` calls | `RefreshSchedule`, `BuildSchedulePlan`, `ReconcileAthan` |
| `home` | next prayer, countdown, day timeline, confidence badges, Sky theme host | — |
| `passport` | Accuracy Passport, trace rendering, Calculation ID share/import | `ResolveCalculationId`, `ImportCalculationLink` |
| `athan` | settings, Athan Health, Athan Test, sounds, pre-reminders, receipts drain | `RunAthanTest`, `ReadHealth`, `ApplyAthanSettings`, `DrainReceipts` |
| `qibla` | bearing + heading quality + calibration guidance | `ObserveHeading` |
| `packages` | TUF-lite sync, activation, rollback, change notes | `SyncPackages`, `RollbackPackage` |
| `settings` | language, digits, theme mode, privacy, diagnostics export, attributions | `ExportDiagnosticBundle` |
| `hijri` | date display, Ramadan state, override | `OverrideHijriDay` |
| `travel` `[V1]` | zone-change detection (no background location), confirmation policy | `HandleZoneChange` |
| `widgets` `[V1]` | snapshot consumers (native) | — |
| `mosque`, `iqama` `[V1.5]` | per ADR-020 | — |

Diagnostic bundle = zip of `events.jsonl`, `health.json`, `plan_redacted.json`, `packages.json`, `device.json{model, os, appVersion}`; coordinates rounded to 0.01°; contents shown before export. `[REQ-PRIV-005]`

### 7.3 Storage (drift / SQLite) — two database files

`dm.sqlite` (backed up) and `places.sqlite` (**excluded from backup**: Android `dataExtractionRules` + `fullBackupContent`, iOS `isExcludedFromBackup`) `[REQ-PRIV-003]`.

```
places.sqlite:
  location_contexts(id PK, kind ∈ {current,pinned,manual}, lat, lon, h_acc_m, zone_id, country, source, pinned BOOL, label, created_utc, last_used_utc)
  elevation_samples(id PK, context_id FK, value_m, datum, source, v_acc_m, dataset_version, observed_utc)        -- provenance only
dm.sqlite:
  active_packages(type PK, version, sequence, sha256, source ∈ {bundled,downloaded}, activated_utc, previous_version)
  package_files(type, version, path, sha256, state ∈ {staged,active,previous,garbage})
  day_results(context_id, day, profile_id, profile_version, tzdb_version, calculation_id, json_times, created_utc,
              PK(context_id, day, profile_id, profile_version, tzdb_version))
  provenance(calculation_id PK, inputs_hash, engine_version, delta_t_model, adjustment_trace_json, created_utc)
  schedule_plans(generation PK, context_id, json_plan, horizon_end_utc, created_utc, state ∈ {desired,applied,superseded})
  alarm_receipts(entry_id PK, generation, state ∈ {scheduled,presented,dismissed,unknown}, platform_ref, updated_utc)
  athan_test_results(id PK, started_utc, presented_by_os BOOL NULL, heard_by_user BOOL NULL, platform_path, notes)
  gazetteer(id PK, name, ascii_name, alt_names_json, country, admin1, lat, lon, population, zone_id, name_norm INDEX)   -- imported at package activation
  hijri_months(country, hijri_year, hijri_month, gregorian_start, status, source_url, PK(country, hijri_year, hijri_month))
  event_log(seq PK, utc, level, code, attrs_json)        -- validated against Appendix J; coordinates impossible by schema
  settings(key PK, value_json)                             -- keys: Appendix K
```
Rules: `day_results` rows are immutable; a new profile/TZDB version writes new rows and a change-note entry. Migrations forward-only; package pointer downgrade-safe. Retention `[REQ-DATA-001]`: `day_results`/`provenance` > 400 days purged; `alarm_receipts`, `athan_test_results` > 90 days; `schedule_plans` keep last 3 generations; `event_log` ring ≤ 5 000 rows; package `garbage` after 7 days; purge job on app open at most daily.

### 7.4 Package store, bundled seed, sync policy
`dm_packages`: fetch `timestamp` → `snapshot` → `targets`; verify chain against the embedded `root`; accept only strictly higher `sequence` `[REQ-PKG-005]`; download by content hash to `staged/`; verify sha256 + schema + `compat` `[REQ-PKG-006]`; **single transaction** flips `active_packages` and marks the previous version; GC after 7 days. Expired `timestamp` ⇒ `FRESHNESS_UNVERIFIED` warning only `[REQ-PKG-002]`. `[REQ-PKG-003]` The binary bundles the latest `lab`-approved versions of `prayer_profiles`, `tzdata`, `tz_polygons`, `country_polygons`, `gazetteer`, `hijri`, `athan_audio_manifest` under `assets/packages/`; first launch imports them as `source=bundled`. `[REQ-PKG-004]` Sync on app open at most every 6 h; metadata (≤ 50 kB) on any network; payloads > 2 MB only on unmetered unless `priority: urgent`; never in the alarm path. Dev root keys (3, threshold 2) are generated in S01 — public keys committed, private keys in CI secrets; the production root is created in the S27 ceremony.

### 7.5 Location resolver, zones, countries (ADR-014, `REQ-PRIV-002`)
Resolver acts only on the `current` context: fresh fix (age ≤ 15 min, accuracy ≤ 5 000 m) → last known (< 24 h, flagged stale) → prompt manual. Pinned/manual contexts are immutable until the user changes them. Zone via tz polygon index; no containing polygon ⇒ nearest within 50 km, else `Etc/GMT±h` from longitude, flagged `manualCoordinateResolution`. Country via `country_polygons`; none ⇒ `engine.default` with `noLocalProfile`. `zoneBoundaryProximity` within 10 km of a tz/country boundary is the only resolver trigger for the precise-location offer. Mock location (`isMock` / `isSimulatedBySoftware`) recorded in diagnostics only. Plugins: `geolocator`, `permission_handler`.

### 7.6 Clock integrity `[REQ-TIME-010]`
Compare device clock with the GNSS fix time (when available) and the CDN `Date` header (when online); skew > 60 s ⇒ `Needs attention` banner. Never reject packages or calculations by clock.

### 7.7 `SchedulePlan` v1 — the Dart ↔ native contract (schema Appendix B)

```json
{
  "schemaVersion": 1,
  "generation": 42,
  "contextId": "ctx_8f3…",
  "zoneId": "Africa/Cairo",
  "tzdbVersion": "2026c",
  "generatedAtUtcMs": 1761000000000,
  "horizonEndUtcMs": 1763600000000,
  "entries": [
    {
      "id": "a1b2c3d4e5f60718",             // lowercase hex of sha256(UTF-8 "contextId|day|event|kind")[0:16] — deterministic
      "day": "2026-10-21",
      "event": "FAJR",
      "kind": "ATHAN",                       // ATHAN | PRE_REMINDER | IMSAK | HORIZON_WARNING
      "fireAtUtcMs": 1761021660000,          // = displayedUtcMs (REQ-ALM-001)
      "displayLocal": "04:41",               // pre-rendered in the plan's zone
      "title": { "ar": "أذان الفجر", "en": "Fajr Adhan" },
      "body":  { "ar": "…", "en": "…" },
      "soundId": "athan_fajr_v1",
      "priority": 1                          // iOS 64-slot fitting: ATHAN 1 > IMSAK 2 > PRE_REMINDER 3; HORIZON_WARNING always kept
    }
  ],
  "policy": { "locale": "ar", "respectDnd": false, "vibrate": true, "fullAthanAndroid": true, "iosClipSeconds": 29,
              "preReminderMinutes": 0, "snoozeMinutes": 5 }
}
```
Horizon `[REQ-ALM-010]`: Android 30 days of entries; iOS as many days as the 64 budget allows after priority fitting (≈ 12 days of 5 Athans without reminders). `HORIZON_WARNING` is emitted on both platforms (iOS 24 h, Android 48 h before `horizonEndUtcMs`). Pre-reminder is global, `∈ {0,5,10,15,30}` min, default 0 (one entry per Athan when > 0); snooze 5 min, once `[REQ-ALM-042]`. Native renders `title/body[policy.locale]` falling back to `en`.

`Snapshot` v1 (Appendix I): next 48 h of displayed times, labels and the sky-phase timeline; written alongside the plan; widgets never recalculate.

### 7.8 Platform contracts (pigeon, `dm_contracts`)

```dart
enum HealthState { ready, limited, notReady, unknown }
enum HealthReason { needsNotificationPermission, needsExactAlarmPermission, needsAlarmKitAuthorization, mutedChannel, batteryRestricted,
  stalePlan, horizonEnding, failedTest, clockSkew, noSoundAsset, inexactFallback, unverifiableDelivery, forceStoppedPreviously }
class ProbeResult { String name; bool? positive /* null = platform cannot tell */; String? detail; }
class AthanHealthReport { HealthState state; List<HealthReason> reasons; List<ProbeResult> probes; int evaluatedAtUtcMs;
  String platformPath /* androidExact | androidInexact | iosAlarmKit | iosNotification */; }
enum ReceiptState { scheduled, presented, dismissed, unknown }
class AlarmReceipt { String entryId; int generation; ReceiptState state; String? platformRef; int utcMs; }
class ClockSkewInfo { int deviceUtcMs; int? gnssUtcMs; int? gnssAgeMs; }
class LocationCapability { bool preciseGranted; bool approximateGranted; bool servicesEnabled; }
enum SystemEventKind { boot, lockedBoot, timeChanged, timezoneChanged, packageReplaced, permissionChanged, testFired, planApplied }
class SystemEvent { SystemEventKind kind; int utcMs; String? detail; }
class HeadingSample { double magneticDeg; double? trueDeg; double accuracyDeg; int utcMs; }

@HostApi() abstract class AthanSchedulerApi {
  void reconcile(String schedulePlanJson);              // idempotent by entry id + generation
  void cancelGenerationsBelow(int generation);
  AthanHealthReport health();
  void startTest(String testId, int fireInSeconds, String soundId);
  List<AlarmReceipt> drainReceipts();                   // REQ-ALM-041
  List<SystemEvent> drainSystemEvents();
}
@HostApi() abstract class PlatformInfoApi { ClockSkewInfo clockInfo(); LocationCapability locationCapability(); }
@HostApi() abstract class SnapshotApi { void write(String snapshotJson); }
@HostApi() abstract class HeadingApi { void start(); void stop(); }           // samples on EventChannel "dm/heading"
@FlutterApi() abstract class AthanEventsApi { void onSystemEvent(SystemEvent e); }   // best-effort while Dart is alive; native also appends to events.jsonl
```

### 7.9 Design system and Sky theme (`dm_ui`)
- Tokens (Appendix G): `color.*`, `space.*` (4-pt grid), `radius.*`, `type.*`, `motion.*`. Sky-driven roles apply to the Home surface; content surfaces use static roles (readability first).
- `SkyTheme.fromSolarState(s)` returns gradient stops, accent and on-surface colours; WCAG 2.2 AA contrast enforced; golden test per phase × light/dark × LTR/RTL. `[REQ-UX-010]`
- Typography: `IBM Plex Sans Arabic` + `Inter` (OFL); numerals follow locale with override.
- RTL: all layouts `start/end`; mirror-safe icons; `Directionality.rtl` goldens. `[REQ-UX-030]`
- Accessibility: semantics on every time row (event, time, confidence), ≥ 44 pt targets, dynamic type to 200 %, reduced motion disables sky animation, non-colour status cues. `[REQ-UX-020]`
- `ConfidenceChip(label: ConfidenceLabel)` — sealed input, no free text. `[REQ-UX-040]`

### 7.10 Screens — inventory and states in §18.4.

### 7.11 Localisation
ARB-based `ar` (Egyptian tone) and `en`; copy is a product decision kept out of code; locale never alters calculation semantics `[REQ-DOM-040]`; status copy lives in shared constants guarded by prohibited-word tests (§18.5).

---

## 8. Native platform layers

### 8.1 Android — `athan-core` (Kotlin, minSdk 26, targetSdk 36)

```
athan-core/
├─ plan/        PlanStore (device-protected storage: <dpsContext.filesDir>/plan/plan.json, write .tmp + atomic rename), PlanReader,
│               EventsStore (<…>/plan/events.jsonl, append; drained by Dart)
├─ schedule/    ExactAlarmScheduler (setAlarmClock, RTC_WAKEUP epoch ms), InexactFallbackScheduler (setAndAllowWhileIdle), Reconciler (diff by entry id + generation)
├─ receive/     AlarmReceiver (exported=false, FLAG_IMMUTABLE, request code from entry id), BootReceiver (directBootAware; LOCKED_BOOT_COMPLETED + BOOT_COMPLETED),
│               TimeChangeReceiver (TIME_CHANGED, TIMEZONE_CHANGED), PackageReplacedReceiver (MY_PACKAGE_REPLACED), ExactAlarmPermissionReceiver
├─ playback/    AthanForegroundService (FGS type mediaPlayback; AudioAttributes USAGE_ALARM; alarm stream; stop/snooze actions; audio from device-protected files/athan/)
├─ notify/      ChannelRegistry (channelId = "athan_" + sha256("kind|soundId|v").hex[0:12]; new sound ⇒ new channel + migration), NotificationFactory (pre-rendered text)
├─ health/      HealthProbes: canScheduleExactAlarms, areNotificationsEnabled (POST_NOTIFICATIONS), channelImportance ≥ HIGH, isIgnoringBatteryOptimizations (informational),
│               DND alarm policy, soundAssetPresence, planHorizon, previousForceStop (ApplicationExitInfo)
├─ widget/      Glance widget reading Snapshot (V1)
└─ bridge/      Pigeon host implementation
```
Decisions: `setAlarmClock` for ATHAN entries (Doze-exempt, alarm icon); the exact-alarm delivery is the background-start path for the playback service — validated in S19; fallback = high-importance notification with the alarm-stream sound. Receivers do the minimum (read plan → schedule) and hand anything > 1 s to `WorkManager`. OEM battery guidance = bundled `assets/oem_guidance.json` `{manufacturerRegex, androidMin, androidMax, steps{ar,en}[], settingsIntent?}` owned by Product. `[REQ-ALM-020..027]`

### 8.2 iOS — `AthanKit` (Swift 6, iOS 18+, local SwiftPM package via Flutter's SwiftPM integration)

```
AthanKit/
├─ Plan/        PlanStore (App Group "group.app.dailymuslim.shared": <container>/plan/plan.json, atomic write), PlanReader, EventsStore (events.jsonl)
├─ Scheduling/  AlarmKitScheduler (iOS 26+, Alarm.Schedule.fixed(Date)), NotificationScheduler (UNTimeIntervalNotificationTrigger from absolute instant; ≤ 64 by priority), Reconciler
├─ Health/      Probes: alarmKitAuthorization, notificationAuthorization, soundAssetPresence, planHorizon, backgroundRefreshStatus;
│               silentSwitch / Focus ⇒ ProbeResult.positive = nil (⇒ unknown); criticalAlerts ⇒ notApplicable (not requested in MVP)
├─ Audio/       AthanClipCatalog (≤ 29 s clips cut at phrase boundaries, copied to Library/Sounds/; full Athan plays on app open)
├─ Widgets/     WidgetKit timeline from Snapshot (V1); Live Activity (V1, evaluate)
└─ Bridge/      Pigeon host implementation
```
Decisions: never `DateComponents` triggers; schedule from epoch instants only. `BGAppRefreshTask` requests a plan refresh opportunistically, never relied upon. `PrivacyInfo.xcprivacy` declares `UserDefaults` and file-timestamp required-reason APIs; `places.sqlite` `isExcludedFromBackup`. `[REQ-ALM-030..036]`

### 8.3 Athan Health state machine (shared semantics, platform evidence)

```
                 all probes positive            ┌─────────┐
  ┌──────────┐ ───────────────────────────────▶ │  READY  │  (androidExact; iosAlarmKit only after S19 proves delivery receipts — ADR-013 update)
  │ EVALUATE │ ── one degrading probe ────────▶ │ LIMITED │  (inexactFallback, unverifiableDelivery, batteryRestricted, horizonEnding, stalePlan)
  │ (on open,│ ── blocking probe ─────────────▶ │NOT_READY│  (needs*Permission, no plan, noSoundAsset)
  │  events) │ ── probe.positive == null ─────▶ │ UNKNOWN │  (silent switch / Focus; never implies readiness)
  └──────────┘                                  └─────────┘
```
Athan Test: user-initiated, fires in 60 s via the real path, asks "Did you hear it?"; stores `presentedByOs` (when available) and `heardByUser` separately. `[REQ-ALM-040]`

---

## 9. Backend

### 9.1 Distribution plane (static) `[REQ-DIST-001..006]`

```
R2 bucket dm-dist (versioning + object lock)
/{channel}/metadata/root.json · targets.json · snapshot.json · timestamp.json      channel ∈ dev|lab|beta|production
/{channel}/packages/{type}/{version}/{sha256}.dmpkg                                  .dmpkg = gzip(single payload file); payloadFormat in target.custom
```
Signature envelope on every metadata file: `{ "signed": {...}, "signatures": [{ "keyId", "sig" }] }`, Ed25519 over **JCS (RFC 8785)** canonical JSON of `signed`; Dart verifies with `package:cryptography`, Go signs with `crypto/ed25519`. Keys: `root` 3 offline hardware tokens, threshold 2, public keys embedded in app, rotatable by old-root signature; `targets` in Google Cloud KMS under a dual-control release environment; `snapshot` + `timestamp` automated (timestamp expiry 7 d). Target `custom`: `{schemaVersion, payloadFormat, compat{minApp, minEngineSchema}, effectiveFrom, priority ∈ {normal, urgent}, changeNote{ar,en}, rollbackOf?, attribution?}`. CDN: packages `immutable, max-age=31536000`; `timestamp.json` `max-age=300`; other metadata `max-age=3600`. Logs retained 24 h without IP beyond that.

### 9.2 Profile pipeline (GitOps) `[REQ-GOV-001..004]`
```
PR (profile yaml + evidence) ─▶ profiles-gate: schema ─▶ non-overlap ─▶ compile profiles.json ─▶ lab benchmark (derivation set)
  ─▶ workflow_dispatch in private repo profiles-holdout on the candidate SHA → holdout report artifact
  ─▶ CODEOWNERS reviews (accuracy-lead + sharia-reviewer) ─▶ merge ─▶ release-package: gsctl build → sign targets (KMS, dual control) → publish lab → beta
  ─▶ gsctl promote --from beta --to production --sequence N  (release manager; GitHub environment with a second required reviewer)
  ─▶ religious changes use one effectiveFrom for all users; canaries are technical only (hash/parse/crash-free)
```
Prohibited-practice checks: `|perEventMinutes[*]| ≤ maxAbsMinutes`; no angle change in a PR that also touches tz/coordinate data; `rounding.* = nearest` on an entry event requires `approvals.religious.scope` to contain `rounding`; `status: APPROVED` requires both approvals and a holdout report.

### 9.3 Control plane API (Go) `[REQ-API-001..006]`
Layout: `cmd/api`, `internal/{domain,app,ports,adapters/{http,postgres,attest,storage}}`. `/v1`, JSON, RFC 9457 problem details with trace id, 5 s timeouts, 64 kB body limit, `Idempotency-Key` on POST.

| Method | Path | Purpose | Auth / limits |
|---|---|---|---|
| POST | `/feedback/corrections` | explicit user correction `{kind ∈ zone|profile|hijri|other, payload, country, roundedLat, roundedLon}` | Play Integrity / App Attest token; 10/day per attestation key; returns `receiptId` |
| POST | `/telemetry/aggregates` | Appendix L counters; no ids | attestation optional; schema-validated; rejected on unknown keys |
| GET | `/evidence/profiles/{id}` | statistical summary + source links (never raw authority tables) | public, cached 1 h |
| GET | `/healthz`, `/readyz` | liveness / readiness | — |

Rate-limit key = `sha256(attestationKeyId + dailyServerSalt)`, retained ≤ 24 h — the only device-derived identifier (`REQ-PRIV-007`). Tables: `corrections(id, received_utc, kind, payload_json, country, rounded_lat, rounded_lon, status ∈ {new,accepted,rejected,duplicate}, reviewed_by, reviewed_utc)`, `telemetry_daily(date, metric, dim, count)`, `evidence_summaries(profile_id, version, summary_json)`. Corrections are reviewed weekly by the accuracy lead; `accepted` ⇒ profile/package PR. Retention `[REQ-DATA-002]`: corrections 365 d; telemetry 730 d aggregated; request logs 24 h. Observability: zerolog structured logs, RED metrics, OpenTelemetry traces. SQL via `sqlc`; migrations via `goose` in the deploy job.

### 9.4 Accuracy Lab (Python, `lab/`)
`uv run lab benchmark --engine dart --cities lab/benchmarks/cities.v1.json --years 2026-2028` runs `dart run geo_salah_core:bench` over JSONL (`{observer, profileId, day}` → `DayResult`), compares with Skyfield/de440s per ADR-019, writes discrepancy reports (§6.7) as artifacts; nightly job. Holdout = fixed list in `profiles-holdout` (40 % of cities + both solstice weeks), run only via `workflow_dispatch` from that repo.

### 9.5 Data pipelines and payload formats (Python → Dart contracts)

| Package type | Payload | Format / size |
|---|---|---|
| `prayer_profiles` | `profiles.json` — array of compiled profiles | json, ~50 kB |
| `tzdata` | `package:timezone` database bytes built from the IANA release with the package's tooling | bin, ~400 kB |
| `tz_polygons` | little-endian: header `{magic "TZPG", version u16, count u32}`; zone-name table; 1°×1° grid index (cell → polygon ids); rings as int32 micro-degree deltas; Douglas-Peucker 0.001°; `schemas/tz_polygons.v1.ksy` | bin, ~3 MB |
| `country_polygons` | same layout, magic `"CTPG"`, ISO2 table; Natural Earth admin-0 1:10m | bin, ~1 MB |
| `gazetteer` | JSON array `{id, name, asciiName, altNames{ar,en}, country, admin1, lat, lon, population, zoneId}`; imported into drift at activation | json, ~1.5 MB gz |
| `hijri` | `{country, months[{hijriYear, hijriMonth, gregorianStart, status ∈ confirmed|expected, sourceUrl}]}`; source country = first of profile `scope.countries`; user override stored in `settings.hijriOverrideDays` and applied before `HijriState` is built | json, ~10 kB |
| `athan_audio_manifest` | `{sounds[{soundId, file, durationMs, fajrVariantOf?, licenceRef, sha256}]}`; audio AAC-LC 96 kbps `.m4a`, −16 LUFS, bundled under `assets/athan/` (MVP) | json |
| `mosques` `[V1.5]` | OSM extract → dedupe → ODbL produced database | sqlite |

### 9.6 Observability without surveillance
On-device ring-buffer event log (Appendix J codes, no coordinates) → user-initiated redacted diagnostic bundle. Aggregate telemetry (Appendix L) is off in beta (D11). No crash SDK by default; optional self-hosted Sentry behind a build flag with PII scrubbing tested.

---

## 10. Cross-cutting concerns

### 10.1 Security controls
Tampered package (TUF-lite + schema + compat) · CDN freeze/rollback (sequence + timestamp expiry) · key theft (threshold root, rotation runbook) · malicious deep link (allow-list + confirmation for setting changes) · alarm spoofing (non-exported receivers, immutable PendingIntents, deterministic ids) · log leakage (schema-level ban on coordinates) · supply chain (locked `pubspec.lock`, Gradle version catalog, `Package.resolved`, `go.sum`, `uv.lock`; SBOM via syft; license scan; dependency review) `[REQ-SEC-040]` · secrets never in repo; OIDC short-lived CI credentials; production signing requires two approvers `[REQ-SEC-030]`.

### 10.2 Error handling model
Domain returns typed failures; application maps them to `Needs attention` states with remediation; data layer wraps I/O errors with context (never swallowed); native layer reports failures as receipts/events and never crashes the alarm path. Codes are enumerated in Appendix J and mirrored in Kotlin/Swift via `dm_contracts`. `[REQ-ERR-002]`

### 10.3 Versioning and compatibility
Engine `minEngineSchema` gates profiles; `SchedulePlan.schemaVersion` gates native readers (accept N and N−1, otherwise keep the previously applied plan); packages declare `compat`; incompatible packages are not activated and the event is logged. Semantic versioning; conventional commits.

### 10.4 Licensing posture
ODbL (tz polygons; mosques V1.5): attribution screen + produced databases published under ODbL — a conscious decision. CC BY 4.0 (GeoNames) and Natural Earth (public domain): attribution. Fonts OFL. Audio: written agreement with the muezzin; separate Fajr file; neutral test tone `[DECIDED · revisit D12]`. `LICENSES.md` generated per release.

### 10.5 Feature flags
Build-time flags only for MVP. Remote configuration may **select signed package versions** per channel and never carry rule values or toggles affecting calculation. `[REQ-SEC-020]`

---

## 11. Failure modes and mitigations

| Failure | Where | Detection | Mitigation | Runbook |
|---|---|---|---|---|
| App not opened for weeks → alarms stop | iOS 64 budget / Android plan horizon | `horizonEnding`; `HORIZON_WARNING` entry | 30-day plan; priority fitting; "open the app" notification | — |
| Reboot before unlock | Android credential-encrypted storage | device suite | direct-boot-aware receiver + device-protected plan store | — |
| Force-stop / hibernation | Android | `ApplicationExitInfo` on next open | `Needs attention` banner with remediation | — |
| Device zone ≠ schedule zone | triggers | plan-entry unit tests | absolute-instant scheduling; pre-rendered local text | — |
| TZ law change after release | civil time | IANA release watch; `staleTzdb` by zone | urgent `tzdata` package ≤ 48 h; targeted warning | tzdb-emergency |
| Profile update changes future times | schedule | change note required in manifest | future-only reconciliation by generation; prior provenance kept | — |
| Package signature invalid / hostile network | distribution | verification failure counters | last-known-good; backoff; never block today | package-rollback |
| Clock skew on device | time | GNSS/CDN comparison | banner; no hard rejection | — |
| Polar / no-event dates | engine | property tests | typed `NoEvent` + chain; disclosure | — |
| Near-minute boundary disagreement | engine | `nearRoundingBoundary` | 1 ms truncation; flag in Passport | — |
| Control plane down | backend | `/readyz`, client timeouts | app unaffected; consented submissions queued, dropped after 7 d | control-plane-restore |
| Feedback endpoint abuse | backend | attestation failures, rate-limit metrics | attestation, per-key limits, moderation queue | — |
| Signing key compromise | distribution | metadata monitor, disclosure | threshold root; revoke + re-sign; app hot-fix only if root compromised | key-compromise |
| Hijri month not confirmed in time | data | calendar alert 3 d before boundary | `Expected` label + user override; urgent package when confirmed | hijri-announcement |

---

## 12. Testing strategy and CI gates

| Level | Tooling | Gate |
|---|---|---|
| Dart unit + property | `test`, `glados` | PR |
| Golden conformance | frozen JSON corpus | PR; `golden-update` label to change |
| Import/arch lint | `dm_lints` custom lint: no `package:flutter` in the pure Dart set; layer rules in `apps/mobile` | PR |
| Schema | `ajv` on `schemas/` + fixtures round-trip in Dart/Kotlin/Swift/Go | PR |
| REQ index | every `REQ-*` in code/tests exists in Appendix F | PR |
| Kotlin/Swift unit | JUnit 5 + Robolectric; XCTest | PR |
| Integration (Flutter) | drift migrations (both DBs), package activation/rollback, resolver, plan builder | PR |
| E2E | Patrol on tier-1 devices (first run → Passport → Athan Test) | nightly + RC |
| Device alarm suite | `adb shell dumpsys deviceidle force-idle`, reboot, locked boot, tz/time change; iOS silent switch / Focus | RC `[REQ-TEST-005]` |
| Differential (lab) | Skyfield/de440s vs engine; benchmark + holdout | nightly, profile PRs |
| Security | secret scan, dependency audit, merged-manifest `AD_ID` check, egress allow-list (proxy), deep-link fuzz | PR/RC |
| Accessibility | semantics tests, SkyTheme contrast goldens, RTL goldens, 200 % text | PR |
| Privacy | event-log schema scan; `places.sqlite` backup-exclusion test; diagnostics rounding test | PR |
| Performance | one-year calc on Galaxy A50; cold Home < 1 s; installed size ≤ 60 MB | RC |

Branching: trunk-based, protected `main`, short-lived branches, conventional commits, required checks per path.

---

## 13. Delivery plan — milestones and ordered vertical slices

Each slice is a mergeable unit (1–5 PRs) with a **done-test** Claude Code can run. Order is binding; a slice may start when its inputs exist. Human decisions in §15 are **not** blockers — defaults are built behind data fields. If a single implementer works alone, the lab harness (S03) is written and frozen **before** the engine, and the engine is written without reading the harness code.

| # | Slice | M | Inputs | Outputs | Done-test |
|---|---|---|---|---|---|
| S01 | Monorepo runway: melos, `.tool-versions` pins (§5.4), `dm_lints`, `dm_core_types`, CI skeletons, ADR stubs 000–024, PR templates (`golden-update`, `profile-change`), dev TUF root keys, `CLAUDE.md` | M0 | this doc | green empty CI | arch lint fails on a deliberate `package:flutter` import in `geo_salah_core` |
| S02 | Schemas + fixtures + per-language model skeletons (ADR-023); REQ-index check | M0 | Appendices | `schemas/`, `ci-schemas` | ajv validates fixtures; four-language round-trip passes |
| S03 | Lab reference harness (Skyfield/de440s), Appendix H city file, JSONL contract — frozen before the engine | M1 | Appendix H | `lab/`, reference JSONL for Dhuhr/Sunrise/Sunset 2026–2028 | harness reproduces published equinox/solstice sunrise for 3 cities within 1 min |
| S04 | SPA + ΔT + interpolation + culmination segments + Brent | M1 | S03 | `astro/`, `solver/` | property: continuity, bracket exhaustiveness; unit vs SPA paper example values |
| S05 | Transit + horizon rules; `calculateDay` for Dhuhr/Sunrise/Sunset with `engine.default` constants and a fixed-offset `TzDatabase` fake; trace + CalculationId; minimal `bench` CLI speaking the §15 D29 JSONL contract for these events | M1 | S04 | first `DayResult` | `lab benchmark --engine dart --tags DAY_OF_MONTH` within ADR-019 tolerance (0 blocking) for the 49 Appendix H cities × 12 monthly dates per year (§15 D30); golden corpus v1 frozen |
| S06 | Altitude/shadow/interval rules; per-event rounding; flags; ordering guard; confidence mapper; `calculateRange` cache; `bench` CLI extended to every event | M2 | S05 | full engine | golden extended (`golden-update`); `REQ-PERF-001` baseline recorded |
| S07 | `PrayerProfile` model in core; `geo_salah_profiles` parser/validator/resolver; seed profiles + `engine.default`; non-overlap check | M2 | S06, Appendix A | profiles load | all seed variants pass conformance; overlap fixture fails validation |
| S08 | High-latitude chain + polar edge suite; `dm_hijri` tabular fallback + `HijriState`; Ramadan rule replacement | M2 | S07 | `high_latitude.dart`, `dm_hijri` | Tromsø/Longyearbyen/Utqiaġvik produce typed origins; Ramadan Isha replacement visible in trace |
| S09 | `gsctl validate|build|sign|verify` + TUF-lite metadata (dev keys) | M2 | S02 | Go CLI | sign→verify round-trip Go↔Dart; tampered byte fails; sequence regression rejected |
| S10 | `tzdata` pipeline + `dm_civil_time` `TzDatabase`; DST transition suite | M3 | S09 | pinned TZDB | transition-day conversions ±7 d for all corpus zones |
| S11 | `tz_polygons` + `country_polygons` pipelines + Dart readers; ocean/boundary fallbacks | M3 | S10 | binary packages | 1 000 random points agree with shapely ≥ 99.9 %; boundary flag within 10 km |
| S12 | `gazetteer` pipeline + drift import + normalized search | M3 | S11 | offline search | "القاهرة" and "Cairo" both resolve; search < 50 ms |
| S13 | Location contexts + resolver + pinning + clock skew; `geolocator`/`permission_handler` adapters | M3 | S11 | `contexts` feature | `REQ-PRIV-002` test; mock-location recorded |
| S14 | `dm_packages` client: verify/stage/activate/rollback; bundled seed import; sync policy | M4 | S09 | package store | tamper, downgrade, expiry-warning, rollback tests |
| S15 | `dm_ui`: tokens (Appendix G), SkyTheme, components, RTL/a11y goldens | M4 | Appendix G | design system | contrast ≥ 4.5:1 for 10 phases × 2 modes × 2 directions |
| S16 | App shell: DI, router, failure model, drift (two DBs), settings, l10n ARB, attributions | M4 | S13–S15 | runnable app | migrations test; `places.sqlite` backup-exclusion test |
| S17 | Onboarding + Home + Day timeline + Manual place (all §18.4 states) | M4 | S16 | MVP core UX | first run offline → schedule; every `UiState` variant has a widget test |
| S18 | Accuracy Passport (explanation, flags copy, perturbation line, share/import link) + Qibla (HeadingApi, calibration UX) | M4 | S17 | P1 + Qibla | `<calcId>#event` resolves; import mismatch message; Qibla golden vectors |
| S19 | **Native spike (time-boxed 5 days, physical devices)**: Android exact alarm → FGS audio; iOS AlarmKit `.fixed`, long audio, receipts; iOS 64 budget | M5 | S07 | ADR-012/013 updated | spike report in `docs/adr/` with go/no-go per path |
| S20 | `SchedulePlan` builder + `Snapshot` + plan/snapshot stores (both platforms) | M5 | S19 | plan JSON | schema validation; deterministic ids; iOS budget fitting test |
| S21 | Android `athan-core`: scheduler, receivers, FGS playback, channels, probes, test | M5 | S20 | Android Athan | 72 h device suite: forced Doze, reboot, locked boot, tz change, time change |
| S22 | iOS `AthanKit`: AlarmKit + notification schedulers, probes, test, App Group; early TestFlight submission | M5 | S20 | iOS Athan | device suite incl. silent switch ⇒ `unknown`; notification path never `ready` |
| S23 | Athan feature UI: Health, Test ("did you hear it?"), sounds, pre-reminder, receipts drain | M5 | S21–S22 | P2 | state-machine unit tests; `REQ-ALM-003` |
| S24 | Privacy hardening: egress allow-list test, `AD_ID` manifest test, event-log schema scan, diagnostics export, privacy manifest, Data safety draft | M6 | S23 | privacy gates | all gates in CI |
| S25 | Distribution infra (Terraform: R2, CDN rules, KMS) + `release-package` + promote flow | M6 | S09 | live `dev`/`lab` channels | app syncs from `lab` end-to-end |
| S26 | Control plane: API, attestation, Postgres, OTel, Cloud Run deploy | M6 | S02 | `api.dailymuslim.app` | contract tests; rate-limit test; problem-details test |
| S27 | Production key ceremony; runbooks (§19.4); release checklist (§20); threat-model review; accessibility audit; beta on internal tracks | M6 | all | MVP beta | rollback drill restores prior schedule atomically; §18.6 beta exit criteria |
| S28 | V1: widgets (Glance/WidgetKit from Snapshot), Travel Mode, Ramadan UX, ops dashboard | M7 | MVP | V1 RC | widget correctness across midnight / profile update |

Milestone map: M0 runway (S01–S02) · M1 astronomical core (S03–S05) · M2 rules/profiles/Hijri/signing (S06–S09) · M3 civil time & location (S10–S13) · M4 app shell & MVP UX (S14–S18) · M5 native Athan (S19–S23) · M6 distribution, control plane, hardening → MVP beta (S24–S27) · M7 V1 (S28). V1.5/V2 remain design-only (mosque/Iqama typed, wearables with Rust trigger evaluation, advanced windows in UTC, optional verified sources, independent reviews).

---

## 14. Gap register

### 14.1 Baseline gaps closed in v1.0 (red-team mapping)

| # | Gap (source) | Recommended practice | Closed by |
|---|---|---|---|
| G1 | Refraction double-counting; altitude kind undefined (RT F-01) | geometric targets; exclusivity property test | ADR-003 |
| G2 | Dip from sea-level elevation (RT F-02) | dip = 0 default; elevation recorded only; policy field | ADR-003 |
| G3 | Civil-midnight search window (RT F-03) | culmination segments; `+1` display | ADR-004 |
| G4 | Nearest-minute rounding & symmetric budget (RT F-04) | per-event rounding, asymmetric budget, alarm on displayed minute | ADR-005 |
| G5 | Who reschedules without the app open (RT F-05) | 30-day native-readable plan; horizon states | ADR-002, §7.7 |
| G6 | No Sharia role (RT F-06) | signed `approvals.religious`; CODEOWNERS; CI gate | ADR-008 |
| G7 | EN/AR divergence (RT F-07) | DESIGN.md normative + REQ-tag diff | ADR-000 |
| G8 | Ramadan/Hijri source (RT F-08) | signed hijri package + flagged fallback; Ramadan rules in MVP | ADR-016 |
| G9 | Exact vs authority-point ambiguity (RT F-09) | `referenceMode` field; UI shows mode | ADR-006 |
| G10 | Mosque phantom minute (RT F-10) | mosque shows only Verified/Observed values | §13 V1.5 |
| G11 | Generic Iqama default (RT F-11/12) | sealed `IqamaInfo`, Unknown default | ADR-020 |
| G12 | iOS Ready unprovable (RT F-13) | `Unknown` + "did you hear it?" | §8.3 |
| G13 | Android permission undecided (RT F-14) | `SCHEDULE_EXACT_ALARM` + `setAlarmClock` | ADR-012 |
| G14 | Full Athan vs notification clip (RT F-15) | per-platform statement; clip catalogue | ADR-013 |
| G15 | Direct boot / force stop (RT F-16) | direct-boot receiver; exit-info detection | §8.1 |
| G16 | High-lat methods undefined for polar (RT F-17) | ordered chain, UTC nights, `NoEvent` | §6.4 |
| G17 | Trigger zone ambiguity (RT F-18) | absolute instants; pre-rendered text | §7.7, §8.2 |
| G18 | Freeze/rollback/key hierarchy (RT F-19) | TUF-lite roles, sequence, threshold root | ADR-009 |
| G19 | Religious canary (RT F-20) | technical canary only; unified `effectiveFrom` | §9.2 |
| G20 | Bit-identical conformance impossible (RT F-21/22) | 1 ms truncation; independent de440s reference | ADR-019 |
| G21 | SRTM coverage / DEM licensing (RT F-23) | DEM removed from MVP | ADR-015 |
| G22 | ODbL/CC-BY review timing (RT F-24) | licensing posture now; attribution in-app | §10.4 |
| G23 | Backups & regional metadata leak (RT F-25) | separate places DB excluded; country packages; CDN log policy | ADR-017 |
| G24 | Geofencing needs background location (RT F-26) | tz-change receivers + on-open checks | S28 |
| G25 | Live GPS beats manual (RT F-28) | context pinning invariant | `REQ-PRIV-002` |
| G26 | Unpredictable ids vs idempotency (RT F-29) | deterministic ids; non-exported receivers | §7.7, §8.1 |
| G27 | `localTime` stored (RT F-30) | removed; derive at edge | `REQ-TIME-001` |
| G28 | "30 days offline" undefined (RT F-32) | three horizons; soft expiry | §18.7 |
| G29 | Perf of full SPA per iteration (RT F-33) | interpolation + final refinement | §6.4 |
| G30 | Holdout missing (RT F-35) | frozen holdout in private repo | §9.2 |
| G31 | Precise location by default (RT F-36) | approximate default; boundary upsell | ADR-014 |
| G32 | Offline manual place search (RT F-37) | GeoNames gazetteer package | ADR-015 |
| G33 | Audio rights / Fajr file / test tone (RT F-38) | agreement; separate files; neutral tone | §10.4 |
| G34 | Acceptance criteria unmeasurable (RT F-44/45) | numeric thresholds §12, §18.6; D11 | §22 |
| G35 | Asr/ΔT unspecified (RT F-46/59) | formulas; Espenak–Meeus ΔT | §6.4 |
| G36 | Wall-clock night durations (RT F-48) | UTC durations + DST-night tests | §13 V1.5 |
| G37 | Clock skew undetected (RT F-49) | GNSS/CDN comparison banner | §7.6 |
| G38 | Crash/analytics SDK undecided (RT F-50) | none by default; manifest + egress tests | ADR-017 |
| G39 | Notification channel immutability (RT F-51) | channel id derivation + migration | §8.1 |
| G40 | Privacy manifest / Data safety (RT F-52) | S24 | §13 |
| G41 | Evidence API republishing tables (RT F-54) | summaries + links only | §9.3 |
| G42 | "Country" model (RT F-55) | geo-scoped `PrayerProfile`, `authorityType` | ADR-007 |
| G43 | Emergency TZDB SLA (RT F-56) | 48 h runbook; monitor | §19 |
| G44 | Mock locations (RT F-60) | detection recorded | §7.5 |
| G45–G53 | New in v1.0: plan contract, app architecture, theme spec, error taxonomy, remote-config limits, authoring tooling, monorepo/CI, native tests, copy/semantics separation | — | §7.7, §7, ADR-018, §10.2, `REQ-SEC-020`, ADR-008, §5.3/§12, §12, §7.11 |

### 14.2 Audit gaps closed in v1.1

| # | Gap | Closed by |
|---|---|---|
| G54 | REQ ranges without text | Appendix F |
| G55 | Undefined domain types; circular package dependency | §6.2, §5.2 |
| G56 | `calculateDay` return vs typed failure | §6.3 |
| G57 | Golden corpus definition unsatisfiable | ADR-019 |
| G58 | Night definition wrong for Fajr | §6.4 ¶7 |
| G59 | Ramadan rule sequencing | §6.4 ¶6 |
| G60 | No point→country source | ADR-015, `country_polygons` |
| G61 | No toolchain/library versions | §5.4 |
| G62 | No signature envelope / canonicalisation / compression format | §9.1, Appendix C |
| G63 | Backup exclusion of a table | §7.3 two databases |
| G64 | No sky token values; phase count inconsistent | Appendix G (10 phases) |
| G65 | No ordered slices | §13 |
| G66 | No functional spec (personas, stories, states, permissions, copy) | §18 |
| G67 | No operations / SLO / severity / runbook content | §19 |
| G68 | No release & store process | §20 |
| G69 | No support model | §21 |
| G70 | No KPIs under the privacy posture | §22 |
| G71 | No RACI / board charter / document change control | §23 |
| G72 | Thin legal register | §24 |
| G73 | No security programme / key custody | §25 |
| G74 | No deployment specifics, cost model, staffing, programme risks | §26–§27 |
| G75 | Attestation identifier vs REQ-PRIV-001 | `REQ-PRIV-007` |
| G76 | `POST_NOTIFICATIONS` missing | ADR-012, §8.1 |
| G77 | Status-tag misuse for code decisions | `[DECIDED · revisit Dn]` |
| G78 | Imsak rule inexpressible | `intervalBefore` |
| G79 | Authority tables referenced without a package type | `[DEFERRED V2]` everywhere |

---

## 15. Open decisions requiring human input (defaults are built)

| ID | Decision | Owner | Default implemented | Lives in |
|---|---|---|---|---|
| D1 | Sharia board formation and charter (§23.2) | Business | CI gate blocks production signing | ADR-008 |
| D2 | Alarm follows exact coordinate or authority reference point | Product + Sharia | `EXACT_COORDINATE` | profile `referenceMode` |
| D3 | Elevation/dip policy | Sharia + Accuracy | `NONE` | profile `horizon.elevationPolicy` |
| D4 | Rounding per event; Ihtiyat; budget | Sharia | ceil / floor sunrise; −0/+60 s | profile `rounding` |
| D5 | Android exact-alarm permission posture | Mobile + Legal | `SCHEDULE_EXACT_ALARM` | ADR-012 (code) |
| D6 | Minimum iOS | Product + Mobile | iOS 18 | ADR-013 (code) |
| D7 | Launch countries and date vs Ramadan 1448 (~8 Feb 2027) | Business | **Assumed EG, SA, AE**; if §18.6 beta exit is not met by 15 Jan 2027, GA moves to after Eid al-Fitr 1448 (~Mar 2027) | `profiles/`, §18.6 |
| D8 | Hijri announcement sources per country | Sharia + Data | tabular fallback flagged `Expected` | ADR-016 |
| D9 | ODbL/CC-BY acceptance | Legal | accepted; attribution shipped | §10.4 |
| D10 | Document SSOT | Architect | this file | ADR-000 |
| D11 | Telemetry: anonymous daily health ping vs store vitals only | Product + Security | off in beta | §9.6, §22 |
| D12 | Athan Test audio | Sharia + Legal | neutral tone | §10.4 (code) |
| D13 | Hosting vendors | Business + Security | Cloudflare + GCP | ADR-022 |
| D14 | Funding model / donation feature | Business | sponsor-funded; no donation UI | §1.1 |
| D15 | Melos configuration location (added S01) | Architect | melos ≥ 7 reads its config from the `melos:` key of the root `pubspec.yaml` (pub workspace); the `melos.yaml` named in §5.3 does not exist | root `pubspec.yaml` |
| D16 | Arch lint mechanism and scope (added S01) | Architect | standalone CLI `dart run dm_lints:arch_lint` (analyzer AST, no analyzer plugin). Pure set `lib/`: no Flutter (`package:flutter*`, `dart:ui`, `dm_ui`, `dm_contracts`) and no `dart:io/ffi/html/isolate/js*/mirrors`; pure set `bin/`, `test/`: no Flutter (`dart:io` allowed for the `bench` CLI and golden files); pure pubspecs: no Flutter dependency. App: `features/<f>/<layer>/` direction presentation → application → domain ← data; domain gets the pure `lib/` ban | `packages/dm_lints` |
| D17 | TUF key encoding (added S01) | Architect + Security | `public` = lowercase hex of the 32 raw Ed25519 public-key bytes; `keyId` = lowercase hex SHA-256 of those 32 bytes | Appendix C, `tools/gsctl/keys/` |
| D18 | Pins below "latest stable" (added S01, extended S02) | Architect | Flutter 3.47.7 pins `test_api` 0.7.12 ⇒ `test` 1.31.1, `analyzer` 13.3.0, `freezed` 4.0.1, `build_runner` 2.16.1; `macos-15` runners top out at Xcode 26.3; JDK Temurin 21.0.11 and Node 22.22.0 have no §5.4 floor and use the current LTS. Revisit on each toolchain upgrade PR | ADR-011 table |
| D19 | Value types with invariants (added S01) | Architect | types whose constructor must reject invalid values (e.g. `CivilDate`) are hand-written `@immutable final class`es with a validating constructor and value equality; `freezed` (which cannot enforce construction invariants) is used for record-like data types | `dm_core_types` |
| D20 | Application identifiers (added S01) | Mobile + Product | Android `applicationId` and iOS bundle id `app.dailymuslim`, derived from the App Group `group.app.dailymuslim.shared` (§8.2) | `apps/mobile` |
| D21 | Wire conventions of the new schemas (added S02) | Architect | optional members are absent, never `null` (Appendix A's nullable members excepted); enums `SCREAMING_SNAKE_CASE` unless the source section spells them otherwise; `SchedulePlan` `HORIZON_WARNING` entries carry no `event`; snapshot `confidence.detail` is absent exactly for `CALCULATED`; trace times of `NO_EVENT` carry no instants; provenance's adjustment trace is carried per event; event-log `level ∈ {DEBUG, INFO, WARN, ERROR}` and attribute patterns admit no decimal coordinate | `schemas/`, `schemas/README.md` |
| D22 | Generated Dart code (added S02) | Architect | `*.g.dart` / `*.freezed.dart` are committed; `ci-dart` regenerates them with `melos run gen` and fails when the tree changes | root `pubspec.yaml`, `ci-dart` |
| D23 | Binary polygon layout details (added S02) | Architect + Data | beyond §9.5: name table of u1-length UTF-8 strings; `polygon_count` u4; 360×180 grid as u4 prefix offsets (64 801) into a u4 polygon-id array; per polygon name index u4, bbox s4×4, rings (ring 0 outer, then holes) of u4 point count + s4 lon/lat deltas from the previous point (first from 0,0); lon first | `schemas/*.ksy` |
| D24 | Go wire models and the round-trip matrix (added S02) | Architect | Go models are hand-written typed structs with strict decoding; go-jsonschema 0.24.1 failed the `prayer_profile` round-trip and emits `interface{}` (evidence in the ADR-023 amendment, pending Architect approval of the §4 text). Each language round-trips the schemas it produces or consumes (`schemas/README.md`), not all ten | ADR-023, `schemas/README.md` |
| D25 | Lab reference model and time scales (added S03) | Accuracy + Architect | Skyfield 1.55 over `de440s.bsp`: apparent topocentric position of the Sun's centre, observer on the WGS84 ellipsoid at 0 m, polar motion ignored. ADR-019's UT1 ≡ UTC is realised as ΔT = 32.184 s + (TAI − UTC = 37 s) = 69.184 s; the harness refuses any day on which Skyfield's leap-second table disagrees. The engine's Espenak–Meeus ΔT (≈ 75–76 s in 2026–2028) only moves the solar position (≈ 0.016 s at sunrise). Crossings are sampled every 5 min, then bracketed to 1 ms; solar altitude is monotone within a half segment and the endpoints are always sampled, so no crossing is missed (the architect review checked the 36 polar-transition days of 2026). A half segment without exactly one crossing in the event's direction is `AMBIGUOUS` (none in 2026–2028). Instants are truncated to 1 ms. Two runs on one platform are byte-identical; libm differences across platforms can move an instant by ±1 ms, so regeneration is checked within 1 ms. The manifest hashes the reference-deciding lab code (`harness_source`) | `lab/config/harness.v1.toml`, `lab/src/dm_lab/sky.py` |
| D26 | ADR-019 tolerances (added S03, amended after the S03 review) | Accuracy + Architect | **Decided 2026-10-21** (project owner); the ADR-019 text in §4 is amended to match. *Sunrise/sunset* use `clamp(0.001° / \|dh/dt\|, 0.2 s, 60 s)` only where `\|dh/dt\| ≥ 0.001° / 60 s`. A slower crossing is reported as `NEAR_TANGENT`: its instant is ill-conditioned, so it is graded explicitly — an engine instant within 60 s agrees, anything else is a non-blocking `REFERENCE_AMBIGUITY` — and is never given a capped tolerance. Missing crossings are typed `NO_EVENT`, multiple ones `AMBIGUOUS`. *Dhuhr* is removed from the altitude-rate rule because the transit is not altitude-defined, and a 60 s fallback is no justification. It has a fixed time tolerance of **0.2 s**, set by the required accuracy and the reference's precision: reference bracket ≤ 1 ms, ΔT-model difference ≤ 0.02 s, SPA position error (±0.0003°) ≤ 0.07 s at the transit, and below ADR-005's 0.5 s near-rounding-boundary flag. Expressed as an angle that is ≈ 0.00083° of hour angle; it is a time criterion, not an angular one. A configured Dhuhr offset is verified separately (§15 D29). Tolerances are rounded up to whole milliseconds | ADR-019, `harness.v1.toml` `[tolerance]`, `lab/src/dm_lab/tolerance.py` |
| D27 | Python wire models (added S03) | Architect | pydantic v2 models generated from `schemas/` by datamodel-code-generator 0.86.0 (`lab/scripts/gen_models.sh`), committed and checked fresh in `ci-lab`. The generator runs from its own locked project, `lab/tools/codegen` (`uv.lock`, CPython 3.14.8), because its pyyaml 6.0.3 dependency has no CPython 3.15 Windows wheel (revisit when one ships). `if/then/else` conditionals are not modelled; ajv rejects such shapes, and the comparator raises a contract error for them. The lab's own TOML configuration is a hand-written frozen pydantic model, not a wire contract. New schemas: `bench_request`, `bench_failure`, `benchmark_cities`, `lab_reference`, `discrepancy_report`, `pipeline_manifest`. Manifest `inputs` paths are repository-relative (shared files); `outputs` paths are relative to the manifest, because an output directory travels as one artifact | `schemas/`, `lab/src/dm_lab/schema/`, `lab/tools/codegen/` |
| D28 | Ephemeris custody (added S03) | Architect + Security | `de440s.bsp` is never committed. It is fetched from `https://ssd.jpl.nasa.gov/ftp/eph/planets/bsp/de440s.bsp` and used only when its sha256 is `c1c7feeab882263fc493a9d5a5b2ddd71b54826cdf65d8d17a76126b260a49f2` (32 726 016 bytes; the NAIF mirror served identical bytes on 2026-10-21). It is cached in gitignored `lab/.cache/` (`$DM_LAB_CACHE` overrides) and in the `ci-lab` cache. This is a development-time fetch; the app's egress allow-list (`REQ-PRIV-006`) is unaffected | `lab/config/harness.v1.toml`, `ci-lab` |
| D29 | Engine bench contract and benchmark rules (added S03, amended after the S03 review) | Accuracy + Architect | **Contract.** stdin: `bench_request.v1` lines `{observer, profileId, day, hijri}`. Until the hijri package exists, `hijri` is the ADR-016 tabular state (`EXPECTED`) supplied by the lab, so the bench never invents one; the trace must echo it in `inputs.hijri`. stdout: exactly one line per request, in order — `calculation_trace.v1`, or `bench_failure.v1` with an Appendix J code. A time whose origin is `NO_EVENT` carries no instants and every other time carries all three (`rawUtcMs` is the instant after the rule, before rounding); a violation is a contract error. **Comparison.** Raw instants SUNRISE↔sunrise, DHUHR↔transit, MAGHRIB↔sunset, only for allow-listed profiles (`[benchmark] profiles`, now `engine.default`) and only when compared events carry no adjustment other than rounding. A Dhuhr offset (`--dhuhr-offset-minutes`, default 0 = Appendix A's absent `offsetMinutes`) is removed before the transit residual is judged; a whole-minute residual is reported as `DHUHR_OFFSET`, separately from `INSTANT`. Other events need a later reference extension. **Verdicts.** Residual beyond tolerance (`INSTANT`), wrong offset (`DHUHR_OFFSET`), wrong origin or no-event reason, including a fallback where a root exists (`ORIGIN`, `REQ-DOM-002`), and bench failures are `UNKNOWN` and block. `NEAR_TANGENT` and `AMBIGUOUS_REFERENCE` mismatches are `REFERENCE_AMBIGUITY` and do not block. `lab benchmark` exits 1 when anything blocks | `schemas/bench_*.v1`, `harness.v1.toml` `[benchmark]` `[hijri]`, `lab/README.md` |
| D30 | Appendix H date set and city file (added S03) | Accuracy | Season days are the civil dates of the instants in the city's zone. A DST day is one whose local-noon UTC offset differs from the previous day's; it selects ±7 days inclusive (15 days). Ramadan start/end are the first and last days of the tabular (ADR-016, `Expected`) Ramadan 1447–1449. All days are clipped to the requested years. Cities carry an IANA zone and an ISO country, which Appendix H does not list. Appendix H names 49 cities; S05's "46 cities" is read as all 49 (the polar cities with typed `NO_EVENT`s). **Decided 2026-10-21** (project owner, on the implementer's recommendation): the S05 differential and golden corpus use all 49 cities. Tromsø, Longyearbyen and Utqiaġvik stay in, because polar days and nights are exactly where an engine must return typed `NO_EVENT`s instead of invented times (§0.2 rule 10); "46" is treated as a miscount | `lab/benchmarks/cities.v1.json` |
| D31 | Published source of the S03 done-test (added S03) | Accuracy | USNO Astronomical Applications refused every connection from the build environment on 2026-10-21. The done-test therefore uses the MET Norway Sunrise API 3.0 (Norwegian Meteorological Institute, NLOD 2.0 / CC BY 4.0), which uses the same 0.833° definition: 3 cities × the 2026 equinoxes and solstices. MET Norway publishes truncated UTC minutes (all 36 values lie 3.7–57.3 s before the reference, which rounding could not produce), so the test requires the reference truncated to the minute to equal the published minute. That bounds any systematic bias to a few seconds. A separate check matches Skyfield's own rise/set/transit finders to ≤ 2 ms. **Decided 2026-10-21** (project owner, on the implementer's recommendation): MET Norway is accepted. It is a national government institute, operated independently of this project, using the ADR-003 definition, and it also matched our transit and sunset. A USNO cross-check is welcome when the site is reachable but is not required | `lab/tests/data/published_sun_events_2026.json` |
| D32 | ΔT evaluation epoch (added S04) | Accuracy + Architect | Espenak–Meeus (2006) polynomials are evaluated at the continuous decimal year `y = 2000 + (t − 2000-01-01T00:00Z) / 365.2425 d` instead of the month midpoint, so ΔT has no monthly steps inside a solver bracket. The model's own interval joins step by ≤ 0.26 s (largest at 1600). The difference from the month-midpoint convention is ≤ 0.03 s of ΔT in 2026–2028 | `geo_salah_core/lib/src/astro/delta_t.dart` |
| D33 | Equation of time and the interpolation grid (added S04) | Accuracy + Architect | §6.4 ¶2's EoT is **defined** as the apparent minus the mean Greenwich hour angle, `E = ν − α − (15°·UT_h − 180°)`, so `H = 15°·UT_h − 180° + σ + E` is exactly the SPA hour angle at every sample. The SPA paper's eq. A1 (mean longitude in TT) differs from it by ≈ 0.2 s and would eat the whole 0.2 s Dhuhr tolerance (D26), so it is not used. The five samples (δ, E and R, since parallax needs R) are 12 h apart. They are centred on the day's mean-solar-noon guess, `anchor − 24 h … anchor + 24 h`, rather than on 00:00 UTC, because a civil day's segment `[A₋, A₊]` can lie up to 26 h on either side of 00:00 UTC (UTC−12…+14). Slopes are central differences, second-order one-sided at the two end samples. Interpolated altitude was measured within 1.1·10⁻⁶° of exact SPA (12 test cities at the 2026 equinox and solstices) and a property test bounds it at 1·10⁻⁵°; each converged root and each transit gets one exact SPA Newton step | `geo_salah_core/lib/src/astro/{exact_sun,solar_day_model,interpolation}.dart` |
| D34 | Bracket exhaustiveness (added S04) | Accuracy + Architect | Each half segment (ADR-004) is split at the stationary points of the interpolated altitude into monotone pieces. The altitude rate is sampled at ≤ 1 h spacing and each sign change is solved with Brent to 1 ms. A target is crossed on a piece exactly when it lies between the piece's end values, so every root is bracketed; with no sign change the result is no root, never an extrapolation. The rate sampling is provably complete for `\|φ\| ≤ 89.9°` (`d(sin h)/dt = A·sin H + B` puts two zeros in one cell only when `cos φ ≤ 1.3·10⁻³`). Near a tangency the exact-refined instant may sit up to `1·10⁻⁵° / \|dh/dt\|` (≤ 60 s) from the interpolated root, which is the D26 `NEAR_TANGENT` regime. A day whose upper transit has no local date `D` (a skipped calendar day such as `Pacific/Apia` 2011-12-30) has no segments | `geo_salah_core/lib/src/solver/{monotone_pieces,culmination_segments}.dart` |
| D35 | Domain of the astronomical core (added S04) | Architect | The SPA is valid for years −2000 to 6000 (paper abstract); `ApparentSun.at` throws `RangeError` outside it, although `CivilDate` admits years up to 9999. No Appendix J code or `NoEventReason` fits a date outside the ephemeris or a skipped calendar day, so S05 decides how `calculateDay` reports them (default: a documented `ArgumentError` precondition, years 1–6000; a skipped day yields a `DayResult` without times). Two SPA paper erratum notes are recorded with the S04 tests rather than corrected: Table A5.1's printed `H′ = 11.10629°` disagrees with its own `H − (α′ − α) = 11.10627°`, and §A.2's example "sunset 00:20:19 UT" is the evening of 16 October local time, because A.2 limits `m₂` to the UT day | `geo_salah_core/test/astro/spa_paper_example_test.dart`, `test/solver/crossings_test.dart` |
| D36 | Domain of `calculateDay` (added S05; resolves D35) | Architect | Days in years 1–5999 (`CalculateDay.lastYear`; the ephemeris ends in 6000 and a day needs its neighbours). A later day is a documented precondition that throws `ArgumentError`, like an invalid `CivilDate`; the bench answers it as a contract error (exit 2), because no Appendix J code describes it and the lab never sends one. A calendar day the zone skipped (`Pacific/Apia` 2011-12-30) has no upper transit, so it is no prayer day: `calculateDay` returns `Ok(DayResult)` with **no times**, and the neighbouring days' segments still tile time. `calculation_trace.v1` requires at least one time, so such a day has no trace; the bench answers it with `bench_failure` `TZ_UNRESOLVED` ("calendar day … does not exist in …"). Revisit when the trace schema next changes | `geo_salah_core/lib/src/api/calculate_day.dart`, `src/bench/bench_runner.dart` |
| D37 | Horizon crossing choice and no-event reason (added S05) | Accuracy + Architect | Sunrise is the **last** rising crossing of the target in `[A₋, T₀]` and Maghrib the **first** setting crossing in `[T₀, A₊]`: the edges of the daylight around the transit. Several crossings in one direction occur only near a grazing crossing (the lab reference has none in 2026–2028, D25). With no crossing in the event's direction the Sun stays on one side of the target: `NoEvent(polarDay)` when the interpolated altitude at `T₀` is at or above the target, `NoEvent(polarNight)` otherwise — never a fallback or an extrapolation (REQ-DOM-002). A rule an event cannot use (a horizon rule for Dhuhr, a transit rule for any other event) is `EngineFailure.invalidProfile`; an elevation policy other than `NONE` is `unsupportedPolicy` (ADR-003) | `geo_salah_core/lib/src/rules/horizon_rule_solver.dart` |
| D38 | Calculation ID details (added S05) | Architect | The engine calculates at the coordinates **rounded to 6 decimals** (half away from zero, ≈ 0.1 m), so equal `inputsHash`es give equal raw instants (REQ-DOM-004). The hashed object is exactly the trace's `inputs` (Hijri confidence as its wire code); JCS (RFC 8785) is implemented in the package for the JSON subset it needs (ECMAScript number form, members sorted by UTF-16 code unit). The ID hashes the UTF-8 string `inputsHash|engineVersion|deltaTModel|tzdbVersion` with `inputsHash` in lowercase hex. `engineVersion` is the `geo_salah_core` package version (a test keeps them equal); a release that can change any output bumps it. `crypto` 3.0.7 (BSD-3-Clause, §5.4) becomes a direct dependency | `geo_salah_core/lib/src/trace/{calculation_inputs,calculation_id,canonical_json}.dart`, ADR-011 table |
| D39 | S05 interim day output (added S05) | Architect | Until S06 adds adjustments, rounding (ADR-005), flags and the ordering guard, `displayedUtcMs = rawUtcMs`, `flags` and the adjustment trace are empty, and a time is labelled by the two §6.2 rows an `ENGINE_DEFAULT` profile reaches: `primary → Calculated`, `noEvent(reason) → Unknown(reason)`; the full confidence mapper (REQ-DOM-050) and `calculateRange` arrive in S06. `EventRule` has the `transit` and `horizon` variants; S06 adds the others to the sealed type and the switch in `CalculateDay`. `PrayerProfile` carries only `profileId`, `version`, `rules` and `elevationPolicy` until S07. Each §6.3 operation is a one-method use case (`CalculateDay`, §17.1 S); the `GeoSalahEngine` facade (REQ-DOM-020) is assembled once its four methods exist | `geo_salah_core/lib/src/api/`, `src/model/` |
| D40 | S05 bench stand-ins and golden corpus v1 (added S05) | Accuracy + Architect | The bench (§15 D29) runs with **(a)** the §13 fixed-offset `TzDatabase` fake: each Appendix H zone (and common aliases, 44 ids) at its constant **standard** offset, no DST, version sentinel `0000a` that no TZDB release has; an unknown zone is `TZ_UNRESOLVED`. Raw instants do not depend on it (`T₀` lies near local noon), but `dayOffset` can be off by a day near local midnight in summer. `dm_civil_time` replaces it in S10. **(b)** An `engine.default` stand-in, version sentinel `0000.0.0`: the §6.5 rule *types* `sunrise: horizon`, `dhuhr: transit`, `maghrib: horizon` at the §6.2 defaults, with no value written in code; S07's profile loader replaces it. Both live in `lib/src/bench/`, are not exported and are never used by the app. **Golden corpus v1** = the engine's raw instants and origins (not IDs, displayed times or day offsets, which S06, S07 and S10 change) for the 49 Appendix H cities on the 15th of each month 2026–2028, written by `tool/update_golden.dart` after `lab benchmark --engine dart --tags DAY_OF_MONTH` gave 1764 cases, 5292 events agreed, 0 discrepancies, max \|residual\| 1575 ms (every reference case: 4188 cases, 12564 events, 0 discrepancies, max 1575 ms); each golden file records its fixed offset | `geo_salah_core/lib/src/bench/`, `test/golden/`, `tool/update_golden.dart` |
| D41 | Altitude and shadow-factor rules (added S06) | Accuracy + Architect | **`solarAltitude`** targets the geometric altitude `−degrees` with no refraction and no dip (ADR-003). It may define any event but Dhuhr and is searched in that event's ADR-004 half. The crossing is chosen as in D37: the last rising crossing before `T₀`, the first setting one after it. With no crossing, an altitude at `T₀` below the target is `NoEvent(polarNight)` and anything else `NoEvent(twilightAbsent)`. **`shadowFactor`** defines descending events only. `φ` is the geodetic latitude of the rounded observer (D38) and `δ(T₀)` the interpolated geocentric declination at the transit (≤ 10⁻⁶° from SPA, D33). `90° − \|φ − δ\| ≤ 0` is `NoEvent(asrUndefined)`. With no setting crossing, a Sun above the target at `T₀` is `NoEvent(polarDay)`; one below it (parallax at a near-zero noon altitude) is `asrUndefined`. **Domain:** the engine only refuses physically meaningless values (`0 < degrees < 90`, `k ≥ 1`; otherwise `invalidProfile`). The Appendix A bounds (5–25°, `k ∈ {1, 2}`) are the S07 validator's | `geo_salah_core/lib/src/rules/{altitude_rule_solver,shadow_rule_solver,half_segment_crossing,day_rule_solver}.dart` |
| D42 | Interval rules (added S06) | Architect | The event is the base's **raw** instant ± the duration, floored to 1 ms (REQ-DOM-003). A base with `NoEvent` gives the event `NoEvent` for the same reason; S08 decides intervals on a fallback base. The base must be another event of the profile solved by a non-interval rule. `intervalAfter` needs a base earlier in `PrayerEvent` order and `intervalBefore` a later one, and the duration must be positive; anything else is `invalidProfile`. Appendix A limits bases to `maghrib`/`fajr`; the engine accepts any base that obeys the order rule | `geo_salah_core/lib/src/rules/{interval_rule_solver,day_rule_solver}.dart` |
| D43 | Adjustment and rounding mechanics (added S06) | Sharia (values) + Architect (mechanics) | Per event: rule → `perEventMinutes` (§6.4 ¶8; `\|m\| > maxAbsMinutes` is `invalidProfile`; a `PER_EVENT_OFFSET` step, reason `adjustments.perEventMinutes`, only when `m ≠ 0`; no `evidenceId` until S07 models evidence) → rounding. The mode is the event's override, else the profile default; there is no code default (D4). Rounding works in **local** minutes, with the zone offset at the pre-rounding instant. `ceil`/`floor` keep an instant already on a boundary, and `nearest` rounds half a minute up. Every timed event gets exactly one `ROUNDING` step, also when `deltaMs = 0`, reason `rounding.<mode>`. `nearRoundingBoundary` is set when the pre-rounding instant is < 500 ms from its nearest local minute boundary. `rawUtcMs` stays the rule's instant; `dayOffset` is taken from the displayed instant. The trace lists events in `PrayerEvent` order, each event's steps in the order applied. The S06 `PrayerProfile` subset adds `status`, `authorityType`, `benchmarkReportId`, `roundingDefault` (required), `roundingOverrides`, `perEventMinutes` and `maxAbsMinutes`. Absent overrides and offsets are empty (`maxAbsMinutes` 0): an absence, not a value. Engine version **0.2.0** (outputs changed, D38) | `geo_salah_core/lib/src/policy/{adjustments,rounding,event_finisher}.dart`, `src/model/prayer_profile.dart` |
| D44 | Result flags the engine sets (added S06) | Architect | The engine sets only flags that its inputs determine. **S06:** `nearRoundingBoundary` per event (D43). `dstTransitionDay` on every time of a day where the zone offset at local 00:00 differs from the offset 1 ms before the next local 00:00 (both found at the day's starting offset). `manualCoordinateResolution` on every time when `Observer.source == manual`. **Later:** `highLatitudeFallback` (S08); `hijriExpected` (S08, on the events whose rule depends on the Ramadan state; on every time it would mark every day until the hijri package ships); `referenceModeAuthorityPoint` and `noLocalProfile` (S07 reference mode and resolver); `staleTzdb` (S10, needs the package age); `zoneBoundaryProximity` (S11 resolver); `lowLocationAccuracy` (S13, which needs a threshold that ADR-014 does not give) | `geo_salah_core/lib/src/policy/day_flags.dart` |
| D45 | Ordering guard and the one polar tie (added S06) | Sharia + Architect | The guard compares consecutive events that have an instant, in `PrayerEvent` order. Ties are allowed for Imsak = Fajr, and between two fallbacks that both carry `highLatitudeFallback` (S08); everything else must be strictly increasing. A violation returns `Err(orderingViolation(<the day's calculation_trace.v1 JSON>))`. **Observed:** 49 Appendix H cities × every day of 2026–2028 (53 704 days) with the `engine.default` stand-in give exactly **one** violation. On Tromsø 2026-11-21 the noon Sun stands 0.1° high; Asr (k = 1) falls 37 s after Dhuhr and both round up to 10:31 UTC. The engine reports it as REQ-DOM-001 requires and invents no fix. Whether such a day has an Asr, or takes a high-latitude method, is a religious decision for the S08 chain and the Sharia board. Until then the app receives that day's failure. No benchmark or golden day is affected | `geo_salah_core/lib/src/policy/ordering_guard.dart` |
| D46 | Confidence mapping inputs (added S06) | Architect | `ConfidenceMapper` (REQ-DOM-050) reads only the origin and the profile's `status`, `authorityType` and `benchmarkReportId`, which replaces the S05 inline mapping (D39). §6.2 does not define the fallback row's `perturbationMinutes(method)`. **Default:** S08 supplies the fallback instant's ±1 km sensitivity (§6.7), rounded up to whole minutes; the 5-minute floor is §6.2's. Before S08 no fallback exists, so the engine passes 0 | `geo_salah_core/lib/src/policy/confidence_mapper.dart` |
| D47 | `calculateRange` domain and cache (added S06) | Architect | `1 ≤ days ≤ 400` (§6.3), otherwise `RangeError`; a last day after year 5999 is `ArgumentError` (D36 preconditions). `hijriFor` is called once per day, in order. The first failing day ends the range with its failure. A per-call `SunSampleCache`, keyed by the exact instant, shares three of each day's five SPA samples (2N + 3 samples for N days). Results are bit-identical to `calculateDay` (property test), and no state outlives a call (§17.2). Both use cases run one internal `DayCalculation` pipeline | `geo_salah_core/lib/src/api/{calculate_range,day_calculation}.dart`, `src/astro/sun_sample_cache.dart` |
| D48 | Bench profile data and golden corpus v2 (added S06; replaces D40 (b)) | Accuracy + Architect | The `engine.default` stand-in leaves Dart and becomes **profile data**: `geo_salah_core/bench/profiles/engine.default.json`. It is an Appendix A document cut to the members the S06 engine reads, version sentinel `0000.0.1`, `DRAFT_UNVERIFIED`, and every value is cited: §6.5 Fajr/Isha 18° and k = 1, ADR-003 horizon, ADR-005 rounding `ceil` with `sunrise: floor`, Imsak `null`. Unread members (high-latitude chain, adjustments, scope, approvals) are omitted, not invented. `BenchProfileReader` reads it for the bench, the golden tool and the tests; S07's loader replaces it. **Golden v2** (schemaVersion 2) adds Fajr, Asr, Isha and `displayedUtcMs`; the v1 entries are identical (5292 of 5292). The lab reference has no Fajr, Asr or Isha (D29). Those 5292 entries are engine output, checked by property tests against the exact SPA altitude at the instant (rule target within 10⁻⁵° plus 1 ms of rate) but **not** by an independent reference. ADR-019's "lab-confirmed" holds for them only after a lab `reference-update` adds twilight and Asr crossings. That update is owned by Accuracy; the engine author may not edit the lab (kickoff §C) | `geo_salah_core/bench/profiles/`, `src/bench/bench_profile_reader.dart`, `test/golden/`, `tool/update_golden.dart` |
| D49 | `REQ-PERF-001` baseline (added S06) | Mobile + Accuracy | Measured with `geo_salah_core/tool/range_baseline.dart`, AOT (`dart compile exe`), Dart 3.13.5, Windows 11 x64, Intel Core Ultra 7 155H, one isolate. A one-year `calculateRange` with the `engine.default` stand-in, median of 5 after 3 warm-ups, takes **27–39 ms per city** (Makkah, Cairo, London, Oslo, Reykjavik, Kiritimati; two runs on 2026-10-21; worst per-city median 38.8 ms). The same year day by day through `calculateDay` takes 31–54 ms. The gate is < 500 ms on **Samsung Galaxy A50 / Android 11** (release, median of 5) and < 150 ms on Pixel 8. **The device measurement is still owed**, at the first app build (S16–S17) and as the §12 RC gate; a desktop figure is not evidence for it | `geo_salah_core/tool/range_baseline.dart` |

---

## 16. Glossary

| Term | Meaning here |
|---|---|
| **SchedulePlan** | Precomputed, native-readable alarm plan (§7.7); the only thing native scheduling reads. |
| **Snapshot** | 48-h display data for widgets/watch; never recalculated natively. |
| **SolarState / SkyPhase** | Engine output driving the theme (ADR-018, Appendix G). |
| **PrayerProfile** | Geo-scoped, signed rule policy replacing "Country Profile" (ADR-007). |
| **TUF-lite** | Four-role signed metadata with sequence + expiry (ADR-009, Appendix C). |
| **Culmination segment** | Prayer-day search window bounded by solar lower transits (ADR-004). |
| **Generation** | Monotonic id of a desired alarm plan; reconciliation acts on future entries of older generations only. |
| **Slice** | Ordered mergeable unit of work in §13 with a done-test. |
| **Holdout** | Frozen benchmark set in a private repo, used to prevent profile over-fitting. |
| **Pure Dart set** | The six packages named in rule 2 that import nothing from Flutter or the platform. |

---

## 17. Code quality bar — clean code, SOLID, strict typing `[DECIDED]`

Binding for every language. CI enforces the mechanical parts; reviewers enforce the rest with §17.8.

### 17.1 SOLID as concrete rules in this codebase

| Principle | Rule here | Example |
|---|---|---|
| **S** — Single responsibility | One use case = one class with one public method (`call`). One repository interface per aggregate. One pigeon API per platform concern. A file changes for one reason. | `BuildSchedulePlan` only builds the plan; `ReconcileAthan` only reconciles. Never a `ScheduleService` doing both. |
| **O** — Open/closed | Variation points are **sealed hierarchies + exhaustive `switch`**, never `if/else` on type tags. New `EventRule`, `HighLatitudeMethod`, `Failure`, `UiState` variants are new types; existing code is extended via the switch, never patched with flags. | Adding `EventRule.intervalBefore` touches the sealed class and the solver's switch; nothing else. |
| **L** — Liskov substitution | Adapters honour the port contract documented in its doc comment (idempotency, error types, nullability). Fakes implement the same port and run the same contract tests (`*_contract_test.dart`). | Every `AthanSchedulerApi` implementation (Android, iOS, fake) passes the shared contract suite. |
| **I** — Interface segregation | Ports are narrow and consumer-defined. No god repository: `ReadDayResults`, `WriteDayResults`, `ActivePackagePointer` are separate; a use case depends only on what it calls. | `ResolveCalculationId` depends on `ReadProvenance` only. |
| **D** — Dependency inversion | `domain`/`application` declare ports; `data` and platform adapters implement them; wiring only in `app/di.dart` (Riverpod) / Go `cmd/` / Swift & Kotlin composition roots. No service-locator lookups inside logic. | A use case receives `GeoSalahEngine`, `Clock`, `ReadActiveProfile` via constructor; never `GetIt.I<…>()`. |

Supporting principles: composition over inheritance (sealed types for data variants only); immutability by default; explicit over implicit (no magic strings, reflection, `dynamic`); make illegal states unrepresentable; pure core / impure shell; fail loudly in dev, degrade honestly in prod.

### 17.2 Dart (engine packages and Flutter app)
- `analysis_options.yaml` (from `dm_lints`): `strict-casts`, `strict-inference`, `strict-raw-types`; `very_good_analysis` plus `always_declare_return_types`, `avoid_dynamic_calls`, `prefer_final_locals`, `prefer_final_in_for_each`, `unnecessary_late`, `cast_nullable_to_non_nullable`, `public_member_api_docs` (pure packages), `require_trailing_commas`, `sort_constructors_first`.
- **Forbidden**: `dynamic` (except at the JSON parse boundary, immediately narrowed); `Object?` escaping a public API; `!` without a `// SAFETY:` comment; `as` downcasts (use patterns); `late` in domain/application types; `print`; mutable static state; `part` files outside codegen; catching `Exception`/`Object` without rethrow or conversion to a typed `Failure`.
- **Required**: Dart 3 class modifiers on every class; `freezed` immutables; exhaustive `switch` expressions (no `default` on sealed types); `Result<T, Failure>` across layers; epoch-ms ints / `Duration`, never `DateTime.now()` outside the injected `Clock`; `const` constructors wherever possible; one public type per file; `lib/src/` private, `lib/<pkg>.dart` the only export surface.
- Naming: types `UpperCamelCase`, members `lowerCamelCase`, files `snake_case.dart`; use cases are verb phrases, ports are capabilities (`ReadDayResults`), adapters name their technology (`DriftDayResultsStore`); tests mirror source paths.
- Size heuristics: a function fits one screen (≈ 40 lines); ≤ 7 public members per class; a widget `build` ≤ 80 lines or split into sub-widgets (not helper methods returning widgets).
- Flutter: `const` widgets; no business logic in `build`; Riverpod is the only state mechanism (no `setState` outside leaf animation widgets); `ConsumerWidget` over `StatefulWidget`; every interactive widget has `Semantics`.
- Doc comments on every public API in the pure packages state inputs, invariants, failure cases and the determinism guarantee.

### 17.3 Kotlin (`athan-core`)
- `kotlin { explicitApi() }`, `allWarningsAsErrors = true`, K2, version catalog. Lint: `detekt` (+ formatting) with complexity threshold 10, `ktlint`, `MaxLineLength` 120.
- **Forbidden**: `!!`; platform types in public API; `lateinit` outside Android lifecycle fields; `GlobalScope`; blocking calls on main; `Any` in signatures; catching `Throwable`/`Exception` without re-throwing `CancellationException`; mutable collections in public APIs; stateful `companion object` singletons.
- **Required**: `internal` by default; `data class` / `value class` records; `sealed interface` outcomes (`ReconcileOutcome.Applied | Partial | Failed`); structured concurrency with injected dispatchers; `kotlinx.serialization` with `ignoreUnknownKeys = true`; constructor injection; composition root in the app module.
- Android: receivers do the minimum and hand work > 1 s to `WorkManager`; `FLAG_IMMUTABLE`; `exported=false`; `Application.onCreate` wires only.

### 17.4 Swift (`AthanKit`)
- Swift 6 language mode, `-strict-concurrency=complete`, `Sendable` across actor boundaries, `@MainActor` only for UI-facing types. `SwiftLint --strict`, `SwiftFormat`; `force_unwrapping`, `force_cast`, `force_try`, `implicitly_unwrapped_optional` are errors.
- **Required**: value types by default; `enum` with associated values for state machines; protocol-oriented ports with one fake each; typed `throws` or domain `Error` enums (never `NSError` in APIs); `Codable` models with `decodeIfPresent`; `final class` for reference types; `private` by default; initializer injection.
- **Forbidden**: `Any`/`AnyObject` in public APIs; `DispatchQueue.main.async` in new code; stringly-typed notification names / defaults keys; singletons other than the composition root.

### 17.5 Go (`control-plane`, `gsctl`)
- `golangci-lint` (`errcheck`, `staticcheck`, `gosec`, `govet`, `revive`, `errorlint`, `exhaustive`, `gocritic`), `gofumpt`, `go vet`, `-race`.
- Hexagonal layout; interfaces are small (1–3 methods) and defined by their consumers. Errors wrapped with context (`%w`), sentinel `var Err…`, typed errors for HTTP mapping, `log.Fatal` only in `main`, no ignored errors without a comment.
- `context.Context` first on every I/O function; no package-level mutable state; one typed config loaded once; `sqlc` + `goose`; table-driven tests naming REQ IDs. HTTP: RFC 9457, thin handlers, schema-generated request types, timeouts and body limits on every route.

### 17.6 Python (`lab/`, `data-pipelines/`)
`uv`; `ruff` (`ALL` with documented ignores); `mypy --strict`; `pytest` + `hypothesis`. Typed records via `pydantic` v2 generated from `schemas/`; `pathlib`; no notebooks in the repo; every pipeline is deterministic given pinned inputs and records input hashes in its output manifest.

### 17.7 Tests as code quality
Arrange–Act–Assert; one behaviour per test; names cite the REQ. Never mock the unit under test or the pure engine; fake only ports. Contract tests run against real and fake port implementations. Property tests for every §3 invariant; golden tests for determinism; no snapshot tests presented as assertions. A bug fix adds the failing test first.

### 17.8 Review checklist (every PR)
1. One reason to change per class? Any type-tag `if` that should be a sealed variant?
2. Layer boundaries respected (arch lint green); wiring only in the composition root?
3. Any `dynamic`, `!`, `!!`, force-unwrap, `Any`, ignored error, or catch-all without justification?
4. Fallible paths typed and mapped to a user-facing state?
5. New public APIs documented with their contract and covered by a contract test?
6. Anything religious, locational or time-zone-related hard-coded that belongs in a profile or package?
7. Tests named by behaviour/REQ; fakes limited to ports; invariants property-tested?
8. Contract changed ⇒ schema first, regenerated, ADR updated?

---

## 18. Functional specification (business analysis)

### 18.1 Personas

| Persona | Context | Primary needs | Design consequences |
|---|---|---|---|
| **Omar**, 34, Cairo commuter | Android mid-range, Arabic UI, hears the mosque Adhan daily | app must match what he hears; reliable Fajr alarm; Ramadan Imsak | `referenceMode` visibility; Ramadan rules in MVP; Android exact path |
| **Noura**, 41, Riyadh parent | iPhone 15, iOS 27, Focus on at night | an alarm that breaks Focus; trust that it will ring | AlarmKit; `Unknown` honesty; Athan Test |
| **Yusuf**, 22, Oslo student | Travels EG↔NO; high-latitude summers | correct Isha after midnight; visible fallback method; safe travel | culmination day; fallback disclosure; Travel Mode V1 |
| **Hajja Fatma**, 68, Alexandria | Low vision, large text, Arabic only | big readable next prayer, screen reader, few taps | 200 % type; semantics; quiet Home |
| **Ahmed**, 29, Dubai engineer | Precision-minded, sceptical of apps | wants to see *why* a minute is what it is | Accuracy Passport; shareable `CalculationId` |

### 18.2 Epics and user stories (MVP unless marked) — Given/When/Then; mapped to REQ IDs

**E1 First run & location**
- **US-01** As a new user I get today's times without an account or network. *Given* fresh install in airplane mode; *When* I finish onboarding with approximate location or a manual place; *Then* Home shows today's six times with confidence labels within 3 s. (`REQ-PKG-003`, `REQ-PERF-002`)
- **US-02** As a privacy-conscious user I can refuse location and pick a place. *Given* I deny location; *When* I search "Alexandria" offline; *Then* a manual context is created, labelled "Manual place · city centre", flagged `manualCoordinateResolution`. (`REQ-PRIV-002`)
- **US-03** Near a zone/country boundary I am offered precise location once, with the reason. (ADR-014)

**E2 Daily prayer times**
- **US-04** Home shows next prayer, countdown and today's list; Isha after midnight shows "+1". (`REQ-TIME-002`)
- **US-05** Each time shows its confidence label; tapping opens the Passport entry. (`REQ-UX-001`)
- **US-06** With no local authority profile I am told the engine default is used and times are `Calculated`. (ADR-007)
- **US-07** In Ramadan, Imsak (if defined) and the Ramadan Isha rule apply, with an `Expected`/`Confirmed` Hijri badge and a one-tap ±1 day override. (ADR-016)

**E3 Accuracy Passport (P1)**
- **US-08** I see inputs, versions, raw vs displayed instant, rounding mode, flags in plain language and a sensitivity line. (§6.4)
- **US-09** I share a time; a friend's device recomputes and shows match/mismatch. (§6.4 ¶11)

**E4 Athan (P2)**
- **US-10** I enable Athan per prayer, choose a sound and set a pre-reminder. (`REQ-ALM-042`)
- **US-11** Athan Health shows Ready/Limited/Not ready/Unknown with the exact reason and a fix button opening the right OS screen. (`REQ-ALM-003`)
- **US-12** Athan Test rings in 60 s via the real path and asks whether I heard it. (`REQ-ALM-040`)
- **US-13** Alarms keep ringing after reboot and after 3 weeks unopened; 24–48 h before the plan ends I am told to open the app. (`REQ-ALM-002`, `REQ-ALM-010`)
- **US-14** On iOS without AlarmKit I am told alarms are "scheduled (unverifiable)" and why. (ADR-013)

**E5 Qibla** — **US-15** I see the true-north bearing, a compass with accuracy, calibration guidance when poor, and a numeric fallback. (`REQ-DOM-030`)

**E6 Data freshness** — **US-16** Profiles/TZ/Hijri update silently; a change note appears when displayed times change. (`REQ-PKG-001`) · **US-17** If freshness cannot be verified I see "data last verified N days ago" — times still work. (`REQ-PKG-002`)

**E7 Settings, privacy, accessibility** — **US-18** Arabic/English, digits, theme mode (sky/light/dark/system), reduced motion honoured. (`REQ-UX-020`) · **US-19** I export a redacted diagnostic bundle and see its contents first. (`REQ-PRIV-005`) · **US-20** I can read attributions and the privacy policy offline. (§24)

**V1**: US-21 widgets; US-22 Travel Mode confirmation ("You seem to be in Oslo. Switch schedule?"); US-23 Ramadan fasting window. **V1.5**: US-24 selected mosque (Verified/Observed only); US-25 Iqama typed; US-26 wearables.

### 18.3 Permission flows (with denial branches)

| Step | Android | iOS | On denial |
|---|---|---|---|
| Location | `ACCESS_COARSE_LOCATION` first; fine only per ADR-014 | "When in use", reduced accuracy first | Manual place flow; Home shows "Manual place" chip |
| Notifications | `POST_NOTIFICATIONS` (API 33+) at Athan enable | `UNUserNotificationCenter` auth at Athan enable | `notReady(needsNotificationPermission)` + settings button |
| Exact alarm | `canScheduleExactAlarms()`; deep link `ACTION_REQUEST_SCHEDULE_EXACT_ALARM` | — | `limited(inexactFallback)`; inexact scheduler used |
| AlarmKit | — | `AlarmManager.requestAuthorization()` on iOS 26+ | notification path; `limited(unverifiableDelivery)` |
| Battery optimisation | informational card from `oem_guidance.json`; never mandatory | — | `limited(batteryRestricted)` |
Permissions are requested at the moment of need; first launch asks only for approximate location.

### 18.4 Screen inventory and states (`UiState` sealed classes)

| Screen | States |
|---|---|
| Onboarding | `step(welcome|location|place|done)`, `resolving`, `failed(failure)` |
| Home | `loading`, `ready(day, nextPrayer, health, sky)`, `needsLocation`, `needsAttention(reasons)`, `noProfile(engineDefault)`, `error(failure)` |
| Day timeline | `loading`, `ready(days)`, `error` |
| Passport | `ready(entry)`, `importMismatch(details)`, `notFound` |
| Athan settings | `ready(settings, health)`, `saving`, `error` |
| Athan Health | `evaluating`, `ready`, `limited(reasons)`, `notReady(reasons)`, `unknown(reasons)` |
| Athan Test | `idle`, `scheduled(countdown)`, `fired`, `askHeard`, `recorded(result)` |
| Qibla | `noHeading`, `calibrating(accuracy)`, `ready(bearing, heading, accuracy)`, `numericOnly` |
| Manual place | `idle`, `searching`, `results(list)`, `empty`, `coordinateEntry`, `error` |
| Packages & change notes | `upToDate(lastVerified)`, `syncing`, `freshnessUnverified(days)`, `updated(changeNotes)`, `rollbackAvailable` |
| Settings / Privacy / Attributions | static; `exporting` for diagnostics |

### 18.5 Status copy (shared constants; prohibited-word tests)

| Label | en | ar | Never co-occurs with |
|---|---|---|---|
| Calculated | Calculated for your location | محسوب لموقعك | "verified", "official" |
| Authority aligned | Matches <authority> within 1 min | متوافق مع <الجهة> | — |
| Verified | Verified · <source> · updated <date> | موثّق | — |
| Estimated | Estimated · ±<n> min | تقديري | a single minute without range |
| Observed | Reported by <n> users · <date> | ملاحظات المستخدمين | "verified" |
| Unknown | Not available · <reason> | غير متاح | any number |
| Expected (Hijri) | Expected — not yet announced | متوقع — لم يُعلن بعد | "confirmed" |

### 18.6 Release scope and exit criteria

| Release | Must | Should | Exit criteria |
|---|---|---|---|
| **MVP beta** | E1–E7; Android exact Athan; iOS AlarmKit + notification path; seed profiles on `lab` | pre-reminders | §12 gates green; 72 h device suite on tier-1 devices; 0 open P1/P2; accessibility audit passed; privacy gates green |
| **MVP GA** | beta + **Sharia-approved** profiles for launch countries on `production`; confirmed Hijri source per launch country | — | lab: ≥ 95 % of benchmark entries within 1 min of authority tables, no unexplained > 2 min; beta cohort (≥ 200 devices, 4 weeks): Athan "heard" ≥ 90 % on Android exact / AlarmKit; crash-free sessions ≥ 99.5 %; store declarations approved |
| **V1** | widgets, Travel Mode, Ramadan UX, ops dashboard | more profiles | widget correctness suite; TZDB emergency runbook rehearsed |
| **V1.5** | mosque/Iqama typed, wearables | advanced windows | ODbL produced database published; battery budget met |

### 18.7 Non-functional requirements (numeric)

| Quality | Target | Verification |
|---|---|---|
| Cold start to cached Home | < 1.0 s (Galaxy A50) | `REQ-PERF-002` |
| One-year calculation | < 500 ms (Galaxy A50) | `REQ-PERF-001` |
| Installed size | ≤ 60 MB incl. bundled packages and 3 Athan sounds | `REQ-PERF-003` |
| Battery | no background location; background CPU < 1 min/day; Qibla sensors stop ≤ 2 s after leaving the screen | `REQ-PERF-004` |
| Storage | ≤ 120 MB after one year with retention jobs | retention test |
| Offline | calculation indefinitely; Hijri until the next unannounced month; Athan 30 days (Android) / budget-limited (iOS) with warning | `REQ-ALM-010` |
| Accessibility | WCAG 2.2 AA; platform screen readers; 200 % text | `REQ-UX-020` |
| Localisation | ar (Egyptian tone), en; RTL mirror-safe | `REQ-UX-030` |

### 18.8 Content and localisation process
Product owns ARB copy and `oem_guidance.json`; Egyptian-Arabic copy is written by a native writer and reviewed by the Sharia board for religious wording; translation PRs follow code review; future languages (`ur`, `tr`, `id`, `fr`, `ms`) `[DEFERRED V2]`. Athan audio: contracted muezzin, separate Fajr file, loudness −16 LUFS, clip boundaries QA'd.

### 18.9 Device and OS support matrix

| Tier | Devices | Policy |
|---|---|---|
| 1 — certified (own lab) | Pixel 8 (Android 16), Samsung Galaxy A50 (Android 11), Samsung Galaxy S23 (Android 15), Xiaomi Redmi Note 13 (HyperOS), iPhone 15 (iOS 27), iPhone 12 (iOS 18) | full device suite each RC |
| 2 — best effort | Oppo/ColorOS, Vivo, OnePlus, Huawei EMUI (no GMS: attestation degrades gracefully), iPad (compatibility mode) | Firebase Test Lab smoke; beta reports |
| 3 — unsupported | Android < 8.0, iOS < 18, watches (until V1.5) | store targeting excludes |
Minimum 2 GB RAM, 200 MB free. OS policy: current + previous two Android majors; iOS 18/26/27.

### 18.10 Quality beyond automation
Field validation before GA: in each launch city, 3 volunteers log the app's Athan vs the nearest mosque's Adhan for 14 days (minute-level, no coordinates); discrepancies classified like lab findings. Beta programme: ≥ 200 devices across tiers; in-app feedback form (no identity); weekly triage. Accessibility audit with two screen-reader users (ar, en). Religious-accuracy sign-off: the Sharia board signs the GA profile set and the status copy.

---

## 19. Operations

### 19.1 SLOs `[REQ-OPS-003]`

| Service | SLO |
|---|---|
| CDN metadata & package availability | 99.9 % monthly |
| `timestamp.json` freshness | never expired in production (alert at 48 h remaining) |
| Control plane availability | 99.5 % monthly (not user-critical) |
| Publish latency (merge → `lab`) | < 30 min |
| TZDB emergency package | ≤ 48 h from an official announcement affecting a launch country `[REQ-OPS-001]` |
| Hijri month confirmation | ≤ 6 h from official announcement for launch countries `[REQ-OPS-002]` |

### 19.2 Alert catalogue
timestamp expiring < 48 h · publish job failed · verification-canary signature mismatch · attestation failure rate > 20 % · control plane 5xx > 1 % · Postgres disk > 80 % · upstream IANA release detected · launch-country Hijri month boundary within 3 days without confirmation.

### 19.3 Incident severity

| Sev | Definition | Response |
|---|---|---|
| SEV1 | Wrong prayer times or a missed-Athan pattern on `production` in a launch country; signing-key compromise | page on-call + architect + accuracy lead; rollback ≤ 1 h; public note in Passport change notes |
| SEV2 | Distribution down > 1 h; TZ law change unaddressed within SLA | on-call within 4 h |
| SEV3 | Control plane down; dashboard gaps | next business day |
Blameless post-incident review within 5 working days; findings become ADRs/tests.

### 19.4 Runbooks (`docs/runbooks/`)
- **tzdb-emergency.md** — detect (IANA release / news) → confirm affected zones → `data-pipelines tzdata build` → lab transition suite → `gsctl` publish `lab` → `beta` → `production` with `priority: urgent` → verify on canary device → Passport change note.
- **package-rollback.md** — identify bad `sequence` → `gsctl rollback --type X --to <version>` (new manifest, higher sequence, `rollbackOf`) → verify on canary → incident note.
- **key-rotation.md / key-compromise.md** — root rotation signed by old-root threshold; targets rotation via KMS key version; compromise: revoke in new root, re-sign all metadata, force `timestamp` expiry; app hot-fix only if root compromised.
- **hijri-announcement.md** — capture official source → update `hijri` package → publish `urgent` → confirm Ramadan rule activation in lab.
- **wrong-time-report.md** — triage correction → reproduce with `CalculationId` → classify → profile PR or user guidance.
- **control-plane-restore.md** — Cloud SQL PITR, Terraform re-apply, smoke tests.
On-call: weekly rotation across mobile/backend leads in Ramadan ±2 weeks and release weeks; business hours otherwise. Backups: Cloud SQL daily + PITR 7 d; R2 object versioning; quarterly restore drill. Data-ops calendar: IANA releases (as published), Hijri (monthly for launch countries), profile review (quarterly + authority changes).

---

## 20. Release management and store submission
- Versioning `MAJOR.MINOR.PATCH` + monotonic build number; 4-week minors during V1; hotfix as needed. Phased rollout: Android 5 % → 25 % → 100 % over 3 days; iOS phased release 7 days. Binary rollback = halt rollout + hotfix.
- Tracks: internal → closed beta (tier devices + volunteers) → open beta (not during Ramadan) → production.
- Signing custody: Play App Signing with the upload key in KMS-backed CI; Apple certificates in the organisation's App Store Connect with two admins.
- Declarations: Play exact-alarm policy note (user-scheduled, time-critical prayer alarm), Data safety (location on-device only; no collection), Apple privacy nutrition label (no data collected; diagnostics user-initiated), `ITSAppUsesNonExemptEncryption = NO`, App Review notes (AlarmKit usage, background audio, location rationale), age rating 4+/Everyone.
- Go/no-go checklist (`docs/release/checklist.md`): §12 gates, device suite, declarations filed, Sharia approvals present for production profiles, runbook owners named, support ready.

## 21. Support model
Channels: in-app "Report a time" (→ `/feedback/corrections`, no identity) and support email; ar/en; first response ≤ 2 business days (≤ 24 h in Ramadan). Triage: "time is wrong" → request `CalculationId` → reproduce → classify → profile PR with a 10-working-day turnaround target; Sharia questions escalate to the board; OEM alarm issues answered from `oem_guidance.json`; diagnostic bundles accepted only via in-app export. Knowledge base: 15 FAQ articles at launch (ar/en), including "Why does my time differ from the mosque by a minute".

## 22. KPIs under the privacy posture

| KPI | Target | Source |
|---|---|---|
| Authority alignment | ≥ 95 % within 1 min; 0 unexplained > 2 min | lab benchmarks |
| Athan heard rate (test) | ≥ 90 % Android exact / AlarmKit | opt-in aggregate (D11) or beta cohort |
| Devices in READY/LIMITED | tracked | opt-in daily anonymous health ping; beta cohort if D11 = off |
| Crash-free sessions | ≥ 99.5 % | Play Vitals / App Store analytics |
| Cold start | < 1 s | perf CI |
| Urgent package adoption | ≥ 80 % of active devices within 72 h | aggregate activation counts |
| Store rating | ≥ 4.6 | stores |
| Retention | informational | store analytics |
Explicitly **not measurable** by design: per-user behaviour, location distribution, DAU beyond store estimates.

## 23. Governance

### 23.1 RACI

| Deliverable | Business | Product | Accuracy | Architect | Mobile | Backend/Data | QA | Security | Sharia board |
|---|---|---|---|---|---|---|---|---|---|
| Scope & release | A | R | C | C | C | C | C | C | C |
| Prayer profile content | I | C | R | C | I | R | C | I | **A** |
| Engine & algorithms | I | C | A | R | R | C | R | C | C |
| Athan platform | I | A | C | R | R | I | R | C | I |
| Signed data release | I | C | A | C | I | R | R | C | I |
| Privacy & threat model | I | C | C | R | C | C | C | A | I |
| Status copy & religious wording | I | R | C | I | I | I | C | I | **A** |
| Incident response | I | A | R | R | R | R | R | R | C |

### 23.2 Sharia board charter (summary; full text `docs/governance/sharia-board.md`)
≥ 3 qualified scholars with recorded qualifications; quorum 2; decisions recorded in `approvals.religious` with scope; dissent recorded in evidence; conflicts of interest declared; approvals public in the Passport evidence summary. The board approves rules, rounding, high-latitude methods, Hijri sources, religious wording and Athan Test audio — never engineering internals.

### 23.3 Document change control — PR + ADR; Architect approves; religious-semantics sections (§6.4–§6.5, D2–D4, D8, D12) also require a Sharia board member.

### 23.4 Sign-off block — `Business ☐ · Product ☐ · Architect ☐ · Sharia board chair ☐ · Security ☐` (recorded in `docs/governance/signoff.md`).

## 24. Legal register

| Item | Owner | Status | Launch-blocking |
|---|---|---|---|
| Privacy policy + ToS (ar/en, offline in app) | Legal | to draft | yes |
| Accuracy disclaimer (times are calculated; follow local authority where required) | Legal + Sharia | to draft | yes |
| Trademark clearance "Daily Muslim" | Legal | to check | yes |
| Privacy-law analysis (Egypt PDPL, Saudi PDPL, UAE PDPL, GDPR for diaspora); expected conclusion: no personal data server-side except transient IP / salted attestation hash | DPO | to confirm | yes |
| DPAs with Cloudflare and Google | DPO | to sign | yes |
| ODbL (tz polygons; mosques V1.5), CC BY 4.0 (GeoNames), Natural Earth (PD), OFL fonts, MIT/BSD/Apache deps — `LICENSES.md` + attribution screen | Legal + Architect | accepted | yes |
| SPA implemented from the Reda & Andreas paper; **no NREL C code** | Architect | decided | — |
| Audio performance/recording agreement; separate Fajr file; test tone | Legal | to sign | yes (placeholder until then) |
| Encryption export: `ITSAppUsesNonExemptEncryption = NO` | Legal | decided | — |
| Store policy declarations (§20); age rating; accessibility statement | Mobile lead / Product | to file | yes |

## 25. Security programme
- Vulnerability disclosure: `security@dailymuslim.app` + `SECURITY.md`; 90-day coordinated disclosure.
- Independent numerical + security review before GA (S27 output); full pen-test before V1.5; annual thereafter.
- Secure SDLC: §12 gates, dependency review, SBOM (syft), secret scanning, OIDC short-lived CI credentials.
- Key custody: three root hardware tokens held by Architect, Security owner, Business sponsor (threshold 2); ceremony witnessed and minuted; targets key in Cloud KMS under a dual-control release environment; snapshot/timestamp keys in CI secrets rotated quarterly.
- No TLS pinning; no SQLCipher (ADR-024). Consent records for telemetry/corrections stored locally with timestamps.
- Privacy-by-design assessment (`docs/governance/pia.md`) updated per release.

## 26. Deployment architecture and cost

```
Users ─▶ Cloudflare CDN ─▶ R2 bucket dm-dist (versioned, object lock)   ◀── release-package (GitHub Actions, OIDC → R2 token; Cloud KMS signs targets)
Users ─▶ api.dailymuslim.app (Cloudflare DNS/WAF, rate limits on POST) ─▶ Cloud Run control-plane (0–3 instances) ─▶ Cloud SQL Postgres 16 (PITR 7 d)
                                                                            └─▶ Secret Manager · Cloud KMS · Cloud Logging (24 h) · OTel → Cloud Monitoring
Environments: dev (shared) · beta · production — separate R2 channels; separate Cloud Run services + databases for beta/production. Terraform in infra/.
```

**12-month technical cost estimate (USD, order of magnitude)**

| Line | 10k installs | 100k | 1M |
|---|---|---|---|
| R2 storage + CDN (free egress; ~50 kB metadata/device/day) | 10 | 30 | 150 |
| Cloud Run + Cloud SQL (smallest HA) | 900 | 1 200 | 2 400 |
| Cloud KMS, Secret Manager, logging | 50 | 100 | 300 |
| GitHub Actions incl. macOS minutes | 1 500 | 1 500 | 2 000 |
| Firebase Test Lab | 300 | 300 | 600 |
| Device lab (one-off, 6 devices) | 3 500 | — | — |
| Apple + Google developer accounts | 125 | 125 | 125 |
| Self-hosted Sentry (optional) | 500 | 500 | 800 |
| Audio production/licence, Sharia board, translation, legal | set by Business | | |
Technical run-rate stays < $10k/year even at 1M installs; people and content dominate.

## 27. Team and programme risks

**Minimum team:** 1 architect/tech lead (Dart + Go), 1 Android (Kotlin), 1 iOS (Swift), 1 Flutter, 1 data/accuracy engineer (Python), 0.5 QA, 0.5 product/BA; external: Sharia board, legal/DPO, muezzin. Bus-factor risks: native alarm expertise per platform; accuracy pipeline — mitigated by ADRs, runbooks and device suites.

| Risk | L | I | Mitigation / trigger | Owner |
|---|---|---|---|---|
| Sharia board not formed before GA | M | H | D1 now; GA is blocked by CI anyway; interim `lab` only | Business |
| Apple rejects AlarmKit / background-audio usage | M | H | notification fallback; review notes; early TestFlight in S22 | Mobile |
| Play denies exact-alarm posture | L | H | ADR-012 compliant posture; visible inexact fallback | Mobile + Legal |
| Audio rights not signed | M | M | placeholder tone; deadline S27 | Legal |
| Ramadan 1448 deadline slip | H | M | D7 rule: GA after Eid if beta exit not met by 15 Jan 2027 | Product |
| TZ law change in a launch country before release | M | M | runbook rehearsed in S27 | Data |
| Single maintainer | H | H | this document + slices + tests; recruit a second native developer | Business |
| Store account suspension | L | H | two admins; policy compliance log | Mobile |

---

## Appendix A — `prayer_profile.v1.schema.json` (normative shape)

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "$id": "https://dailymuslim.app/schemas/prayer_profile.v1.schema.json",
  "type": "object", "additionalProperties": false,
  "required": ["profileId","schemaVersion","version","status","effectiveFrom","scope","authority","referenceMode","referencePoints","rules","horizon","highLatitude","rounding","adjustments","evidence","approvals","compatibility"],
  "properties": {
    "profileId": {"type":"string","pattern":"^[a-z]{2}\\.[a-z0-9_]+\\.[a-z0-9_]+$|^engine\\.default$"},
    "schemaVersion": {"const": 1},
    "version": {"type":"string","pattern":"^\\d{4}\\.\\d{1,2}\\.\\d+$"},
    "status": {"enum":["DRAFT_UNVERIFIED","CANDIDATE","APPROVED","RETIRED"]},
    "effectiveFrom": {"type":"string","format":"date"}, "effectiveTo": {"type":["string","null"],"format":"date"},
    "scope": {"type":"object","additionalProperties":false,"required":["countries"],"properties":{
      "countries":{"type":"array","items":{"type":"string","pattern":"^[A-Z]{2}$|^\\*$"}},
      "adminAreas":{"type":"array","items":{"type":"string","pattern":"^[A-Z]{2}-[A-Z0-9]{1,3}$"}},
      "polygonsRef":{"type":["string","null"]}}},
    "authority": {"type":"object","required":["name","type"],"properties":{"name":{"type":"string"},"type":{"enum":["GOVERNMENT","RECOGNIZED_BODY","COMMUNITY_CONVENTION","ENGINE_DEFAULT"]}}},
    "referenceMode": {"enum":["EXACT_COORDINATE","AUTHORITY_REFERENCE_POINT"]},
    "referencePoints": {"type":"array","items":{"type":"object","required":["area","lat","lon"],"properties":{"area":{"type":"string"},"lat":{"type":"number"},"lon":{"type":"number"}}}},
    "rules": {"type":"object","additionalProperties":false,"required":["fajr","sunrise","dhuhr","asr","maghrib","isha"],"properties":{
      "imsak":{"oneOf":[{"$ref":"#/$defs/rule"},{"type":"null"}]},"fajr":{"$ref":"#/$defs/rule"},"sunrise":{"$ref":"#/$defs/rule"},"dhuhr":{"$ref":"#/$defs/rule"},
      "asr":{"$ref":"#/$defs/rule"},"maghrib":{"$ref":"#/$defs/rule"},"isha":{"$ref":"#/$defs/rule"}}},
    "horizon": {"type":"object","required":["elevationPolicy"],"properties":{"elevationPolicy":{"enum":["NONE","ABOVE_LOCAL_TERRAIN","AUTHORITY_TABLE"]}}},
    "highLatitude": {"type":"object","required":["chain"],"properties":{"chain":{"type":"array","minItems":1,"items":{"$ref":"#/$defs/hlMethod"}}}},
    "rounding": {"type":"object","required":["default"],"properties":{"default":{"$ref":"#/$defs/rounding"}},"additionalProperties":{"$ref":"#/$defs/rounding"}},
    "adjustments": {"type":"object","required":["maxAbsMinutes"],"properties":{
      "perEventMinutes":{"type":"object","additionalProperties":{"type":"integer","minimum":-10,"maximum":10}},
      "maxAbsMinutes":{"type":"integer","minimum":0,"maximum":10},
      "ramadan":{"type":"object","additionalProperties":{"$ref":"#/$defs/rule"}}}},
    "evidence": {"type":"object","required":["sources","benchmarkSet"],"properties":{
      "sources":{"type":"array","items":{"type":"object","required":["title","url","retrievedOn","sha256"]}},
      "benchmarkSet":{"type":"string"},"holdoutReport":{"type":["string","null"]},"benchmarkReportId":{"type":["string","null"]}}},
    "approvals": {"type":"object","properties":{
      "religious":{"type":["object","null"],"required":["reviewer","qualification","date","scope"]},
      "accuracy":{"type":["object","null"],"required":["reviewer","date"]}}},
    "compatibility": {"type":"object","required":["minEngineSchema","minAppVersion"]}
  },
  "$defs": {
    "rounding": {"enum":["ceil","floor","nearest"]},
    "rule": {"oneOf":[
      {"type":"object","required":["type","degrees"],"properties":{"type":{"const":"solarAltitude"},"degrees":{"type":"number","minimum":5,"maximum":25}}},
      {"type":"object","required":["type"],"properties":{"type":{"const":"transit"},"offsetMinutes":{"type":"integer","minimum":0,"maximum":5}}},
      {"type":"object","required":["type","k"],"properties":{"type":{"const":"shadowFactor"},"k":{"enum":[1,2]}}},
      {"type":"object","required":["type"],"properties":{"type":{"const":"horizon"},"refractionArcmin":{"type":"number","minimum":0,"maximum":60},"semidiameterArcmin":{"type":"number","minimum":0,"maximum":20}}},
      {"type":"object","required":["type","base","minutes"],"properties":{"type":{"const":"intervalAfter"},"base":{"enum":["maghrib"]},"minutes":{"type":"integer","minimum":30,"maximum":150}}},
      {"type":"object","required":["type","base","minutes"],"properties":{"type":{"const":"intervalBefore"},"base":{"enum":["fajr"]},"minutes":{"type":"integer","minimum":5,"maximum":120}}}
    ]},
    "hlMethod": {"oneOf":[
      {"const":"anglePortion"},{"const":"middleOfNight"},{"const":"seventhOfNight"},
      {"type":"object","required":["nearestLatitude"],"properties":{"nearestLatitude":{"type":"object","required":["latDeg"],"properties":{"latDeg":{"type":"number","minimum":40,"maximum":60}}}}},
      {"type":"object","required":["nearestValidDay"],"properties":{"nearestValidDay":{"type":"object","required":["maxDays"],"properties":{"maxDays":{"type":"integer","minimum":1,"maximum":60}}}}}
    ]}
  }
}
```
CI gate (not schema): `status == APPROVED ⇒ approvals.religious ≠ null ∧ approvals.accuracy ≠ null ∧ evidence.holdoutReport ≠ null`. `Authority aligned` requires `evidence.benchmarkReportId ≠ null`.

## Appendix B — `schedule_plan.v1.schema.json`
Fields exactly as §7.7. Constraints: `entries[].id` `^[a-f0-9]{16}$`; `event` enum `IMSAK|FAJR|SUNRISE|DHUHR|ASR|MAGHRIB|ISHA`; `kind` enum `ATHAN|PRE_REMINDER|IMSAK|HORIZON_WARNING`; `priority` 1–3; `policy.locale` enum `ar|en`; `policy.preReminderMinutes` enum `0|5|10|15|30`; `horizonEndUtcMs ≥ max(fireAtUtcMs)`; `additionalProperties: false`. Native readers accept schemaVersion N and N−1 and otherwise keep the previously applied plan.

## Appendix C — TUF-lite metadata
Every file: `{ "signed": {...}, "signatures": [{ "keyId": "<sha256 of public key, hex>", "sig": "<base64 Ed25519>" }] }`; signature over JCS (RFC 8785) of `signed`.
`root.signed {type:"root", version, expires, keys{keyId:{scheme:"ed25519", public}}, roles{root:{keyIds[3], threshold:2}, targets:{keyIds, threshold:1}, snapshot:{…}, timestamp:{…}}}` · `targets.signed {type:"targets", sequence, expires, targets{"<type>/<version>": {length, sha256, custom{schemaVersion, payloadFormat, compat{minApp, minEngineSchema}, effectiveFrom, priority, changeNote{ar,en}, rollbackOf?, attribution?}}}}` · `snapshot.signed {type:"snapshot", sequence, expires, meta{"targets.json":{version, sha256}}}` · `timestamp.signed {type:"timestamp", sequence, expires ≤ 7 d, meta{"snapshot.json":{version, sha256}}}`. Client rules: verify bottom-up against the embedded root; accept only `sequence` strictly greater than stored; expiry ⇒ `FRESHNESS_UNVERIFIED` warning; root rotation accepted when the new root is signed by the old root's threshold.

## Appendix D — ADR template (`docs/adr/ADR-nnn-title.md`)
`Status · Context · Decision · Trade-offs (win/lose) · Consequences · REQ tags · Tests · Supersedes`.

## Appendix E — Seed profile policy
S07 creates `eg.egas.standard`, `sa.ummalqura.standard`, `ae.awqaf.standard`, `engine.default` with `status: DRAFT_UNVERIFIED`, `approvals.religious: null`, and `evidence.sources` listing the official publication URLs to be verified. Loadable on `dev`/`lab` only; the `beta`/`production` release job refuses `DRAFT_UNVERIFIED` and `CANDIDATE` profiles.

## Appendix F — Requirement index (normative; one sentence each)

**Domain**
- `REQ-DOM-001` Displayed instants satisfy Imsak ≤ Fajr < Sunrise < Dhuhr < Asr < Maghrib < Isha per prayer day; violation returns `EngineFailure.orderingViolation`.
- `REQ-DOM-002` Every `PrayerTime.origin` is `primary`, `fallback(method)` or `noEvent(reason)`; a fallback is never used when a primary root exists.
- `REQ-DOM-003` Rounding is applied exactly once per event, as the last step, and never feeds another calculation.
- `REQ-DOM-004` Identical `(inputsHash, engineVersion, deltaTModel, tzdbVersion)` yields identical `rawUtcMs` (1 ms truncation) on all production platforms.
- `REQ-DOM-010` Confidence labels are the sealed `ConfidenceLabel` type; no string or enum flag may change a label.
- `REQ-DOM-020` `GeoSalahEngine` exposes exactly the four methods of §6.3 and performs no I/O, reads no clock and uses no randomness.
- `REQ-DOM-030` Qibla bearing is the WGS84 initial geodesic bearing to the versioned Kaaba coordinate, within 0.01° of GeographicLib.
- `REQ-DOM-040` Locale affects presentation only; calculation inputs and outputs are locale-independent.
- `REQ-DOM-050` `ConfidenceLabel` is derived solely by the §6.2 mapping from `EventOrigin` and profile status/authority.

**Time**
- `REQ-TIME-001` Behaviour-driving times are stored as UTC epoch-ms plus `zoneId` and `tzdbVersion`.
- `REQ-TIME-002` The prayer day is bounded by solar lower culminations (ADR-004).
- `REQ-TIME-010` Device-clock skew > 60 s versus GNSS/CDN time produces a `Needs attention` state and never blocks calculation or packages.
- `REQ-TIME-020` Local time is derived from the app's pinned TZDB package, never the OS database.

**Athan**
- `REQ-ALM-001` Alarms fire at `displayedUtcMs`, scheduled as absolute instants.
- `REQ-ALM-002` Native layers reschedule from the persisted plan after boot, locked boot, time change, zone change, package replace and permission change without Dart.
- `REQ-ALM-003` `READY` requires every probe `positive == true`; any `null` probe yields `UNKNOWN` or `LIMITED`.
- `REQ-ALM-010` The plan covers ≥ 30 days (Android) or the 64-slot priority fit (iOS) and always contains a `HORIZON_WARNING` entry.
- `REQ-ALM-020` Android ATHAN entries use `setAlarmClock` when `canScheduleExactAlarms()` is true.
- `REQ-ALM-021` All receivers are `exported=false`; all `PendingIntent`s are `FLAG_IMMUTABLE` with request codes derived from the entry id.
- `REQ-ALM-022` A `directBootAware` receiver reschedules from device-protected storage on `LOCKED_BOOT_COMPLETED`.
- `REQ-ALM-023` Android Athan audio plays via a `mediaPlayback` foreground service with `USAGE_ALARM` attributes.
- `REQ-ALM-024` Notification channel ids derive from `(kind, soundId, v)`; a sound change creates a new channel and migrates settings.
- `REQ-ALM-025` A previous force-stop is detected via `ApplicationExitInfo` and surfaced as `forceStoppedPreviously`.
- `REQ-ALM-026` `POST_NOTIFICATIONS` is probed and requested at Athan enable on API 33+.
- `REQ-ALM-027` When exact alarms are unavailable, the inexact scheduler is used and Health is `LIMITED(inexactFallback)`.
- `REQ-ALM-030` iOS 26+ schedules via AlarmKit `.fixed(Date)`.
- `REQ-ALM-031` iOS notification triggers are computed from absolute instants, never `DateComponents`.
- `REQ-ALM-032` iOS pending requests never exceed 64; entries are dropped by priority from the farthest day first.
- `REQ-ALM-033` The iOS notification path never reports `READY`.
- `REQ-ALM-034` iOS notification sounds are ≤ 29 s clips listed in the audio manifest.
- `REQ-ALM-035` The iOS plan lives in the App Group container and is written atomically.
- `REQ-ALM-036` `PrivacyInfo.xcprivacy` is present and `places.sqlite` is excluded from backup.
- `REQ-ALM-040` Athan Test fires in 60 s via the real path and records `heardByUser` from the user's answer.
- `REQ-ALM-041` Receipts and system events are drained by Dart on every start.
- `REQ-ALM-042` Pre-reminder offset ∈ {0,5,10,15,30} min (default 0) and snooze = 5 min once.

**Packages**
- `REQ-PKG-001` Download → verify (hash, signature chain, schema, compat) → stage → single-transaction activation; any failure leaves last-known-good active.
- `REQ-PKG-002` Metadata expiry yields `FRESHNESS_UNVERIFIED` and never blocks calculation.
- `REQ-PKG-003` The binary bundles seed versions of all MVP package types and imports them on first launch.
- `REQ-PKG-004` Sync runs at most every 6 h on open; payloads > 2 MB download only on unmetered unless `urgent`.
- `REQ-PKG-005` Only metadata with strictly higher `sequence` is accepted.
- `REQ-PKG-006` Compatibility (`minApp`, `minEngineSchema`) is checked before activation.

**Privacy**
- `REQ-PRIV-001` No egress path contains coordinates with > 2 decimals or any persistent identifier (sole exception `REQ-PRIV-007`).
- `REQ-PRIV-002` Pinned/manual contexts are never replaced by the resolver.
- `REQ-PRIV-003` `places.sqlite` is excluded from OS backups on both platforms.
- `REQ-PRIV-004` Downloadable packages are country-level or global, never sub-country.
- `REQ-PRIV-005` Diagnostic bundles round coordinates to 0.01° and show their contents before export.
- `REQ-PRIV-006` The app contacts only `cdn.dailymuslim.app` and `api.dailymuslim.app`; a CI egress test enforces it.
- `REQ-PRIV-007` The sole device-derived server identifier is `sha256(attestationKeyId + dailySalt)`, retained ≤ 24 h.

**UX**
- `REQ-UX-001` Every time row shows its `ConfidenceLabel`; `Estimated`/`Observed` always show a range or count.
- `REQ-UX-010` Every sky-phase token set meets WCAG 2.2 AA contrast in light/dark/LTR/RTL golden tests.
- `REQ-UX-020` All interactive widgets have semantics labels, ≥ 44 pt targets, and support 200 % text and reduced motion.
- `REQ-UX-030` All layouts use start/end and pass RTL golden tests.
- `REQ-UX-040` Status copy comes only from shared constants guarded by prohibited-word tests.

**Governance**
- `REQ-GOV-001` No profile set is signed for `production` unless every `APPROVED` profile has `approvals.religious` and `approvals.accuracy`.
- `REQ-GOV-002` Profile PRs require CODEOWNERS review from the accuracy and Sharia roles.
- `REQ-GOV-003` Promotion requires a holdout report within tolerance.
- `REQ-GOV-004` Religious changes activate at one `effectiveFrom` for all users; canaries are technical only.
- `REQ-GOV-005` Changes to `DESIGN.md` follow §23.3.

**Distribution**
- `REQ-DIST-001` Metadata uses root/targets/snapshot/timestamp roles with the thresholds of Appendix C.
- `REQ-DIST-002` `sequence` is monotonic; rollback is a new higher-sequence manifest.
- `REQ-DIST-003` Packages are immutable and content-addressed by sha256.
- `REQ-DIST-004` Signatures are Ed25519 over JCS-canonical `signed`.
- `REQ-DIST-005` CDN cache policy follows §9.1.
- `REQ-DIST-006` Distribution logs retain no IP beyond 24 h.

**API**
- `REQ-API-001` Errors are RFC 9457 problem details carrying a trace id.
- `REQ-API-002` Every route has a 5 s timeout and a 64 kB body limit.
- `REQ-API-003` POSTs are idempotent by `Idempotency-Key`.
- `REQ-API-004` Writes require a valid attestation token.
- `REQ-API-005` Bodies are validated against `schemas/`; unknown keys are rejected.
- `REQ-API-006` No endpoint creates or requires a user identity.

**Testing**
- `REQ-TEST-001` Golden exact-match tests exist for all Appendix H cities.
- `REQ-TEST-002` Property tests cover every §3 invariant.
- `REQ-TEST-003` Nightly differential tests versus Skyfield/de440s stay within ADR-019 tolerance.
- `REQ-TEST-004` Every port has contract tests run against real and fake implementations.
- `REQ-TEST-005` The device suite (Doze, reboot, locked boot, tz/time change, silent switch) passes on tier-1 devices per RC.

**Errors · Security · Performance · Data · Operations**
- `REQ-ERR-001` Fallible operations across layers return `Result<T, Failure>`; exceptions never cross a layer.
- `REQ-ERR-002` Failure and event codes are enumerated (Appendix J) and mirrored in Kotlin/Swift.
- `REQ-SEC-010` Deep links are allow-listed and validated before navigation.
- `REQ-SEC-020` Remote configuration may only select signed package versions.
- `REQ-SEC-030` No secrets in the repo; CI uses OIDC short-lived credentials.
- `REQ-SEC-040` Every release produces an SBOM and license notices.
- `REQ-PERF-001` One-year `calculateRange` < 500 ms on Galaxy A50 (release, median of 5).
- `REQ-PERF-002` Cold start to cached Home < 1 s on Galaxy A50.
- `REQ-PERF-003` Installed size ≤ 60 MB.
- `REQ-PERF-004` No background location; background CPU < 1 min/day.
- `REQ-DATA-001` Device retention per §7.3.
- `REQ-DATA-002` Server retention per §9.3.
- `REQ-OPS-001` TZDB emergency package ≤ 48 h.
- `REQ-OPS-002` Hijri confirmation ≤ 6 h.
- `REQ-OPS-003` The SLOs of §19.1 are monitored with alerts.

## Appendix G — Sky phases and design tokens (`packages/dm_ui/tokens/sky.v1.json`)

| Phase | Altitude band (geometric °) | Direction | Gradient top → bottom | Accent | On-surface |
|---|---|---|---|---|---|
| night | < −18 | any | `#0B1026 → #1B2140` | `#F4D58D` | `#F3F4F8` |
| astronomicalDawn | [−18, −12) | rising | `#14183A → #3B2A5E` | `#E9B98A` | `#F3F4F8` |
| nauticalDawn | [−12, −6) | rising | `#3B2A5E → #7A4B7A` | `#FFC9A3` | `#F3F4F8` |
| civilDawn | [−6, −0.833) | rising | `#7A4B7A → #E08A6A` | `#FFE3B0` | `#F3F4F8` |
| goldenMorning | [−0.833, 6) | rising | `#E08A6A → #F6C177` | `#2B2140` | `#0F1B2D` |
| day | ≥ 6 | any | `#5FA8E6 → #CFE8FA` | `#1F4F7A` | `#0F1B2D` |
| goldenEvening | (−0.833, 6] | setting | `#F2A65A → #E26D5A` | `#2B2140` | `#0F1B2D` |
| civilDusk | (−6, −0.833] | setting | `#D96C7A → #6E4A8E` | `#FFE3B0` | `#F3F4F8` |
| nauticalDusk | (−12, −6] | setting | `#4A3A7A → #262B57` | `#E9B98A` | `#F3F4F8` |
| astronomicalDusk | (−18, −12] | setting | `#1B2140 → #0F1430` | `#F4D58D` | `#F3F4F8` |

On-surface is chosen from `{#0F1B2D, #F3F4F8}` by WCAG contrast ≥ 4.5:1 against the gradient midpoint (golden test). Static fallback — light: surface `#FAF9F6`, onSurface `#1C1B1F`, primary `#1F6F5F`, secondary `#B8862E`, error `#B3261E`; dark: surface `#121318`, onSurface `#E6E1E5`, primary `#7FC8B8`, secondary `#E3B661`, error `#F2B8B5`. Scales: space `4 8 12 16 24 32 48`; radius `8 12 16 24`; type (size/line) display 40/48, headline 28/36, title 20/28, body 16/24, label 13/18 (+2 line-height for Arabic); motion 200 ms standard / 0 ms reduced-motion; the sky gradient re-renders at most once per minute.

## Appendix H — Benchmark cities (`lab/benchmarks/cities.v1.json`; lat, lon)
Dubai 25.20, 55.27 · Abu Dhabi 24.45, 54.38 · Makkah 21.42, 39.83 · Riyadh 24.71, 46.68 · Jeddah 21.49, 39.19 · Muscat 23.59, 58.38 · Doha 25.29, 51.53 · Kuwait City 29.38, 47.99 · Amman 31.95, 35.93 · Istanbul 41.01, 28.98 · Cairo 30.04, 31.24 · Alexandria 31.20, 29.92 · Aswan 24.09, 32.90 · Casablanca 33.57, −7.59 · Tunis 36.81, 10.17 · Algiers 36.75, 3.06 · London 51.51, −0.13 · Paris 48.86, 2.35 · Berlin 52.52, 13.41 · Oslo 59.91, 10.75 · Stockholm 59.33, 18.07 · Reykjavik 64.15, −21.94 · Tromsø 69.65, 18.96 · Longyearbyen 78.22, 15.63 · Karachi 24.86, 67.01 · Delhi 28.61, 77.21 · Dhaka 23.81, 90.41 · Kuala Lumpur 3.14, 101.69 · Jakarta −6.21, 106.85 · Tokyo 35.68, 139.69 · Tashkent 41.30, 69.24 · Kabul 34.53, 69.17 · New York 40.71, −74.01 · Toronto 43.65, −79.38 · Chicago 41.88, −87.63 · Vancouver 49.28, −123.12 · Anchorage 61.22, −149.90 · Utqiaġvik 71.29, −156.79 · Mexico City 19.43, −99.13 · São Paulo −23.55, −46.63 · Cape Town −33.92, 18.42 · Johannesburg −26.20, 28.05 · Sydney −33.87, 151.21 · Auckland −36.85, 174.76 · Ushuaia −54.80, −68.30 · Quito −0.18, −78.47 · Kiritimati 1.87, −157.43 · Suva −18.14, 178.44 · Nairobi −1.29, 36.82.
Dates per city: both solstices, both equinoxes, the 15th of each month, every DST transition ±7 days, Ramadan start/end 1447–1449.

## Appendix I — `snapshot.v1.schema.json`
`{schemaVersion: 1, contextId, zoneId, tzdbVersion, generatedAtUtcMs, locale, items[{day, event, displayedUtcMs, displayLocal, confidence{kind, detail?}, dayOffset}], skyTimeline[{fromUtcMs, phase}], health{state, reasonsCount}}` — 48 h horizon; `additionalProperties: false`.

## Appendix J — Failure and event codes (`dm_core_types/lib/codes.dart`, mirrored natively)
Failures: `LOC_PERMISSION_DENIED, LOC_SERVICES_OFF, LOC_UNAVAILABLE, LOC_STALE, TZ_UNRESOLVED, COUNTRY_UNRESOLVED, PROFILE_NOT_FOUND, PROFILE_OVERLAP, PROFILE_INVALID, ENGINE_ORDERING, ENGINE_UNSUPPORTED_POLICY, HIJRI_UNKNOWN_MONTH, PKG_SIG_INVALID, PKG_HASH_MISMATCH, PKG_INCOMPATIBLE, PKG_SEQUENCE_REGRESSION, PKG_EXPIRED_WARNING, PKG_NETWORK, PKG_STORAGE, PLAN_WRITE_FAILED, PLAN_SCHEMA_UNSUPPORTED, ALARM_PERMISSION_MISSING, ALARM_SCHEDULE_FAILED, AUDIO_ASSET_MISSING, CLOCK_SKEW, DB_MIGRATION_FAILED, DIAG_EXPORT_FAILED`.
Event-log codes: `APP_START, PKG_ACTIVATED, PKG_ROLLED_BACK, PLAN_BUILT, PLAN_APPLIED, ALARM_SCHEDULED, ALARM_PRESENTED, ALARM_DISMISSED, HEALTH_EVALUATED, TEST_STARTED, TEST_RESULT, CONTEXT_CHANGED, SYNC_RESULT, RETENTION_RUN`.
`event_log.v1.schema.json`: `attrs` is an object with `additionalProperties: false` and the key allow-list `code, generation, entryId, packageType, version, state, reason, durationMs, count, zoneId, countryCode` — no `lat`/`lon` key can exist.

## Appendix K — Settings keys
`locale (ar|en|system)`, `digits (locale|western|arabicIndic)`, `themeMode (sky|light|dark|system)`, `reducedMotionOverride`, `athanEnabled{event: bool}`, `soundId`, `preReminderMinutes`, `hijriOverrideDays (−1|0|1)`, `telemetryOptIn`, `telemetryConsentUtcMs`, `lastSyncUtcMs`, `lastRetentionRunUtcMs`, `onboardingComplete`, `activeContextId`, `showSeconds (expert)`.

## Appendix L — `telemetry_aggregate.v1.schema.json`
`{schemaVersion: 1, day: "YYYY-MM-DD", appVersion, platform: android|ios, osMajor, countryCode?, counters{packageActivations{type}, healthState{state}, testResults{heard|notHeard|unknown}, syncOutcome{ok|warn|fail}}}` — `additionalProperties: false`; no ids, no coordinates, no timestamps finer than a day.

## Appendix M — `calculation_trace.v1.schema.json`
Serialised `DayResult` + `Provenance` + per-event `{rawUtcMs, displayedUtcMs, origin, confidence, flags, adjustmentTrace}` plus the `inputs` object of §6.4 ¶11; used by the Passport renderer, the deep-link import and lab discrepancy reports.
