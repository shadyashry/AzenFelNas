import 'package:daily_muslim/features/contexts/domain/gazetteer_hit.dart';
import 'package:dm_core_types/dm_core_types.dart';

/// Manual place (§18.4): `idle`, `searching`, `results(list)`, `empty`,
/// `coordinateEntry`, `error`.
sealed class ManualPlaceState {
  const new();
}

/// Nothing searched yet: the places of the phone's time zone are offered
/// to tap (§15 D100).
final class ManualPlaceIdle extends ManualPlaceState {
  /// The state offering [suggestions].
  const new({this.suggestions = const []});

  /// Places to tap, largest first; empty while loading or when the zone is
  /// unknown.
  final List<GazetteerHit> suggestions;
}

/// A search is running.
final class ManualPlaceSearching extends ManualPlaceState {
  /// The state.
  const new();
}

/// Places found, best first.
final class ManualPlaceResults extends ManualPlaceState {
  /// The state over [hits].
  const new(this.hits);

  /// The places; never empty.
  final List<GazetteerHit> hits;
}

/// The search found nothing.
final class ManualPlaceEmpty extends ManualPlaceState {
  /// The state.
  const new();
}

/// The user types coordinates instead; [invalid] after a refused entry.
final class ManualPlaceCoordinateEntry extends ManualPlaceState {
  /// The state.
  const new({this.invalid = false});

  /// The last entry was out of range.
  final bool invalid;
}

/// Searching or saving failed.
final class ManualPlaceError extends ManualPlaceState {
  /// The state.
  const new(this.failure);

  /// What went wrong.
  final Failure failure;
}
