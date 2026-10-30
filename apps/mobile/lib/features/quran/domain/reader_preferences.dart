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
  /// The choices.
  const new({this.fit = PageFit.page, this.facingPages = true});

  /// Fit mode.
  final PageFit fit;

  /// Whether wide windows show two facing pages.
  final bool facingPages;

  /// A copy with the given fields replaced.
  ReaderPreferences copyWith({PageFit? fit, bool? facingPages}) =>
      ReaderPreferences(
        fit: fit ?? this.fit,
        facingPages: facingPages ?? this.facingPages,
      );

  @override
  bool operator ==(Object other) =>
      other is ReaderPreferences &&
      other.fit == fit &&
      other.facingPages == facingPages;

  @override
  int get hashCode => Object.hash(fit, facingPages);
}
