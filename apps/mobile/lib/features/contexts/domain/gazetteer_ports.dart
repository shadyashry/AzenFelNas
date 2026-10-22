import 'package:daily_muslim/features/contexts/domain/gazetteer_failure.dart';
import 'package:daily_muslim/features/contexts/domain/gazetteer_hit.dart';
import 'package:daily_muslim/features/contexts/domain/gazetteer_place.dart';
import 'package:daily_muslim/features/contexts/domain/search_key.dart';
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
  Result<List<GazetteerPlace>, GazetteerFailure> decode(List<int> payload);
}
