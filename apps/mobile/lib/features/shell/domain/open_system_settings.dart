/// Opens the system settings screen a remediation points to (§10.2,
/// §15 D97). Returns once the screen was asked for; never throws.
abstract interface class OpenSystemSettings {
  /// The device's location settings (location services off).
  Future<void> location();

  /// This app's settings (a permission the system no longer asks for).
  Future<void> app();
}
