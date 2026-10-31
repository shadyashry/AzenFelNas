import 'package:daily_muslim/features/onboarding/presentation/onboarding_state.dart';
import 'package:daily_muslim/features/onboarding/presentation/welcome_hero.dart';
import 'package:daily_muslim/features/onboarding/presentation/welcome_metrics.dart';
import 'package:daily_muslim/features/onboarding/presentation/welcome_panel.dart';
import 'package:dm_ui/dm_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// The Emerald horizon welcome screen (§15 D126): the emerald hero, edge to
/// edge under light status-bar icons, over the ivory panel; in a landscape
/// window with room, the hero is a pane on the leading side and the panel
/// one on the trailing side. Nothing is drawn on a fixed canvas: the
/// layout follows the window and the text size, and scrolls only when it
/// must. Renders the welcome step, resolving and failed.
final class WelcomeView extends StatelessWidget {
  /// The screen for [state].
  const new({required this.state, super.key});

  /// The onboarding state shown.
  final OnboardingState state;

  /// Light status-bar icons on the hero, dark navigation icons on the
  /// panel.
  static final SystemUiOverlayStyle bars = DmTheme.statusBarOn(
    Brightness.dark,
  ).copyWith(systemNavigationBarIconBrightness: Brightness.dark);

  @override
  Widget build(BuildContext context) {
    final language = Localizations.localeOf(context).languageCode == 'ar'
        ? StatusLocale.ar
        : StatusLocale.en;
    final textScale = MediaQuery.textScalerOf(context).scale(16) / 16;
    final insets = MediaQuery.paddingOf(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: bars,
      child: Scaffold(
        backgroundColor: EmeraldPalette.panel,
        body: LayoutBuilder(
          builder: (context, box) {
            final metrics = WelcomeMetrics.of(box.biggest, textScale);
            final type = WelcomeType.of(
              language,
              compact: metrics.compactType,
            );
            return metrics.sideBySide
                ? _SideBySide(
                    state: state,
                    metrics: metrics,
                    type: type,
                    size: box.biggest,
                    insets: insets,
                  )
                : _Stacked(
                    state: state,
                    metrics: metrics,
                    type: type,
                    size: box.biggest,
                    insets: insets,
                  );
          },
        ),
      ),
    );
  }
}

/// Portrait and narrow windows: the hero, then the panel filling the rest;
/// one column that scrolls when it does not fit.
final class _Stacked extends StatelessWidget {
  const new({
    required this.state,
    required this.metrics,
    required this.type,
    required this.size,
    required this.insets,
  });

  final OnboardingState state;
  final WelcomeMetrics metrics;
  final WelcomeType type;
  final Size size;
  final EdgeInsets insets;

  @override
  Widget build(BuildContext context) => CustomScrollView(
    physics: const ClampingScrollPhysics(),
    slivers: [
      SliverToBoxAdapter(
        child: WelcomeHero(
          metrics: metrics,
          type: type,
          minHeight: size.height * metrics.heroShare,
          width: size.width,
          topInset: insets.top,
        ),
      ),
      SliverFillRemaining(
        hasScrollBody: false,
        child: WelcomePanel(
          state: state,
          metrics: metrics,
          type: type,
          width: size.width,
          bottomInset: insets.bottom,
        ),
      ),
    ],
  );
}

/// Landscape with room: the hero pane on the leading side, the panel on the
/// trailing side under the status bar, each scrolling on its own; display
/// cutouts are kept clear.
final class _SideBySide extends StatelessWidget {
  const new({
    required this.state,
    required this.metrics,
    required this.type,
    required this.size,
    required this.insets,
  });

  final OnboardingState state;
  final WelcomeMetrics metrics;
  final WelcomeType type;
  final Size size;
  final EdgeInsets insets;

  @override
  Widget build(BuildContext context) {
    final inner = size.width - insets.left - insets.right;
    final heroWidth = inner * 0.45;
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
                child: WelcomeHero(
                  metrics: metrics,
                  type: type,
                  minHeight: size.height,
                  width: heroWidth,
                  topInset: insets.top,
                ),
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
                      child: WelcomePanel(
                        state: state,
                        metrics: metrics,
                        type: type,
                        width: inner - heroWidth,
                        bottomInset: insets.bottom,
                      ),
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
