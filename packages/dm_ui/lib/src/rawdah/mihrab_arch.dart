import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:dm_ui/src/rawdah/arch_mark.dart';
import 'package:dm_ui/src/rawdah/arch_position.dart';
import 'package:dm_ui/src/rawdah/ornament_paths.dart';
import 'package:dm_ui/src/tokens/hour_light.dart';
import 'package:dm_ui/src/tokens/rawdah_palette.dart';
import 'package:flutter/widgets.dart';

/// The day drawn as a mihrab (§15 D89): the Sun's path from sunrise to
/// sunset is a pointed arch, the passed part gilded and the rest dotted,
/// with every prayer at its real instant and a glowing Sun at now. The
/// niche inside is left for the next prayer. Sunrise is on the reading
/// start side, so the arch mirrors with the text direction (REQ-UX-030).
///
/// Decorative to assistive technology: the prayer list below carries the
/// same times as text (REQ-UX-020).
final class MihrabArch extends StatelessWidget {
  /// The arch for [marks] with the Sun at [sun], in [light].
  const new({
    required this.marks,
    required this.sun,
    required this.light,
    required this.labelStyle,
    super.key,
  });

  /// The prayers.
  final List<ArchMark> marks;

  /// The Sun now.
  final ArchPosition sun;

  /// The hour light (glow colour).
  final HourLight light;

  /// Style of the prayer labels; the next one is drawn bolder in gold.
  final TextStyle labelStyle;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: AspectRatio(
      aspectRatio: 330 / 240,
      child: CustomPaint(
        painter: _ArchPainter(
          marks: marks,
          sun: sun,
          light: light,
          labelStyle: labelStyle,
          rtl: Directionality.of(context) == TextDirection.rtl,
        ),
      ),
    ),
  );
}

final class _ArchPainter extends CustomPainter {
  const new({
    required this.marks,
    required this.sun,
    required this.light,
    required this.labelStyle,
    required this.rtl,
  });

  final List<ArchMark> marks;
  final ArchPosition sun;
  final HourLight light;
  final TextStyle labelStyle;
  final bool rtl;

  static const double _w = 330;
  static const double _base = 196;

  @override
  void paint(Canvas canvas, Size size) {
    canvas
      ..save()
      ..scale(size.width / _w);
    final curve = _ArchCurve.build(rtl: rtl);
    canvas.drawLine(
      const Offset(0, _base),
      const Offset(_w, _base),
      Paint()
        ..color = RawdahPalette.goldLight.withValues(alpha: 0.35)
        ..strokeWidth = 1,
    );
    _dotted(canvas, curve);
    final sunFraction = switch (sun) {
      OnArch(:final fraction) => fraction.clamp(0.0, 1.0),
      BeforeSunrise() => null,
      AfterSunset() => 1.0,
    };
    if (sunFraction != null && sunFraction > 0) {
      canvas.drawPath(
        curve.path(0, sunFraction),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.6
          ..strokeCap = StrokeCap.round
          ..shader = RawdahPalette.gilded.createShader(
            const Rect.fromLTWH(0, 0, _w, _base),
          ),
      );
    }
    for (final mark in marks) {
      _mark(canvas, curve, mark);
    }
    _sun(canvas, curve);
    canvas.restore();
  }

  void _dotted(Canvas canvas, _ArchCurve curve) {
    final dot = Paint()
      ..color = RawdahPalette.goldLight.withValues(alpha: 0.32);
    for (var f = 0.0; f <= 1.0; f += 0.018) {
      canvas.drawCircle(curve.at(f), 0.9, dot);
    }
  }

  Offset _point(_ArchCurve curve, ArchPosition position) => switch (position) {
    OnArch(:final fraction) => curve.at(fraction.clamp(0.0, 1.0)),
    BeforeSunrise() => Offset(rtl ? 318 : 12, _base),
    AfterSunset() => Offset(rtl ? 12 : 318, _base),
  };

