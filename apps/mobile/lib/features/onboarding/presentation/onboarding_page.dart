import 'package:daily_muslim/features/contexts/presentation/manual_place_view.dart';
import 'package:daily_muslim/features/onboarding/presentation/onboarding_controller.dart';
import 'package:daily_muslim/features/onboarding/presentation/onboarding_state.dart';
import 'package:daily_muslim/features/shell/application/describe_failure.dart';
import 'package:daily_muslim/features/shell/presentation/needs_attention_card.dart';
import 'package:daily_muslim/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The first run (§18.4 Onboarding): every [OnboardingState] is rendered by
/// one exhaustive switch. Only approximate location is asked for (§18.3).
final class OnboardingPage extends ConsumerWidget {
  /// The page.
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final controller = ref.read(onboardingProvider.notifier);
    return Scaffold(
      appBar: AppBar(title: Text(l.appTitle)),
      body: SafeArea(
        child: switch (ref.watch(onboardingProvider)) {
          OnboardingStep(step: OnboardingStepKind.welcome) => _Step(
            title: l.onboardingWelcomeTitle,
            body: l.onboardingWelcomeBody,
            actions: [
              FilledButton(
                onPressed: controller.start,
                child: Text(l.onboardingStart),
              ),
            ],
          ),
          OnboardingStep(step: OnboardingStepKind.location) => _Step(
            title: l.onboardingLocationTitle,
            body: l.onboardingLocationBody,
            actions: [
              FilledButton(
                onPressed: controller.useApproximateLocation,
                child: Text(l.onboardingUseLocation),
              ),
              OutlinedButton(
                onPressed: controller.choosePlace,
                child: Text(l.onboardingChoosePlace),
              ),
            ],
          ),
          OnboardingStep(step: OnboardingStepKind.place) => ManualPlaceView(
            onPinned: controller.placePinned,
          ),
          OnboardingStep(step: OnboardingStepKind.done, :final placeLabel) =>
            _Step(
              title: l.onboardingDoneTitle,
              body: placeLabel.isEmpty
                  ? l.homeCurrentPlace
                  : l.onboardingDoneBody(placeLabel),
              actions: [
                FilledButton(
                  onPressed: controller.finish,
                  child: Text(l.onboardingShowTimes),
                ),
              ],
            ),
          OnboardingResolving() => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(l.onboardingResolving),
              ],
            ),
          ),
          OnboardingFailed(:final failure) => ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                l.onboardingFailedTitle,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              NeedsAttentionCard(const DescribeFailure()(failure)),
              FilledButton(
                onPressed: controller.choosePlace,
                child: Text(l.onboardingChoosePlace),
              ),
              TextButton(
                onPressed: controller.useApproximateLocation,
                child: Text(l.onboardingTryAgain),
              ),
            ],
          ),
        },
      ),
    );
  }
}

final class _Step extends StatelessWidget {
  const new({required this.title, required this.body, required this.actions});

  final String title;
  final String body;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(title, style: text.headlineSmall),
        const SizedBox(height: 12),
        Text(body, style: text.bodyLarge),
        const SizedBox(height: 24),
        for (final action in actions)
          Padding(padding: const EdgeInsets.only(bottom: 12), child: action),
      ],
    );
  }
}
