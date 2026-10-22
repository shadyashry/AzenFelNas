import 'package:daily_muslim/features/contexts/domain/context_kind.dart';
import 'package:daily_muslim/features/contexts/domain/context_place.dart';
import 'package:daily_muslim/features/contexts/domain/context_source.dart';
import 'package:meta/meta.dart';

/// A stored location context: one row of `places.sqlite`
/// `location_contexts` (§7.3). The active context is the one used last.
@immutable
final class LocationContext {
  /// Context [id] of [kind] at [place].
  const new({
    required this.id,
    required this.kind,
    required this.place,
    required this.source,
    required this.createdUtcMs,
    required this.lastUsedUtcMs,
  });

  /// Row id.
  final int id;

  /// Current, pinned or manual.
  final ContextKind kind;

  /// Where the context is.
  final ContextPlace place;

  /// Where [place] came from.
  final ContextSource source;

  /// When the row was written first (UTC epoch ms).
  final int createdUtcMs;

  /// When the context was last selected or refreshed (UTC epoch ms).
  final int lastUsedUtcMs;

  @override
  bool operator ==(Object other) =>
      other is LocationContext &&
      other.id == id &&
      other.kind == kind &&
      other.place == place &&
      other.source == source &&
      other.createdUtcMs == createdUtcMs &&
      other.lastUsedUtcMs == lastUsedUtcMs;

  @override
  int get hashCode =>
      Object.hash(id, kind, place, source, createdUtcMs, lastUsedUtcMs);

  @override
  String toString() => 'LocationContext($id, ${kind.wire}, $place)';
}
