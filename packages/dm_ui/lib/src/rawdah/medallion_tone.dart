/// What a `ReadinessMedallion`'s ring says (§15 D89).
enum MedallionTone {
  /// Evidence says it works: a full gilded ring with a glow.
  ready,

  /// It works with limits: three quarters of a gold ring.
  limited,

  /// It will not work: a carpet-red ring.
  notReady,

  /// No evidence either way: a dotted ring.
  unknown,
}
