import 'dart:io';

import 'package:daily_muslim/features/settings/data/drift_settings_store.dart';
import 'package:daily_muslim/features/settings/domain/app_settings.dart';
import 'package:daily_muslim/features/settings/domain/setting_values.dart';
import 'package:daily_muslim/features/storage/data/dm_database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late DmDatabase db;
  late DriftSettingsStore store;

  setUp(() {
    db = DmDatabase(NativeDatabase.memory());
    store = DriftSettingsStore(db);
  });
  tearDown(() => db.close());

  Future<int> rows() async => (await db.select(db.settings).get()).length;

  test('AppSettings lists exactly the Appendix K keys, in order', () {
    final design = File('../../DESIGN.md').readAsStringSync();
    final line = RegExp(r'## Appendix K — Settings keys\n(.*)\n')
        .firstMatch(design)
        ?.group(1);
    final names = [
      for (final m in RegExp('`([A-Za-z]+)').allMatches(line ?? '')) m.group(1),
    ];
    expect(AppSettings.wires, names);
    expect(
      [
        AppSettings.locale,
        AppSettings.digits,
        AppSettings.themeMode,
        AppSettings.reducedMotionOverride,
        AppSettings.athanEnabled,
        AppSettings.soundId,
        AppSettings.preReminderMinutes,
        AppSettings.hijriOverrideDays,
        AppSettings.telemetryOptIn,
        AppSettings.telemetryConsentUtcMs,
        AppSettings.lastSyncUtcMs,
        AppSettings.lastRetentionRunUtcMs,
        AppSettings.onboardingComplete,
        AppSettings.activeContextId,
        AppSettings.showSeconds,
        AppSettings.athanPlanGeneration,
        AppSettings.fajrSoundId,
        AppSettings.quranRemoved,
        AppSettings.radioFavorites,
        AppSettings.radioStationId,
      ].map((k) => k.wire),
      AppSettings.wires,
    );
  });

  test('an unset key reads as its default', () async {
    expect(await store.read(AppSettings.locale), LocaleSetting.system);
    expect(await store.read(AppSettings.telemetryOptIn), isFalse);
    expect(await store.read(AppSettings.activeContextId), isNull);
    expect(await store.read(AppSettings.athanEnabled), isEmpty);
  });

  test('every kind of value round-trips', () async {
    await store.write(AppSettings.locale, LocaleSetting.ar);
    await store.write(AppSettings.digits, DigitsSetting.arabicIndic);
    await store.write(AppSettings.hijriOverrideDays, -1);
    await store.write(AppSettings.activeContextId, 7);
    await store.write(AppSettings.soundId, 'tone');
    await store.write(AppSettings.athanEnabled, {'fajr': true, 'asr': false});
    await store.write(AppSettings.showSeconds, true);

    expect(await store.read(AppSettings.locale), LocaleSetting.ar);
    expect(await store.read(AppSettings.digits), DigitsSetting.arabicIndic);
    expect(await store.read(AppSettings.hijriOverrideDays), -1);
    expect(await store.read(AppSettings.activeContextId), 7);
    expect(await store.read(AppSettings.soundId), 'tone');
    expect(await store.read(AppSettings.athanEnabled), {
      'fajr': true,
      'asr': false,
    });
    expect(await store.read(AppSettings.showSeconds), isTrue);
  });

  test('writing the default removes the row', () async {
    await store.write(AppSettings.themeMode, ThemeModeSetting.dark);
    expect(await rows(), 1);
    await store.write(
      AppSettings.themeMode,
      AppSettings.themeMode.defaultValue,
    );
    expect(await rows(), 0);
  });

  test('an unreadable or out-of-range row reads as the default', () async {
    Future<void> raw(String key, String json) => db
        .into(db.settings)
        .insertOnConflictUpdate(
          SettingsCompanion.insert(key: key, valueJson: json),
        );
    await raw('locale', '"fr"');
    await raw('hijriOverrideDays', '2');
    await raw('preReminderMinutes', '-5');
    await raw('telemetryOptIn', 'not json');
    await raw('athanEnabled', '{"fajr": 1}');

    expect(await store.read(AppSettings.locale), LocaleSetting.system);
    expect(await store.read(AppSettings.hijriOverrideDays), 0);
    expect(await store.read(AppSettings.preReminderMinutes), 0);
    expect(await store.read(AppSettings.telemetryOptIn), isFalse);
    expect(await store.read(AppSettings.athanEnabled), isEmpty);
  });

  test('watch emits the current value, then each change', () async {
    final seen = store.watch(AppSettings.locale).take(3).toList();
    await pumpEventQueue();
    await store.write(AppSettings.locale, LocaleSetting.ar);
    await pumpEventQueue();
    await store.write(AppSettings.locale, LocaleSetting.en);
    expect(await seen, [
      LocaleSetting.system,
      LocaleSetting.ar,
      LocaleSetting.en,
    ]);
  });
}
