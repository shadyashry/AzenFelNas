import 'dart:math' as math;

import 'package:dm_ui/src/rawdah/athan_ring.dart';
import 'package:dm_ui/src/rawdah/ornament_paths.dart';
import 'package:dm_ui/src/rawdah/rawdah_tab.dart';
import 'package:dm_ui/src/rawdah/rawdah_tab_labels.dart';
import 'package:dm_ui/src/tokens/dm_scales.dart';
import 'package:dm_ui/src/tokens/hour_light.dart';
import 'package:dm_ui/src/tokens/rawdah_palette.dart';
import 'package:flutter/material.dart';

/// The floating emerald navigation bar (§15 D89): a mihrab for Home, an
/// eight-point star compass whose needle points at the real Qibla, a
/// minaret with the Athan ring, a rosette for Settings. The current tab
/// stands inside a gilded mihrab lit with the hour's [light].
///
/// Every destination is a button of at least 48 dp with its label and
/// selected state in semantics (REQ-UX-020); the order follows the text
/// direction (REQ-UX-030).
final class RawdahNavBar extends StatelessWidget {
  /// The bar with [current] selected.
  const new({
    required this.current,
    required this.labels,
    required this.onSelect,
    required this.light,
    this.qiblaBearingDeg,
    this.athanRing = AthanRing.unknown,
    super.key,
  });

  /// The selected destination.
  final RawdahTab current;

  /// Localised labels.
  final RawdahTabLabels labels;

  /// Called with the tapped destination.
  final ValueChanged<RawdahTab> onSelect;

  /// The hour light of the active tab.
  final HourLight light;

  /// The Qibla bearing from true north, degrees; `null` (no place yet)
  /// draws the star without a needle.
  final double? qiblaBearingDeg;

  /// The Athan ring.
  final AthanRing athanRing;

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    minimum: const EdgeInsets.fromLTRB(12, 0, 12, 10),
    child: DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF17563C), RawdahPalette.emeraldDeep],
        ),
        border: Border.all(
          color: RawdahPalette.goldLight.withValues(alpha: 0.55),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x590E3B2A),
            offset: Offset(0, 8),
            blurRadius: 24,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Row(
          children: [
            for (final tab in RawdahTab.values)
              Expanded(
                child: _Destination(
                  tab: tab,
                  label: labels.of(tab),
                  selected: tab == current,
                  light: light,
                  qiblaBearingDeg: qiblaBearingDeg,
                  athanRing: athanRing,
                  onTap: () => onSelect(tab),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}

final class _Destination extends StatelessWidget {
  const new({
    required this.tab,
    required this.label,
    required this.selected,
    required this.light,
    required this.qiblaBearingDeg,
    required this.athanRing,
    required this.onTap,
  });

  final RawdahTab tab;
  final String label;
  final bool selected;
  final HourLight light;
  final double? qiblaBearingDeg;
  final AthanRing athanRing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? const Color(0xFFF6E7B3) : const Color(0xFFBFD2C4);
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      onTap: onTap,
      child: InkResponse(
        onTap: onTap,
        radius: 36,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 62, minWidth: 48),
          child: CustomPaint(
            painter: selected ? _HaloPainter(light) : null,
            child: Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 6),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox.square(
                    dimension: 26,
                    child: CustomPaint(
                      painter: _IconPainter(
                        tab: tab,
                        color: color,
                        qiblaBearingDeg: qiblaBearingDeg,
                        athanRing: athanRing,
                      ),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: color,
                      fontSize: DmScales.label.size - 1,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The gilded mihrab behind the selected destination.
final class _HaloPainter extends CustomPainter {
  const new(this.light);

  final HourLight light;

  @override
  void paint(Canvas canvas, Size size) {
    const w = 54.0;
    final left = (size.width - w) / 2;
    const top = -12.0;
    final bottom = size.height + 2;
    final path = Path()
      ..moveTo(left, bottom)
      ..lineTo(left, top + 24)
      ..cubicTo(left, top + 13, left + 11, top + 5, left + w / 2, top)
      ..cubicTo(left + w - 11, top + 5, left + w, top + 13, left + w, top + 24)
      ..lineTo(left + w, bottom);
    final rect = Rect.fromLTRB(left, top, left + w, bottom);
    canvas
      ..drawPath(
        path,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              light.glow.withValues(alpha: 0.55),
              light.glow.withValues(alpha: 0.06),
            ],
          ).createShader(rect),
      )
      ..drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.3
          ..color = const Color(0xFFE2C77E),
      );
  }

  @override
  bool shouldRepaint(_HaloPainter old) => old.light != light;
}

/// The four authored icons on a 26 × 26 grid, one stroke weight.
final class _IconPainter extends CustomPainter {
  const new({
    required this.tab,
    required this.color,
    required this.qiblaBearingDeg,
    required this.athanRing,
  });

  final RawdahTab tab;
  final Color color;
  final double? qiblaBearingDeg;
  final AthanRing athanRing;

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
    switch (tab) {
      case RawdahTab.home:
        _mihrab(canvas, stroke);
      case RawdahTab.qibla:
        _compass(canvas, stroke);
      case RawdahTab.athan:
        _minaret(canvas, stroke);
      case RawdahTab.settings:
        _rosette(canvas, stroke);
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

  @override
  bool shouldRepaint(_IconPainter old) =>
      old.tab != tab ||
      old.color != color ||
      old.qiblaBearingDeg != qiblaBearingDeg ||
      old.athanRing != athanRing;
}
