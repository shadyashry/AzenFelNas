/// Whether the Sun's altitude increases or decreases through a target.
enum CrossingDirection {
  /// Altitude increasing (ascending half: Imsak, Fajr, Sunrise).
  rising,

  /// Altitude decreasing (descending half: Asr, Maghrib, Isha).
  setting,
}
