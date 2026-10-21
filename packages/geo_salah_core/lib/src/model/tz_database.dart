/// The pinned time-zone database (§6.2), as the engine consumes it.
///
/// Implemented by `dm_civil_time` over the app's pinned TZDB package, never
/// the OS database (REQ-TIME-020); the engine depends on this interface only.
///
/// Contract: [offsetSecondsAt] is pure and total for every zone the
/// implementation supports, and returns the UTC offset in effect at the
/// instant (local = UTC + offset). [version] identifies the data
/// (`Provenance.tzdbVersion`).
abstract interface class TzDatabase {
  /// The TZDB version of the data, e.g. `2026b`.
  String get version;

  /// UTC offset of [zoneId] at [utcMs] (UTC epoch milliseconds), in seconds.
  int offsetSecondsAt(String zoneId, int utcMs);
}
