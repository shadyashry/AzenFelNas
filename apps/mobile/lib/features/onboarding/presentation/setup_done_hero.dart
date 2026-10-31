import 'package:daily_muslim/features/onboarding/presentation/horizon_line.dart';
import 'package:daily_muslim/features/onboarding/presentation/preferred_break_text.dart';
import 'package:daily_muslim/features/onboarding/presentation/times_progress.dart';
import 'package:daily_muslim/features/onboarding/presentation/welcome_metrics.dart';
import 'package:daily_muslim/l10n/app_localizations.dart';
import 'package:dm_ui/dm_ui.dart';
import 'package:flutter/material.dart';

/// The compact emerald confirmation of the setup-completion screen (§15
/// D127): *Prayer setup* with Back, one restrained check ring, the gold
/// *Location saved* and the headline, over the fine gold horizon. Shorter
/// than the welcome hero: this is a confirmation, not a splash.
final class SetupDoneHero extends StatelessWidget {
  /// The hero.
  const new({
    required this.metrics,
    required this.type,
    required this.progress,
    required this.minHeight,
    required this.width,
    required this.topInset,
    required this.onBack,
    super.key,
  });

  /// How the window is used.
  final WelcomeMetrics metrics;

  /// The type scale of the language shown.
  final WelcomeType type;

  /// Where the prayer times stand.
  final TimesProgress progress;

  /// The least height.
  final double minHeight;

  /// The hero's width.
  final double width;

  /// The status bar's height: the hero runs under it.
  final double topInset;

  /// Back.
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final g = metrics.gap;
    final side = metrics.sidePadding;
    final textWidth = (width - 2 * side)
        .clamp(0, WelcomeMetrics.readingWidth)
        .toDouble();
    return ClipRect(
      child: ColoredBox(
        color: EmeraldPalette.hero,
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: minHeight),
          // Laid out from the bottom up so the header paints last, above
          // the glow; it still sits at the top.
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            verticalDirection: VerticalDirection.up,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 14 * g, bottom: 4),
                child: const HorizonLine(),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(side, 20 * g, side, 0),
                child: Column(
                  children: [
                    _Confirmation(progress: progress),
                    SizedBox(height: 16 * g),
                    Text(
                      l.setupLocationSaved,
                      textAlign: TextAlign.center,
                      style: type.eyebrow.copyWith(
                        color: EmeraldPalette.eyebrow,
                      ),
                    ),
                    SizedBox(height: 10 * g),
                    Semantics(
                      header: true,
                      liveRegion: true,
                      child: PreferredBreakText(
                        switch (progress) {
                          TimesProgress.preparing => l.setupPreparing,
                          TimesProgress.ready => l.setupReadyHeadline,
                          TimesProgress.failed => l.setupNotReady,
                        },
                        width: textWidth,
                        textAlign: TextAlign.center,
                        style: type.headline.copyWith(
                          color: EmeraldPalette.headline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: topInset + 4),
                child: SizedBox(
                  // The Back button's own padding sits outside the column.
                  width: textWidth + 24,
                  child: _Header(type: type, onBack: onBack),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Back and *Prayer setup*; the arrow mirrors in Arabic.
final class _Header extends StatelessWidget {
  const new({required this.type, required this.onBack});

  final WelcomeType type;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      IconButton(
        key: const Key('setupBack'),
        onPressed: onBack,
        tooltip: MaterialLocalizations.of(context).backButtonTooltip,
        style: IconButton.styleFrom(
          backgroundColor: EmeraldPalette.headline.withValues(alpha: 0.07),
          foregroundColor: EmeraldPalette.headline,
          minimumSize: const Size.square(48),
        ),
        icon: const Icon(Icons.arrow_back),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: Text(
          AppLocalizations.of(context).setupHeader,
          style: type.action.copyWith(color: EmeraldPalette.headline),
        ),
      ),
    ],
  );
}

/// One fine gold ring holding a check, progress while the times are
/// calculated, or a mark when they could not be; the glow behind it is
/// decoration only.
final class _Confirmation extends StatelessWidget {
  const new({required this.progress});

  final TimesProgress progress;

  static const double _size = 66;

  @override
  Widget build(BuildContext context) => Stack(
    alignment: Alignment.center,
    clipBehavior: Clip.none,
    children: [
      Positioned(
        left: -_size * 1.6,
        top: -_size * 1.6,
        right: -_size * 1.6,
        bottom: -_size * 1.6,
        child: IgnorePointer(
          child: ExcludeSemantics(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    EmeraldPalette.confirmGlow.withValues(
                      alpha: EmeraldPalette.glowOpacity * 0.8,
                    ),
                    EmeraldPalette.confirmGlow.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      ExcludeSemantics(
        child: Container(
          width: _size,
          height: _size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: EmeraldPalette.headline.withValues(alpha: 0.05),
            border: Border.all(
              color: EmeraldPalette.confirmRing.withValues(alpha: 0.85),
              width: 1.2,
            ),
          ),
          alignment: Alignment.center,
          child: switch (progress) {
            TimesProgress.ready => const Icon(
              Icons.check,
              size: 32,
              color: EmeraldPalette.headline,
            ),
            TimesProgress.preparing => const SizedBox.square(
              dimension: 26,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: EmeraldPalette.headline,
              ),
            ),
            TimesProgress.failed => const Icon(
              Icons.priority_high,
              size: 30,
              color: EmeraldPalette.headline,
            ),
          },
        ),
      ),
    ],
  );
}
