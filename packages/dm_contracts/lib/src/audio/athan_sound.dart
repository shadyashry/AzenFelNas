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
  }) = _AthanSound;

  /// Decodes [json]; throws `CheckedFromJsonException` when it does not
  /// have the schema's shape.
  factory fromJson(Map<String, Object?> json) => _$AthanSoundFromJson(json);
}
