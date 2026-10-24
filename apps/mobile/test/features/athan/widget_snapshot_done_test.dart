// S28 done-test, Dart half: the widget snapshot stays correct across local
// midnight and is rewritten whole on a profile update (§7.7, Appendix I).
// The native half runs `schemas/vectors/widget_content.v1.json` in the
// Kotlin `SelectWidgetContentTest` and the Swift `WidgetTimelineTests`.
import 'dart:convert';
import 'dart:io';

import 'package:daily_muslim/features/athan/application/build_snapshot.dart';
import 'package:daily_muslim/features/athan/application/refresh_widget_snapshot.dart';
import 'package:daily_muslim/features/contexts/domain/resolved_context.dart';
import 'package:daily_muslim/features/schedule/application/calculate_schedule.dart';
import 'package:daily_muslim/features/schedule/domain/runtime_data.dart';
import 'package:daily_muslim/features/schedule/domain/schedule.dart';
import 'package:dm_contracts/dm_contracts.dart';
import 'package:dm_core_types/dm_core_types.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geo_salah_core/geo_salah_core.dart';
import 'package:geo_salah_profiles/geo_salah_profiles.dart';

import '../../support/runtime_fixtures.dart';
import 'support/fake_widget_host.dart';

/// 2026-11-10T21:50:00Z: 23:50 in Cairo (UTC+2), inside the seed country
/// profiles' effective range.
const int _beforeMidnight = 1794347400000;

/// 2026-11-10T22:10:00Z: 00:10 on 11 November in Cairo.
const int _afterMidnight = 1794348600000;

const SnapshotHealth _health = SnapshotHealth(
  state: HealthStateCode.unknown,
  reasonsCount: 0,
);

T _ok<T>(Result<T, Failure> result) => switch (result) {
  Ok(:final value) => value,
  Err(:final failure) => throw StateError('$failure'),
};

Schedule _schedule(
  ResolvedContext Function() context,
  RuntimeData data,
  int now,
) => _ok(CalculateSchedule(FixedClock(now))(context(), data));

Future<Snapshot> _refresh(
  Schedule schedule,
  RuntimeData data,
  int now, {
  PlanLocale locale = PlanLocale.en,
}) async {
  final host = FakeWidgetHost();
  final written = await RefreshWidgetSnapshot(
    BuildSnapshot(data.tzdb),
    host,
    FixedClock(now),
  )(schedule, locale: locale, health: _health);
  expect(written, isTrue);
  return host.stored ?? (throw StateError('nothing stored'));
}

/// The seed set without its `SA` profile: Makkah falls back to
/// `engine.default`, a different schedule built only from the seed's own
/// draft data (§0.2 rule 1).
RuntimeData _withoutSaudi(RuntimeData data) => RuntimeData(
  tzdb: data.tzdb,
  zones: data.zones,
  countries: data.countries,
  profiles: _ok(
    const ParseProfileSetPayload()(
      utf8.encode(
        jsonEncode([
          for (final profile in jsonDecode(
            File(
              'assets/packages/prayer_profiles/2026.10.1/'
              'profiles.json',
            ).readAsStringSync(),
          ) as List<Object?>)
            if (profile is Map<String, Object?> &&
                profile['profileId'] != 'sa.ummalqura.standard')
              profile,
        ]),
      ),
    ),
  ),
);

void main() {
  final data = bundledRuntimeData();

  group('S28 widget snapshot across local midnight', () {
    test('REQ-WID-002 a snapshot written just before midnight and one just '
        'after agree on every shared time', () async {
      final before = await _refresh(
        _schedule(cairo, data, _beforeMidnight),
        data,
        _beforeMidnight,
      );
      final after = await _refresh(
        _schedule(cairo, data, _afterMidnight),
        data,
        _afterMidnight,
      );
      final byInstant = {
        for (final item in before.items) item.displayedUtcMs: item,
      };
      final shared = after.items.where(
        (item) => byInstant.containsKey(item.displayedUtcMs),
      );
      expect(shared.length, greaterThanOrEqualTo(12));
      for (final item in shared) {
        expect(item, byInstant[item.displayedUtcMs]);
      }
      // The next prayer is 11 November's Fajr in both.
      expect(before.items.first.day, '2026-11-11');
      expect(before.items.first.event, PrayerEventCode.fajr);
      expect(after.items.first, before.items.first);
    });

    test('REQ-WID-002 every item carries its prayer day and the local time '
        'the pinned TZDB gives, so a widget needs no zone rules', () async {
      final snapshot = await _refresh(
        _schedule(cairo, data, _beforeMidnight),
        data,
        _beforeMidnight,
      );
      for (final item in snapshot.items) {
        final local = data.tzdb.localDateTimeOf(
          snapshot.zoneId,
          item.displayedUtcMs,
        );
        expect(item.day, local.date.toJson());
        final minutes = local.millisecondOfDay ~/ 60000;
        expect(
          item.displayLocal,
          '${(minutes ~/ 60).toString().padLeft(2, '0')}:'
          '${(minutes % 60).toString().padLeft(2, '0')}',
        );
      }
    });
  });

  group('S28 widget snapshot on a profile update', () {
    ResolvedContext makkah() => manualContext(
      latitudeDeg: 21.4225,
      longitudeDeg: 39.8262,
      zoneId: 'Asia/Riyadh',
      country: 'SA',
      label: 'Makkah',
    );

    test('REQ-WID-003 the new profile set rewrites the snapshot whole with '
        'the new times', () async {
      final updated = _withoutSaudi(data);
      final host = FakeWidgetHost();
      final refresh = RefreshWidgetSnapshot(
        BuildSnapshot(data.tzdb),
        host,
        FixedClock(_beforeMidnight),
      );
      final oldSchedule = _schedule(makkah, data, _beforeMidnight);
      await refresh(oldSchedule, locale: PlanLocale.ar, health: _health);
      final old = host.stored;
      final newSchedule = _schedule(makkah, updated, _beforeMidnight);
      expect(newSchedule.profileId, isNot(oldSchedule.profileId));
      await refresh(newSchedule, locale: PlanLocale.ar, health: _health);
      final stored = host.stored;

      expect(stored, isNot(old));
      expect(
        stored,
        await _refresh(
          newSchedule,
          updated,
          _beforeMidnight,
          locale: PlanLocale.ar,
        ),
      );
    });

    test('REQ-WID-003 a refused snapshot keeps the previous one', () async {
      final host = FakeWidgetHost();
      final refresh = RefreshWidgetSnapshot(
        BuildSnapshot(data.tzdb),
        host,
        FixedClock(_beforeMidnight),
      );
      await refresh(
        _schedule(makkah, data, _beforeMidnight),
        locale: PlanLocale.ar,
        health: _health,
      );
      final kept = host.stored;
      host.accepts = false;
      final written = await refresh(
        _schedule(makkah, _withoutSaudi(data), _beforeMidnight),
        locale: PlanLocale.ar,
        health: _health,
      );
      expect(written, isFalse);
      expect(host.stored, kept);
    });
  });
}
