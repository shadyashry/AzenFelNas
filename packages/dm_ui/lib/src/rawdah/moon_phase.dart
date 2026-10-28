import 'dart:math' as math;

import 'package:dm_ui/src/tokens/rawdah_palette.dart';
import 'package:flutter/widgets.dart';

/// The Moon as it looks on Hijri day [hijriDay] (1–30) (§15 D89): a mean
/// synodic month of 29.53 days, waxing lit on the right, waning on the
/// left (the view from the northern hemisphere, where the launch audience
/// lives). Decorative: the Hijri date beside it carries the meaning.
final class MoonPhaseGlyph extends StatelessWidget {
  /// The glyph for [hijriDay], [size] logical pixels across.
  const new({required this.hijriDay, this.size = 16, super.key});

  /// Day of the Hijri month, 1–30.
  final int hijriDay;

  /// Diameter.
  final double size;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: CustomPaint(
      size: Size.square(size),
      painter: _MoonPainter(hijriDay),
    ),
  );
}

final class _MoonPainter extends CustomPainter {
  const new(this.day);

  final int day;

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width / 2 - 0.5;
    final c = size.center(Offset.zero);
    canvas.drawCircle(
      c,
      r,
      Paint()..color = RawdahPalette.emeraldDeep.withValues(alpha: 0.85),
    );
    final age = ((day - 1).clamp(0, 29) + 0.5) / 29.53;
    final waxing = age < 0.5;
    final terminator = math.cos(2 * math.pi * age);
    final lit = Path();
    const steps = 24;
    for (var k = 0; k <= steps; k++) {
      final y = -r + 2 * r * k / steps;
      final edge = math.sqrt(math.max(0, r * r - y * y));
      final x = waxing ? edge : -edge;
      final point = c + Offset(x, y);
      if (k == 0) {
        lit.moveTo(point.dx, point.dy);
      } else {
        lit.lineTo(point.dx, point.dy);
      }
    }
    for (var k = steps; k >= 0; k--) {
      final y = -r + 2 * r * k / steps;
      final edge = math.sqrt(math.max(0, r * r - y * y));
      final x = (waxing ? 1 : -1) * terminator * edge;
      lit.lineTo(c.dx + x, c.dy + y);
    }
    canvas.drawPath(lit..close(), Paint()..color = const Color(0xFFF6E7B3));
  }

  @override
  bool shouldRepaint(_MoonPainter old) => old.day != day;
}
