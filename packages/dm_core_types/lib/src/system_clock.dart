import 'package:dm_core_types/src/clock.dart';

/// [Clock] backed by the device clock.
///
/// The only place in the codebase that calls `DateTime.now()`
/// (DESIGN.md §17.2). Not deterministic by nature; inject a `FixedClock`
/// in tests.
final class SystemClock implements Clock {
  /// Creates a clock reading the device time.
  const new();

  @override
  int nowUtcMs() => DateTime.now().millisecondsSinceEpoch;
}
