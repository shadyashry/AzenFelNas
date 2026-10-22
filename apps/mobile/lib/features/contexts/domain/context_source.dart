/// Where the place of a location context came from (§7.3
/// `location_contexts.source`).
enum ContextSource {
  /// A device fix no older than 15 min with accuracy ≤ 5 000 m (ADR-014).
  freshFix('fresh_fix'),

  /// The platform's last known fix, younger than 24 h (§7.5, stale).
  lastKnownFix('last_known_fix'),

  /// A gazetteer search hit (`SearchGazetteer`).
  gazetteer('gazetteer'),

  /// Coordinates the user typed.
  typedCoordinates('typed_coordinates');

  /// The source stored as [wire].
  new(this.wire);

  /// Column value.
  final String wire;

  /// The source stored as [wire], or `null` for an unknown value.
  static ContextSource? fromWire(String wire) => _byWire[wire];

  static final Map<String, ContextSource> _byWire = {
    for (final source in values) source.wire: source,
  };
}
