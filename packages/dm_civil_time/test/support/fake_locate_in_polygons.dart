import 'package:dm_civil_time/dm_civil_time.dart';

/// Fake [LocateInPolygons] port: answers from a table of matches keyed by
/// point, [NoPolygon] otherwise; distances beyond the radius are dropped as
/// the contract requires.
final class FakeLocateInPolygons implements LocateInPolygons {
  /// Answers from [answers].
  const new(this.answers);

  /// Match per point, at an unlimited radius.
  final Map<GeoPointE6, PolygonMatch> answers;

  @override
  PolygonMatch locate(GeoPointE6 point, {required int searchRadiusM}) {
    RangeError.checkValueInInterval(searchRadiusM, 1, 1 << 30, 'searchRadiusM');
    double? within(double? metres) =>
        metres != null && metres <= searchRadiusM ? metres : null;
    return switch (answers[point]) {
      null || NoPolygon() => const NoPolygon(),
      InsidePolygon(:final name, :final otherDistanceM) => InsidePolygon(
        name,
        otherDistanceM: within(otherDistanceM),
      ),
      NearPolygon(:final name, :final distanceM, :final otherDistanceM) =>
        distanceM <= searchRadiusM
            ? NearPolygon(
                name,
                distanceM: distanceM,
                otherDistanceM: within(otherDistanceM),
              )
            : const NoPolygon(),
    };
  }
}