  void _mark(Canvas canvas, _ArchCurve curve, ArchMark mark) {
    final p = _point(curve, mark.position);
    final half = mark.isNext ? 5.2 : 3.6;
    canvas
      ..drawPath(
        OrnamentPaths.diamond(p, half * 1.35),
        Paint()
          ..color = mark.isNext
              ? const Color(0xFFF6E7B3)
              : const Color(0xFFC9A65A),
      )
      ..drawPath(
        OrnamentPaths.diamond(p, half * 1.35),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8
          ..color = RawdahPalette.emeraldDeep,
      );
    final style = mark.isNext
        ? labelStyle.copyWith(
            color: const Color(0xFFF6E7B3),
            fontWeight: FontWeight.w600,
          )
        : labelStyle;
    final text = TextPainter(
      text: TextSpan(text: mark.label, style: style),
      textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
    )..layout();
    final onGround = p.dy >= _base - 1;
    final atApex = (p.dx - _w / 2).abs() < 8 && !onGround;
    final Offset origin;
    if (onGround) {
      // Sunrise and sunset label just under the line; Fajr and Isha, which
      // stand beside them on the ground, one step lower so they never touch.
      final offArch = mark.position is! OnArch;
      origin = Offset(p.dx - text.width / 2, p.dy + (offArch ? 22 : 8));
    } else if (atApex) {
      origin = Offset(p.dx - text.width / 2, p.dy - text.height - 6);
    } else {
      final outward = p.dx > _w / 2 ? 1 : -1;
      origin = Offset(
        outward > 0 ? p.dx + 9 : p.dx - 9 - text.width,
        p.dy - text.height - 2,
      );
    }
    text.paint(canvas, origin);
  }

  void _sun(Canvas canvas, _ArchCurve curve) {
    final p = switch (sun) {
      OnArch(:final fraction) => curve.at(fraction.clamp(0.0, 1.0)),
      BeforeSunrise() => Offset(rtl ? 304 : 26, _base),
      AfterSunset() => Offset(rtl ? 26 : 304, _base),
    };
    canvas
      ..drawCircle(
        p,
        16,
        Paint()
          ..shader = ui.Gradient.radial(p, 16, [
            light.glow.withValues(alpha: 0.9),
            light.glow.withValues(alpha: 0),
          ]),
      )
      ..drawCircle(
        p,
        5.5,
        Paint()
          ..color = Color.alphaBlend(
            const Color(0x66FFFFFF),
            light.glow,
          ),
      );
  }

  @override
  bool shouldRepaint(_ArchPainter old) =>
      old.marks != marks ||
      old.sun != sun ||
      old.light != light ||
      old.rtl != rtl ||
      old.labelStyle != labelStyle;
}

/// The arch as a polyline sampled by arc length.
final class _ArchCurve {
  /// Sunrise base, two cubic halves through the apex, sunset base.
  factory build({required bool rtl}) {
    const right = [
      Offset(290, 196),
      Offset(290, 96),
      Offset(226, 46),
      Offset(165, 26),
    ];
    const left = [
      Offset(165, 26),
      Offset(104, 46),
      Offset(40, 96),
      Offset(40, 196),
    ];
    final points = <Offset>[
      for (var i = 0; i <= 120; i++) _cubic(right, i / 120),
      for (var i = 1; i <= 120; i++) _cubic(left, i / 120),
    ];
    final ordered = rtl
        ? points
        : [for (final p in points) Offset(330 - p.dx, p.dy)];
    final lengths = <double>[0];
    for (var i = 1; i < ordered.length; i++) {
      lengths.add(lengths.last + (ordered[i] - ordered[i - 1]).distance);
    }
    return _ArchCurve._(ordered, lengths);
  }

  const new _(this._points, this._lengths);

  static Offset _cubic(List<Offset> c, double t) {
    final u = 1 - t;
    return c[0] * (u * u * u) +
        c[1] * (3 * u * u * t) +
        c[2] * (3 * u * t * t) +
        c[3] * (t * t * t);
  }

  final List<Offset> _points;
  final List<double> _lengths;

  /// The point [fraction] of the way along the arch.
  Offset at(double fraction) {
    final target = fraction * _lengths.last;
    for (var i = 1; i < _lengths.length; i++) {
      if (_lengths[i] >= target) {
        final span = _lengths[i] - _lengths[i - 1];
        final k = span == 0 ? 0.0 : (target - _lengths[i - 1]) / span;
        return _points[i - 1] + (_points[i] - _points[i - 1]) * k;
      }
    }
    return _points.last;
  }

  /// The part of the arch from [from] to [to].
  Path path(double from, double to) {
    final path = Path();
    final n = math.max(2, ((to - from) * 160).round());
    for (var i = 0; i <= n; i++) {
      final p = at(from + (to - from) * i / n);
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    return path;
  }
}
