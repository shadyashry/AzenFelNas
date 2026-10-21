/// Where an observer's position came from (§6.2).
enum ObserverSource {
  /// A device location fix.
  device,

  /// A pinned context (REQ-PRIV-002).
  pinned,

  /// A manually chosen place.
  manual,

  /// A mosque's published position (`[DEFERRED V1.5]`).
  mosque,

  /// An Accuracy Lab benchmark city.
  benchmark,
}
