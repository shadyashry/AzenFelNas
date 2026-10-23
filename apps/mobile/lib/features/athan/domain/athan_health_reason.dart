/// Why Athan Health is not `ready` (§7.8 `HealthReason`); the names equal
/// the pigeon, Kotlin and Swift labels.
enum AthanHealthReason {
  /// Notifications are off for the app.
  needsNotificationPermission,

  /// Android exact alarms are not allowed.
  needsExactAlarmPermission,

  /// iOS AlarmKit is not authorised.
  needsAlarmKitAuthorization,

  /// The Athan channel or notification sound is muted.
  mutedChannel,

  /// The OS restricts the app in the background.
  batteryRestricted,

  /// No plan, or one the native layer cannot read.
  stalePlan,

  /// The plan ends soon (§7.7 horizon warning lead).
  horizonEnding,

  /// The user did not hear the last Athan Test (§15 D83).
  failedTest,

  /// The device clock disagrees with a trusted time source.
  clockSkew,

  /// The chosen sound is not installed.
  noSoundAsset,

  /// Alarms fall back to the inexact scheduler (REQ-ALM-027).
  inexactFallback,

  /// The path cannot prove delivery (REQ-ALM-033).
  unverifiableDelivery,

  /// The app was force-stopped before (REQ-ALM-025); advisory only.
  forceStoppedPreviously;

  /// The reason named [wire], or null for a name this build does not know.
  static AthanHealthReason? ofWire(String wire) {
    for (final value in values) {
      if (value.name == wire) return value;
    }
    return null;
  }
}
