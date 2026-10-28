/// Where a mark or the Sun sits on the day's arch (§15 D89).
sealed class ArchPosition {
  const new();
}

/// On the arch: [fraction] of the way from sunrise (0) to sunset (1),
/// measured along the arch.
final class OnArch extends ArchPosition {
  /// At [fraction], clamped to `[0, 1]` when drawn.
  const new(this.fraction);

  /// Fraction of the daylight span.
  final double fraction;
}

/// On the ground line before sunrise (Imsak, Fajr, the night Sun).
final class BeforeSunrise extends ArchPosition {
  /// The position.
  const new();
}

/// On the ground line after sunset (Isha, the evening Sun).
final class AfterSunset extends ArchPosition {
  /// The position.
  const new();
}
