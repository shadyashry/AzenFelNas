import 'package:freezed_annotation/freezed_annotation.dart';

part 'quran_page_image.freezed.dart';
part 'quran_page_image.g.dart';

/// The geometry and naming of the package's page images.
@freezed
abstract class QuranPageImage with _$QuranPageImage {
  /// Creates a [QuranPageImage].
  const factory({
    /// `webp-lossless` in v1.
    required String format,

    /// Width in pixels.
    required int width,

    /// Height in pixels.
    required int height,

    /// Path of page N, e.g. `pages/{page:03}.webp`.
    required String pathPattern,
  }) = _QuranPageImage;

  /// Decodes [json]; throws `CheckedFromJsonException` when it does not
  /// have the schema's shape.
  factory fromJson(Map<String, Object?> json) =>
      _$QuranPageImageFromJson(json);
}
