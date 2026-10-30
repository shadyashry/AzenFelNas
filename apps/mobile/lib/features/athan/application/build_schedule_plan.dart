import 'package:daily_muslim/features/athan/application/athan_preferences.dart';
import 'package:daily_muslim/features/athan/application/fit_slot_budget.dart';
import 'package:daily_muslim/features/athan/application/plan_entry_id.dart';
import 'package:daily_muslim/features/athan/application/plan_event_code.dart';
import 'package:daily_muslim/features/athan/application/plan_request.dart';
import 'package:daily_muslim/features/athan/domain/plan_copy.dart';
import 'package:daily_muslim/features/athan/domain/plan_target.dart';
import 'package:daily_muslim/features/athan/domain/plan_text_key.dart';
import 'package:daily_muslim/features/athan/domain/plan_texts.dart';
import 'package:dm_civil_time/dm_civil_time.dart';
import 'package:dm_contracts/dm_contracts.dart';
import 'package:dm_core_types/dm_core_types.dart';
import 'package:geo_salah_core/geo_salah_core.dart';

/// Builds the platform-fitted `SchedulePlan` (ADR-002, §7.7, Appendix B):
/// the only input of native scheduling. Pure: the same request gives the
/// same plan, byte for byte.
///
/// Entries fire at the event's `displayedUtcMs` (REQ-ALM-001); a
/// pre-reminder fires its offset earlier. Entries at or before
/// [PlanRequest.nowUtcMs] are left out. Android keeps 30 days; iOS keeps
/// what its slot budget allows after priority fitting (REQ-ALM-032). Every
/// plan ends with one `HORIZON_WARNING` (REQ-ALM-010). Local times are read
/// with the pinned TZDB (REQ-TIME-020).
final class BuildSchedulePlan {
  /// Builds with [_tzdb] and the copy of [_texts].
  const new(this._tzdb, this._texts);

  final PinnedTzDatabase _tzdb;
  final PlanTexts _texts;

  /// Sound id of entries other than `ATHAN`: the OS notification sound
  /// (§15 D80).
  static const String notificationSoundId = 'notification_default';

  static const FitSlotBudget _fit = FitSlotBudget();
  static const int _minuteMs = 60000;
  static const int _hourMs = 3600000;

  /// The plan of [request].
  SchedulePlan call(PlanRequest request) {
    final target = request.target;
    final days = switch (target) {
      AndroidPlanTarget() => request.days.take(AndroidPlanTarget.horizonDays),
      IosPlanTarget() => request.days,
    };
    final candidates = [
      for (final day in days)
        for (final time in day.times) ..._entriesOf(request, day.day, time),
    ];
    final fitted = switch (target) {
      AndroidPlanTarget() => candidates,
      IosPlanTarget(:final slotBudget) => _fit(candidates, slotBudget - 1),
    };
    final horizonEnd = _horizonEnd(fitted, days, request.nowUtcMs);
    final entries = [
      ...fitted,
      _warning(request, horizonEnd - target.warningLeadHours * _hourMs),
    ]..sort(_byInstant);
    return SchedulePlan(
      schemaVersion: 1,
      generation: request.generation,
      contextId: request.contextId,
      zoneId: request.zoneId,
      tzdbVersion: _tzdb.version,
      generatedAtUtcMs: request.nowUtcMs,
      horizonEndUtcMs: horizonEnd,
      entries: List.unmodifiable(entries),
      policy: _policy(request.preferences),
    );
  }

  List<SchedulePlanEntry> _entriesOf(
    PlanRequest request,
    CivilDate day,
    PrayerTime time,
  ) {
    final displayed = time.displayedUtcMs;
    final preferences = request.preferences;
    if (displayed == null || !preferences.enabled.contains(time.event)) {
      return const [];
    }
    final event = time.event;
    final minutes = preferences.preReminder.minutes;
    final candidates = switch (event) {
      PrayerEvent.sunrise => const <SchedulePlanEntry>[],
      PrayerEvent.imsak => [
        _entry(request, day, event, ScheduleEntryKind.imsak, displayed),
      ],
      PrayerEvent.fajr ||
      PrayerEvent.dhuhr ||
      PrayerEvent.asr ||
      PrayerEvent.maghrib ||
      PrayerEvent.isha => [
        _entry(request, day, event, ScheduleEntryKind.athan, displayed),
        if (minutes > 0)
          _entry(
            request,
            day,
            event,
            ScheduleEntryKind.preReminder,
            displayed - minutes * _minuteMs,
          ),
      ],
    };
    return [
      for (final entry in candidates)
        if (entry.fireAtUtcMs > request.nowUtcMs) entry,
    ];
  }

