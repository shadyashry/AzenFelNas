import 'package:dm_ui/src/rawdah/ornament_paths.dart';
import 'package:dm_ui/src/tokens/rawdah_palette.dart';
import 'package:flutter/widgets.dart';

/// A surah-header cartouche around [child] (§15 D89): a pointed band with
/// a gilded rim on a translucent emerald fill. It grows with its text, so
/// 200 % type widens it instead of clipping (REQ-UX-020).
final class Cartouche extends StatelessWidget {
  /// The cartouche around [child].
  const new({required this.child, super.key});

  /// The title, usually Amiri on ivory.
  final Widget child;

  @override
  Widget build(BuildContext context) => CustomPaint(
    painter: const _CartouchePainter(),
    child: Padding(
      padding: const EdgeInsets.fromLTRB(36, 4, 36, 8),
      child: child,
    ),
  );
}

final class _CartouchePainter extends CustomPainter {
  const new();

  @override
  void paint(Canvas canvas, Size size) {
    final outer = (Offset.zero & size).deflate(1.5);
    final path = OrnamentPaths.cartouche(outer);
    canvas
      ..drawPath(path, Paint()..color = const Color(0x8C0A281C))
      ..drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..shader = RawdahPalette.gilded.createShader(outer),
      )
      ..drawPath(
        OrnamentPaths.cartouche(outer.deflate(5)),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8
          ..color = RawdahPalette.goldLight.withValues(alpha: 0.7),
      );
  }

  @override
  bool shouldRepaint(_CartouchePainter old) => false;
}
