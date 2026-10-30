/// The Athan playing on this phone now (§15 D118, REQ-ALM-043), so the app
/// can show a Stop whenever one plays: an Athan may outlive its
/// notification, which the user can swipe away on Android 14+.
abstract interface class AthanPlayback {
  /// Whether an Athan is playing. Never throws: no platform is `false`.
  Future<bool> athanPlaying();

  /// Ends the Athan playing now, if any. Never throws.
  Future<void> stopAthan();

  /// `true` each time an Athan starts, `false` each time one ends.
  Stream<bool> get athanChanges;
}
