import 'package:daily_muslim/features/onboarding/presentation/welcome_metrics.dart';
import 'package:dm_ui/dm_ui.dart';
import 'package:flutter/widgets.dart';

/// The warm ivory surface of the first run (§15 D126, D127): rounded top
/// corners over the emerald, with no gap, and [child] centred at most
/// [WelcomeMetrics.readingWidth] wide, so buttons never stretch on wide
/// windows. Fills the height it is given.
final class IvorySheet extends StatelessWidget {
  /// The sheet, [width] wide, holding [child].
  const new({
    required this.width,
    required this.side,
    required this.top,
    required this.bottom,
    required this.child,
    this.radius = 31,
    super.key,
  });

  /// The sheet's width.
  final double width;

  /// The side padding.
  final double side;

  /// The padding above [child].
  final double top;

  /// The padding below [child], navigation bar included.
  final double bottom;

  /// The rounding of the top corners.
  final double radius;

  /// The content.
  final Widget child;

  /// The width the content of a sheet [width] wide with [side] padding is
  /// laid out in.
  static double contentWidthOf(double width, double side) =>
      (width - 2 * side).clamp(0, WelcomeMetrics.readingWidth).toDouble();

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: EmeraldPalette.hero,
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: EmeraldPalette.panel,
        borderRadius: BorderRadius.vertical(top: Radius.circular(radius)),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(side, top, side, bottom),
        child: Center(
          heightFactor: 1,
          child: SizedBox(width: contentWidthOf(width, side), child: child),
        ),
      ),
    ),
  );
}
