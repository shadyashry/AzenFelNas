import 'package:daily_muslim/features/athan/domain/athan_voice.dart';
import 'package:daily_muslim/features/athan/domain/voice_download_status.dart';
import 'package:daily_muslim/features/athan/domain/voice_failure.dart';
import 'package:daily_muslim/features/athan/domain/voice_ports.dart';
import 'package:daily_muslim/features/quran/domain/build_search_index.dart';
import 'package:daily_muslim/features/quran/domain/download_cancel.dart';
import 'package:dm_core_types/dm_core_types.dart';

/// Downloads one voice, verifies it and hands it to the alarm player
/// (§15 D111, REQ-ALM-051), as the Quran download does (§15 D107):
///
/// 1. Free space must cover what is left of the file plus a margin.
/// 2. The file is appended to a `.part` file, resumed with an HTTP range
///    after a cancel, a lost connection or the app closing.
/// 3. The part must match the pinned size and SHA-256; only then is it
///    moved into place (a mismatch deletes it).
/// 4. The native side copies it to where alarms read it; a refusal removes
///    the file again, so "downloaded" always means "the alarm can play it".
final class DownloadVoice {
  /// The use case over its ports.
  const new({
    required this._disk,
    required this._origin,
    required this._host,
    required this._freeSpace,
  });

  final VoiceDisk _disk;
  final VoiceOrigin _origin;
  final VoiceAudioHost _host;
  final ReadFreeSpace _freeSpace;

  /// Space kept free beyond the file.
  static const int safetyMarginBytes = 4 * 1024 * 1024;

  /// The statuses of one attempt; the last is [VoiceDownloaded] or
  /// [VoiceDownloadFailed].
  Stream<VoiceDownloadStatus> call(
    AthanVoice voice,
    DownloadCancel cancel,
  ) async* {
    if (await _disk.check(voice) == VoiceFileState.verified) {
      yield* _install(voice);
      return;
    }
    var done = await _disk.partBytes(voice);
    final needed = voice.bytes - done + safetyMarginBytes;
    final free = await _freeSpace(_disk.directory);
    if (free != null && free < needed) {
      yield VoiceDownloadFailed(VoiceNoSpace(neededBytes: needed));
      return;
    }
    yield VoiceDownloading(doneBytes: done, totalBytes: voice.bytes);
    final progress = <int>[];
    final result = await _origin.download(
      voice.path,
      _disk.partPath(voice),
      totalBytes: voice.bytes,
      onBytes: progress.add,
      cancelled: () => cancel.isCancelled,
    );
    done += progress.fold(0, (a, b) => a + b);
    if (result case Err(:final failure)) {
      yield VoiceDownloadFailed(failure);
      return;
    }
    yield VoiceDownloading(doneBytes: done, totalBytes: voice.bytes);
    if (await _disk.commit(voice) case Err(:final failure)) {
      yield VoiceDownloadFailed(failure);
      return;
    }
    yield* _install(voice);
  }

  Stream<VoiceDownloadStatus> _install(AthanVoice voice) async* {
    final path = _disk.filePath(voice);
    if (await _host.install(voice.soundId, path, voice.sha256)) {
      yield const VoiceDownloaded();
    } else {
      await _disk.remove(voice);
      yield const VoiceDownloadFailed(VoiceStorageFailed('alarm player'));
    }
  }
}
