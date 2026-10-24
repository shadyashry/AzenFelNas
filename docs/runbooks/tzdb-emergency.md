# TZDB emergency (REQ-OPS-001: ≤ 48 h from the announcement)

**Trigger:** an IANA tz release, or news of a DST/offset law change in a launch country (EG, SA, AE seeds). **Owner:** Backend/Data; accuracy lead verifies. **SEV2.**

1. **Detect:** watch `https://github.com/eggert/tz` tags (`git ls-remote --tags https://github.com/eggert/tz`; `data.iana.org` is not reachable from the cloud sessions, §15 D28/D85) and launch-country government notices.
2. **Confirm the zones affected:** the release's `NEWS`; list the launch-country zones (`Africa/Cairo`, `Asia/Riyadh`, `Asia/Dubai`) touched.
3. **Build:** `cd data-pipelines && uv run --frozen dm-pipelines tzdata fetch --dest /tmp/tz && uv run --frozen dm-pipelines tzdata build --source /tmp/tz --out /tmp/tzout` (see `data-pipelines/README.md`); the transition suite runs in `pytest -k rebuild` with `DM_TZ_SOURCE=/tmp/tz`.
4. **Lab:** `uv run lab benchmark` for the affected countries; Dart `dm_civil_time` transition tests over the new payload.
5. **Package:** `gsctl build -type tzdata -payload tzdata.tzf -manifest manifest.json -version <iana-version>.<n> -priority urgent ...`, sign, verify, publish to `lab`; promote `lab` → `beta` → `production` (production keys: key-ceremony.md).
6. **Verify on a canary device:** Passport shows the new `tzdbVersion`; a time across the transition is right in Home and Timeline; the plan was rebuilt (Health unchanged).
7. **Passport change note** (ar/en) naming the zones and the law.

If the 48 h SLA cannot be met, raise to SEV1 when a launch country's transition is within 7 days.
