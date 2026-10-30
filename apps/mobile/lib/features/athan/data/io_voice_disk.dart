import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:daily_muslim/features/athan/domain/athan_voice.dart';
import 'package:daily_muslim/features/athan/domain/voice_failure.dart';
import 'package:daily_muslim/features/athan/domain/voice_ports.dart';
import 'package:dm_core_types/dm_core_types.dart';

/// [VoiceDisk] under [root] (`<app support>/athan_voices/`, persistent,
/// never a cache, §15 D111): `<soundId>.m4a` once verified and
/// `<soundId>.m4a.part` while downloading.
final class IoVoiceDisk implements VoiceDisk {
  /// The disk under [root].
  const new(this.root);

  /// The voices directory.
  final Directory root;

  @override
  String get directory => root.path;

  @override
  String filePath(AthanVoice voice) => '${root.path}/${voice.soundId}.m4a';

  @override
  String partPath(AthanVoice voice) => '${filePath(voice)}.part';

  @override
  Future<int> partBytes(AthanVoice voice) async {
    final part = File(partPath(voice));
    return part.existsSync() ? part.lengthSync() : 0;
  }

  @override
  Future<VoiceFileState> check(AthanVoice voice) async {
    final file = File(filePath(voice));
    if (!file.existsSync()) return VoiceFileState.absent;
    return await _matches(file, voice)
        ? VoiceFileState.verified
        : VoiceFileState.damaged;
  }

  @override
  Future<Result<void, VoiceFailure>> commit(AthanVoice voice) async {
    final part = File(partPath(voice));
    try {
      if (!await _matches(part, voice)) {
        if (part.existsSync()) await part.delete();
        return const Result.err(VoiceIntegrityFailed());
      }
      await part.rename(filePath(voice));
      return const Result.ok(null);
    } on FileSystemException catch (error) {
      return Result.err(VoiceStorageFailed(error.message));
    }
  }

  @override
  Future<void> remove(AthanVoice voice) async {
    for (final f in [File(filePath(voice)), File(partPath(voice))]) {
      try {
        if (f.existsSync()) await f.delete();
      } on FileSystemException {
        // Gone or locked: the next check reports what is left.
      }
    }
  }

  static Future<bool> _matches(File file, AthanVoice voice) async =>
      file.existsSync() &&
      file.lengthSync() == voice.bytes &&
      (await sha256.bind(file.openRead()).first).toString() == voice.sha256;
}
