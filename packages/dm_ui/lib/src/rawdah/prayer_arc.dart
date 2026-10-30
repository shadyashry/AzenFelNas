import 'dart:math' as math;

import 'package:dm_ui/src/tokens/rawdah_palette.dart';
import 'package:flutter/widgets.dart';

/// The day's five prayers as a thin gold timeline arc (§15 D105): evenly
/// spaced markers from Fajr at the reading start to Isha at the end, the
/// passed part of the line in solid gold and the rest faint. The next
/// prayer's marker is larger, filled light gold and ringed, and its label
/// bold; passed markers are filled, later ones hollow, so the state does
/// not rest on colour alone. It is a prayer timeline, not the Sun's path.
///
/// Decorative to assistive technology: the next prayer and the schedule
/// carry the same facts as text (REQ-UX-020). Labels never overlap: each
/// is fitted to its share of the width.
final class PrayerArc extends StatelessWidget {
  /// The arc of [labels] with [next] ringed and [progress] passed.
  const new({
    required this.labels,
    required this.next,
    required this.progress,
    required this.labelStyle,
    super.key,
  }) : assert(labels.length >= 2, 'an arc needs two prayers');

  /// The prayers' names in day order.
  final List<String> labels;

  /// The index in [labels] of the next prayer; `null` rings none.
  final int? next;

  /// How far along the line the day is, 0 at the first marker and 1 at the
  /// last; markers at or before it are passed.
  final double progress;

  /// Style of the labels; the next one is drawn bold in light gold.
  final TextStyle labelStyle;

  /// Height for a width, so the arc reads the same on every screen.
  static const double aspect = 3.6;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: LayoutBuilder(
      builder: (context, box) {
        // The labels sit under the line; leave room for two lines of them
        // at the reader's text size.
        final scale = MediaQuery.textScalerOf(context).scale(1);
        final labelRoom = (labelStyle.fontSize ?? 12) * 1.4 * scale + 6;
        return SizedBox(
          height: box.maxWidth / aspect + labelRoom,
          width: box.maxWidth,
          child: CustomPaint(
            painter: _ArcPainter(
              labels: labels,
              next: next,
              progress: progress.clamp(0.0, 1.0),
              labelStyle: labelStyle,
              textScaler: MediaQuery.textScalerOf(context),
              rtl: Directionality.of(context) == TextDirection.rtl,
            ),
          ),
        );
      },
    ),
  );
}

final class _ArcPainter extends CustomPainter {
  const new({
    required this.labels,
    required this.next,
    required this.progress,
    required this.labelStyle,
    required this.textScaler,
    required this.rtl,
  });

  final List<String> labels;
  final int? next;
  final double progress;
  final TextStyle labelStyle;
  final TextScaler textScaler;
  final bool rtl;

  @override
  void paint(Canvas canvas, Size size) {
    // A circular arc through both ends and the apex, filling the box:
    // the apex 12 below the top (room for the ringed marker), the ends
    // [PrayerArc.aspect] of the width lower.
    final inset = size.width * 0.06;
    final halfChord = size.width / 2 - inset;
    final rise = size.width / PrayerArc.aspect - 12;
    final radius = (halfChord * halfChord + rise * rise) / (2 * rise);
    final centre = Offset(size.width / 2, 12 + radius);
    final half = math.asin(halfChord / radius);
    Offset at(double t) {
      // t = 0 at the reading start, 1 at the end.
      final f = rtl ? 1 - t : t;
      final angle = -math.pi / 2 - half + 2 * half * f;
      return centre + Offset(math.cos(angle), math.sin(angle)) * radius;
    }

    Path path(double from, double to) {
      final p = Path();
      const steps = 64;
      for (var i = 0; i <= steps; i++) {
        final point = at(from + (to - from) * i / steps);
        i == 0 ? p.moveTo(point.dx, point.dy) : p.lineTo(point.dx, point.dy);
      }
      return p;
    }

    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(
      path(0, 1),
      line
        ..strokeWidth = 1.2
        ..color = RawdahPalette.gold.withValues(alpha: 0.45),
    );
    if (progress > 0) {
      canvas.drawPath(
        path(0, progress),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 2
          ..color = RawdahPalette.gold,
      );
    }

    final n = labels.length;
    final share = size.width / n;
    for (var i = 0; i < n; i++) {
      final t = i / (n - 1);
      final point = at(t);
      final isNext = i == next;
      final passed = !isNext && t <= progress + 1e-9;
      if (isNext) {
        canvas
          ..drawCircle(
            point,
            11,
            Paint()..color = RawdahPalette.goldLight.withValues(alpha: 0.18),
          )
          ..drawCircle(point, 8, Paint()..color = RawdahPalette.goldLight)
          ..drawCircle(
            point,
            8,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.5
              ..color = RawdahPalette.ivory,
          );
      } else {
        canvas
          ..drawCircle(
            point,
            5,
            Paint()
              ..color = passed
                  ? RawdahPalette.gold
                  : RawdahPalette.emeraldDeep.withValues(alpha: 0.7),
          )
          ..drawCircle(
            point,
            5,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.2
              ..color = RawdahPalette.gold,
          );
      }
      final painter = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: isNext
              ? labelStyle.copyWith(
                  color: RawdahPalette.goldLight,
                  fontWeight: FontWeight.w700,
                )
              : labelStyle,
        ),
        textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
        textScaler: textScaler,
        maxLines: 1,
      )..layout();
      // Fitted to its share of the width, so labels never overlap.
      if (painter.width > share - 4) {
        painter
          ..textScaler = TextScaler.linear(
            textScaler.scale(1) * (share - 4) / painter.width,
          )
          ..layout();
      }
      final x = (point.dx - painter.width / 2).clamp(
        0.0,
        size.width - painter.width,
      );
      painter
        ..paint(canvas, Offset(x, point.dy + (isNext ? 13 : 9)))
        ..dispose();
    }
  }

  @override
  bool shouldRepaint(_ArcPainter old) =>
      old.next != next ||
      old.progress != progress ||
      old.rtl != rtl ||
      old.labelStyle != labelStyle ||
      old.textScaler != textScaler ||
      !_same(old.labels, labels);

  static bool _same(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
