import 'package:daily_muslim/features/contexts/domain/gazetteer_hit.dart';
import 'package:dm_civil_time/dm_civil_time.dart';
import 'package:meta/meta.dart';

/// A place the user chooses to keep (`PinPlace`, §7.2).
@immutable
sealed class PlaceChoice {
  const new();
}

/// A gazetteer search hit: its zone and country come from the gazetteer.
final class GazetteerChoice extends PlaceChoice {
  /// The choice of [hit].
  const new(this.hit);

  /// The chosen place.
  final GazetteerHit hit;

  @override
  bool operator ==(Object other) =>
      other is GazetteerChoice && other.hit == hit;

  @override
  int get hashCode => Object.hash(GazetteerChoice, hit);
}

/// Coordinates typed by the user, named [label].
final class TypedCoordinates extends PlaceChoice {
  /// The choice of [point].
  const new(this.point, {required this.label});

  /// The typed point.
  final GeoPointE6 point;

  /// The user's name for it.
  final String label;

  @override
  bool operator ==(Object other) =>
      other is TypedCoordinates && other.point == point && other.label == label;

  @override
  int get hashCode => Object.hash(TypedCoordinates, point, label);

  /// No coordinates (REQ-PRIV-001).
  @override
  String toString() => 'TypedCoordinates($label)';
}

/// The current device context, kept as it is now (pinning).
final class PinCurrentLocation extends PlaceChoice {
  /// The choice, named [label].
  const new({required this.label});

  /// The user's name for the pinned place.
  final String label;

  @override
  bool operator ==(Object other) =>
      other is PinCurrentLocation && other.label == label;

  @override
  int get hashCode => Object.hash(PinCurrentLocation, label);
}
