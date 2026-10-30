import 'dart:math' as math;
import 'dart:ui';

import 'package:daily_muslim/features/quran/domain/reader_preferences.dart';
import 'package:meta/meta.dart';

/// Where the page sits in the reader at a zoom level (§15 D107,
/// REQ-QRN-030): pure geometry, so rotation, resizing and zoom are tested
/// without a device.
///
/// The page keeps its aspect ratio at every size: it is never stretched,
/// cropped or reflowed. *Fit page* shows the whole page; *fit width* fills
/// the width and scrolls vertically. A zoomed page can be panned to every
/// edge and no further; a page smaller than the viewport is centred.
@immutable
final class MushafGeometry {
  /// The geometry of content with [aspect] (width / height) in [viewport]
  /// under [fit].
  const new({
    required this.viewport,
    required this.aspect,
    required this.fit,
  });

  /// The reader's size in logical pixels.
  final Size viewport;

  /// Width / height of what is shown (one page, or a spread of two).
  final double aspect;

  /// The fit mode.
  final PageFit fit;

  /// The largest zoom.
  static const double maxScale = 4;

  /// The content's size at scale 1.
  Size get baseSize {
    if (viewport.isEmpty) return Size.zero;
    final width = switch (fit) {
      PageFit.page => math.min(viewport.width, viewport.height * aspect),
      PageFit.width => viewport.width,
    };
    return Size(width, width / aspect);
  }

  /// The content's top-left at scale 1: centred, or at the top when fit
  /// width makes it taller than the viewport.
  Offset get baseOffset => clampOffset(
    Offset(
      (viewport.width - baseSize.width) / 2,
      // Taller than the window (fit width): start at the top of the page.
      baseSize.height > viewport.height
          ? 0
          : (viewport.height - baseSize.height) / 2,
    ),
    1,
  );

  /// [offset] moved so content at [scale] covers no more than it must:
  /// centred on an axis where it is smaller than the viewport, otherwise
  /// kept between the two edges.
  Offset clampOffset(Offset offset, double scale) {
    final size = baseSize * scale;
    double axis(double value, double content, double view) => content <= view
        ? (view - content) / 2
        : value.clamp(view - content, 0).toDouble();
    return Offset(
      axis(offset.dx, size.width, viewport.width),
      axis(offset.dy, size.height, viewport.height),
    );
  }

  /// [scale] kept within 1..[maxScale].
  static double clampScale(double scale) => scale.clamp(1, maxScale).toDouble();

  /// The offset that keeps the content point under [focal] in place when
  /// the scale goes from [fromScale] (at [fromOffset]) to [toScale].
  Offset zoomAround(
    Offset focal,
    Offset fromOffset,
    double fromScale,
    double toScale,
  ) {
    final point = (focal - fromOffset) / fromScale;
    return clampOffset(focal - point * toScale, toScale);
  }

  /// Whether a horizontal drag at [scale] should turn the page: the content
  /// is not wider than the viewport, so there is nothing to pan sideways.
  bool turnsPages(double scale) =>
      baseSize.width * scale <= viewport.width + 0.5;

  /// The page-relative point (0..1 of the content) under the viewport
  /// point [p], for content at [offset] and [scale].
  Offset relative(Offset p, Offset offset, double scale) {
    final size = baseSize * scale;
    if (size.isEmpty) return Offset.zero;
    return Offset(
      (p.dx - offset.dx) / size.width,
      (p.dy - offset.dy) / size.height,
    );
  }
}
