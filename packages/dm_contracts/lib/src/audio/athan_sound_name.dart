import 'package:freezed_annotation/freezed_annotation.dart';

part 'athan_sound_name.freezed.dart';
part 'athan_sound_name.g.dart';

/// The name the voices page shows for a bundled sound (§15 D124).
@freezed
abstract class AthanSoundName with _$AthanSoundName {
  /// Creates a [AthanSoundName].
  const factory({
    /// English name.
    required String en,

    /// Arabic name.
    required String ar,
  }) = _AthanSoundName;

  /// Decodes [json]; throws `CheckedFromJsonException` when it does not
  /// have the schema's shape.
  factory fromJson(Map<String, Object?> json) => _$AthanSoundNameFromJson(json);
}
