import 'dart:io';
import 'dart:math' as math;

import 'package:daily_muslim/features/quran/domain/highlight.dart';
import 'package:daily_muslim/features/quran/domain/highlight_color.dart';
import 'package:flutter/material.dart';

/// One official Mushaf page exactly as published (§15 D107, REQ-QRN-031):
/// the image is shown at its own aspect ratio with no filter, tint, theme
/// or control over it. The only overlay is the reader's own highlights,
/// drawn translucent (multiply) so every letter and mark stays readable;
/// with [regions] empty the page is untouched.
///
/// The image is decoded no larger than shown (rounded up to 256 px steps
/// and never above the source), so a small phone never holds a full-size
/// bitmap and zooming in decodes more detail.
final class MushafPageImage extends StatelessWidget {
  /// Page [page] from [path], shown at [size] logical pixels.
  const new({
    required this.page,
    required this.path,
    required this.size,
    required this.sourceWidth,
    required this.regions,
    required this.errorLabel,
    super.key,
  });

  /// Page number.
  final int page;

  /// Absolute path of the page image.
  final String path;

  /// Size on screen.
  final Size size;

  /// Width of the source image in pixels.
  final int sourceWidth;

  /// Highlight areas on this page and their colours.
  final List<(HighlightRegion, HighlightColor)> regions;

  /// Shown when the file cannot be decoded.
  final String errorLabel;

  /// The decode width for [logicalWidth] at [pixelRatio].
  static int decodeWidth(double logicalWidth, double pixelRatio, int source) {
    final physical = (logicalWidth * pixelRatio / 256).ceil() * 256;
    return math.max(256, math.min(physical, source));
  }

  @override
  Widget build(BuildContext context) {
    final width = decodeWidth(
      size.width,
      MediaQuery.devicePixelRatioOf(context),
      sourceWidth,
    );
    return Stack(
      fit: StackFit.expand,
      children: [
        Image(
          image: ResizeImage(FileImage(File(path)), width: width),
          fit: BoxFit.fill,
          gaplessPlayback: true,
          excludeFromSemantics: true,
          errorBuilder: (context, error, stack) => ColoredBox(
            color: Theme.of(context).colorScheme.surface,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(errorLabel, textAlign: TextAlign.center),
              ),
            ),
          ),
        ),
        if (regions.isNotEmpty)
          IgnorePointer(
            child: CustomPaint(painter: HighlightPainter(regions)),
          ),
      ],
    );
  }
}

/// Paints highlight areas in page-relative coordinates, so they stay on
/// their content at every zoom, size and orientation.
final class HighlightPainter extends CustomPainter {
  /// The painter of [regions].
  const new(this.regions);

  /// Areas and colours.
  final List<(HighlightRegion, HighlightColor)> regions;

  /// The translucent colour of [color].
  static Color colorOf(HighlightColor color) => switch (color) {
    HighlightColor.yellow => const Color(0x8CFFE45C),
    HighlightColor.green => const Color(0x8095DE95),
    HighlightColor.blue => const Color(0x8094C6F2),
    HighlightColor.pink => const Color(0x80F4A6C6),
    HighlightColor.orange => const Color(0x80FFC078),
  };

  @override
  void paint(Canvas canvas, Size size) {
    for (final (r, color) in regions) {
      canvas.drawRect(
        Rect.fromLTRB(
          r.left * size.width,
          r.top * size.height,
          r.right * size.width,
          r.bottom * size.height,
        ),
        Paint()
          ..color = colorOf(color)
          ..blendMode = BlendMode.multiply,
      );
    }
  }

  @override
  bool shouldRepaint(HighlightPainter old) => old.regions != regions;
}
