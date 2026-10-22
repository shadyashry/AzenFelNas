/// What the user can do about a failure: the action of a `Needs attention`
/// state (§10.2). The copy for each is in the ARB files.
enum Remediation {
  /// Allow location access.
  grantLocationPermission,

  /// Turn on the device's location services.
  turnOnLocationServices,

  /// Choose a place from the list or enter coordinates.
  chooseManualPlace,

  /// Nothing to do now; a data update will fix it.
  waitForDataUpdate,

  /// Connect to the internet; the app retries on its own.
  retryWhenOnline,

  /// Free some storage on the device.
  freeUpStorage,

  /// Try the same action again.
  tryAgain,

  /// Install the latest app version.
  updateApp,

  /// Allow exact alarms (Android) or notifications.
  grantAlarmPermission,

  /// Open Athan Health for the details.
  openAthanHealth,

  /// Set the device's date and time automatically.
  checkDeviceClock,
}
