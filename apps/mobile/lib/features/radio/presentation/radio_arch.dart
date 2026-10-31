import 'package:flutter/material.dart';

/// The arch the Radio screens frame a station in (§15 D122): a round top
/// over straight sides, as in the reference. Decorative; callers put the
/// meaning in a label.
final class RadioArch extends StatelessWidget {
  /// An arch [width] × [height] around [child].
  const new({
    required this.width,
    required this.height,
    required this.child,
    this.color,
    this.gradient,
    this.border,
    this.ring,
    super.key,
  });

  /// Width, logical pixels.
  final double width;

  /// Height, logical pixels.
  final double height;

  /// A flat fill.
  final Color? color;

  /// A gradient fill (wins over [color]).
  final Gradient? gradient;

  /// The outline, if any.
  final BorderSide? border;

  /// A faint second outline around the arch, if any.
  final Color? ring;

  /// The icon inside.
  final Widget child;

  /// The arch's shape at [width].
  static ShapeBorder shape(double width, {BorderSide side = BorderSide.none}) =>
      RoundedRectangleBorder(
        side: side,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(width / 2),
          bottom: Radius.circular(width * 0.12),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final arch = SizedBox(
      width: width,
      height: height,
      child: DecoratedBox(
        decoration: ShapeDecoration(
          color: gradient == null ? color : null,
          gradient: gradient,
          shape: shape(width, side: border ?? BorderSide.none),
        ),
        child: Center(child: child),
      ),
    );
    final outer = ring;
    if (outer == null) return ExcludeSemantics(child: arch);
    final gap = width * 0.16;
    return ExcludeSemantics(
      child: SizedBox(
        width: width + gap * 2,
        height: height + gap * 2,
        child: DecoratedBox(
          decoration: ShapeDecoration(
            shape: shape(width + gap * 2, side: BorderSide(color: outer)),
          ),
          child: Center(child: arch),
        ),
      ),
    );
  }
}
