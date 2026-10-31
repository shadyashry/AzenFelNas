import 'package:daily_muslim/features/onboarding/presentation/emerald_frame.dart';
import 'package:daily_muslim/features/onboarding/presentation/onboarding_state.dart';
import 'package:daily_muslim/features/onboarding/presentation/welcome_hero.dart';
import 'package:daily_muslim/features/onboarding/presentation/welcome_metrics.dart';
import 'package:daily_muslim/features/onboarding/presentation/welcome_panel.dart';
import 'package:dm_ui/dm_ui.dart';
import 'package:flutter/material.dart';

/// The Emerald horizon welcome screen (§15 D126) in an [EmeraldFrame]: the
/// emerald hero over the ivory panel, or beside it in a landscape window
/// with room. The layout follows the window and the text size. Renders the
/// welcome step, resolving and failed.
final class WelcomeView extends StatelessWidget {
  /// The screen for [state].
  const new({required this.state, super.key});

  /// The onboarding state shown.
  final OnboardingState state;

  @override
  Widget build(BuildContext context) {
    final language = Localizations.localeOf(context).languageCode == 'ar'
        ? StatusLocale.ar
        : StatusLocale.en;
    final metrics = WelcomeMetrics.of(
      MediaQuery.sizeOf(context),
      MediaQuery.textScalerOf(context).scale(16) / 16,
    );
    final type = WelcomeType.of(language, compact: metrics.compactType);
    return EmeraldFrame(
      sideBySide: metrics.sideBySide,
      heroShare: metrics.heroShare,
      hero: (minHeight, width, topInset) => WelcomeHero(
        metrics: metrics,
        type: type,
        minHeight: minHeight,
        width: width,
        topInset: topInset,
      ),
      panel: (width, bottomInset) => WelcomePanel(
        state: state,
        metrics: metrics,
        type: type,
        width: width,
        bottomInset: bottomInset,
      ),
    );
  }
}
