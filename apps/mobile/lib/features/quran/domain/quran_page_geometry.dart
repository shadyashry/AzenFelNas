import 'package:meta/meta.dart';

/// The size and naming of the package's page images.
@immutable
final class QuranPageGeometry {
  /// Pages of [width] × [height] pixels at [pathPattern].
  const new({
    required this.width,
    required this.height,
    required this.pathPattern,
  });

  /// Width in pixels.
  final int width;

  /// Height in pixels.
  final int height;

  /// Path of page N, e.g. `pages/{page:03}.webp`.
  final String pathPattern;

  /// The path of [page] inside the package.
  String pathOf(int page) =>
      pathPattern.replaceFirst('{page:03}', page.toString().padLeft(3, '0'));

  @override
  bool operator ==(Object other) =>
      other is QuranPageGeometry &&
      other.width == width &&
      other.height == height &&
      other.pathPattern == pathPattern;

  @override
  int get hashCode => Object.hash(width, height, pathPattern);
}
