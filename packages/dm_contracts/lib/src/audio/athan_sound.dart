import 'package:dm_contracts/src/audio/athan_ios_clip.dart';
import 'package:dm_contracts/src/audio/athan_sound_name.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'athan_sound.freezed.dart';
part 'athan_sound.g.dart';

/// One bundled Athan sound.
@freezed
abstract class AthanSound with _$AthanSound {
  /// Creates a [AthanSound].
  const factory({
    /// Sound id.
    required String soundId,

    /// Path under `assets/`.
    required String file,

    /// Duration.
    required int durationMs,

    /// Licence reference.
    required String licenceRef,

    /// Lowercase hex SHA-256.
    required String sha256,

    /// Regular sound this Fajr recording belongs to.
    String? fajrVariantOf,

    /// iOS notification and AlarmKit clip (REQ-ALM-034).
    AthanIosClip? iosClip,

    /// The name the voices page shows (§15 D124).
    AthanSoundName? name,
  }) = _AthanSound;

  /// Decodes [json]; throws `CheckedFromJsonException` when it does not
  /// have the schema's shape.
  factory fromJson(Map<String, Object?> json) => _$AthanSoundFromJson(json);
}
