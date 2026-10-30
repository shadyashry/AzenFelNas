import 'package:daily_muslim/features/athan/domain/athan_voice.dart';
import 'package:daily_muslim/features/athan/domain/voice_ports.dart';
import 'package:meta/meta.dart';

/// The downloaded voices after a check (§15 D111).
@immutable
final class VoiceInventory {
  /// The inventory.
  const new({required this.installed, required this.damaged});

  /// Nothing downloaded.
  static const VoiceInventory empty = VoiceInventory(
    installed: {},
    damaged: {},
  );

  /// Ids of voices verified on disk and held by the alarm player.
  final Set<String> installed;

  /// Ids of voices whose file was damaged and has been deleted.
  final Set<String> damaged;
}

/// Checks every catalog voice on disk when the app needs the list
/// (REQ-ALM-051): a verified file is handed to the alarm player again (a
/// cleared or restored device copy comes back), a damaged one is deleted
/// from both places and reported, never played.
final class CheckVoices {
  /// The use case over its ports.
  const new({required this._disk, required this._host});

  final VoiceDisk _disk;
  final VoiceAudioHost _host;

  /// The inventory of [catalog].
  Future<VoiceInventory> call(List<AthanVoice> catalog) async {
    final installed = <String>{};
    final damaged = <String>{};
    for (final voice in catalog) {
      switch (await _disk.check(voice)) {
        case VoiceFileState.absent:
          break;
        case VoiceFileState.verified:
          final path = _disk.filePath(voice);
          if (await _host.install(voice.soundId, path, voice.sha256)) {
            installed.add(voice.soundId);
          }
        case VoiceFileState.damaged:
          await _host.uninstall(voice.soundId);
          await _disk.remove(voice);
          damaged.add(voice.soundId);
      }
    }
    return VoiceInventory(installed: installed, damaged: damaged);
  }
}
