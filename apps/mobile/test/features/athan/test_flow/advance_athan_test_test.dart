import 'package:daily_muslim/features/athan/application/advance_athan_test.dart';
import 'package:daily_muslim/features/athan/domain/athan_test_event.dart';
import 'package:daily_muslim/features/athan/domain/athan_test_result.dart';
import 'package:daily_muslim/features/athan/domain/athan_test_state.dart';
import 'package:flutter_test/flutter_test.dart';

const _id = '0000019a1b2c3d4e';
const _fire = 1000000;

void main() {
  const advance = AdvanceAthanTest();
  const scheduled = AthanTestScheduled(
    testId: _id,
    fireAtUtcMs: _fire,
    secondsLeft: 60,
  );
  const fired = AthanTestFired(testId: _id, fireAtUtcMs: _fire);

  group('AdvanceAthanTest (§18.4 Athan Test states)', () {
    test(
      'REQ-ALM-040 arming from idle schedules with a rounded-up countdown',
      () {
        expect(
          advance(
            const AthanTestIdle(),
            const TestArmed(
              testId: _id,
              fireAtUtcMs: _fire,
              nowUtcMs: _fire - 59001,
            ),
          ),
          scheduled,
        );
      },
    );

    test('REQ-ALM-040 ticks count down, then fire at the fire instant', () {
      expect(
        advance(scheduled, const ClockTicked(_fire - 1500)),
        const AthanTestScheduled(
          testId: _id,
          fireAtUtcMs: _fire,
          secondsLeft: 2,
        ),
      );
      expect(advance(scheduled, const ClockTicked(_fire)), fired);
    });

    test('REQ-ALM-040 the question appears askDelayMs after firing', () {
      const delay = AdvanceAthanTest.askDelayMs;
      expect(advance(fired, const ClockTicked(_fire + delay - 1)), fired);
      expect(
        advance(fired, const ClockTicked(_fire + delay)),
        const AthanTestAskHeard(_id),
      );
    });

    test(
      'REQ-ALM-040 an answer records heardByUser and presentedByOs apart',
      () {
        for (final state in [fired, const AthanTestAskHeard(_id)]) {
          expect(
            advance(
              state,
              const HeardAnswered(
                heard: false,
                presentedByOs: true,
                nowUtcMs: 7,
              ),
            ),
            const AthanTestRecorded(
              AthanTestResult(
                testId: _id,
                heardByUser: false,
                presentedByOs: true,
                answeredAtUtcMs: 7,
              ),
            ),
          );
        }
      },
    );

    test('REQ-ALM-040 an answer before the Test fires is ignored', () {
      expect(
        advance(
          scheduled,
          const HeardAnswered(heard: true, presentedByOs: null, nowUtcMs: 1),
        ),
        scheduled,
      );
    });

    test('REQ-ALM-040 a second arm while a Test runs is ignored', () {
      const again = TestArmed(
        testId: 'ffffffffffffffff',
        fireAtUtcMs: 9,
        nowUtcMs: 0,
      );
      for (final state in [scheduled, fired, const AthanTestAskHeard(_id)]) {
        expect(advance(state, again), state);
      }
    });

    test('REQ-ALM-040 a refusal is notArmed, and a retry can arm again', () {
      final refused = advance(const AthanTestIdle(), const TestRefused());
      expect(refused, const AthanTestNotArmed());
      expect(
        advance(
          refused,
          const TestArmed(testId: _id, fireAtUtcMs: _fire, nowUtcMs: _fire),
        ),
        fired,
      );
    });

    test('REQ-ALM-040 reset returns to idle from every state', () {
      final states = <AthanTestState>[
        const AthanTestIdle(),
        scheduled,
        fired,
        const AthanTestAskHeard(_id),
        const AthanTestNotArmed(),
        const AthanTestRecorded(
          AthanTestResult(
            testId: _id,
            heardByUser: true,
            presentedByOs: null,
            answeredAtUtcMs: 0,
          ),
        ),
      ];
      for (final state in states) {
        expect(advance(state, const TestReset()), const AthanTestIdle());
      }
    });

    test('REQ-ALM-040 ticks leave idle, askHeard and recorded unchanged', () {
      for (final state in [
        const AthanTestIdle(),
        const AthanTestAskHeard(_id),
        const AthanTestNotArmed(),
      ]) {
        expect(advance(state, const ClockTicked(_fire * 2)), state);
      }
    });
  });
}
