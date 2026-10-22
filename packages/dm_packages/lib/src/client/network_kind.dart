/// The device's network, as far as the sync policy needs it (REQ-PKG-004).
enum NetworkKind {
  /// No connection: nothing is fetched.
  offline,

  /// Cellular or otherwise metered, and the unknown case: metadata and
  /// payloads up to 2 MB, or `urgent` ones.
  metered,

  /// Wi-Fi or Ethernet: everything.
  unmetered,
}
