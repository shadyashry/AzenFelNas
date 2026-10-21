/// How observer elevation enters horizon events (§6.2, ADR-003,
/// `[DEFAULT · D3]`).
enum HorizonElevationPolicy {
  /// No dip: the horizon rule's target is used as is (the default).
  none,

  /// Dip above local terrain (`[DEFERRED V2]`; the engine returns
  /// `EngineFailure.unsupportedPolicy`).
  aboveLocalTerrain,

  /// Dip from an authority table (`[DEFERRED V2]`; the engine returns
  /// `EngineFailure.unsupportedPolicy`).
  authorityTable,
}
