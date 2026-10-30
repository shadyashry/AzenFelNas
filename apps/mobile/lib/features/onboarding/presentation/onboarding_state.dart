import 'package:daily_muslim/features/contexts/domain/gazetteer_hit.dart';
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

  /// The place's name: the chosen place, or the place nearest the device
  /// location (§15 D100); empty when no place is near.
  final String placeLabel;
}

/// Location access is asked for and the place resolved.
final class OnboardingResolving extends OnboardingState {
  /// The state.
  const new();
}

/// Location failed; the user may retry or choose a place (§18.3 denial
/// branch), or take the largest place of the phone's time zone with one tap
/// (§15 D100).
final class OnboardingFailed extends OnboardingState {
  /// The state.
  const new(this.failure, {this.suggestion});

  /// Why.
  final Failure failure;

  /// The place the phone's time zone suggests, or `null` when it names none.
  final GazetteerHit? suggestion;
}
