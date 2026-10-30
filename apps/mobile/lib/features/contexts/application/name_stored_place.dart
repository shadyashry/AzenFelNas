import 'package:daily_muslim/features/contexts/application/name_nearest_place.dart';
import 'package:daily_muslim/features/contexts/domain/gazetteer_hit.dart';
import 'package:daily_muslim/features/contexts/domain/gazetteer_ports.dart';
import 'package:dm_civil_time/dm_civil_time.dart';
import 'package:dm_core_types/dm_core_types.dart';

/// The gazetteer place a chosen place's stored label names, so the screen
/// can show it in the reader's language (§15 D104): a place picked as
/// «دبي» in Arabic reads "Dubai" in English. A chosen place keeps the
/// label it was picked under, in the language of that moment; the stored
/// context and the calculation are unchanged.
///
/// The label must be one of the place's own names: its primary name, its
/// first Arabic name, or, for an Arabic label (an alternate Arabic name
/// matched by a search), the place standing at that very point. A name the
/// user typed for coordinates matches nothing and is shown as typed.
final class NameStoredPlace {
  /// Names through [_places].
  const new(this._places);

  final FindPlacesAround _places;

  /// A gazetteer choice stores the place's own coordinates; closer than
  /// this, the place found is the one that was chosen.
  static const samePointKm = 0.05;

  static final _arabic = RegExp('[؀-ۿ]');

  /// The place [label] at [point] names, or `null` when it names none.
  Future<GazetteerHit?> call(GeoPointE6 point, String label) async {
    final name = label.trim();
    if (name.isEmpty) return null;
    final near = switch (await _places.near(
      point,
      withinKm: NameNearestPlace.withinKm,
    )) {
      Ok(:final value) => value,
      Err() => const <(GazetteerHit, double)>[],
    };
    for (final (hit, km) in near) {
      if (hit.name == name || hit.arabicName == name) return hit;
      if (km <= samePointKm && _arabic.hasMatch(name)) return hit;
    }
    return null;
  }
}
