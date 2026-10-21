/// How an elevation sample was obtained (§6.2). DEM-derived elevation is
/// `[DEFERRED V2]` (ADR-015).
enum ElevationSource {
  /// Satellite positioning.
  gnss,

  /// Entered by the user.
  manual,
}
