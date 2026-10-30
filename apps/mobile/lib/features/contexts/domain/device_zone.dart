/// The time zone the phone is set to (port of `SuggestPlaces`, §15 D100):
/// no permission, no network, and close enough to name the user's region.
abstract interface class ReadDeviceZone {
  /// The IANA zone id, or `null` when the platform does not say.
  Future<String?> zoneId();
}
