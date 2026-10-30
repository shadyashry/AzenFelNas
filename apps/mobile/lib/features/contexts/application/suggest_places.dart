import 'package:daily_muslim/features/contexts/domain/device_zone.dart';
import 'package:daily_muslim/features/contexts/domain/gazetteer_hit.dart';
import 'package:daily_muslim/features/contexts/domain/gazetteer_ports.dart';
import 'package:dm_core_types/dm_core_types.dart';

/// The places to offer before anything is typed (§15 D100): the largest
/// places of the phone's time zone, so most users tap their city instead of
/// searching for it. Nothing is chosen for them: a zone such as
/// `Asia/Riyadh` holds cities whose times differ by many minutes.
final class SuggestPlaces {
  /// Suggests through [_zone] and [_places].
  const new(this._zone, this._places);

  final ReadDeviceZone _zone;
  final FindPlacesAround _places;

  /// Places offered at most.
  static const limit = 8;

  /// The suggestions, largest first; empty when the zone is unknown or has
  /// no place.
  Future<List<GazetteerHit>> call() async {
    final zone = await _zone.zoneId();
    if (zone == null) return const [];
    return switch (await _places.largestIn(zone, limit: limit)) {
      Ok(:final value) => value,
      Err() => const [],
    };
  }
}
