/// The ten sky phases of Appendix G (ADR-018), from the Sun's geometric
/// altitude and direction. Design data for the theme, never a prayer rule:
/// no prayer time is derived from a phase.
enum SkyPhase {
  /// Altitude below −18°, either direction.
  night,

  /// Rising, altitude in `[−18°, −12°)`.
  astronomicalDawn,

  /// Rising, altitude in `[−12°, −6°)`.
  nauticalDawn,

  /// Rising, altitude in `[−6°, −0.833°)`.
  civilDawn,

  /// Rising, altitude in `[−0.833°, 6°]`.
  goldenMorning,

  /// Altitude above 6°, either direction.
  day,

  /// Setting, altitude in `(−0.833°, 6°]`.
  goldenEvening,

  /// Setting, altitude in `(−6°, −0.833°]`.
  civilDusk,

  /// Setting, altitude in `(−12°, −6°]`.
  nauticalDusk,

  /// Setting, altitude in `(−18°, −12°]`.
  astronomicalDusk;

  /// The lower altitude edge of each twilight band, degrees.
  static const List<double> _edges = [-18, -12, -6, -0.833, 6];

  /// The phase at geometric [altitudeDeg] for a [rising] or setting Sun
  /// (Appendix G). Rising bands are closed below, setting bands closed
  /// above; exactly 6° is still golden while setting and day while rising
  /// (§15 D75). Total over every finite altitude.
  static SkyPhase classify({
    required double altitudeDeg,
    required bool rising,
  }) {
    if (rising ? altitudeDeg < -18 : altitudeDeg <= -18) return night;
    if (rising ? altitudeDeg >= 6 : altitudeDeg > 6) return day;
    var band = 0;
    while (band < 3 &&
        (rising
            ? altitudeDeg >= _edges[band + 1]
            : altitudeDeg > _edges[band + 1])) {
      band++;
    }
    const risingBands = [
      astronomicalDawn,
      nauticalDawn,
      civilDawn,
      goldenMorning,
    ];
    const settingBands = [
      astronomicalDusk,
      nauticalDusk,
      civilDusk,
      goldenEvening,
    ];
    return rising ? risingBands[band] : settingBands[band];
  }

  /// How far [altitudeDeg] has moved through this phase's band in its
  /// direction, in `[0, 1]`; `0` for the unbounded [night] and [day].
  double progressAt(double altitudeDeg) {
    final (double lo, double hi, bool up) = switch (this) {
      night || day => (0, 0, true),
      astronomicalDawn => (-18, -12, true),
      nauticalDawn => (-12, -6, true),
      civilDawn => (-6, -0.833, true),
      goldenMorning => (-0.833, 6, true),
      goldenEvening => (-0.833, 6, false),
      civilDusk => (-6, -0.833, false),
      nauticalDusk => (-12, -6, false),
      astronomicalDusk => (-18, -12, false),
    };
    if (hi == lo) return 0;
    final f = up
        ? (altitudeDeg - lo) / (hi - lo)
        : (hi - altitudeDeg) / (hi - lo);
    return f.clamp(0, 1).toDouble();
  }
}
