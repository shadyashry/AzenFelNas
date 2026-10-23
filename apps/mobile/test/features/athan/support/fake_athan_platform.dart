import 'package:daily_muslim/features/athan/domain/athan_platform_ports.dart';
import 'package:daily_muslim/features/athan/domain/native_event.dart';
import 'package:daily_muslim/features/athan/domain/platform_health.dart';

/// A scripted native Athan layer for tests (fake at the ports only, §17.7).
final class FakeAthanPlatform implements ReadPlatformHealth {
  new({PlatformHealth? report, this.armed = true})
    : report = report ?? PlatformHealth.unavailable(0);

  /// What [call] returns.
  PlatformHealth report;

  /// What [arm] answers.
  bool armed;

  /// Events the next drain returns (then cleared).
  final pending = <NativeEvent>[];

  /// Every Test the fake armed.
  final armedTests = <String>[];

  @override
  Future<PlatformHealth> call() async => report;

  /// The [ArmAthanTest] port.
  ArmAthanTest get arm => _Arm(this);

  /// The [DrainNativeEvents] port.
  DrainNativeEvents get drain => _Drain(this);
}

final class _Arm implements ArmAthanTest {
  const new(this._fake);

  final FakeAthanPlatform _fake;

  @override
  Future<bool> call({
    required String testId,
    required int fireInSeconds,
    required String soundId,
  }) async {
    if (_fake.armed) _fake.armedTests.add(testId);
    return _fake.armed;
  }
}

final class _Drain implements DrainNativeEvents {
  const new(this._fake);

  final FakeAthanPlatform _fake;

  @override
  Future<List<NativeEvent>> call() async {
    final events = List<NativeEvent>.of(_fake.pending);
    _fake.pending.clear();
    return events;
  }
}
