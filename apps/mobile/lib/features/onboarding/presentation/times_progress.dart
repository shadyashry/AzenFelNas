/// How far the prayer times are (§15 D127): the hero says they are ready
/// only once the place, its time zone and the calculation are all in.
enum TimesProgress {
  /// Being calculated.
  preparing,

  /// Calculated.
  ready,

  /// Could not be calculated; the panel says why.
  failed,
}
