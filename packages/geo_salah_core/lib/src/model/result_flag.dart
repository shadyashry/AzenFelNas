/// A fact about a prayer time that the Accuracy Passport explains (§6.2).
enum ResultFlag {
  /// The raw instant is within 500 ms of a minute boundary (ADR-005).
  nearRoundingBoundary,

  /// A high-latitude method produced the time.
  highLatitudeFallback,

  /// The observer's location accuracy is low.
  lowLocationAccuracy,

  /// The day has a UTC-offset transition.
  dstTransitionDay,

  /// The pinned TZDB is stale.
  staleTzdb,

  /// The Hijri date is the tabular expectation (ADR-016).
  hijriExpected,

  /// Calculated at the authority reference point (ADR-006).
  referenceModeAuthorityPoint,

  /// The coordinate came from a manual place.
  manualCoordinateResolution,

  /// The observer is near a time-zone boundary.
  zoneBoundaryProximity,

  /// No local authority profile covers the observer.
  noLocalProfile,
}
