import 'package:daily_muslim/features/athan/application/start_athan_test.dart';
import 'package:daily_muslim/features/athan/domain/athan_platform_ports.dart';
import 'package:daily_muslim/features/athan/domain/athan_test_event.dart';
import 'package:dm_core_types/dm_core_types.dart';
import 'package:flutter_test/flutter_test.dart';

final class _FakeArm implements ArmAthanTest {
  new({required this.armed});

  final bool armed;
  final calls = <(String, int, String)>[];

  @override
  Future<bool> call({
    required String testId,
    required int fireInSeconds,
    required String soundId,
  }) async {
    calls.add((testId, fireInSeconds, soundId));
    return armed;
  }
}

void main() {
  group('StartAthanTest', () {
    test(
      'REQ-ALM-040 arms through the port 60 s ahead with a 16-hex id',
      () async {
        final arm = _FakeArm(armed: true);
        final event = await StartAthanTest(arm, FixedClock(1761249600000))(
          soundId: 'makkah',
        );
        expect(arm.calls, [('0000019a12a82200', 60, 'makkah')]);
        expect(
          event,
          isA<TestArmed>()
              .having((e) => e.fireAtUtcMs, 'fireAtUtcMs', 1761249660000)
              .having((e) => e.testId, 'testId', '0000019a12a82200'),
        );
      },
    );
  });
}
