import 'package:daily_muslim/features/athan/domain/athan_health.dart';
import 'package:daily_muslim/features/athan/domain/athan_health_reason.dart';
import 'package:daily_muslim/features/athan/domain/athan_test_result.dart';
import 'package:daily_muslim/features/athan/domain/athan_test_state.dart';
import 'package:daily_muslim/features/athan/domain/native_event.dart';
import 'package:daily_muslim/features/athan/presentation/athan_providers.dart';
import 'package:daily_muslim/features/athan/presentation/athan_test_controller.dart';
import 'package:daily_muslim/features/schedule/presentation/schedule_providers.dart';
import 'package:dm_contracts/dm_contracts.dart';
import 'package:dm_core_types/dm_core_types.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../contexts/support/settable_clock.dart';
import '../support/athan_overrides.dart';
import '../support/fake_athan_platform.dart';
import '../support/health_reports.dart';

void main() {
  test(
    'REQ-ALM-040 a Test runs idle → scheduled → fired → askHeard → '
    'recorded, stores the answer and degrades Health when not heard',
    () async {
      final clock = SettableClock(1761249600000);
      final platform = FakeAthanPlatform(report: androidReport());
      final log = <EventLogEntry>[];
      final container = ProviderContainer(
        overrides: [
          clockProvider.overrideWithValue(clock),
          ...athanOverrides(platform, log),
        ],
      );
      addTearDown(container.dispose);
      container.listen(athanTestProvider, (_, _) {});
      final test = container.read(athanTestProvider.notifier);

      expect(
        await container.read(athanHealthProvider.future),
        const AthanHealthReady(),
      );
      await test.start('makkah');
      expect(
        container.read(athanTestProvider),
        isA<AthanTestScheduled>().having((s) => s.secondsLeft, 'left', 60),
      );
      final testId = platform.armedTests.single;

      clock.utcMs += 60000;
      test.tick();
      expect(container.read(athanTestProvider), isA<AthanTestFired>());
      clock.utcMs += 10000;
      test.tick();
      expect(container.read(athanTestProvider), AthanTestAskHeard(testId));

      platform.pending.addAll(const [
        NativeEvent(EventCode.testStarted, entryId: 'c3c3c3c3c3c3c3c3'),
        NativeEvent(EventCode.alarmPresented, entryId: 'c3c3c3c3c3c3c3c3'),
      ]);
      await test.answer(heard: false);
      expect(
        container.read(athanTestProvider),
        AthanTestRecorded(
          AthanTestResult(
            testId: testId,
            heardByUser: false,
            presentedByOs: true,
            answeredAtUtcMs: clock.utcMs,
          ),
        ),
      );
      expect(log.single.code, EventCode.testResult);
      expect(
        await container.read(athanHealthProvider.future),
        const AthanHealthLimited([AthanHealthReason.failedTest]),
      );
    },
  );

  test('REQ-ALM-040 a platform refusal is notArmed', () async {
    final platform = FakeAthanPlatform(armed: false);
    final container = ProviderContainer(
      overrides: [
        clockProvider.overrideWithValue(SettableClock(0)),
        ...athanOverrides(platform, []),
      ],
    );
    addTearDown(container.dispose);
    container.listen(athanTestProvider, (_, _) {});
    await container.read(athanTestProvider.notifier).start('makkah');
    expect(container.read(athanTestProvider), const AthanTestNotArmed());
  });
}
