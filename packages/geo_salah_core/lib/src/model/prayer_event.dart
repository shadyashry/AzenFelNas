/// The events of a prayer day (§6.2), in their order within the day
/// (REQ-DOM-001). Duha, midnight and last third are `[DEFERRED V1.5]`.
enum PrayerEvent {
  /// Imsak: the start of the fast, defined relative to Fajr.
  imsak,

  /// Fajr.
  fajr,

  /// Sunrise.
  sunrise,

  /// Dhuhr.
  dhuhr,

  /// Asr.
  asr,

  /// Maghrib.
  maghrib,

  /// Isha.
  isha,
}
