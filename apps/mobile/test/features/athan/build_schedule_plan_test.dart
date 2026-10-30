import 'package:daily_muslim/features/athan/application/athan_preferences.dart';
import 'package:daily_muslim/features/athan/domain/plan_target.dart';
import 'package:daily_muslim/features/athan/domain/pre_reminder.dart';
import 'package:dm_contracts/dm_contracts.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geo_salah_core/geo_salah_core.dart';

import '../../support/app_harness.dart';
import '../../support/runtime_fixtures.dart';
import 'plan_fixtures.dart';

const int _hourMs = 3600000;

Iterable<SchedulePlanEntry> _of(SchedulePlan plan, ScheduleEntryKind kind) =>
    plan.entries.where((e) => e.kind == kind);

void main() {
  final build = planBuilder();
  final android = build(cairoRequest());
  final ios = build(cairoRequest(target: const IosPlanTarget()));

  group('BuildSchedulePlan (§7.7, ADR-002)', () {
    test('REQ-ALM-001 every Athan and Imsak entry fires at its event '
        'displayedUtcMs', () {
      final displayed = {
        for (final day in cairoPlanDays())
          for (final time in day.times)
            '${day.day.toJson()}|${time.event.name}': time.displayedUtcMs,
      };
      final alerts = android.entries.where(
        (e) =>
            e.kind == ScheduleEntryKind.athan ||
            e.kind == ScheduleEntryKind.imsak,
      );
      expect(alerts, isNotEmpty);
      for (final entry in alerts) {
        final event = entry.event;
        expect(event, isNotNull);
        expect(
          entry.fireAtUtcMs,
          displayed['${entry.day}|${event?.name}'],
          reason: entry.id,
        );
      }
    });

    test('REQ-ALM-001 nothing at or before the build instant is '
        'scheduled and Sunrise never is', () {
      for (final entry in android.entries) {
        expect(entry.fireAtUtcMs, greaterThan(harnessNowUtcMs));
        expect(entry.event, isNot(PrayerEventCode.sunrise));
      }
    });

    test('REQ-ALM-042 one pre-reminder per Athan fires its offset '
        'earlier; the policy carries it and a 5-minute snooze', () {
      final athans = {
        for (final e in _of(android, ScheduleEntryKind.athan))
          '${e.day}|${e.event}': e,
      };
      final reminders = _of(android, ScheduleEntryKind.preReminder).toList();
      expect(reminders, hasLength(athans.length));
      for (final reminder in reminders) {
        final athan = athans['${reminder.day}|${reminder.event}'];
        expect(athan?.fireAtUtcMs, reminder.fireAtUtcMs + 10 * 60000);
        expect(reminder.priority, 3);
      }
      expect(android.policy.preReminderMinutes, 10);
      expect(android.policy.snoozeMinutes, 5);
    });

    test('REQ-ALM-042 the offset is one of 0, 5, 10, 15, 30 and off '
        'schedules no pre-reminder', () {
      expect(PreReminder.values.map((p) => p.minutes), [0, 5, 10, 15, 30]);
      expect(PreReminder.ofMinutes(7), isNull);
      expect(PreReminder.ofMinutes(15), PreReminder.fifteen);
      final off = build(
        cairoRequest(
          preferences: AthanPreferences(
            enabled: allEvents.enabled,
            soundId: allEvents.soundId,
            fajrSoundId: allEvents.fajrSoundId,
            preReminder: PreReminder.off,
            locale: PlanLocale.en,
          ),
        ),
      );
      expect(_of(off, ScheduleEntryKind.preReminder), isEmpty);
    });

    test('REQ-ALM-010 the Android plan covers 30 days and ends with one '
        'horizon warning 48 h before its last entry', () {
      final days = _of(android, ScheduleEntryKind.athan).map((e) => e.day);
      expect(days.toSet(), hasLength(30));
      final warnings = _of(android, ScheduleEntryKind.horizonWarning).toList();
      expect(warnings, hasLength(1));
      expect(warnings.single.event, isNull);
      expect(
        warnings.single.fireAtUtcMs,
        android.horizonEndUtcMs - 48 * _hourMs,
      );
      expect(
        android.horizonEndUtcMs,
        android.entries
            .map((e) => e.fireAtUtcMs)
            .reduce(
              (a, b) => a > b ? a : b,
            ),
      );
    });

    test('REQ-ALM-052 the Fajr Athan carries the Fajr voice and every other '
        'Athan the Athan voice; reminders keep the notification sound', () {
      final plan = build(
        cairoRequest(
          preferences: AthanPreferences(
            enabled: allEvents.enabled,
            soundId: 'athan_v1',
            fajrSoundId: 'fajr_v1',
            preReminder: PreReminder.ten,
            locale: PlanLocale.en,
          ),
        ),
      );
      final athans = _of(plan, ScheduleEntryKind.athan).toList();
      expect(
        athans
            .where((e) => e.event == PrayerEventCode.fajr)
            .map((e) => e.soundId)
            .toSet(),
        {'fajr_v1'},
      );
      expect(
        athans
            .where((e) => e.event != PrayerEventCode.fajr)
            .map((e) => e.soundId)
            .toSet(),
        {'athan_v1'},
      );
      expect(
        _of(plan, ScheduleEntryKind.preReminder).map((e) => e.soundId),
        everyElement(isNot(anyOf('fajr_v1', 'athan_v1'))),
      );
    });

    test('REQ-ALM-010 with no event enabled the plan still holds its '
        'horizon warning', () {
      final none = build(
        cairoRequest(
          preferences: AthanPreferences(
            enabled: const {},
            soundId: allEvents.soundId,
            fajrSoundId: allEvents.fajrSoundId,
            preReminder: PreReminder.off,
            locale: PlanLocale.ar,
          ),
        ),
      );
      expect(none.entries.map((e) => e.kind), [
        ScheduleEntryKind.horizonWarning,
      ]);
    });

    test('REQ-ALM-032 the iOS plan never exceeds 64 entries: reminders and '
        'Imsak go first, then the farthest Athans', () {
      expect(ios.entries, hasLength(IosPlanTarget.defaultSlotBudget));
      expect(_of(ios, ScheduleEntryKind.preReminder), isEmpty);
      expect(_of(ios, ScheduleEntryKind.imsak), isEmpty);
      final earliestAthans = _of(
        android,
        ScheduleEntryKind.athan,
      ).take(IosPlanTarget.defaultSlotBudget - 1).map((e) => e.id).toList();
      expect(
        _of(ios, ScheduleEntryKind.athan).map((e) => e.id),
        earliestAthans,
      );
    });

    test('REQ-ALM-032 a smaller budget keeps priority before proximity', () {
      final plan = build(
        cairoRequest(target: const IosPlanTarget(slotBudget: 8)),
      );
      expect(plan.entries, hasLength(8));
      expect(
        plan.entries.where((e) => e.kind != ScheduleEntryKind.horizonWarning),
        everyElement(
          isA<SchedulePlanEntry>().having((e) => e.priority, 'priority', 1),
        ),
      );
    });

    test('REQ-ALM-010 the iOS horizon warning fires 24 h before the last '
        'kept Athan', () {
      final warning = _of(ios, ScheduleEntryKind.horizonWarning).single;
      expect(warning.fireAtUtcMs, ios.horizonEndUtcMs - 24 * _hourMs);
      expect(
        ios.horizonEndUtcMs,
        _of(ios, ScheduleEntryKind.athan).last.fireAtUtcMs,
      );
    });

    test('REQ-ALM-021 ids are deterministic, unique and stable across '
        'generations', () {
      final again = build(cairoRequest());
      expect(again.toJson(), android.toJson());
      final ids = android.entries.map((e) => e.id).toList();
      expect(ids.toSet(), hasLength(ids.length));
      final later = build(
        cairoRequest(generation: 2, nowUtcMs: harnessNowUtcMs + 6 * _hourMs),
      );
      expect(later.generation, 2);
      final laterIds = later.entries
          .where((e) => e.kind != ScheduleEntryKind.horizonWarning)
          .map((e) => e.id)
          .toSet();
      expect(ids.toSet().intersection(laterIds), isNotEmpty);
      expect(ids.toSet().containsAll(laterIds.take(10)), isTrue);
    });

    test('REQ-TIME-001 the plan carries its zone and pinned TZDB version; '
        'REQ-TIME-020 displayLocal is read with that TZDB', () {
      final tzdb = bundledRuntimeData().tzdb;
      expect(android.zoneId, 'Africa/Cairo');
      expect(android.tzdbVersion, tzdb.version);
      for (final entry in android.entries.take(20)) {
        final minutes =
            tzdb
                .localDateTimeOf('Africa/Cairo', entry.fireAtUtcMs)
                .millisecondOfDay ~/
            60000;
        final hh = (minutes ~/ 60).toString().padLeft(2, '0');
        final mm = (minutes % 60).toString().padLeft(2, '0');
        expect(entry.displayLocal, '$hh:$mm');
      }
    });

    test('REQ-ALM-010 the built plans match the committed schema '
        'fixtures', () {
      expectFixture(
        'schedule_plan/valid/built_android.json',
        fixtureText(android.toJson()),
      );
      expectFixture(
        'schedule_plan/valid/built_ios.json',
        fixtureText(ios.toJson()),
      );
    });

    test('REQ-ALM-010 a built plan decodes back to itself', () {
      expect(SchedulePlan.fromJson(ios.toJson()), ios);
    });
  });
}
