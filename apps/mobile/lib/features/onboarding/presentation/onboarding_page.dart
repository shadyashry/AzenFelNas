import 'package:daily_muslim/features/onboarding/presentation/city_picker_view.dart';
import 'package:daily_muslim/features/onboarding/presentation/onboarding_controller.dart';
import 'package:daily_muslim/features/onboarding/presentation/onboarding_state.dart';
import 'package:daily_muslim/features/onboarding/presentation/setup_done_view.dart';
import 'package:daily_muslim/features/onboarding/presentation/welcome_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The first run (§18.4 Onboarding): every [OnboardingState] is rendered by
/// one exhaustive switch. The Emerald horizon welcome screen shows the
/// welcome step, the search for the device's place and its failure
/// (§15 D126); the city picker the place step; the setup-completion screen
/// the done step (§15 D127). Only approximate location is asked for
/// (§18.3).
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
        onBack: controller.leavePlace,
      ),
      OnboardingStep(step: OnboardingStepKind.done, :final placeLabel) =>
        SetupDoneView(placeLabel: placeLabel),
    };
  }
}
