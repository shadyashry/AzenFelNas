import 'package:flutter/widgets.dart';

/// How the welcome screen fits a window (§15 D126). Decorative spacing and
/// the logo shrink first on short windows or large text; text never does,
/// and whatever still does not fit scrolls. A landscape window with room
/// puts the hero beside the panel.
@immutable
final class WelcomeMetrics {
  /// Metrics; use [WelcomeMetrics.of].
  const new({
    required this.sideBySide,
    required this.compactType,
    required this.sidePadding,
    required this.logo,
    required this.gap,
    required this.heroShare,
  });

  /// The metrics of a [size] window whose text is scaled by [textScale]
  /// (1 at the default size).
  factory of(Size size, double textScale) {
    final sideBySide = size.width >= 600 && size.width > size.height * 1.2;
    final narrow = size.width < 360;
    final room = sideBySide ? size.height * 2 : size.height;
    final tier = switch ((room, textScale)) {
      (>= 820, <= 1.15) => _Tier.regular,
      (>= 680, <= 1.3) => _Tier.medium,
      _ => _Tier.short,
    };
    return WelcomeMetrics(
      sideBySide: sideBySide,
      compactType: narrow,
      sidePadding: narrow ? 20 : 24,
      logo: switch (tier) {
        _Tier.regular => 112,
        _Tier.medium => 96,
        _Tier.short => sideBySide || size.height < 600 ? 72 : 80,
      },
      gap: switch (tier) {
        _Tier.regular => 1,
        _Tier.medium => 0.75,
        _Tier.short => 0.5,
      },
      heroShare: !sideBySide && tier == _Tier.regular ? 0.47 : 0,
    );
  }

  /// The hero is a pane on the leading side and the panel one on the
  /// trailing side.
  final bool sideBySide;

  /// Narrow phones: the compact type scale and 20-unit side padding.
  final bool compactType;

  /// The side padding of the hero and the panel.
  final double sidePadding;

  /// The logo's side.
  final double logo;

  /// The factor applied to the hero's decorative gaps and the panel's
  /// flexible ones.
  final double gap;

  /// The least share of the window's height the portrait hero takes; 0 lets
  /// it take only what its content needs.
  final double heroShare;

  /// The widest the panel's content and the hero's text grow.
  static const double readingWidth = 480;
}

enum _Tier { regular, medium, short }
