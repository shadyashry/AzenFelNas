import 'package:daily_muslim/features/athan/application/apply_athan_plan.dart';
import 'package:daily_muslim/features/athan/application/athan_preferences.dart';
import 'package:daily_muslim/features/athan/application/plan_schedule.dart';
import 'package:daily_muslim/features/athan/data/arb_plan_texts.dart';
import 'package:daily_muslim/features/athan/domain/athan_grant.dart';
import 'package:daily_muslim/features/athan/domain/athan_health_reason.dart';
import 'package:daily_muslim/features/athan/domain/plan_failure.dart';
import 'package:daily_muslim/features/athan/domain/plan_target.dart';
import 'package:daily_muslim/features/athan/domain/pre_reminder.dart';
import 'package:daily_muslim/features/settings/data/drift_settings_store.dart';
import 'package:daily_muslim/features/settings/domain/app_settings.dart';
import 'package:daily_muslim/features/storage/data/dm_database.dart';
import 'package:dm_contracts/dm_contracts.dart';
import 'package:dm_core_types/dm_core_types.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geo_salah_core/geo_salah_core.dart';

import '../../support/app_harness.dart';
import '../../support/runtime_fixtures.dart';
import 'support/fake_plan_host.dart';

AthanPreferences _defaults({List<String> sounds = const ['test_cc0_adhan']}) =>
    AthanPreferences.ofSettings(
      enabled: const {},
      soundId: null,
      sounds: sounds,
      preReminderMinutes: 0,
      locale: PlanLocale.ar,
    );

void main() {
  late DmDatabase db;
  late DriftSettingsStore settings;
  late FakePlanHost host;
  late ApplyAthanPlan apply;

  setUp(() {
    db = DmDatabase(NativeDatabase.memory());
    settings = DriftSettingsStore(db);
    host = FakePlanHost();
    apply = ApplyAthanPlan(
      plan: PlanSchedule(FixedClock(harnessNowUtcMs), ArbPlanTexts()),
      apply: host,
      read: settings,
      write: settings,
    );
  });
  tearDown(() => db.close());

  Future<Result<SchedulePlan, Failure>> arm([AthanPreferences? preferences]) =>
      apply(
        bundledRuntimeData(),
        cairo(),
        preferences: preferences ?? _defaults(),
        target: const AndroidPlanTarget(),
        hijriOverrideDays: 0,
      );

  group('ApplyAthanPlan (§15 D94)', () {
    test('REQ-ALM-001 REQ-ALM-010 arms the five prayers of 30 Cairo days '
        'with the bundled sound when the user has not chosen', () async {
      final result = await arm();

      final plan = switch (result) {
        Ok(:final value) => value,
        Err(:final failure) => fail('$failure'),
      };
      final athans = plan.entries.where(
        (e) => e.kind == ScheduleEntryKind.athan,
      );
      final perDay = <String, int>{};
      for (final athan in athans) {
        perDay[athan.day] = (perDay[athan.day] ?? 0) + 1;
      }
      expect(host.stored, plan);
      // 30 days of five prayers; the harness instant is Cairo noon, so the
      // first day keeps only the prayers still ahead.
      expect(perDay, hasLength(AndroidPlanTarget.horizonDays));
      expect(perDay.values.skip(1), everyElement(5));
      expect(athans.every((e) => e.fireAtUtcMs > harnessNowUtcMs), isTrue);
      expect(athans.map((e) => e.soundId).toSet(), {'test_cc0_adhan'});
      expect(
        plan.entries.where((e) => e.kind == ScheduleEntryKind.horizonWarning),
        hasLength(1),
      );
    });

    test('REQ-ALM-002 each applied plan takes the generation above the last '
        'stored one', () async {
      await arm();
      await arm();

      expect(host.offered.map((p) => p.generation), [1, 2]);
      expect(await settings.read(AppSettings.athanPlanGeneration), 2);
    });

    test('a refused plan keeps the stored generation, so the next one is '
        'offered under the same number', () async {
      host.accepts = false;
      final refused = await arm();
      host.accepts = true;
      await arm();

      expect(
        refused,
        const Result<SchedulePlan, Failure>.err(
          PlanFailure.writeRefused(1),
        ),
      );
      expect(host.offered.map((p) => p.generation), [1, 1]);
      expect(await settings.read(AppSettings.athanPlanGeneration), 1);
    });
  });

  group('AthanPreferences.ofSettings (§15 D94)', () {
    test('the five prayers alert until the user chooses; then only the '
        'events set true', () {
      expect(_defaults().enabled, AthanPreferences.defaultEvents);
      expect(
        AthanPreferences.ofSettings(
          enabled: const {'fajr': true, 'dhuhr': false, 'imsak': true},
          soundId: null,
          sounds: const [],
          preReminderMinutes: 0,
          locale: PlanLocale.en,
        ).enabled,
        {PrayerEvent.fajr, PrayerEvent.imsak},
      );
    });

    test('the chosen sound while bundled, else the first bundled one, else '
        'the device alarm', () {
      AthanPreferences prefs(String? chosen, List<String> sounds) =>
          AthanPreferences.ofSettings(
            enabled: const {},
            soundId: chosen,
            sounds: sounds,
            preReminderMinutes: 0,
            locale: PlanLocale.en,
          );

      expect(prefs('rifaat', ['ali', 'rifaat']).soundId, 'rifaat');
      expect(prefs('gone', ['ali', 'rifaat']).soundId, 'ali');
      expect(
        prefs(null, const []).soundId,
        AthanPreferences.deviceAlarmSoundId,
      );
    });

    test('REQ-ALM-042 an allowed pre-reminder is kept and any other value '
        'is off', () {
      AthanPreferences prefs(int minutes) => AthanPreferences.ofSettings(
        enabled: const {},
        soundId: null,
        sounds: const [],
        preReminderMinutes: minutes,
        locale: PlanLocale.en,
      );

      expect(prefs(15).preReminder, PreReminder.fifteen);
      expect(prefs(7).preReminder, PreReminder.off);
    });
  });

  group('Athan switches and grants (§15 D95)', () {
    test('turning a prayer off makes the whole choice explicit; turning the '
        'last one off stays off', () {
      final noFajr = AthanPreferences.toggled(
        const {},
        PrayerEvent.fajr,
        on: false,
      );
      expect(AthanPreferences.enabledOf(noFajr), {
        PrayerEvent.dhuhr,
        PrayerEvent.asr,
        PrayerEvent.maghrib,
        PrayerEvent.isha,
      });
      var none = noFajr;
      for (final e in [
        PrayerEvent.dhuhr,
        PrayerEvent.asr,
        PrayerEvent.maghrib,
        PrayerEvent.isha,
      ]) {
        none = AthanPreferences.toggled(none, e, on: false);
      }
      expect(AthanPreferences.enabledOf(none), isEmpty);
    });

    test(
      'REQ-ALM-026 a permission reason maps to its grant; others to none',
      () {
        expect(
          AthanGrant.of(AthanHealthReason.needsNotificationPermission),
          AthanGrant.notifications,
        );
        expect(
          AthanGrant.of(AthanHealthReason.inexactFallback),
          AthanGrant.exactAlarms,
        );
        expect(
          AthanGrant.of(AthanHealthReason.batteryRestricted),
          AthanGrant.appSettings,
        );
        expect(AthanGrant.of(AthanHealthReason.stalePlan), isNull);
      },
    );
  });
}
