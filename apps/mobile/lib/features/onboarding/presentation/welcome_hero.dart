import 'package:daily_muslim/features/onboarding/presentation/horizon_line.dart';
import 'package:daily_muslim/features/onboarding/presentation/language_choice.dart';
import 'package:daily_muslim/features/onboarding/presentation/preferred_break_text.dart';
import 'package:daily_muslim/features/onboarding/presentation/welcome_metrics.dart';
import 'package:daily_muslim/l10n/app_localizations.dart';
import 'package:dm_ui/dm_ui.dart';
import 'package:flutter/material.dart';

/// The deep emerald hero of the welcome screen (§15 D126): "Welcome" and
/// the language choice at the top, the approved logo in a restrained glow,
/// the gold eyebrow, the ivory headline, and the gold horizon at its foot.
/// At least [minHeight] tall; spare height goes around the logo group.
final class WelcomeHero extends StatelessWidget {
  /// The hero.
  const new({
    required this.metrics,
    required this.type,
    required this.minHeight,
    required this.width,
    required this.topInset,
    super.key,
  });

  /// How the window is used.
  final WelcomeMetrics metrics;

  /// The type scale of the language shown.
  final WelcomeType type;

  /// The least height.
  final double minHeight;

  /// The hero's width.
  final double width;

  /// The status bar's height: the hero runs under it.
  final double topInset;

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
          // the logo's glow; it still sits at the top.
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            verticalDirection: VerticalDirection.up,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 8 * g, bottom: 4),
                child: const HorizonLine(),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(side, 26 * g, side, 0),
                child: Column(
                  children: [
                    _Logo(size: metrics.logo),
                    SizedBox(height: 22 * g),
                    Text(
                      l.welcomeEyebrow,
                      textAlign: TextAlign.center,
                      style: type.eyebrow.copyWith(
                        color: EmeraldPalette.eyebrow,
                      ),
                    ),
                    SizedBox(height: 12 * g),
                    Semantics(
                      header: true,
                      child: PreferredBreakText(
                        l.welcomeHeadline,
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
                padding: EdgeInsets.only(top: topInset + 6),
                // With large text the switch moves under "Welcome".
                child: SizedBox(
                  width: textWidth,
                  child: Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    runSpacing: 4,
                    children: [
                      Text(
                        l.welcomeHeader,
                        style: type.welcome.copyWith(
                          color: EmeraldPalette.welcome,
                        ),
                      ),
                      const LanguageChoice(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The approved logo, whole and unaltered (§15 D106), in a soft green glow
/// that is decoration only.
final class _Logo extends StatelessWidget {
  const new({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    final glow = size * 1.3;
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: -glow,
          top: -glow,
          right: -glow,
          bottom: -glow,
          child: IgnorePointer(
            child: ExcludeSemantics(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      EmeraldPalette.glow.withValues(
                        alpha: EmeraldPalette.glowOpacity,
                      ),
                      EmeraldPalette.glow.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        Semantics(
          image: true,
          label: AppLocalizations.of(context).appTitle,
          // The rounding takes only plain green corners (§15 D106).
          child: ClipRRect(
            borderRadius: BorderRadius.circular(size * 0.22),
            child: Image.asset(
              'assets/brand/logo.png',
              width: size,
              height: size,
              excludeFromSemantics: true,
            ),
          ),
        ),
      ],
    );
  }
}
