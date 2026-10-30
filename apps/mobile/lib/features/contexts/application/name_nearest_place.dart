import 'package:daily_muslim/features/contexts/domain/gazetteer_hit.dart';
import 'package:daily_muslim/features/contexts/domain/gazetteer_ports.dart';
import 'package:dm_civil_time/dm_civil_time.dart';
import 'package:dm_core_types/dm_core_types.dart';

/// The place a device fix is in, for the words on screen only (§15 D100):
/// "Prayer times for Cairo" instead of "your current location". The stored
/// context and the calculation keep the fix itself.
final class NameNearestPlace {
  /// Names through [_places].
  const new(this._places);

  final FindPlacesAround _places;

  /// Farther than this, a place does not name where the user is.
  static const withinKm = 30.0;

  /// The nearest place to [point], or `null` when none is within [withinKm].
  Future<GazetteerHit?> call(GeoPointE6 point) async =>
      switch (await _places.nearest(point, withinKm: withinKm)) {
        Ok(:final value) => value,
        Err() => null,
      };
}
