import 'package:daily_muslim/features/onboarding/presentation/city_picker_view.dart';
import 'package:daily_muslim/features/onboarding/presentation/onboarding_controller.dart';
import 'package:daily_muslim/features/onboarding/presentation/onboarding_state.dart';
import 'package:daily_muslim/features/onboarding/presentation/welcome_view.dart';
import 'package:daily_muslim/l10n/app_localizations.dart';
import 'package:dm_ui/dm_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The first run (§18.4 Onboarding): every [OnboardingState] is rendered by
/// one exhaustive switch. The Emerald horizon welcome screen shows the
/// welcome step, the search for the device's place and its failure
/// (§15 D126); the city picker the place step. Only approximate location
/// is asked for (§18.3).
final class OnboardingPage extends ConsumerWidget {
  /// The page.
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(onboardingProvider.notifier);
    final state = ref.watch(onboardingProvider);
    return switch (state) {
      OnboardingStep(step: OnboardingStepKind.welcome) ||
      OnboardingResolving() ||
      OnboardingFailed() => WelcomeView(state: state),
      OnboardingStep(step: OnboardingStepKind.place) => CityPickerView(
        onPinned: controller.placePinned,
        onBack: controller.backToWelcome,
      ),
      OnboardingStep(step: OnboardingStepKind.done, :final placeLabel) => _Done(
        placeLabel: placeLabel,
      ),
    };
  }
}

/// The place is stored: the Rawdah step that asks for the Athan's
/// permissions on the way to Home (§15 D94, D96).
final class _Done extends ConsumerWidget {
  const new({required this.placeLabel});

  final String placeLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final controller = ref.read(onboardingProvider.notifier);
    return Scaffold(
      body: GirihBackdrop(
        ground: RawdahScheme.of(context).ground,
        ink: RawdahPalette.gold,
        // A whisper of pattern on the first run only (§15 D102).
        opacity: 0.05,
        tile: 72,
        child: SafeArea(
          child: _Step(
            hero: const ReadinessMedallion(
              glyph: RawdahGlyphKind.mihrab,
              tone: MedallionTone.ready,
              size: 128,
            ),
            title: l.onboardingDoneTitle,
            body: placeLabel.isEmpty
                ? l.homeCurrentPlace
                : l.onboardingDoneBody(placeLabel),
            extra: _Note(
              icon: Icons.notifications_active_outlined,
              text: l.onboardingAthanPermissions,
            ),
            actions: [
              FilledButton.icon(
                onPressed: controller.finish,
                icon: const Icon(Icons.arrow_forward),
                label: Text(l.onboardingShowTimes),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One first-run step: the hero, title, body and [extra] scrolling in the
/// middle, and [actions] in a fixed panel at the bottom.
final class _Step extends StatelessWidget {
  const new({
    required this.title,
    required this.body,
    required this.actions,
    this.hero,
    this.extra,
  });

  /// The step's medallion (§15 D89).
  final Widget? hero;

  /// Below the body: the features, a note or a suggestion.
  final Widget? extra;
  final String title;
  final String body;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final r = RawdahScheme.of(context);
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
              child: Column(
                children: [
                  if (hero case final Widget mark) ...[
                    mark,
                    const SizedBox(height: 24),
                  ],
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: DmTheme.naskh(
                      size: 28,
                      color: r.primary,
                      bold: true,
                    ),
                  ),
                  if (body.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      body,
                      textAlign: TextAlign.center,
                      style: text.bodyLarge?.copyWith(color: r.inkMuted),
                    ),
                  ],
                  if (extra case final Widget more) ...[
                    const SizedBox(height: 20),
                    more,
                  ],
                ],
              ),
            ),
          ),
        ),
        if (actions.isNotEmpty)
          DecoratedBox(
            decoration: BoxDecoration(
              color: r.ground,
              border: Border(top: BorderSide(color: r.hairline, width: 0.8)),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final (i, action) in actions.indexed)
                    Padding(
                      padding: EdgeInsets.only(top: i == 0 ? 0 : 8),
                      child: action,
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// A panel with an icon and a line.
final class _Note extends StatelessWidget {
  const new({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final r = RawdahScheme.of(context);
    final style = Theme.of(context).textTheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: r.panel,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: RawdahPalette.gold.withValues(alpha: 0.6)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(icon, color: r.accent),
            const SizedBox(width: 12),
            Expanded(child: Text(text, style: style.bodyMedium)),
          ],
        ),
      ),
    );
  }
}
