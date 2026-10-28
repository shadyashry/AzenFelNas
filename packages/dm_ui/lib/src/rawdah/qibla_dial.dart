import 'dart:math' as math;

import 'package:dm_ui/src/rawdah/ornament_paths.dart';
import 'package:dm_ui/src/theme/dm_theme.dart';
import 'package:dm_ui/src/tokens/rawdah_palette.dart';
import 'package:flutter/widgets.dart';

/// The Qibla as an eight-point star compass (§6.6, §15 D89): a gilded
/// ring with degree ticks and the four cardinal letters, a star rosette at
/// the centre, and a gold needle to the Kaaba at [bearingDeg] from true
/// north.
///
/// With [headingDeg] (a trustworthy compass) the dial turns so its north
/// is real, a lamp at the top marks where the phone points, and the needle
/// glows when [aligned]. Without it the dial is a north-up map. Decorative
/// to assistive technology: the page states the bearing and the turn as
/// text (REQ-UX-020).
final class QiblaDial extends StatelessWidget {
  /// The dial for [bearingDeg]; [cardinals] are N, E, S, W in the locale.
  const new({
    required this.bearingDeg,
    required this.cardinals,
    this.headingDeg,
    this.aligned = false,
    super.key,
  });

  /// The Qibla bearing from true north, degrees.
  final double bearingDeg;

  /// The phone's true heading, degrees; `null` for a north-up map.
  final double? headingDeg;

  /// Whether the phone faces the Qibla.
  final bool aligned;

  /// Localised N, E, S, W.
  final (String, String, String, String) cardinals;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: AspectRatio(
      aspectRatio: 1,
      child: CustomPaint(
        painter: _DialPainter(
          bearingDeg: bearingDeg,
          headingDeg: headingDeg,
          aligned: aligned,
          cardinals: cardinals,
        ),
      ),
    ),
  );
}

final class _DialPainter extends CustomPainter {
  const new({
    required this.bearingDeg,
    required this.headingDeg,
    required this.aligned,
    required this.cardinals,
  });

  final double bearingDeg;
  final double? headingDeg;
  final bool aligned;
  final (String, String, String, String) cardinals;

  static double _rad(double deg) => deg * math.pi / 180;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide / 2 - 14;
    final ring = Rect.fromCircle(center: c, radius: r);
    canvas
      ..drawCircle(
        c,
        r,
        Paint()..color = RawdahPalette.emerald.withValues(alpha: 0.06),
      )
      ..drawCircle(
        c,
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4
          ..shader = RawdahPalette.gilded.createShader(ring),
      )
      ..drawCircle(
        c,
        r - 9,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8
          ..color = RawdahPalette.gold,
      )
      ..save()
      ..translate(c.dx, c.dy)
      ..rotate(-_rad(headingDeg ?? 0));
    _ticks(canvas, r);
    _cardinals(canvas, r);
    _rosette(canvas, r);
    _needle(canvas, r);
    canvas.restore();
    if (headingDeg != null) _lamp(canvas, c, r);
  }

  void _ticks(Canvas canvas, double r) {
    final minor = Paint()
      ..color = RawdahPalette.goldDeep.withValues(alpha: 0.55)
      ..strokeWidth = 1;
    final major = Paint()
      ..color = RawdahPalette.goldDeep
      ..strokeWidth = 1.6;
    for (var deg = 0; deg < 360; deg += 5) {
      final a = _rad(deg.toDouble());
      final dir = Offset(math.sin(a), -math.cos(a));
      final long = deg % 45 == 0;
      canvas.drawLine(
        dir * (r - 10),
        dir * (r - (long ? 22 : 16)),
        long ? major : minor,
      );
    }
  }

  void _cardinals(Canvas canvas, double r) {
    final (n, e, s, w) = cardinals;
    for (final (label, deg) in [(n, 0.0), (e, 90.0), (s, 180.0), (w, 270.0)]) {
      final a = _rad(deg);
      final at = Offset(math.sin(a), -math.cos(a)) * (r - 36);
      final text = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(
            fontFamily: DmTheme.naskhFamily,
            fontSize: 17,
            fontWeight: deg == 0 ? FontWeight.w700 : FontWeight.w400,
            color: deg == 0 ? RawdahPalette.carpetRed : RawdahPalette.emerald,
          ),
        ),
        textDirection: TextDirection.rtl,
      )..layout();
      canvas
        ..save()
        ..translate(at.dx, at.dy)
        ..rotate(_rad(headingDeg ?? 0));
      text.paint(canvas, Offset(-text.width / 2, -text.height / 2));
      canvas.restore();
    }
  }

  void _rosette(Canvas canvas, double r) {
    final star = OrnamentPaths.star(Offset.zero, r * 0.46, innerRatio: 0.7);
    canvas
      ..drawPath(
        star,
        Paint()..color = RawdahPalette.emerald.withValues(alpha: 0.08),
      )
      ..drawPath(
        star,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.1
          ..color = RawdahPalette.gold,
      )
      ..drawPath(
        OrnamentPaths.girihTile(Offset.zero, r * 0.2),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8
          ..color = RawdahPalette.gold.withValues(alpha: 0.7),
      );
  }

  void _needle(Canvas canvas, double r) {
    final a = _rad(bearingDeg);
    final dir = Offset(math.sin(a), -math.cos(a));
    final tip = dir * (r - 30);
    if (aligned) {
      canvas.drawCircle(
        tip,
        26,
        Paint()
          ..color = RawdahPalette.goldLight.withValues(alpha: 0.55)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
      );
    }
    canvas
      ..drawLine(
        Offset.zero,
        tip,
        Paint()
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.round
          ..shader = const LinearGradient(
            colors: [RawdahPalette.goldDeep, RawdahPalette.goldLight],
          ).createShader(Rect.fromPoints(Offset.zero, tip)),
      )
      ..drawCircle(Offset.zero, 7, Paint()..color = RawdahPalette.emerald)
      ..drawCircle(Offset.zero, 3, Paint()..color = RawdahPalette.goldLight)
      ..save()
      ..translate(tip.dx, tip.dy)
      ..rotate(a);
    // The Kaaba: a dark cube with its gold band.
    const half = 11.0;
    canvas
      ..drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTRB(-half, -half, half, half),
          const Radius.circular(2),
        ),
        Paint()..color = const Color(0xFF151513),
      )
      ..drawRect(
        const Rect.fromLTRB(-half, -half * 0.45, half, -half * 0.18),
        Paint()..color = RawdahPalette.goldLight,
      )
      ..restore();
  }

  void _lamp(Canvas canvas, Offset c, double r) {
    final top = c + Offset(0, -r - 2);
    canvas.drawPath(
      Path()
        ..moveTo(top.dx, top.dy + 12)
        ..lineTo(top.dx - 8, top.dy - 4)
        ..lineTo(top.dx + 8, top.dy - 4)
        ..close(),
      Paint()
        ..color = aligned ? RawdahPalette.goldLight : RawdahPalette.emerald,
    );
  }

  @override
  bool shouldRepaint(_DialPainter old) =>
      old.bearingDeg != bearingDeg ||
      old.headingDeg != headingDeg ||
      old.aligned != aligned ||
      old.cardinals != cardinals;
}
