import 'dart:math' as math;

import 'package:dm_ui/src/rawdah/athan_ring.dart';
import 'package:dm_ui/src/rawdah/ornament_paths.dart';
import 'package:dm_ui/src/rawdah/rawdah_glyph_kind.dart';
import 'package:dm_ui/src/tokens/rawdah_palette.dart';
import 'package:flutter/widgets.dart';

/// One of the authored Rawdah glyphs (§15 D89), drawn on a 26 × 26 grid in
/// one stroke weight and scaled to [size]: the navigation bar's icons and
/// the emblems of the Athan medallion and onboarding. Decorative: callers
/// put the meaning in a label.
final class RawdahGlyph extends StatelessWidget {
  /// [kind] in [color], [size] logical pixels square.
  const new({
    required this.kind,
    required this.color,
    this.size = 26,
    this.qiblaBearingDeg,
    this.athanRing,
    super.key,
  });

  /// Which glyph.
  final RawdahGlyphKind kind;

  /// Stroke colour.
  final Color color;

  /// Side, logical pixels.
  final double size;

  /// The star compass needle's bearing from true north; `null` draws the
  /// star alone.
  final double? qiblaBearingDeg;

  /// The minaret's Athan ring; `null` draws none.
  final AthanRing? athanRing;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _GlyphPainter(
          kind: kind,
          color: color,
          qiblaBearingDeg: qiblaBearingDeg,
          athanRing: athanRing,
        ),
      ),
    ),
  );
}

final class _GlyphPainter extends CustomPainter {
  const new({
    required this.kind,
    required this.color,
    required this.qiblaBearingDeg,
    required this.athanRing,
  });

  final RawdahGlyphKind kind;
  final Color color;
  final double? qiblaBearingDeg;
  final AthanRing? athanRing;

  @override
  void paint(Canvas canvas, Size size) {
    canvas
      ..save()
      ..scale(size.width / 26);
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round
      ..color = color;
    switch (kind) {
      case RawdahGlyphKind.mihrab:
        _mihrab(canvas, stroke);
      case RawdahGlyphKind.starCompass:
        _compass(canvas, stroke);
      case RawdahGlyphKind.minaret:
        _minaret(canvas, stroke);
      case RawdahGlyphKind.rosette:
        _rosette(canvas, stroke);
      case RawdahGlyphKind.mushaf:
        _mushaf(canvas, stroke);
    }
    canvas.restore();
  }

  void _mihrab(Canvas canvas, Paint stroke) {
    canvas
      ..drawPath(
        Path()
          ..moveTo(5, 24)
          ..lineTo(5, 12)
          ..cubicTo(5, 7.5, 9, 4.4, 13, 2.4)
          ..cubicTo(17, 4.4, 21, 7.5, 21, 12)
          ..lineTo(21, 24),
        stroke,
      )
      ..drawLine(const Offset(13, 8.5), const Offset(13, 11.7), stroke)
      ..drawPath(
        Path()
          ..moveTo(11, 11.7)
          ..lineTo(15, 11.7)
          ..lineTo(14.2, 14.7)
          ..lineTo(11.8, 14.7)
          ..close(),
        Paint()..color = color,
      );
  }

  void _compass(Canvas canvas, Paint stroke) {
    const c = Offset(13, 13);
    canvas.drawPath(OrnamentPaths.girihTile(c, 6.5), stroke..strokeWidth = 1.4);
    final bearingDeg = qiblaBearingDeg;
    if (bearingDeg == null) {
      // No place yet: the star alone, never a needle pointing nowhere.
      canvas.drawCircle(c, 1.4, Paint()..color = color);
      return;
    }
    final bearing = bearingDeg * math.pi / 180;
    final tip = c + Offset(math.sin(bearing), -math.cos(bearing)) * 9.5;
    canvas
      ..drawLine(
        c,
        tip,
        Paint()
          ..color = const Color(0xFFE9C46A)
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round,
      )
      ..drawRect(
        Rect.fromCenter(center: tip, width: 3, height: 3),
        Paint()..color = const Color(0xFFE9C46A),
      )
      ..drawCircle(c, 1.4, Paint()..color = color);
  }

  void _minaret(Canvas canvas, Paint stroke) {
    canvas
      ..drawPath(
        Path()
          ..moveTo(9.5, 23)
          ..lineTo(9.5, 10.5)
          ..lineTo(16.5, 10.5)
          ..lineTo(16.5, 23),
        stroke,
      )
      ..drawLine(const Offset(8, 10.5), const Offset(18, 10.5), stroke)
      ..drawLine(const Offset(9.5, 15), const Offset(16.5, 15), stroke)
      ..drawPath(
        Path()
          ..moveTo(10.5, 10.5)
          ..cubicTo(10.5, 7, 11.7, 5.6, 13, 4.2)
          ..cubicTo(14.3, 5.6, 15.5, 7, 15.5, 10.5),
        stroke,
      )
      ..drawLine(const Offset(13, 4.2), const Offset(13, 2), stroke);
    const ring = Offset(21.5, 4.5);
    switch (athanRing) {
      case null:
        break;
      case AthanRing.unknown:
        canvas.drawCircle(
          ring,
          2.6,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.4
            ..color = RawdahPalette.gold,
        );
      case AthanRing.ready:
        canvas.drawCircle(ring, 3, Paint()..color = RawdahPalette.goldLight);
      case AthanRing.attention:
        canvas.drawCircle(ring, 3, Paint()..color = const Color(0xFFE07A6A));
    }
  }

  void _rosette(Canvas canvas, Paint stroke) {
    canvas
      ..drawPath(OrnamentPaths.star(const Offset(13, 13), 10.5), stroke)
      ..drawCircle(const Offset(13, 13), 2.8, stroke);
  }

  /// An open Mushaf on a rahl (folding stand), §15 D106.
  void _mushaf(Canvas canvas, Paint stroke) {
    for (final side in const [-1.0, 1.0]) {
      canvas.drawPath(
        Path()
          ..moveTo(13, 8)
          ..quadraticBezierTo(13 + side * 5, 5.5, 13 + side * 9.5, 6.5)
          ..lineTo(13 + side * 9.5, 16.5)
          ..quadraticBezierTo(13 + side * 5, 15.5, 13, 18)
          ..close(),
        stroke,
      );
    }
    canvas
      ..drawLine(const Offset(13, 8), const Offset(13, 18), stroke)
      ..drawLine(const Offset(8, 24), const Offset(17, 19), stroke)
      ..drawLine(const Offset(18, 24), const Offset(9, 19), stroke);
  }

  @override
  bool shouldRepaint(_GlyphPainter old) =>
      old.kind != kind ||
      old.color != color ||
      old.qiblaBearingDeg != qiblaBearingDeg ||
      old.athanRing != athanRing;
}