  SchedulePlanEntry _entry(
    PlanRequest request,
    CivilDate day,
    PrayerEvent event,
    ScheduleEntryKind kind,
    int fireAtUtcMs,
  ) {
    final code = PlanEventCode.of(event);
    final dayWire = day.toJson();
    final spec = switch (kind) {
      ScheduleEntryKind.athan => (
        AthanText(event),
        1,
        event == PrayerEvent.fajr
            ? request.preferences.fajrSoundId
            : request.preferences.soundId,
      ),
      ScheduleEntryKind.imsak => (const ImsakText(), 2, notificationSoundId),
      ScheduleEntryKind.preReminder => (
        PreReminderText(event, request.preferences.preReminder.minutes),
        3,
        notificationSoundId,
      ),
      ScheduleEntryKind.horizonWarning => (
        const HorizonText(),
        1,
        notificationSoundId,
      ),
    };
    final (key, priority, soundId) = spec;
    return SchedulePlanEntry(
      id: PlanEntryId.of(
        contextId: request.contextId,
        day: dayWire,
        event: code,
        kind: kind,
      ),
      day: dayWire,
      kind: kind,
      fireAtUtcMs: fireAtUtcMs,
      displayLocal: _local(request.zoneId, fireAtUtcMs),
      title: _text(_texts.title(key)),
      body: _text(_texts.body(key)),
      soundId: soundId,
      priority: priority,
      event: code,
    );
  }

  /// The warning at [atUtcMs], never before the build instant.
  SchedulePlanEntry _warning(PlanRequest request, int atUtcMs) {
    final fireAt = atUtcMs < request.nowUtcMs ? request.nowUtcMs : atUtcMs;
    final day = _tzdb.localDateTimeOf(request.zoneId, fireAt).date.toJson();
    const key = HorizonText();
    return SchedulePlanEntry(
      id: PlanEntryId.of(
        contextId: request.contextId,
        day: day,
        kind: ScheduleEntryKind.horizonWarning,
      ),
      day: day,
      kind: ScheduleEntryKind.horizonWarning,
      fireAtUtcMs: fireAt,
      displayLocal: _local(request.zoneId, fireAt),
      title: _text(_texts.title(key)),
      body: _text(_texts.body(key)),
      soundId: notificationSoundId,
      priority: 1,
    );
  }

  /// The last scheduled instant; with nothing scheduled, the last timed
  /// event of [days] (or the build instant when there is none).
  static int _horizonEnd(
    List<SchedulePlanEntry> entries,
    Iterable<DayResult> days,
    int nowUtcMs,
  ) {
    var end = nowUtcMs;
    final instants = entries.isEmpty
        ? [
            for (final day in days)
              for (final time in day.times) ?time.displayedUtcMs,
          ]
        : [for (final entry in entries) entry.fireAtUtcMs];
    for (final instant in instants) {
      if (instant > end) end = instant;
    }
    return end;
  }

  /// The §7.7 policy: the user's locale and pre-reminder; the delivery
  /// defaults of §7.7 for the rest (§15 D80).
  static SchedulePlanPolicy _policy(AthanPreferences preferences) =>
      SchedulePlanPolicy(
        locale: preferences.locale,
        respectDnd: false,
        vibrate: true,
        fullAthanAndroid: true,
        iosClipSeconds: 29,
        preReminderMinutes: preferences.preReminder.minutes,
        snoozeMinutes: 5,
      );

  String _local(String zoneId, int utcMs) {
    final minutes =
        _tzdb.localDateTimeOf(zoneId, utcMs).millisecondOfDay ~/ _minuteMs;
    return '${_two(minutes ~/ 60)}:${_two(minutes % 60)}';
  }

  static LocalizedText _text(PlanCopy copy) =>
      LocalizedText(ar: copy.ar, en: copy.en);

  static String _two(int value) => value.toString().padLeft(2, '0');

  static int _byInstant(SchedulePlanEntry a, SchedulePlanEntry b) {
    final byInstant = a.fireAtUtcMs.compareTo(b.fireAtUtcMs);
    return byInstant != 0 ? byInstant : a.id.compareTo(b.id);
  }
}
