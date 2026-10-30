import 'package:daily_muslim/features/contexts/domain/gazetteer_failure.dart';
import 'package:daily_muslim/features/contexts/domain/gazetteer_hit.dart';
import 'package:daily_muslim/features/contexts/domain/gazetteer_place.dart';
import 'package:daily_muslim/features/contexts/domain/search_key.dart';
import 'package:dm_civil_time/dm_civil_time.dart';
import 'package:dm_core_types/dm_core_types.dart';

/// Finds places by search-key prefix (port of `SearchGazetteer`).
abstract interface class FindGazetteerPlaces {
  /// At most [limit] places with a key that starts with [prefix], one hit per
  /// place: places with a key equal to [prefix] first, then by population
  /// (largest first), then by id. [prefix] is never empty.
  Future<Result<List<GazetteerHit>, GazetteerFailure>> findByPrefix(
    SearchKey prefix, {
    required int limit,
  });
}

/// Replaces the stored gazetteer (port of `ImportGazetteer`).
abstract interface class StoreGazetteer {
  /// Replaces every stored place with [places] in one transaction and returns
  /// how many were stored; on failure the previous places stay (REQ-PKG-001).
  Future<Result<int, GazetteerFailure>> replaceAll(
    List<GazetteerPlace> places,
  );
}

/// Decodes a `gazetteer_package.v1` payload (port of `ImportGazetteer`).
abstract interface class DecodeGazetteerPayload {
  /// The places of [payload] (UTF-8 JSON), or why it is not a valid payload.
  /// Asynchronous, so an adapter may decode off the UI isolate (§15 D96).
  Future<Result<List<GazetteerPlace>, GazetteerFailure>> decode(
    List<int> payload,
  );
}

/// Places around a point or in a zone (port of `NameNearestPlace` and
/// `SuggestPlaces`, §15 D100): a fix gets a name and a first-run user a
/// list to tap instead of a search.
abstract interface class FindPlacesAround {
  /// The place nearest [point] within [withinKm], or `null` when none is.
  Future<Result<GazetteerHit?, GazetteerFailure>> nearest(
    GeoPointE6 point, {
    required double withinKm,
  });

  /// At most [limit] places in [zoneId], largest population first.
  Future<Result<List<GazetteerHit>, GazetteerFailure>> largestIn(
    String zoneId, {
    required int limit,
  });
}
