import 'package:meta/meta.dart';

/// How a page fills the reader.
enum PageFit {
  /// The whole page, never clipped, aspect ratio kept.
  page,

  /// The page's full width; scroll vertically for the rest.
  width,
}

/// The reader's saved choices.
@immutable
final class ReaderPreferences {
  /// The choices. A portrait window fits the whole page and a landscape
  /// one its width until the reader picks otherwise (§15 D123).
  const new({
    this.fit = PageFit.page,
    this.landscapeFit = PageFit.width,
    this.facingPages = true,
    this.keepControls = false,
  });

  /// Fit mode in a portrait (or square) window.
  final PageFit fit;

  /// Fit mode in a landscape window.
  final PageFit landscapeFit;

  /// Whether wide, tall windows (tablets) show two facing pages.
  final bool facingPages;

  /// Whether the controls stay shown instead of following taps.
  final bool keepControls;

  /// The fit for a window that is [landscape] or not.
  PageFit fitFor({required bool landscape}) => landscape ? landscapeFit : fit;

  /// A copy with the fit for [landscape] windows set to [value].
  ReaderPreferences withFit({
    required bool landscape,
    required PageFit value,
  }) => landscape ? copyWith(landscapeFit: value) : copyWith(fit: value);

  /// A copy with the given fields replaced.
  ReaderPreferences copyWith({
    PageFit? fit,
    PageFit? landscapeFit,
    bool? facingPages,
    bool? keepControls,
  }) => ReaderPreferences(
    fit: fit ?? this.fit,
    landscapeFit: landscapeFit ?? this.landscapeFit,
    facingPages: facingPages ?? this.facingPages,
    keepControls: keepControls ?? this.keepControls,
  );

  @override
  bool operator ==(Object other) =>
      other is ReaderPreferences &&
      other.fit == fit &&
      other.landscapeFit == landscapeFit &&
      other.facingPages == facingPages &&
      other.keepControls == keepControls;

  @override
  int get hashCode => Object.hash(fit, landscapeFit, facingPages, keepControls);
}
