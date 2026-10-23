import 'package:freezed_annotation/freezed_annotation.dart';

part 'athan_ios_clip.freezed.dart';
part 'athan_ios_clip.g.dart';

/// The iOS clip of a sound: a `.caf` of at most 29 s (REQ-ALM-034).
@freezed
abstract class AthanIosClip with _$AthanIosClip {
  /// Creates a [AthanIosClip].
  const factory({
    /// Path under `assets/`.
    required String file,

    /// Duration, at most 29 000.
    required int durationMs,

    /// Lowercase hex SHA-256.
    required String sha256,
  }) = _AthanIosClip;

  /// Decodes [json]; throws `CheckedFromJsonException` when it does not
  /// have the schema's shape.
  factory fromJson(Map<String, Object?> json) => _$AthanIosClipFromJson(json);
}
