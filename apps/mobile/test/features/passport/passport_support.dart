import 'package:daily_muslim/features/schedule/application/calculate_schedule.dart';
import 'package:daily_muslim/features/schedule/domain/schedule.dart';
import 'package:dm_core_types/dm_core_types.dart';

import '../../support/app_harness.dart';
import '../../support/runtime_fixtures.dart';

/// Cairo's week from the bundled seeds at the harness clock.
Schedule cairoSchedule({int plusDays = 0}) {
  final result = CalculateSchedule(
    FixedClock(harnessNowUtcMs + plusDays * Duration.millisecondsPerDay),
  )(cairo(), bundledRuntimeData());
  return switch (result) {
    Ok(:final value) => value,
    Err(:final failure) => throw StateError('$failure'),
  };
}
