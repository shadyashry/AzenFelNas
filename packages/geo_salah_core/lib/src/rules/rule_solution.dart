import 'package:geo_salah_core/src/model/no_event_reason.dart';
import 'package:meta/meta.dart';

/// What an event rule yields on one prayer day: its root, or the typed
/// reason it has none (§6.4 ¶5, REQ-DOM-002). Never an extrapolated value.
@immutable
sealed class RuleSolution {
  const new();
}

/// The rule's instant, UTC epoch milliseconds truncated to 1 ms.
final class RuleRoot extends RuleSolution {
  /// The root at [utcMs].
  const new(this.utcMs);

  /// UTC epoch milliseconds, truncated to 1 ms.
  final int utcMs;

  @override
  bool operator ==(Object other) => other is RuleRoot && other.utcMs == utcMs;

  @override
  int get hashCode => Object.hash(RuleRoot, utcMs);

  @override
  String toString() => 'RuleRoot($utcMs)';
}

/// The rule has no root on this day, for [reason].
final class RuleNoRoot extends RuleSolution {
  /// No root, for [reason].
  const new(this.reason);

  /// Why there is no root.
  final NoEventReason reason;

  @override
  bool operator ==(Object other) =>
      other is RuleNoRoot && other.reason == reason;

  @override
  int get hashCode => Object.hash(RuleNoRoot, reason);

  @override
  String toString() => 'RuleNoRoot(${reason.name})';
}
