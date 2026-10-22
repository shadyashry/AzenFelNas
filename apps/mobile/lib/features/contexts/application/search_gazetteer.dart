import 'package:daily_muslim/features/contexts/domain/gazetteer_failure.dart';
import 'package:daily_muslim/features/contexts/domain/gazetteer_hit.dart';
import 'package:daily_muslim/features/contexts/domain/gazetteer_ports.dart';
import 'package:daily_muslim/features/contexts/domain/search_key.dart';
import 'package:dm_core_types/dm_core_types.dart';

/// Offline manual place search over the imported gazetteer (§7.2 `contexts`,
/// §13 S12, G32): «القاهرة», "Cairo" and "cai" all find Cairo.
final class SearchGazetteer {
  /// Searches through a [FindGazetteerPlaces] port.
  const new(this._places);

  final FindGazetteerPlaces _places;

  /// Hits returned when the caller does not ask for a number.
  static const defaultLimit = 20;

  /// The places whose names start with [query] after normalisation
  /// ([SearchKey]); exact matches first, then larger places. A query with no
  /// letter or digit finds nothing.
  Future<Result<List<GazetteerHit>, GazetteerFailure>> call(
    String query, {
    int limit = defaultLimit,
  }) {
    RangeError.checkValueInInterval(limit, 1, 200, 'limit');
    final key = SearchKey.of(query);
    if (key.isEmpty) return Future.value(const Ok([]));
    return _places.findByPrefix(key, limit: limit);
  }
}
