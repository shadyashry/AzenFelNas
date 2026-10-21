import 'package:geo_salah_core/src/model/high_latitude_method.dart';
import 'package:geo_salah_core/src/model/no_event_reason.dart';
import 'package:geo_salah_core/src/model/prayer_event.dart';
import 'package:meta/meta.dart';

/// What an event yields on one prayer day before its adjustments: its rule's
/// root, a high-latitude fallback where the rule has none (§6.4 ¶7), or the
/// typed reason it has no time (§6.4 ¶5, REQ-DOM-002). Never an
/// extrapolated value.
///
/// The rule step (`DayRuleSolver`) yields [RuleRoot] and [RuleNoRoot]; only
/// the high-latitude step (`HighLatitudeChain`) yields [RuleFallback].
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

/// A high-latitude fallback instant (§6.4 ¶7): the event's rule has no root
/// on this day and [method], a link of the profile's chain, gave [utcMs].
final class RuleFallback extends RuleSolution {
  /// The fallback at [utcMs] by [method]. [base] is the event whose fallback
  /// an interval rule was solved on, `null` when the event's own chain gave
  /// it. [perturbationMinutes] is the instant's ±1 km sensitivity in whole
  /// minutes (§6.7, §15 D55), 0 until measured.
  const new(
    this.utcMs,
    this.method, {
    this.base,
    this.perturbationMinutes = 0,
  });

  /// UTC epoch milliseconds, truncated to 1 ms.
  final int utcMs;

  /// The chain link that gave the instant.
  final HighLatitudeMethod method;

  /// The interval base whose fallback this instant follows, if any.
  final PrayerEvent? base;

  /// The ±1 km sensitivity of [utcMs], whole minutes (≥ 0).
  final int perturbationMinutes;

  @override
  bool operator ==(Object other) =>
      other is RuleFallback &&
      other.utcMs == utcMs &&
      other.method == method &&
      other.base == base &&
      other.perturbationMinutes == perturbationMinutes;

  @override
  int get hashCode =>
      Object.hash(RuleFallback, utcMs, method, base, perturbationMinutes);

  @override
  String toString() =>
      'RuleFallback($utcMs, $method, base: ${base?.name}, '
      '±$perturbationMinutes min)';
}
