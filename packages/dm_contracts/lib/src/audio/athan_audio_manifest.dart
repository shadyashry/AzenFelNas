import 'package:dm_contracts/src/audio/athan_sound.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'athan_audio_manifest.freezed.dart';
part 'athan_audio_manifest.g.dart';

/// Wire form of `athan_audio_manifest.v1` (§9.5).
@freezed
abstract class AthanAudioManifest with _$AthanAudioManifest {
  /// Creates a [AthanAudioManifest].
  const factory({
    /// Sounds.
    required List<AthanSound> sounds,
  }) = _AthanAudioManifest;

  /// Decodes [json]; throws `CheckedFromJsonException` when it does not
  /// have the schema's shape.
  factory fromJson(Map<String, Object?> json) =>
      _$AthanAudioManifestFromJson(json);
}
