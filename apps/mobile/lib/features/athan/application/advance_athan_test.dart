import 'package:daily_muslim/features/athan/domain/athan_test_event.dart';
import 'package:daily_muslim/features/athan/domain/athan_test_result.dart';
import 'package:daily_muslim/features/athan/domain/athan_test_state.dart';

/// The Athan Test state machine (§8.3, §18.4, REQ-ALM-040): a pure
/// transition function, so every edge is unit-tested without a clock.
///
/// `idle`/`recorded`/`notArmed` --armed--> `scheduled` --tick ≥ fire-->
/// `fired` --tick ≥ fire + [askDelayMs]--> `askHeard`; an answer in `fired`
/// or `askHeard` --> `recorded`; a refusal in `idle` --> `notArmed`; reset
/// --> `idle`. Every other pair leaves the state unchanged.
final class AdvanceAthanTest {
  /// The machine.
  const new();

  /// Time the Athan sounds before the question appears (§15 D83).
  static const int askDelayMs = 10000;

  /// The state after [event] in [state].
  AthanTestState call(AthanTestState state, AthanTestEvent event) =>
      switch ((state, event)) {
        (
          AthanTestIdle() || AthanTestRecorded() || AthanTestNotArmed(),
          TestArmed(:final testId, :final fireAtUtcMs, :final nowUtcMs),
        ) =>
          _scheduled(testId, fireAtUtcMs, nowUtcMs),
        (
          AthanTestIdle() || AthanTestRecorded() || AthanTestNotArmed(),
          TestRefused(),
        ) =>
          const AthanTestNotArmed(),
        (
          AthanTestScheduled(:final testId, :final fireAtUtcMs),
          ClockTicked(:final nowUtcMs),
        ) =>
          _scheduled(testId, fireAtUtcMs, nowUtcMs),
        (
          AthanTestFired(:final testId, :final fireAtUtcMs),
          ClockTicked(:final nowUtcMs),
        ) =>
          nowUtcMs >= fireAtUtcMs + askDelayMs
              ? AthanTestAskHeard(testId)
              : state,
        (
          AthanTestFired(:final testId) || AthanTestAskHeard(:final testId),
          HeardAnswered(:final heard, :final presentedByOs, :final nowUtcMs),
        ) =>
          AthanTestRecorded(
            AthanTestResult(
              testId: testId,
              heardByUser: heard,
              presentedByOs: presentedByOs,
              answeredAtUtcMs: nowUtcMs,
            ),
          ),
        (_, TestReset()) => const AthanTestIdle(),
        _ => state,
      };

  static AthanTestState _scheduled(String testId, int fireAt, int now) =>
      now >= fireAt
      ? AthanTestFired(testId: testId, fireAtUtcMs: fireAt)
      : AthanTestScheduled(
          testId: testId,
          fireAtUtcMs: fireAt,
          secondsLeft: (fireAt - now + 999) ~/ 1000,
        );
}
