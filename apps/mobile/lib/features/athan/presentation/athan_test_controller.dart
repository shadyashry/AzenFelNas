import 'package:daily_muslim/features/athan/application/advance_athan_test.dart';
import 'package:daily_muslim/features/athan/application/start_athan_test.dart';
import 'package:daily_muslim/features/athan/application/test_presentation.dart';
import 'package:daily_muslim/features/athan/domain/athan_test_event.dart';
import 'package:daily_muslim/features/athan/domain/athan_test_state.dart';
import 'package:daily_muslim/features/athan/presentation/athan_providers.dart';
import 'package:daily_muslim/features/schedule/presentation/schedule_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Drives the Athan Test (REQ-ALM-040) through `AdvanceAthanTest`; it only
/// turns user actions and ticks into machine events.
final class AthanTestController extends Notifier<AthanTestState> {
  @override
  AthanTestState build() {
    ref.listen(athanTicksProvider, (_, _) => tick());
    return const AthanTestIdle();
  }

  /// Arms a Test playing [soundId].
  Future<void> start(String soundId) async {
    final start = StartAthanTest(
      ref.read(armAthanTestProvider),
      ref.read(clockProvider),
    );
    _apply(await start(soundId: soundId));
  }

  /// Advances the countdown with the injected clock.
  void tick() => _apply(ClockTicked(ref.read(clockProvider).nowUtcMs()));

  /// Records the answer [heard] with the OS receipt evidence, then
  /// re-evaluates Health (a Test not heard is `failedTest`).
  Future<void> answer({required bool heard}) async {
    final drained = await ref.read(drainNativeEventsProvider).call();
    _apply(
      HeardAnswered(
        heard: heard,
        presentedByOs: const TestPresentation()(drained),
        nowUtcMs: ref.read(clockProvider).nowUtcMs(),
      ),
    );
    if (state case AthanTestRecorded(:final result)) {
      await ref.read(recordAthanTestResultProvider).call(result);
      ref.invalidate(athanHealthProvider);
    }
  }

  /// Back to idle.
  void reset() => _apply(const TestReset());

  void _apply(AthanTestEvent event) =>
      state = const AdvanceAthanTest()(state, event);
}

/// The Athan Test state.
final NotifierProvider<AthanTestController, AthanTestState> athanTestProvider =
    NotifierProvider.autoDispose<AthanTestController, AthanTestState>(
      AthanTestController.new,
    );
