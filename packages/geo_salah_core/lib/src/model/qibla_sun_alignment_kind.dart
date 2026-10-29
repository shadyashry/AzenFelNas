/// Which way the Sun stands relative to the Qibla at a Qibla sun alignment
/// (§6.6, REQ-DOM-031).
enum QiblaSunAlignmentKind {
  /// The Sun is in the Qibla direction: facing the Sun is facing the Qibla,
  /// and the shadow of a vertical object points directly **away** from the
  /// Qibla (the classical *raṣd al-qibla* case).
  sunTowardQibla('SUN_TOWARD_QIBLA'),

  /// The Sun is opposite the Qibla: the shadow of a vertical object points
  /// directly **towards** the Qibla.
  sunAwayFromQibla('SUN_AWAY_FROM_QIBLA');

  new(this.code);

  /// The stable wire code of the kind.
  final String code;
}
