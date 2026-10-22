import 'package:daily_muslim/features/contexts/domain/location_context.dart';
import 'package:geo_salah_core/geo_salah_core.dart';
import 'package:meta/meta.dart';

/// The observer context a calculation uses, with what the resolver knows
/// about it (`ResolveObserverContext`, §7.5).
@immutable
final class ResolvedContext {
  /// [context] with its [flags].
  const new({
    required this.context,
    required this.flags,
    required this.stale,
  });

  /// The active context.
  final LocationContext context;

  /// `zoneBoundaryProximity`, `manualCoordinateResolution` and
  /// `noLocalProfile` as the polygons give them for the context's point.
  final Set<ResultFlag> flags;

  /// The place comes from a last known fix, not a fresh one (`LOC_STALE`).
  final bool stale;

  /// Whether to offer precise location: only near a tz or country boundary
  /// (ADR-014 (a); the Qibla trigger (b) belongs to `qibla`).
  bool get offerPreciseLocation =>
      !context.kind.isUserChosen &&
      flags.contains(ResultFlag.zoneBoundaryProximity);

  @override
  bool operator ==(Object other) =>
      other is ResolvedContext &&
      other.context == context &&
      other.stale == stale &&
      other.flags.length == flags.length &&
      other.flags.containsAll(flags);

  @override
  int get hashCode =>
      Object.hash(context, stale, Object.hashAllUnordered(flags));

  @override
  String toString() => 'ResolvedContext($context, $flags, stale: $stale)';
}
