import 'package:json_annotation/json_annotation.dart';

/// Wire form of `ResultFlag` (§6.2).
@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum ResultFlagCode {
  /// Raw instant within 500 ms of a minute boundary.
  nearRoundingBoundary,

  /// A high-latitude method produced the time.
  highLatitudeFallback,

  /// Location accuracy is low.
  lowLocationAccuracy,

  /// The day contains a DST transition.
  dstTransitionDay,

  /// The pinned TZDB is known to be stale for the zone.
  staleTzdb,

  /// The Hijri date is the tabular fallback.
  hijriExpected,

  /// Calculated at the authority reference point (ADR-006).
  referenceModeAuthorityPoint,

  /// Zone resolved from typed coordinates.
  manualCoordinateResolution,

  /// Within 10 km of a zone or country boundary.
  zoneBoundaryProximity,

  /// No local authority profile; engine default used.
  noLocalProfile,
}
