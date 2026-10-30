import 'dart:async';

import 'package:daily_muslim/features/athan/domain/athan_voice.dart';
import 'package:daily_muslim/features/athan/domain/voice_failure.dart';
import 'package:daily_muslim/features/athan/domain/voice_ports.dart';
import 'package:daily_muslim/features/quran/domain/build_search_index.dart';
import 'package:dm_core_types/dm_core_types.dart';

/// A catalog voice for tests (shape data, not a real recording).
AthanVoice fakeVoice(
  String soundId, {
  VoiceDesignation designation = VoiceDesignation.standard,
  VoiceReview review = VoiceReview.passed,
  int bytes = 1000,
}) => AthanVoice(
  soundId: soundId,
  nameEn: 'Voice $soundId',
  nameAr: 'صوت $soundId',
  designation: designation,
  review: review,
  path: '$soundId/1/$soundId.m4a',
  bytes: bytes,
  sha256: 'a' * 64,
  durationMs: 183000,
  credit: const VoiceCredit(
    creator: 'Fixture creator',
    sourcePage: 'https://example.invalid/source',
    licence: 'CC-BY-3.0',
    licenceUrl: 'https://creativecommons.org/licenses/by/3.0/',
    changes: 'none',
  ),
);

/// [ReadVoiceCatalog] over a fixed list.
final class FakeVoiceCatalog implements ReadVoiceCatalog {
  /// The catalog of [voices].
  const new([this.voices = const []]);

  /// The voices.
  final List<AthanVoice> voices;

  @override
  Future<List<AthanVoice>> call() async => voices;
}

/// [VoiceDisk] in memory: a file is its byte count and whether its bytes
/// match the pin.
final class FakeVoiceDisk implements VoiceDisk {
  /// Verified files by `soundId`.
  final Map<String, VoiceFileState> files = {};

  /// Partial bytes by `soundId`.
  final Map<String, int> parts = {};

  /// Whether the next commit finds the part damaged.
  bool corruptNextCommit = false;

  @override
  String get directory => '/voices';

  @override
  String filePath(AthanVoice voice) => '/voices/${voice.soundId}.m4a';

  @override
  String partPath(AthanVoice voice) => '${filePath(voice)}.part';

  @override
  Future<int> partBytes(AthanVoice voice) async => parts[voice.soundId] ?? 0;

  @override
  Future<VoiceFileState> check(AthanVoice voice) async =>
      files[voice.soundId] ?? VoiceFileState.absent;

  @override
  Future<Result<void, VoiceFailure>> commit(AthanVoice voice) async {
    final bytes = parts.remove(voice.soundId) ?? 0;
    if (corruptNextCommit || bytes != voice.bytes) {
      corruptNextCommit = false;
      return const Result.err(VoiceIntegrityFailed());
    }
    files[voice.soundId] = VoiceFileState.verified;
    return const Result.ok(null);
  }

  @override
  Future<void> remove(AthanVoice voice) async {
    files.remove(voice.soundId);
    parts.remove(voice.soundId);
  }
}

/// [VoiceOrigin] that appends to [disk]'s parts, failing with [failWith]
/// after [failAfterBytes] bytes when set.
final class FakeVoiceOrigin implements VoiceOrigin {
  /// The origin writing into [disk].
  new(this.disk);

  /// Where bytes land.
  final FakeVoiceDisk disk;

  /// Fail once this many bytes are in the part.
  int? failAfterBytes;

  /// The failure.
  VoiceFailure failWith = const VoiceOffline();

  /// Paths requested.
  final List<String> requested = [];

  @override
  Future<Result<void, VoiceFailure>> download(
    String path,
    String partPath, {
    required int totalBytes,
    required void Function(int bytes) onBytes,
    required bool Function() cancelled,
  }) async {
    requested.add(path);
    final id = path.split('/').first;
    final from = disk.parts[id] ?? 0;
    final stop = failAfterBytes;
    final to = stop != null && stop < totalBytes ? stop : totalBytes;
    disk.parts[id] = to;
    onBytes(to - from);
    if (stop != null && stop < totalBytes) {
      failAfterBytes = null;
      return Result.err(failWith);
    }
    return const Result.ok(null);
  }
}

/// [VoiceAudioHost] recording what the alarm player holds.
final class FakeVoiceAudioHost implements VoiceAudioHost {
  /// Installed ids.
  final Set<String> installed = {};

  /// Whether installs are refused.
  bool refuse = false;

  @override
  Future<bool> install(String soundId, String path, String sha256) async {
    if (refuse) return false;
    installed.add(soundId);
    return true;
  }

  @override
  Future<void> uninstall(String soundId) async => installed.remove(soundId);
}

/// [VoicePreview] recording what plays.
final class FakeVoicePreview implements VoicePreview {
  /// The file playing, or null.
  String? playing;

  /// Every file started, in order.
  final List<String> started = [];

  /// Whether an Athan is playing (previews are refused).
  bool athanPlaying = false;

  final StreamController<void> _ended = StreamController<void>.broadcast();

  /// The file ends by itself.
  void finish() {
    playing = null;
    _ended.add(null);
  }

  @override
  Future<bool> play(String path) async {
    if (athanPlaying) return false;
    playing = path;
    started.add(path);
    return true;
  }

  @override
  Future<void> stop() async => playing = null;

  @override
  Stream<void> get ended => _ended.stream;
}

/// [ReadFreeSpace] answering [bytes].
final class FakeFreeSpace implements ReadFreeSpace {
  /// The answer.
  const new(this.bytes);

  /// Free bytes, or null when unknown.
  final int? bytes;

  @override
  Future<int?> call(String directory) async => bytes;
}
