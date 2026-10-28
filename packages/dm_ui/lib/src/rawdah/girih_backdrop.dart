import 'package:dm_ui/src/rawdah/ornament_paths.dart';
import 'package:flutter/widgets.dart';

/// A faint girih of eight-point stars behind [child] (§15 D89): the marble
/// floor and Rawdah carpet, kept at an opacity that never touches text
/// contrast (the pattern is hairlines, not fills).
final class GirihBackdrop extends StatelessWidget {
  /// [child] over [ground] with stars in [ink] at [opacity].
  const new({
    required this.child,
    required this.ground,
    required this.ink,
    this.opacity = 0.12,
    this.tile = 56,
    super.key,
  });

  /// What sits on the ground.
  final Widget child;

  /// Ground colour.
  final Color ground;

  /// Star colour.
  final Color ink;

  /// Star opacity.
  final double opacity;

  /// Tile size in logical pixels.
  final double tile;

  @override
  Widget build(BuildContext context) => CustomPaint(
    painter: _GirihPainter(
      ground: ground,
      ink: ink.withValues(alpha: opacity),
      tile: tile,
    ),
    child: child,
  );
}

final class _GirihPainter extends CustomPainter {
  const new({required this.ground, required this.ink, required this.tile});

  final Color ground;
  final Color ink;
  final double tile;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = ground);
    final stroke = Paint()
      ..color = ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7;
    for (var y = tile / 2; y < size.height + tile; y += tile) {
      for (var x = tile / 2; x < size.width + tile; x += tile) {
        canvas.drawPath(
          OrnamentPaths.girihTile(Offset(x, y), tile * 0.215),
          stroke,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_GirihPainter old) =>
      old.ground != ground || old.ink != ink || old.tile != tile;
}
