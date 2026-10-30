import 'package:daily_muslim/features/athan/domain/athan_voice.dart';
import 'package:daily_muslim/features/athan/domain/voice_ports.dart';

/// Deletes a downloaded voice from the phone and from the alarm player
/// (§15 D111). A plan still naming it falls back as REQ-ALM-053 says.
final class RemoveVoice {
  /// The use case over its ports.
  const new({required this._disk, required this._host});

  final VoiceDisk _disk;
  final VoiceAudioHost _host;

  /// Removes [voice].
  Future<void> call(AthanVoice voice) async {
    await _host.uninstall(voice.soundId);
    await _disk.remove(voice);
  }
}
