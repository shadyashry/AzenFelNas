import 'package:dm_ui/src/rawdah/ornament_paths.dart';
import 'package:dm_ui/src/tokens/rawdah_palette.dart';
import 'package:flutter/widgets.dart';

/// The illuminated rule between sections (§15 D89): two gold lines with
/// diamond terminals and an eight-point star at the centre. Decorative:
/// excluded from semantics.
final class GoldDivider extends StatelessWidget {
  /// A divider [height] logical pixels tall.
  const new({this.height = 18, super.key});

  /// Height of the ornament.
  final double height;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: SizedBox(
      height: height,
      width: double.infinity,
      child: const CustomPaint(painter: _DividerPainter()),
    ),
  );
}

final class _DividerPainter extends CustomPainter {
  const new();

  @override
  void paint(Canvas canvas, Size size) {
    final mid = size.height / 2;
    final centre = Offset(size.width / 2, mid);
    final line = Paint()
      ..color = RawdahPalette.gold
      ..strokeWidth = 1.2;
    canvas
      ..drawLine(Offset(10, mid), Offset(centre.dx - 16, mid), line)
      ..drawLine(
        Offset(centre.dx + 16, mid),
        Offset(size.width - 10, mid),
        line,
      );
    final gold = Paint()..color = RawdahPalette.gold;
    canvas
      ..drawPath(OrnamentPaths.diamond(Offset(6, mid), 4), gold)
      ..drawPath(OrnamentPaths.diamond(Offset(size.width - 6, mid), 4), gold)
      ..drawPath(
        OrnamentPaths.star(centre, size.height / 2),
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [RawdahPalette.goldLight, RawdahPalette.goldDeep],
          ).createShader(Rect.fromCircle(center: centre, radius: mid)),
      )
      ..drawCircle(
        centre,
        size.height * 0.14,
        Paint()..color = RawdahPalette.emerald,
      );
  }

  @override
  bool shouldRepaint(_DividerPainter old) => false;
}
