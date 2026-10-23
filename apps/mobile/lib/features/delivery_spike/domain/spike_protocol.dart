/// The S19 native spike's receipt protocol (DESIGN.md §13 S19, §15 D79).
///
/// The spike code on both platforms writes ordinary `event_log.v1` lines to
/// `plan/events.jsonl`; these labels are the values it puts in the `state`,
/// `reason` and `durationMs` attributes, so no schema change is needed:
///
/// - `ALARM_SCHEDULED`: `entryId`, `state` = scenario, `reason` = path
///   label, `durationMs` = trigger instant − `utcMs`.
/// - `ALARM_PRESENTED`: `entryId`, `reason` = stage, `durationMs` = how late
///   the stage ran after the trigger instant.
/// - `ALARM_DISMISSED`: `entryId`, `reason` = stage, `durationMs` = how
///   long it rang.
/// - `TEST_RESULT`: `reason` = observation, `durationMs` / `count` as the
///   observation says.
library;

/// A delivery path the spike decides go or no-go for.
enum SpikePath {
  /// Android `setAlarmClock` → receiver → `mediaPlayback` foreground
  /// service with `USAGE_ALARM` audio (ADR-012).
  androidExactFgs,

  /// Android without exact alarms: `setAndAllowWhileIdle` → notification
  /// on the alarm stream (ADR-012 fallback, REQ-ALM-027).
  androidInexactFallback,

  /// iOS 26+ AlarmKit `Alarm.Schedule.fixed(Date)` delivery (ADR-013).
  iosAlarmKitDelivery,

  /// iOS 26+ AlarmKit sound longer than 30 s (ADR-013 long audio).
  iosAlarmKitLongAudio,

  /// iOS local-notification path: the 64 pending-request budget (ADR-013).
  iosNotificationBudget,
}

/// The labels the native spike code writes (mirrored in
/// `athan-core/src/debug/.../spike/SpikeLabels.kt` and
/// `AthanKit/Sources/AthanKit/Spike/SpikeLabels.swift`).
abstract final class SpikeLabels {
  /// `ALARM_SCHEDULED.reason` for [SpikePath.androidExactFgs].
  static const String androidExact = 'android_exact';

  /// `ALARM_SCHEDULED.reason` for [SpikePath.androidInexactFallback].
  static const String androidInexact = 'android_inexact';

  /// `ALARM_SCHEDULED.reason` for [SpikePath.iosAlarmKitDelivery].
  static const String iosAlarmKit = 'ios_alarmkit';

  /// `ALARM_PRESENTED.reason`: the alarm broadcast reached the receiver.
  static const String receiver = 'receiver';

  /// `ALARM_PRESENTED.reason`: `startForeground` returned.
  static const String fgsStarted = 'fgs_started';

  /// `ALARM_PRESENTED.reason`: the service start threw
  /// `ForegroundServiceStartNotAllowedException`.
  static const String fgsDenied = 'fgs_denied';

  /// `ALARM_PRESENTED.reason`: the player reported it is playing.
  static const String audioStarted = 'audio_started';

  /// `ALARM_PRESENTED.reason`: the fallback notification was posted.
  static const String notificationPosted = 'notification_posted';

  /// `ALARM_PRESENTED.reason`: AlarmKit reported the alarm `alerting`.
  static const String alarmKitAlerting = 'alarmkit_alerting';

  /// `ALARM_DISMISSED.reason`: the user pressed Stop.
  static const String userStop = 'user_stop';

  /// `TEST_RESULT.reason`: the tester heard the alarm.
  static const String heard = 'heard';

  /// `TEST_RESULT.reason`: the tester did not hear the alarm.
  static const String notHeard = 'not_heard';

  /// `TEST_RESULT.reason`: a long clip played to its end (`durationMs` =
  /// heard length).
  static const String longAudioFull = 'long_audio_full';

  /// `TEST_RESULT.reason`: a long clip stopped early (`durationMs` = heard
  /// length).
  static const String longAudioCut = 'long_audio_cut';

  /// `TEST_RESULT.reason`: pending notification requests after asking for
  /// more than 64 (`count` = pending).
  static const String pendingBudget = 'pending_budget';
}

/// The thresholds a spike run is judged by. Engineering defaults (§15 D79),
/// not religious values.
final class SpikeCriteria {
  /// Criteria with the D79 defaults.
  const new({
    this.minRunsPerScenario = 3,
    this.maxExactLatenessMs = 5000,
    this.maxInexactLatenessMs = 15 * 60 * 1000,
    this.missedAfterMs = 30 * 60 * 1000,
    this.minLongAudioRuns = 3,
    this.notificationBudget = 64,
    this.androidScenarios = const {
      'foreground',
      'doze',
      'swiped',
      'reboot_unlocked',
      'reboot_locked',
      'battery_saver',
      'dnd_alarms',
    },
    this.androidFallbackScenarios = const {'exact_revoked'},
    this.iosScenarios = const {
      'foreground',
      'locked_killed',
      'reboot',
      'silent_switch',
      'focus',
    },
  });

  /// Due entries each required scenario needs.
  final int minRunsPerScenario;

  /// Latest an exact path stage may run after its trigger instant.
  final int maxExactLatenessMs;

  /// Latest the inexact fallback may present after its trigger instant.
  final int maxInexactLatenessMs;

  /// An entry with no receipt this long after its trigger is missed;
  /// younger ones are still pending and not judged.
  final int missedAfterMs;

  /// Long-audio observations needed.
  final int minLongAudioRuns;

  /// Pending requests iOS keeps (ADR-013).
  final int notificationBudget;

  /// Scenarios the Android exact path must pass.
  final Set<String> androidScenarios;

  /// Scenarios the Android fallback must pass.
  final Set<String> androidFallbackScenarios;

  /// Scenarios AlarmKit delivery must pass.
  final Set<String> iosScenarios;
}
