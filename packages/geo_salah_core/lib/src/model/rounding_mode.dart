/// How an event's instant becomes its displayed minute (§6.2, ADR-005,
/// `[DEFAULT · D4]`). The mode is profile data, never a code default
/// (§0.2 rule 1).
enum RoundingMode {
  /// Up to the next local minute boundary; an instant on a boundary stays.
  ceil,

  /// Down to the previous local minute boundary; an instant on a boundary
  /// stays.
  floor,

  /// To the nearest local minute boundary; half a minute rounds up.
  nearest,
}
