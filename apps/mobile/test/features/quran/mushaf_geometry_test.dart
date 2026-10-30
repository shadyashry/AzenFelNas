import 'dart:ui';

import 'package:daily_muslim/features/quran/domain/reader_preferences.dart';
import 'package:daily_muslim/features/quran/presentation/mushaf_geometry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // The 1441 page images: 1400 × 2002.
  const aspect = 1400 / 2002;

  MushafGeometry g(Size viewport, PageFit fit) =>
      MushafGeometry(viewport: viewport, aspect: aspect, fit: fit);

  test('REQ-QRN-030: fit page shows the whole page, aspect kept, centred', () {
    for (final viewport in const [
      Size(411, 640),
      Size(360, 520),
      Size(914, 380),
      Size(800, 1200),
    ]) {
      final geometry = g(viewport, PageFit.page);
      final size = geometry.baseSize;
      final offset = geometry.baseOffset;

      expect(size.width, lessThanOrEqualTo(viewport.width + 1e-9));
      expect(size.height, lessThanOrEqualTo(viewport.height + 1e-9));
      expect(size.width / size.height, closeTo(aspect, 1e-9));
      expect(offset.dx * 2 + size.width, closeTo(viewport.width, 1e-9));
      expect(offset.dy * 2 + size.height, closeTo(viewport.height, 1e-9));
    }
  });

  test('REQ-QRN-030: fit width fills the width and starts at the top', () {
    final geometry = g(const Size(914, 380), PageFit.width);

    expect(geometry.baseSize.width, 914);
    expect(
      geometry.baseSize.width / geometry.baseSize.height,
      closeTo(aspect, 1e-9),
    );
    expect(geometry.baseOffset, Offset.zero);
  });

  test('REQ-QRN-030: a zoomed page pans to its edges and no further', () {
    final geometry = g(const Size(400, 600), PageFit.page);
    final size = geometry.baseSize * 2;

    final far = geometry.clampOffset(const Offset(5000, 5000), 2);
    final near = geometry.clampOffset(const Offset(-5000, -5000), 2);

    expect(far, Offset.zero);
    expect(near.dx, closeTo(400 - size.width, 1e-9));
    expect(near.dy, closeTo(600 - size.height, 1e-9));
  });

  test('REQ-QRN-030: zooming keeps the point under the fingers in place', () {
    final geometry = g(const Size(400, 600), PageFit.page);
    const focal = Offset(200, 300);
    final from = geometry.baseOffset;

    final to = geometry.zoomAround(focal, from, 1, 2);

    final before = geometry.relative(focal, from, 1);
    final after = geometry.relative(focal, to, 2);
    expect(after.dx, closeTo(before.dx, 1e-9));
    expect(after.dy, closeTo(before.dy, 1e-9));
  });

  test('REQ-QRN-032: a horizontal drag turns pages only when the page is no '
      'wider than the window', () {
    final geometry = g(const Size(400, 600), PageFit.page);

    expect(geometry.turnsPages(1), isTrue);
    expect(geometry.turnsPages(2), isFalse);
    expect(MushafGeometry.clampScale(9), MushafGeometry.maxScale);
    expect(MushafGeometry.clampScale(0.5), 1);
  });

  test('REQ-QRN-051: a page point keeps its place at every size', () {
    const point = Offset(0.25, 0.75);
    for (final viewport in const [Size(411, 640), Size(914, 380)]) {
      final geometry = g(viewport, PageFit.page);
      final offset = geometry.baseOffset;
      final size = geometry.baseSize;
      final screen =
          offset + Offset(size.width * point.dx, size.height * point.dy);

      final back = geometry.relative(screen, offset, 1);

      expect(back.dx, closeTo(point.dx, 1e-9));
      expect(back.dy, closeTo(point.dy, 1e-9));
    }
  });
}
