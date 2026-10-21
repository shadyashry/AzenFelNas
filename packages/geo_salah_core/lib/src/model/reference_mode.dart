/// Where a profile's times are calculated (§6.2, ADR-006, `[DEFAULT · D2]`).
enum ReferenceMode {
  /// At the observer's own coordinate.
  exactCoordinate,

  /// At the profile's reference point for the observer's area (MVP: the
  /// country); the times carry `referenceModeAuthorityPoint`.
  authorityReferencePoint,
}
