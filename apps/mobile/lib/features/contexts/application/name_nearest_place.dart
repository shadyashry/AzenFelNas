import 'package:daily_muslim/features/contexts/domain/gazetteer_hit.dart';
import 'package:daily_muslim/features/contexts/domain/gazetteer_ports.dart';
import 'package:dm_civil_time/dm_civil_time.dart';
import 'package:dm_core_types/dm_core_types.dart';

/// The place a device fix is in, for the words on screen only (§15 D100,
/// D101): "Prayer times for Cairo" instead of "your current location". The
/// city wins over its districts: the largest place within [cityKm], else
/// the nearest within [withinKm]. The stored context and the calculation
/// keep the fix itself.
final class NameNearestPlace {
  /// Names through [_places].
  const new(this._places);

  final FindPlacesAround _places;

  /// Farther than this, a place does not name where the user is.
  static const withinKm = 30.0;

  /// Within this, the largest place names the fix: a district of a city is
  /// named after the city.
  static const cityKm = 10.0;

  /// The place [point] is in, or `null` when none is within [withinKm].
  Future<GazetteerHit?> call(GeoPointE6 point) async {
    final near = switch (await _places.near(point, withinKm: withinKm)) {
      Ok(:final value) => value,
      Err() => const <(GazetteerHit, double)>[],
    };
    final city = near
        .where((place) => place.$2 <= cityKm)
        .map((place) => place.$1)
        .fold<GazetteerHit?>(
          null,
          (best, hit) =>
              best == null || hit.population > best.population ? hit : best,
        );
    return city ?? near.firstOrNull?.$1;
  }
}
