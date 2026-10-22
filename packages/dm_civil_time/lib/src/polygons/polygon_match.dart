import 'package:meta/meta.dart';

/// What a polygon index says about a point (§8, §15 D71).
///
/// Distances are metres in the local projection of §15 D71 and are only
/// reported up to the search radius of the lookup. `otherDistanceM` is the
/// distance to the nearest polygon whose name differs from the matched name;
/// `null` when there is none within the radius.
@immutable
sealed class PolygonMatch {
  const new();
}

/// A polygon named [name] contains the point.
final class InsidePolygon extends PolygonMatch {
  /// The match.
  const new(this.name, {required this.otherDistanceM});

  /// Zone id or ISO 3166-1 alpha-2 code.
  final String name;

  /// Distance to the nearest polygon of another name, or `null`.
  final double? otherDistanceM;

  @override
  bool operator ==(Object other) =>
      other is InsidePolygon &&
      other.name == name &&
      other.otherDistanceM == otherDistanceM;

  @override
  int get hashCode => Object.hash(InsidePolygon, name, otherDistanceM);

  @override
  String toString() => 'InsidePolygon($name, other: $otherDistanceM)';
}

/// No polygon contains the point; the nearest one, named [name], is
/// [distanceM] away (within the search radius).
final class NearPolygon extends PolygonMatch {
  /// The match.
  const new(this.name, {required this.distanceM, required this.otherDistanceM});

  /// Zone id or ISO 3166-1 alpha-2 code.
  final String name;

  /// Distance to the polygon, metres; at most the radius.
  final double distanceM;

  /// Distance to the nearest polygon of another name, or `null`.
  final double? otherDistanceM;

  @override
  bool operator ==(Object other) =>
      other is NearPolygon &&
      other.name == name &&
      other.distanceM == distanceM &&
      other.otherDistanceM == otherDistanceM;

  @override
  int get hashCode => Object.hash(NearPolygon, name, distanceM, otherDistanceM);

  @override
  String toString() => 'NearPolygon($name, $distanceM, other: $otherDistanceM)';
}

/// No polygon contains the point or lies within the search radius.
final class NoPolygon extends PolygonMatch {
  /// The answer.
  const new();

  @override
  bool operator ==(Object other) => other is NoPolygon;

  @override
  int get hashCode => (NoPolygon).hashCode;

  @override
  String toString() => 'NoPolygon()';
}
