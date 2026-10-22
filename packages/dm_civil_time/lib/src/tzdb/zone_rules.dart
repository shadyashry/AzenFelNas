import 'package:meta/meta.dart';

/// The offsets of one zone over time, as read from a `.tzf` location
/// (§15 D66). Internal to `dm_civil_time`; immutable and pure.
///
/// [startsUtcMs] is strictly increasing; from `startsUtcMs[i]` (inclusive)
/// the offset is `offsetsSeconds[i]`. Before the first start, or when there
/// is none, the offset is [initialOffsetSeconds]. These are exactly the
/// lookup semantics of `package:timezone`'s `Location.lookupTimeZone`.
@immutable
final class ZoneRules {
  /// Builds the rules; the reader has validated the invariants.
  new({
    required this.name,
    required this.initialOffsetSeconds,
    required List<int> startsUtcMs,
    required List<int> offsetsSeconds,
  }) : startsUtcMs = List.unmodifiable(startsUtcMs),
       offsetsSeconds = List.unmodifiable(offsetsSeconds),
       _wallStartsMs = List.unmodifiable(
         _wallStarts(initialOffsetSeconds, startsUtcMs, offsetsSeconds),
       );

  /// The IANA zone name, e.g. `Africa/Cairo`.
  final String name;

  /// Offset before the first transition.
  final int initialOffsetSeconds;

  /// Transition instants, UTC epoch milliseconds, strictly increasing.
  final List<int> startsUtcMs;

  /// Offset in effect from each transition on.
  final List<int> offsetsSeconds;

  /// Local wall-clock instant (epoch ms of the local reading) at which each
  /// transition takes effect for `fold = 0`: the transition plus the larger
  /// of the offsets before and after it (PEP 495, CPython `zoneinfo`).
  final List<int> _wallStartsMs;

  /// The offset in effect at [utcMs].
  int offsetAt(int utcMs) {
    final i = _lastAtOrBefore(startsUtcMs, utcMs);
    return i < 0 ? initialOffsetSeconds : offsetsSeconds[i];
  }

  /// The offset that turns the local reading [localMs] (epoch ms of the
  /// wall clock) into UTC under `fold = 0`: in an overlap the earlier
  /// instant; in a gap the offset before it, i.e. the reading moves forward
  /// by the gap's length (§15 D67).
  int offsetForLocal(int localMs) {
    final i = _lastAtOrBefore(_wallStartsMs, localMs);
    return i < 0 ? initialOffsetSeconds : offsetsSeconds[i];
  }

  /// The last transition at or before [utcMs], or `null` before the first.
  int? transitionAtOrBefore(int utcMs) {
    final i = _lastAtOrBefore(startsUtcMs, utcMs);
    return i < 0 ? null : startsUtcMs[i];
  }

  static List<int> _wallStarts(
    int initial,
    List<int> starts,
    List<int> offsets,
  ) => [
    for (var i = 0; i < starts.length; i++)
      starts[i] + 1000 * _max(i == 0 ? initial : offsets[i - 1], offsets[i]),
  ];

  static int _max(int a, int b) => a > b ? a : b;

  /// Index of the last element `≤ value` (bisect right − 1), or −1.
  static int _lastAtOrBefore(List<int> sorted, int value) {
    var lo = 0;
    var hi = sorted.length;
    while (lo < hi) {
      final mid = (lo + hi) >> 1;
      if (sorted[mid] <= value) {
        lo = mid + 1;
      } else {
        hi = mid;
      }
    }
    return lo - 1;
  }
}
