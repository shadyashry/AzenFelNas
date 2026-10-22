import 'package:daily_muslim/features/contexts/domain/gazetteer_failure.dart';
import 'package:daily_muslim/features/contexts/domain/gazetteer_hit.dart';
import 'package:daily_muslim/features/contexts/domain/gazetteer_place.dart';
import 'package:daily_muslim/features/contexts/domain/gazetteer_ports.dart';
import 'package:daily_muslim/features/contexts/domain/search_key.dart';
import 'package:dm_core_types/dm_core_types.dart';

/// In-memory fake of the [FindGazetteerPlaces] and [StoreGazetteer] ports.
/// Shares the contract tests with `DriftGazetteerStore` (REQ-TEST-004).
final class FakeGazetteerStore implements FindGazetteerPlaces, StoreGazetteer {
  List<GazetteerPlace> _places = const [];

  /// When set, every call fails with it and nothing changes.
  GazetteerFailure? failWith;

  @override
  Future<Result<int, GazetteerFailure>> replaceAll(
    List<GazetteerPlace> places,
  ) async {
    if (failWith case final failure?) return Err(failure);
    _places = List.unmodifiable(places);
    return Ok(places.length);
  }

  @override
  Future<Result<List<GazetteerHit>, GazetteerFailure>> findByPrefix(
    SearchKey prefix, {
    required int limit,
  }) async {
    if (failWith case final failure?) return Err(failure);
    final hits = <GazetteerHit>[];
    for (final place in _places) {
      final matched = <String>[];
      var exact = false;
      final seen = <SearchKey>{};
      for (final name in place.allNames) {
        for (final key in SearchKey.indexKeysOf(name)) {
          if (!seen.add(key) || !key.value.startsWith(prefix.value)) continue;
          matched.add(name);
          exact = exact || key == prefix;
        }
      }
      if (matched.isEmpty) continue;
      matched.sort();
      hits.add(
        GazetteerHit(
          id: place.id,
          name: place.name,
          matchedName: matched.first,
          exact: exact,
          country: place.country,
          admin1: place.admin1,
          point: place.point,
          population: place.population,
          zoneId: place.zoneId,
        ),
      );
    }
    hits.sort(
      (a, b) => a.exact != b.exact
          ? (a.exact ? -1 : 1)
          : a.population != b.population
          ? b.population.compareTo(a.population)
          : a.id.compareTo(b.id),
    );
    return Ok(hits.take(limit).toList());
  }
}
