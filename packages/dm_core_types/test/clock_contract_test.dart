import 'package:dm_core_types/dm_core_types.dart';
import 'package:test/test.dart';

/// The [Clock] port contract, run against every implementation
/// (REQ-TEST-004).
void _clockContract(String name, Clock Function() create) {
  group('$name honours the Clock contract (REQ-TEST-004)', () {
    test('returns non-negative UTC epoch milliseconds (REQ-TEST-004)', () {
      expect(create().nowUtcMs(), greaterThanOrEqualTo(0));
    });

    test('can be read repeatedly without throwing (REQ-TEST-004)', () {
      final clock = create();
      expect(
        () => [for (var i = 0; i < 3; i++) clock.nowUtcMs()],
        returnsNormally,
      );
    });
  });
}

void main() {
  _clockContract('SystemClock', () => const SystemClock());
  _clockContract('FixedClock', () => FixedClock(1761000000000));

  test('SystemClock reads the device clock as UTC epoch ms', () {
    // Arrange
    final before = DateTime.timestamp().millisecondsSinceEpoch;

    // Act
    final now = const SystemClock().nowUtcMs();

    // Assert
    final after = DateTime.timestamp().millisecondsSinceEpoch;
    expect(now, inInclusiveRange(before, after));
  });

  test('FixedClock returns the same instant on every read', () {
    final clock = FixedClock(1761000000000);
    expect(
      [clock.nowUtcMs(), clock.nowUtcMs()],
      [1761000000000, 1761000000000],
    );
  });

  test('FixedClock rejects a negative instant', () {
    expect(() => FixedClock(-1), throwsArgumentError);
  });
}
