import 'package:dm_core_types/dm_core_types.dart';

/// Onboarding (§18.4): `step(welcome|location|place|done)`, `resolving`,
/// `failed(failure)`.
sealed class OnboardingState {
  const new();
}

/// The steps of the first run.
enum OnboardingStepKind {
  /// What the app is and that it works offline.
  welcome,

  /// Manual place search.
  place,

  /// The place is stored; Home can show times.
  done,
}

/// The user is on [step].
final class OnboardingStep extends OnboardingState {
  /// The state; [placeLabel] names the chosen place on
  /// [OnboardingStepKind.done].
  const new(this.step, {this.placeLabel = ''});

  /// The step.
  final OnboardingStepKind step;

  /// The chosen place's name (empty for the device location).
  final String placeLabel;
}

/// Location access is asked for and the place resolved.
final class OnboardingResolving extends OnboardingState {
  /// The state.
  const new();
}

/// Location failed; the user may retry or choose a place (§18.3 denial
/// branch).
final class OnboardingFailed extends OnboardingState {
  /// The state.
  const new(this.failure);

  /// Why.
  final Failure failure;
}
