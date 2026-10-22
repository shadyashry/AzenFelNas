import 'package:geo_salah_core/geo_salah_core.dart';
import 'package:meta/meta.dart';

/// The country the resolver gives a coordinate (§8, ADR-006, §15 D70).
@immutable
sealed class CountryResolution {
  const new();

  /// The result flags this resolution sets: `zoneBoundaryProximity` when
  /// another country lies within the boundary radius. `noLocalProfile` is
  /// for the profile resolution to set, not this one.
  Set<ResultFlag> get flags => switch (this) {
    InCountry(:final nearBoundary) || OffshoreCountry(:final nearBoundary) => {
      if (nearBoundary) ResultFlag.zoneBoundaryProximity,
    },
    NoCountry() => const {},
  };
}

/// A `country_polygons` polygon contains the coordinate.
final class InCountry extends CountryResolution {
  /// The resolution.
  const new(this.iso2, {required this.nearBoundary});

  /// ISO 3166-1 alpha-2 code.
  final String iso2;

  /// Another country lies within the boundary radius.
  final bool nearBoundary;

  @override
  bool operator ==(Object other) =>
      other is InCountry &&
      other.iso2 == iso2 &&
      other.nearBoundary == nearBoundary;

  @override
  int get hashCode => Object.hash(InCountry, iso2, nearBoundary);

  @override
  String toString() => 'InCountry($iso2, nearBoundary: $nearBoundary)';
}

/// No polygon contains the coordinate, and the nearest country lies within
/// the territorial-sea radius (a ship, a pier, a simplified coast).
final class OffshoreCountry extends CountryResolution {
  /// The resolution.
  const new(this.iso2, {required this.distanceM, required this.nearBoundary});

  /// ISO 3166-1 alpha-2 code.
  final String iso2;

  /// Distance to that country, metres.
  final double distanceM;

  /// Another country lies within the boundary radius.
  final bool nearBoundary;

  @override
  bool operator ==(Object other) =>
      other is OffshoreCountry &&
      other.iso2 == iso2 &&
      other.distanceM == distanceM &&
      other.nearBoundary == nearBoundary;

  @override
  int get hashCode =>
      Object.hash(OffshoreCountry, iso2, distanceM, nearBoundary);

  @override
  String toString() => 'OffshoreCountry($iso2, $distanceM, $nearBoundary)';
}

/// No country: the caller uses `engine.default` with `noLocalProfile` (§8).
final class NoCountry extends CountryResolution {
  /// The resolution.
  const new();

  @override
  bool operator ==(Object other) => other is NoCountry;

  @override
  int get hashCode => (NoCountry).hashCode;

  @override
  String toString() => 'NoCountry()';
}
