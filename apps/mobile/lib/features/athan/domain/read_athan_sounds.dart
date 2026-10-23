/// The installed Athan sounds (the audio manifest, §7.7 `soundId`).
abstract interface class ReadAthanSounds {
  /// The `soundId` of every bundled sound; empty when none is bundled.
  Future<List<String>> call();
}
