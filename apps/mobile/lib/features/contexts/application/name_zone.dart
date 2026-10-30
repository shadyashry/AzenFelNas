import 'package:daily_muslim/features/contexts/domain/gazetteer_hit.dart';
import 'package:daily_muslim/features/contexts/domain/gazetteer_ports.dart';
import 'package:dm_core_types/dm_core_types.dart';

/// The city a time zone is known by, for words on screen (§15 D101): the
/// largest place of the zone, so the Travel prompt can say «لوس أنجلوس» to
/// an Arabic reader instead of the zone id's "Los Angeles".
final class NameZone {
  /// Names through [_places].
  const new(this._places);

  final FindPlacesAround _places;

  /// The largest place of [zoneId], or `null` when the zone has none.
  Future<GazetteerHit?> call(String zoneId) async =>
      switch (await _places.largestIn(zoneId, limit: 1)) {
        Ok(:final value) => value.firstOrNull,
        Err() => null,
      };
}
