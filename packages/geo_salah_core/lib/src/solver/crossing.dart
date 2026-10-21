import 'package:geo_salah_core/src/solver/crossing_direction.dart';
import 'package:meta/meta.dart';

/// One instant at which the Sun's geometric altitude crosses a target.
///
/// [utcMs] is the refined root truncated (floored) to 1 ms (§6.4 ¶5,
/// ADR-019). Immutable value type.
@immutable
final class Crossing {
  /// A crossing at [utcMs] in [direction].
  const new({required this.utcMs, required this.direction});

  /// UTC epoch milliseconds, truncated to 1 ms.
  final int utcMs;

  /// Rising or setting.
  final CrossingDirection direction;

  @override
  bool operator ==(Object other) =>
      other is Crossing && other.utcMs == utcMs && other.direction == direction;

  @override
  int get hashCode => Object.hash(utcMs, direction);

  @override
  String toString() => 'Crossing($utcMs, ${direction.name})';
}
