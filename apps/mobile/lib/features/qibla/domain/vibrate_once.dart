/// One vibration of a given length: the phone lining up with the Qibla
/// (§15 D118). Never throws; a phone without a vibrator does nothing.
abstract interface class VibrateOnce {
  /// Vibrates once for [length].
  Future<void> call(Duration length);
}
