import 'dart:convert';
import 'dart:io';

import 'package:daily_muslim/features/athan/application/athan_preferences.dart';
import 'package:daily_muslim/features/athan/application/build_schedule_plan.dart';
import 'package:daily_muslim/features/athan/application/plan_context_id.dart';
import 'package:daily_muslim/features/athan/application/plan_request.dart';
import 'package:daily_muslim/features/athan/data/arb_plan_texts.dart';
import 'package:daily_muslim/features/athan/domain/plan_target.dart';
import 'package:daily_muslim/features/athan/domain/pre_reminder.dart';
import 'package:daily_muslim/features/schedule/application/calculate_schedule.dart';
import 'package:dm_contracts/dm_contracts.dart';
import 'package:dm_core_types/dm_core_types.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geo_salah_core/geo_salah_core.dart';

import '../../support/app_harness.dart';
import '../../support/runtime_fixtures.dart';

/// Every event, a 10-minute pre-reminder, Arabic first.
const AthanPreferences allEvents = AthanPreferences(
  enabled: {...PrayerEvent.values},
  soundId: 'athan_makkah_v1',
  preReminder: PreReminder.ten,
  locale: PlanLocale.ar,
);

/// Cairo's 30 plan days from the harness instant.
List<DayResult> cairoPlanDays({int nowUtcMs = harnessNowUtcMs}) {
  final result = CalculateSchedule(FixedClock(nowUtcMs))(
    cairo(),
    bundledRuntimeData(),
    dayCount: CalculateSchedule.planDays,
  );
  return switch (result) {
    Ok(:final value) => value.days,
    Err(:final failure) => throw StateError('$failure'),
  };
}

/// A Cairo plan request.
PlanRequest cairoRequest({
  PlanTarget target = const AndroidPlanTarget(),
  AthanPreferences preferences = allEvents,
  int generation = 1,
  int nowUtcMs = harnessNowUtcMs,
}) => PlanRequest(
  contextId: PlanContextId.of(1),
  zoneId: 'Africa/Cairo',
  days: cairoPlanDays(nowUtcMs: nowUtcMs),
  generation: generation,
  nowUtcMs: nowUtcMs,
  preferences: preferences,
  target: target,
);

/// The plan builder over the bundled TZDB and the ARB copy.
BuildSchedulePlan planBuilder() =>
    BuildSchedulePlan(bundledRuntimeData().tzdb, ArbPlanTexts());

/// [json] pretty-printed as the committed fixture files are.
String fixtureText(Map<String, Object?> json) =>
    '${const JsonEncoder.withIndent('  ').convert(json)}\n';

/// Compares [actual] with `schemas/fixtures/<path>`; with
/// `DM_UPDATE_FIXTURES=1` it rewrites the fixture instead. The fixture is
/// validated against its schema by `schemas/tools/validate_fixtures.sh`.
void expectFixture(String path, String actual) {
  final file = File('../../schemas/fixtures/$path');
  if (Platform.environment['DM_UPDATE_FIXTURES'] == '1') {
    file.writeAsStringSync(actual);
  }
  expect(actual, file.readAsStringSync(), reason: 'fixture $path');
}
