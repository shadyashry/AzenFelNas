/// How a day's Hijri dates were obtained (§6.2, ADR-016).
enum HijriConfidence {
  /// Month start confirmed by a signed announcement.
  confirmed,

  /// Tabular fallback, not yet announced.
  expected,

  /// Shifted by the user's ±1 day override.
  userOverride,
}
