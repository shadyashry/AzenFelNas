import 'package:dm_civil_time/dm_civil_time.dart';

/// Polygon lookups answered from a table keyed by point; any other point
/// matches nothing.
final class TablePolygons implements LocateInPolygons {
  /// The lookups of [table].
  const TablePolygons(this.table);

  /// The answer per point.
  final Map<GeoPointE6, PolygonMatch> table;

  @override
  PolygonMatch locate(GeoPointE6 point, {required int searchRadiusM}) =>
      table[point] ?? const NoPolygon();
}
