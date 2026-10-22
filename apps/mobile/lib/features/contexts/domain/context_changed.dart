import 'package:meta/meta.dart';

/// Why the resolver logs a [ContextChanged] event.
enum ContextChangeReason {
  /// The current context moved to another zone or country.
  resolver('resolver'),

  /// The fix used was marked mock: diagnostics only (§7.5).
  mockLocation('mock_location');

  /// The reason logged as [wire] (`attrs.reason`, Appendix J).
  new(this.wire);

  /// Event-log value.
  final String wire;
}

/// A diagnostic `CONTEXT_CHANGED` event of the resolver. It holds no
/// coordinate by construction (REQ-PRIV-001).
@immutable
final class ContextChanged {
  /// The event at [utcMs].
  const new({
    required this.utcMs,
    required this.reason,
    required this.zoneId,
    required this.country,
  });

  /// When (UTC epoch ms).
  final int utcMs;

  /// Why.
  final ContextChangeReason reason;

  /// Zone of the current context.
  final String zoneId;

  /// Country of the current context; `null` when none resolves.
  final String? country;

  @override
  bool operator ==(Object other) =>
      other is ContextChanged &&
      other.utcMs == utcMs &&
      other.reason == reason &&
      other.zoneId == zoneId &&
      other.country == country;

  @override
  int get hashCode => Object.hash(utcMs, reason, zoneId, country);

  @override
  String toString() =>
      'ContextChanged(${reason.wire}, $zoneId, ${country ?? '-'})';
}
