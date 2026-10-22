import 'package:dm_core_types/dm_core_types.dart';

/// A clock the test moves.
final class SettableClock implements Clock {
  /// The clock at [utcMs].
  SettableClock(this.utcMs);

  /// The time it reads.
  int utcMs;

  @override
  int nowUtcMs() => utcMs;
}
