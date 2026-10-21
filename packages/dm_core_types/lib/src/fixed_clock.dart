import 'package:dm_core_types/src/clock.dart';

/// [Clock] that always returns the same instant.
///
/// The fake for the [Clock] port in tests and the deterministic clock of
/// lab and benchmark runs. Deterministic: [nowUtcMs] returns [utcMs] on
/// every call.
final class FixedClock implements Clock {
  /// Creates a clock frozen at [utcMs]; throws [ArgumentError] when [utcMs]
  /// is negative, which no [Clock] may return.
  new(this.utcMs) {
    if (utcMs < 0) {
      throw ArgumentError.value(utcMs, 'utcMs', 'must not be negative');
    }
  }

  /// The instant returned by [nowUtcMs], in UTC epoch milliseconds.
  final int utcMs;

  @override
  int nowUtcMs() => utcMs;
}
