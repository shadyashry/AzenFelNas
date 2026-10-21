import 'package:freezed_annotation/freezed_annotation.dart';

part 'reference_point.freezed.dart';

/// An authority's calculation point for one area (§6.2, ADR-006). Profile
/// data, never a code value.
@freezed
abstract class ReferencePoint with _$ReferencePoint {
  /// Creates a [ReferencePoint].
  const factory({
    /// ISO 3166-1 alpha-2 (MVP) or ISO 3166-2 area code.
    required String area,

    /// Geodetic latitude, degrees north.
    required double lat,

    /// Longitude, degrees east.
    required double lon,
  }) = _ReferencePoint;
}
