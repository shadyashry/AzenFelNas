import 'package:dm_ui/dm_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Builds an Emerald horizon hero [minHeight] tall and [width] wide, drawn
/// under a status bar [topInset] tall.
typedef EmeraldHeroBuilder = Widget Function(
  double minHeight,
  double width,
  double topInset,
);

/// Builds the ivory content [width] wide above a navigation bar
/// [bottomInset] tall.
typedef IvoryPanelBuilder = Widget Function(double width, double bottomInset);

/// The Emerald horizon frame of the first run (§15 D126, D127): an emerald
/// hero edge to edge under light status-bar icons, over ivory content that
/// fills the rest; in a landscape window with room, the hero is a pane on
/// the leading side and the content one on the trailing side under the
/// status bar. Nothing is drawn on a fixed canvas: it scrolls only when the
/// content does not fit, and display cutouts are kept clear.
final class EmeraldFrame extends StatelessWidget {
  /// The frame.
  const new({
    required this.sideBySide,
    required this.heroShare,
    required this.hero,
    required this.panel,
    this.heroPaneShare = 0.45,
    super.key,
  });

  /// The hero is a pane beside the content.
  final bool sideBySide;

  /// The least share of the window's height a stacked hero takes.
  final double heroShare;

  /// The hero pane's share of the width when [sideBySide].
  final double heroPaneShare;

  /// The hero.
  final EmeraldHeroBuilder hero;

  /// The content.
  final IvoryPanelBuilder panel;

  /// Light status-bar icons on the hero, dark navigation icons on the
  /// ivory.
  static final SystemUiOverlayStyle bars = DmTheme.statusBarOn(
    Brightness.dark,
  ).copyWith(systemNavigationBarIconBrightness: Brightness.dark);

  @override
  Widget build(BuildContext context) {
    final insets = MediaQuery.paddingOf(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: bars,
      child: Scaffold(
        backgroundColor: EmeraldPalette.panel,
        body: LayoutBuilder(
          builder: (context, box) => sideBySide
              ? _Beside(
                  size: box.biggest,
                  insets: insets,
                  heroPaneShare: heroPaneShare,
                  hero: hero,
                  panel: panel,
                )
              : _Stacked(
                  size: box.biggest,
                  insets: insets,
                  heroShare: heroShare,
                  hero: hero,
                  panel: panel,
                ),
        ),
      ),
    );
  }
}

/// Portrait and narrow windows: the hero, then the content filling the
/// rest; one column that scrolls when it does not fit.
final class _Stacked extends StatelessWidget {
  const new({
    required this.size,
    required this.insets,
    required this.heroShare,
    required this.hero,
    required this.panel,
  });

  final Size size;
  final EdgeInsets insets;
  final double heroShare;
  final EmeraldHeroBuilder hero;
  final IvoryPanelBuilder panel;

  @override
  Widget build(BuildContext context) => CustomScrollView(
    physics: const ClampingScrollPhysics(),
    slivers: [
      SliverToBoxAdapter(
        child: hero(size.height * heroShare, size.width, insets.top),
      ),
      SliverFillRemaining(
        hasScrollBody: false,
        child: panel(size.width, insets.bottom),
      ),
    ],
  );
}

/// Landscape with room: the hero pane leading, the content trailing.
final class _Beside extends StatelessWidget {
  const new({
    required this.size,
    required this.insets,
    required this.heroPaneShare,
    required this.hero,
    required this.panel,
  });

  final Size size;
  final EdgeInsets insets;
  final double heroPaneShare;
  final EmeraldHeroBuilder hero;
  final IvoryPanelBuilder panel;

  @override
  Widget build(BuildContext context) {
    final inner = size.width - insets.left - insets.right;
    final heroWidth = inner * heroPaneShare;
    return ColoredBox(
      color: EmeraldPalette.hero,
      child: Padding(
        padding: EdgeInsets.only(left: insets.left, right: insets.right),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: heroWidth,
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: hero(size.height, heroWidth, insets.top),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(top: insets.top + 10),
                child: CustomScrollView(
                  physics: const ClampingScrollPhysics(),
                  slivers: [
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: panel(inner - heroWidth, insets.bottom),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
