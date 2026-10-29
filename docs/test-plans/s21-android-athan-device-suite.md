# S21 device suite — Android `athan-core` (72 h)

The S21 done-test (`DESIGN.md` §13): forced Doze, reboot, locked boot, time-zone change and time change, on physical devices for 72 hours. **Status: OWED (owner, physical devices).** Nothing in this repository claims these results until a run is recorded below. Mechanics under test: §15 D81; thresholds: D79.

## Devices

At least three: a Pixel on Android 16 (reference), a Samsung on One UI 7+ (aggressive battery management), and one API 26–30 device (pre-exact-permission and pre-`ApplicationExitInfo` paths). Use a debug build: the adb driver `AthanSuiteActivity` is in debug builds only.

## Setup per device

```bash
PKG=app.azenfelnas
SUITE="adb shell am start -n $PKG/app.azenfelnas.athan.suite.AthanSuiteActivity"
EXCH=/sdcard/Android/data/$PKG/files

# A real plan whose instants start 5 minutes from now: the S20 Cairo fixture shifted in time
# (the times are test instants, not prayer times; generation = now so it always wins).
python3 - <<'PY' > /tmp/suite_plan.json
import json, time
p = json.load(open("schemas/fixtures/schedule_plan/valid/built_android.json"))
now = int(time.time() * 1000)
d = now + 5 * 60_000 - min(e["fireAtUtcMs"] for e in p["entries"])
p["generation"], p["generatedAtUtcMs"], p["horizonEndUtcMs"] = now, now, p["horizonEndUtcMs"] + d
for e in p["entries"]:
    e["fireAtUtcMs"] += d
print(json.dumps(p))
PY
adb push /tmp/suite_plan.json $EXCH/suite_plan.json
adb shell run-as $PKG mkdir -p files/athan     # device-protected copy: see "Audio" below
$SUITE --es cmd apply
$SUITE --es cmd health
```

Audio: push a licensed test clip to `/data/user_de/0/$PKG/files/athan/athan_makkah_v1.m4a` (e.g. `adb push clip.m4a /data/local/tmp/` then `adb shell run-as $PKG cp /data/local/tmp/clip.m4a /data/user_de/0/$PKG/files/athan/athan_makkah_v1.m4a`). Without it the default alarm sound plays and an `AUDIO_ASSET_MISSING` line is written; that is itself a scenario.

Evidence: `$SUITE --es cmd drain && adb pull $EXCH/suite_events.jsonl`. Each line is `event_log.v1`. Also keep `adb shell dumpsys alarm | grep -A3 $PKG` before and after each scenario.

## Scenarios (each ≥ 3 judged alarms, as in D79)

| # | Scenario | Steps | Pass |
|---|---|---|---|
| 1 | Foreground | apply; watch the next Athan | `receiver` → `fgs_started` → `audio_started` ≤ 5 s after `fireAtUtcMs` |
| 2 | Forced Doze | screen off; `adb shell dumpsys deviceidle force-idle`; wait for an Athan | same as 1; pre-reminders ≤ 5 s (`setExactAndAllowWhileIdle`) |
| 3 | Reboot, unlocked | `adb reboot`; unlock | `PLAN_APPLIED reason=boot`; next alarm as 1 |
| 4 | Locked boot | `adb reboot`; do **not** unlock; wait for an Athan | `PLAN_APPLIED reason=lockedBoot` before unlock; Athan plays before unlock |
| 5 | Time-zone change | Settings → Date & time: automatic zone off, pick a zone 3 h away | `PLAN_APPLIED reason=timezoneChanged`; alarms still at the same UTC instants |
| 6 | Time change | disable auto time; set the clock +10 min, then back | `reason=timeChanged`; nothing fires twice; past entries are not re-armed |
| 7 | Package replaced | `adb install -r` the same APK | `reason=packageReplaced`; window intact |
| 8 | Exact revoked | Settings → Alarms & reminders → off | Health `limited` with `inexactFallback`; next Athan is a notification (`notification_posted`) ≤ 15 min |
| 9 | Exact re-granted | toggle back on | `reason=permissionChanged`; next Athan as 1 |
| 10 | FGS refused | (Android 14+) battery "Restricted" | `fgs_denied` then `notification_posted`; Health `limited` with `batteryRestricted` |
| 11 | DND (alarms allowed / not) | DND on with and without the alarms category | allowed ⇒ plays; `respectDnd=true` plan ⇒ notification only |
| 12 | Force-stop | Settings → Force stop; open the app; `--es cmd health` | `previousForceStop` false, reason `forceStoppedPreviously`; nothing fires until the app is opened and re-applies |
| 13 | Athan Test | `$SUITE --es cmd test` | `TEST_STARTED`, then 1's receipts 60 s later (REQ-ALM-040) |
| 14 | Snooze | press Snooze on a playing Athan | `ALARM_DISMISSED reason=snoozed`; a second play 5 min later without a Snooze action |
| 15 | 72 h soak | leave the device in normal use; re-apply only via scenarios above | every Athan of the 72 h has a receipt; none missed (no receipt 30 min after trigger) |

Also record the reconcile time on scenario 3 (logcat time of `BOOT_COMPLETED` to the `PLAN_APPLIED` line) and the package's pending-alarm count in `dumpsys alarm` (at most 200 plus a snooze or test).

## Results

| Device | Android | Build | Date | Scenarios passed | Notes |
|---|---|---|---|---|---|
| — | — | — | — | OWED | — |
