import 'package:daily_muslim/features/athan/application/athan_platform_ports.dart';
import 'package:daily_muslim/features/athan/domain/athan_test_event.dart';
import 'package:dm_core_types/dm_core_types.dart';

/// Starts the Athan Test (REQ-ALM-040): arms it [fireInSeconds] from now
/// through the same native path as Athans and reports the machine event.
final class StartAthanTest {
  /// The use case over [_arm] and [_clock].
  const new(this._arm, this._clock);

  final ArmAthanTest _arm;
  final Clock _clock;

  /// Seconds from the tap to the Test Athan (§8.3).
  static const int fireInSeconds = 60;

  /// Arms a Test playing [soundId]; the id is the 16-hex start instant.
  Future<AthanTestEvent> call({required String soundId}) async {
    final now = _clock.nowUtcMs();
    final testId = now.toRadixString(16).padLeft(16, '0');
    final armed = await _arm(
      testId: testId,
      fireInSeconds: fireInSeconds,
      soundId: soundId,
    );
    return armed
        ? TestArmed(
            testId: testId,
            fireAtUtcMs: now + fireInSeconds * 1000,
            nowUtcMs: now,
          )
        : const TestRefused();
  }
}
