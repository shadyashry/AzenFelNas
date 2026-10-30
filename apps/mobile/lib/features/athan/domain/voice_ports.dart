import 'package:daily_muslim/features/athan/domain/athan_voice.dart';
import 'package:daily_muslim/features/athan/domain/voice_failure.dart';
import 'package:dm_core_types/dm_core_types.dart';

/// The downloadable voices this build offers (§15 D111): the bundled,
/// pinned voice catalog, without the voices this channel may not offer.
abstract interface class ReadVoiceCatalog {
  /// The voices, in display order. Never throws: no catalog is no voices.
  Future<List<AthanVoice>> call();
}

/// Where voices are downloaded from: `cdn.azenfelnas.app` only (§0.2).
/// Used by the download only; playing never calls it (REQ-ALM-054).
abstract interface class VoiceOrigin {
  /// Appends voice file [path] to [partPath], resuming after the bytes
  /// already in it, until [totalBytes]; reports appended bytes through
  /// [onBytes] and stops with [VoiceCancelled] once [cancelled] is true.
  Future<Result<void, VoiceFailure>> download(
    String path,
    String partPath, {
    required int totalBytes,
    required void Function(int bytes) onBytes,
    required bool Function() cancelled,
  });
}

/// What is on disk for one voice.
enum VoiceFileState {
  /// No file.
  absent,

  /// The file matches the pinned size and SHA-256.
  verified,

  /// A file is there but does not match.
  damaged,
}

/// The voices on this phone's persistent app storage (§15 D111): never a
/// cache directory, so the OS does not clear them.
abstract interface class VoiceDisk {
  /// The directory holding the voices (for the free-space check).
  String get directory;

  /// Where [voice] is once verified.
  String filePath(AthanVoice voice);

  /// Where [voice] is while downloading.
  String partPath(AthanVoice voice);

  /// Bytes of [voice] already downloaded and not yet verified.
  Future<int> partBytes(AthanVoice voice);

  /// Checks [voice]'s file against its pinned size and SHA-256 (reads every
  /// byte).
  Future<VoiceFileState> check(AthanVoice voice);

  /// Checks the partial download of [voice]; when it matches, moves it into
  /// place in one rename, otherwise deletes it and fails with
  /// [VoiceIntegrityFailed].
  Future<Result<void, VoiceFailure>> commit(AthanVoice voice);

  /// Deletes [voice]'s file and partial download.
  Future<void> remove(AthanVoice voice);
}

/// The native alarm side (§0.2 rule 5: it plays with no Dart alive): a
/// verified voice is copied to where scheduled playback reads it.
abstract interface class VoiceAudioHost {
  /// Copies the file at [path] for [soundId] when it matches [sha256]; true
  /// when the alarm player now has it. Never throws.
  Future<bool> install(String soundId, String path, String sha256);

  /// Deletes the alarm player's copy of [soundId]. Never throws.
  Future<void> uninstall(String soundId);
}

/// Plays one voice file for the user to hear (REQ-ALM-054): one preview at
/// a time, never over a playing Athan, stopped when an Athan starts.
abstract interface class VoicePreview {
  /// Starts [path] after stopping any other preview; false when refused
  /// (an Athan is playing, no player on this platform). Never throws.
  Future<bool> play(String path);

  /// Stops the preview, if any. Never throws.
  Future<void> stop();

  /// An event each time a preview ends by itself or is stopped natively.
  Stream<void> get ended;
}
