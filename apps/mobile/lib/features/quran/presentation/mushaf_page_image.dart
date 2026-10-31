import 'dart:io';
import 'dart:math' as math;

import 'package:daily_muslim/features/quran/domain/highlight.dart';
import 'package:daily_muslim/features/quran/domain/highlight_color.dart';
import 'package:daily_muslim/features/quran/domain/page_box.dart';
import 'package:flutter/material.dart';

/// One official Mushaf page (§15 D107, D123, REQ-QRN-031).
///
/// A frameless package holds each page as grey artwork cut to its content
/// ([box]): the reader draws its ink in [ink], the theme's lettering colour,
/// on the reading surface. Every letter and mark keeps its place and its
/// relative weight; nothing is redrawn, inverted or recoloured mark by
/// mark, and lighter source tones (verse markers, heading bands) stay
/// lighter. Saved highlights lie behind the ink, so they never cover a
/// diacritic; the outline of a verse just opened ([marks], §15 D114) is a
/// thin gold frame over it. With [ink] `null` (a package of whole pages)
/// the image is shown exactly as published, highlights multiplied over it.
///
/// Highlights and marks are stored in whole-page fractions; they are drawn
/// through [box], so they stay on their content at every zoom, size and
/// orientation. The image is decoded no larger than shown (256 px steps,
/// never above the source), so a small phone never holds a full-size
/// bitmap and zooming in decodes more detail.
final class MushafPageImage extends StatelessWidget {
  /// Page [page] from [path], shown at [size] logical pixels.
  const new({
    required this.page,
    required this.path,
    required this.size,
    required this.box,
    required this.regions,
    required this.errorLabel,
    this.ink,
    this.night = false,
    this.marks = const [],
    super.key,
  });

  /// Page number.
  final int page;

  /// Absolute path of the page image.
  final String path;

  /// Size on screen.
  final Size size;

  /// The part of the page the image holds.
  final PageBox box;

  /// The lettering colour; `null` to show the image as published.
  final Color? ink;

  /// Whether the reading surface is dark, for the highlight colours.
  final bool night;

  /// Highlight areas on this page (page fractions) and their colours.
  final List<(HighlightRegion, HighlightColor)> regions;

  /// Shown when the file cannot be decoded.
  final String errorLabel;

  /// Lines outlined for a moment: the verse just opened (page fractions).
  final List<HighlightRegion> marks;

  /// The decode width for [logicalWidth] at [pixelRatio].
  static int decodeWidth(double logicalWidth, double pixelRatio, int source) {
    final physical = (logicalWidth * pixelRatio / 256).ceil() * 256;
    return math.max(256, math.min(physical, source));
  }

  /// Draws grey artwork (white ground, dark ink) as [ink] whose opacity is
  /// the artwork's darkness: white becomes transparent, black full ink.
  static ColorFilter inkFilter(Color ink) => ColorFilter.matrix([
    0, 0, 0, 0, ink.r * 255, //
    0, 0, 0, 0, ink.g * 255,
    0, 0, 0, 0, ink.b * 255,
    -0.299, -0.587, -0.114, 0, 255,
  ]);

  @override
  Widget build(BuildContext context) {
    final width = decodeWidth(
      size.width,
      MediaQuery.devicePixelRatioOf(context),
      box.pixelWidth,
    );
    final tint = ink;
    final inBox = [for (final (r, c) in regions) (box.toBox(r), c)];
    Widget image = Image(
      image: ResizeImage(FileImage(File(path)), width: width),
      fit: BoxFit.fill,
      gaplessPlayback: true,
      excludeFromSemantics: true,
      errorBuilder: (context, error, stack) => Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(errorLabel, textAlign: TextAlign.center),
        ),
      ),
    );
    if (tint != null) {
      image = ColorFiltered(colorFilter: inkFilter(tint), child: image);
    }
    final highlights = inBox.isEmpty
        ? null
        : IgnorePointer(
            child: CustomPaint(
              painter: HighlightPainter(
                inBox,
                over: tint == null,
                night: night,
              ),
            ),
          );
    return ClipRect(
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (tint != null && highlights != null) highlights,
          image,
          if (tint == null && highlights != null) highlights,
          if (marks.isNotEmpty)
            IgnorePointer(
              child: CustomPaint(
                painter: MarkPainter([for (final m in marks) box.toBox(m)]),
              ),
            ),
        ],
      ),
    );
  }
}

/// Paints highlight areas given in fractions of what is drawn, so they stay
/// on their content at every zoom, size and orientation. Behind frameless
/// ink they are soft washes; [over] an opaque page they multiply, so every
/// letter and mark stays readable either way.
final class HighlightPainter extends CustomPainter {
  /// The painter of [regions].
  const new(this.regions, {this.over = true, this.night = false});

  /// Areas and colours.
  final List<(HighlightRegion, HighlightColor)> regions;

  /// Whether the areas are drawn over an opaque page (multiply).
  final bool over;

  /// Whether the reading surface is dark: the washes are fainter, so the
  /// ivory lettering keeps its contrast.
  final bool night;

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
      final base = colorOf(color);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTRB(
            r.left * size.width,
            r.top * size.height,
            r.right * size.width,
            r.bottom * size.height,
          ),
          Radius.circular(over ? 0 : 3),
        ),
        Paint()
          ..color = night ? base.withValues(alpha: 0.30) : base
          ..blendMode = over ? BlendMode.multiply : BlendMode.srcOver,
      );
    }
  }

  @override
  bool shouldRepaint(HighlightPainter old) =>
      old.regions != regions || old.over != over || old.night != night;
}

/// Outlines the lines of a verse just opened: a gold frame and the
/// faintest wash, so it reads as "here" without looking like a saved
/// highlight or a Tajweed colour. It fades away by itself.
final class MarkPainter extends CustomPainter {
  /// The painter of [marks].
  const new(this.marks);

  /// The lines to outline, in fractions of what is drawn.
  final List<HighlightRegion> marks;

  @override
  void paint(Canvas canvas, Size size) {
    for (final r in marks) {
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTRB(
          r.left * size.width,
          r.top * size.height,
          r.right * size.width,
          r.bottom * size.height,
        ),
        const Radius.circular(4),
      );
      canvas
        ..drawRRect(rect, Paint()..color = const Color(0x1FC9A45C))
        ..drawRRect(
          rect,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2
            ..color = const Color(0xFFC9A45C),
        );
    }
  }

  @override
  bool shouldRepaint(MarkPainter old) => old.marks != marks;
}
