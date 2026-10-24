# Package rollback (REQ-DIST-002, REQ-PKG-001)

**Trigger:** a published `prayer_profiles` or `tzdata` release gives wrong times, fails on devices, or was published by mistake. **Owner:** release manager; accuracy lead confirms the cause. **SEV1** on `production`: rollback within 1 h (§19.3).

A rollback is never a delete and never a lower sequence. It is a **new target version with the old content**, `rollbackOf: <bad version>`, published under a higher `targets` sequence. Clients accept only higher sequences (REQ-PKG-005), so the rollback reaches every device by the normal sync.

## 1. Identify
1. Bad version and sequence: `go run ./tools/gsctl pull -repo /tmp/live -channel <ch> -bucket s3://dm-dist`, then read `/tmp/live/metadata/targets.json` (`targets["prayer_profiles/<version>"]`, `sequence`).
2. The last good version: the release before it in the same file, or the git tag `profiles/<version>` the release job created.
3. Record both in the incident note.

## 2. Build and publish the rollback
`prayer_profiles` (dev, lab):
1. Check out the good content: `git checkout <good-commit> -- profiles/` on a branch `rollback/<bad>`; open a PR (the profiles gate runs).
2. Run **release-package** (Actions → workflow_dispatch) with `version` = the next unused version (e.g. `2026.10.3`), `rollback_of` = the bad version, `priority` = `urgent`, `effective_from` = the good release's date, and an ar/en change note that says it is a rollback.
3. The job pulls the live channel, builds, signs targets → snapshot → timestamp, runs `gsctl verify` and publishes.

`beta`/`production`: build and sign on `lab` as above, then **promote-package** with the reviewed `lab` sequence. This becomes possible once the production keys exist (key-ceremony.md); until then beta and production have no packages.

`tzdata`: as above with `gsctl build -type tzdata -payload <good tzdata.tzf> -manifest <good manifest.json> -rollback-of <bad>` from the pipeline output of the good release (`data-pipelines tzdata build`).

## 3. Verify
1. `go run ./tools/gsctl verify -repo /tmp/live` after a fresh `pull`: the chain verifies and `targets.json` names the rollback with `rollbackOf`.
2. Canary device on the channel: open the app (sync runs on open, at most every 6 h; force it by clearing the app's sync time in a debug build) → Passport shows the rollback version → Home times match the good release. The device's event log shows `PKG_ACTIVATED` for the rollback version.
3. The re-armed plan: Athan Health is unchanged and the next Athan fires at the restored time. The app replaces the native plan whole (`ApplySchedulePlan`, REQ-ALM-035); the drill test proves that the restored plan is the prior plan entry for entry.

## Device-local rollback
When an activated package cannot be used on a device, `RollBackAndReplan` returns that device to its previous version. It plans first and then flips the pointer. A previous version that cannot be loaded or planned changes nothing, and a refused plan leaves the native plan whole (§15 D87). This needs no operator.

## 4. Close
Incident note (what, when, sequence numbers, devices affected if known); a Passport change note via the rollback's ar/en note; post-incident review within 5 working days.
