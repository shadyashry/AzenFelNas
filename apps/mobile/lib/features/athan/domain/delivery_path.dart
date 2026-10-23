/// The native path that delivers Athans (§7.8 `platformPath`, D81, D82).
enum DeliveryPath {
  /// Android `setAlarmClock` (REQ-ALM-020).
  androidExact,

  /// Android inexact fallback (REQ-ALM-027).
  androidInexact,

  /// iOS 26+ AlarmKit (REQ-ALM-030).
  iosAlarmKit,

  /// iOS notifications; never `ready` (REQ-ALM-033).
  iosNotification,

  /// No native Athan layer answered (unsupported platform or no host).
  unavailable;

  /// The path named [wire]; unknown names are [unavailable].
  static DeliveryPath ofWire(String wire) {
    for (final value in values) {
      if (value.name == wire) return value;
    }
    return unavailable;
  }
}
