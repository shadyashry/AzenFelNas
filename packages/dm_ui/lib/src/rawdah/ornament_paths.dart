import 'dart:math' as math;
import 'dart:ui';

/// Shared geometry of the Rawdah ornaments (§15 D89): the eight-point star
/// (two squares, one turned 45°) and the pointed cartouche of a surah
/// header. Pure functions of their bounds.
abstract final class OrnamentPaths {
  /// An eight-point star centred on [center], outer radius [radius], inner
  /// radius [innerRatio] × [radius].
  static Path star(Offset center, double radius, {double innerRatio = 0.62}) {
    final path = Path();
    for (var k = 0; k < 16; k++) {
      final angle = math.pi / 8 * k - math.pi / 2;
      final r = k.isEven ? radius : radius * innerRatio;
      final point = center + Offset(math.cos(angle), math.sin(angle)) * r;
      if (k == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    return path..close();
  }

  /// The two overlapping squares of a girih tile, as outlines.
  static Path girihTile(Offset center, double half) {
    final square = Rect.fromCenter(
      center: center,
      width: half * 2,
      height: half * 2,
    );
    final turned = Path();
    for (var k = 0; k < 4; k++) {
      final angle = math.pi / 2 * k;
      final point =
          center + Offset(math.cos(angle), math.sin(angle)) * half * math.sqrt2;
      if (k == 0) {
        turned.moveTo(point.dx, point.dy);
      } else {
        turned.lineTo(point.dx, point.dy);
      }
    }
    return Path()
      ..addRect(square)
      ..addPath(turned..close(), Offset.zero);
  }

  /// A cartouche with pointed ends filling [rect].
  static Path cartouche(Rect rect) {
    final h = rect.height;
    final tip = h * 0.42;
    final l = rect.left;
    final r = rect.right;
    final t = rect.top;
    final b = rect.bottom;
    final mid = rect.center.dy;
    return Path()
      ..moveTo(l + tip, t)
      ..lineTo(r - tip, t)
      ..cubicTo(r - tip * 0.45, t, r - tip * 0.3, t + h * 0.3, r, mid)
      ..cubicTo(r - tip * 0.3, b - h * 0.3, r - tip * 0.45, b, r - tip, b)
      ..lineTo(l + tip, b)
      ..cubicTo(l + tip * 0.45, b, l + tip * 0.3, b - h * 0.3, l, mid)
      ..cubicTo(l + tip * 0.3, t + h * 0.3, l + tip * 0.45, t, l + tip, t)
      ..close();
  }

  /// A diamond (a square turned 45°) centred on [center].
  static Path diamond(Offset center, double half) => Path()
    ..moveTo(center.dx, center.dy - half)
    ..lineTo(center.dx + half, center.dy)
    ..lineTo(center.dx, center.dy + half)
    ..lineTo(center.dx - half, center.dy)
    ..close();
}
