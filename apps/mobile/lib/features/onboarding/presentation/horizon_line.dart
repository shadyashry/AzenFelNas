import 'package:dm_ui/dm_ui.dart';
import 'package:flutter/widgets.dart';

/// The fine gold horizon at the foot of the welcome hero (§15 D126): one
/// shallow arc, highest in the middle, faded at both ends. Decorative, so
/// it has no semantics.
final class HorizonLine extends StatelessWidget {
  /// The line, [height] tall.
  const new({this.height = 24, super.key});

  /// The band it is drawn in.
  final double height;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: SizedBox(
      height: height,
      width: double.infinity,
      child: const CustomPaint(painter: _HorizonPainter()),
    ),
  );
}

final class _HorizonPainter extends CustomPainter {
  const new();

  @override
  void paint(Canvas canvas, Size size) {
    const gold = EmeraldPalette.horizon;
    const strong = EmeraldPalette.horizonOpacity;
    final edge = size.height * 0.6;
    final crest = size.height * 0.25;
    final path = Path()
      ..moveTo(0, edge)
      // The control point that puts the arc's top at [crest].
      ..quadraticBezierTo(size.width / 2, 2 * crest - edge, size.width, edge);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..isAntiAlias = true
      ..shader = LinearGradient(
        colors: [
          gold.withValues(alpha: strong * 0.25),
          gold.withValues(alpha: strong),
          gold.withValues(alpha: strong),
          gold.withValues(alpha: strong * 0.25),
        ],
        stops: const [0, 0.25, 0.75, 1],
      ).createShader(Offset.zero & size);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_HorizonPainter oldDelegate) => false;
}
