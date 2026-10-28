import 'dart:math' as math;

import 'package:dm_ui/src/rawdah/medallion_tone.dart';
import 'package:dm_ui/src/rawdah/rawdah_glyph.dart';
import 'package:dm_ui/src/rawdah/rawdah_glyph_kind.dart';
import 'package:dm_ui/src/tokens/rawdah_palette.dart';
import 'package:flutter/widgets.dart';

/// A glyph in an emerald disc inside a gilded ring whose outer ring tells
/// the state (§15 D89, P2 honest alarm): a full glowing gold ring only for
/// [MedallionTone.ready], three quarters for limited, carpet red for not
/// ready, a dotted ring for unknown. Shape differs per tone, so the state
/// never rests on colour alone; the page states it in text as well
/// (REQ-UX-020), so the medallion is excluded from semantics.
final class ReadinessMedallion extends StatelessWidget {
  /// [glyph] in the [tone] ring, [size] logical pixels across.
  const new({
    required this.glyph,
    required this.tone,
    this.size = 136,
    super.key,
  });

  /// The emblem in the disc.
  final RawdahGlyphKind glyph;

  /// What the ring says; `null` draws a plain emblem with no state ring.
  final MedallionTone? tone;

  /// Diameter.
  final double size;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _MedallionPainter(tone),
        child: Center(
          child: RawdahGlyph(
            kind: glyph,
            color: RawdahPalette.ivory,
            size: size * 0.42,
          ),
        ),
      ),
    ),
  );
}

final class _MedallionPainter extends CustomPainter {
  const new(this.tone);

  final MedallionTone? tone;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2;
    final disc = r * 0.74;
    if (tone == MedallionTone.ready) {
      canvas.drawCircle(
        c,
        r * 0.98,
        Paint()
          ..color = RawdahPalette.goldLight.withValues(alpha: 0.45)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
      );
    }
    canvas
      ..drawCircle(
        c,
        disc,
        Paint()
          ..shader = const RadialGradient(
            colors: [Color(0xFF23855C), RawdahPalette.emeraldDeep],
          ).createShader(Rect.fromCircle(center: c, radius: disc)),
      )
      ..drawCircle(
        c,
        disc,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..shader = RawdahPalette.gilded.createShader(
            Rect.fromCircle(center: c, radius: disc),
          ),
      );
    final ring = Rect.fromCircle(center: c, radius: r * 0.88);
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.07
      ..strokeCap = StrokeCap.round;
    switch (tone) {
      case null:
        break;
      case MedallionTone.ready:
        canvas.drawArc(
          ring,
          0,
          2 * math.pi,
          false,
          stroke..shader = RawdahPalette.gilded.createShader(ring),
        );
      case MedallionTone.limited:
        canvas.drawArc(
          ring,
          -math.pi / 2,
          1.5 * math.pi,
          false,
          stroke..color = RawdahPalette.gold,
        );
      case MedallionTone.notReady:
        canvas.drawArc(
          ring,
          0,
          2 * math.pi,
          false,
          stroke..color = RawdahPalette.carpetRed,
        );
      case MedallionTone.unknown:
        final dot = Paint()..color = RawdahPalette.gold;
        for (var k = 0; k < 36; k++) {
          final a = 2 * math.pi * k / 36;
          canvas.drawCircle(
            c + Offset(math.cos(a), math.sin(a)) * (r * 0.88),
            r * 0.03,
            dot,
          );
        }
    }
  }

  @override
  bool shouldRepaint(_MedallionPainter old) => old.tone != tone;
}
