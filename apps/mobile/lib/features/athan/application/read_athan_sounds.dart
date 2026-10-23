import 'package:dm_contracts/dm_contracts.dart';

/// The installed Athan sounds (the audio manifest, §7.7 `soundId`).
abstract interface class ReadAthanSounds {
  /// Every sound of the bundled manifest; empty when none is bundled.
  Future<List<AthanSound>> call();
}
