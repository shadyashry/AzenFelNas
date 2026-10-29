import 'package:daily_muslim/features/athan/domain/athan_grant.dart';
import 'package:daily_muslim/features/athan/presentation/athan_providers.dart';
import 'package:daily_muslim/features/contexts/domain/resolved_context.dart';
import 'package:daily_muslim/features/onboarding/application/complete_first_run.dart';
import 'package:daily_muslim/features/onboarding/presentation/onboarding_state.dart';
import 'package:daily_muslim/features/schedule/presentation/schedule_providers.dart';
import 'package:dm_core_types/dm_core_types.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Bound in `app/di.dart`: marks the first run complete.
final completeFirstRunProvider = Provider<CompleteFirstRun>(
  (ref) => throw UnimplementedError('bound in app/di.dart'),
);

/// Drives [OnboardingState] (US-01, US-02).
final class OnboardingController extends Notifier<OnboardingState> {
  @override
  OnboardingState build() => const OnboardingStep(OnboardingStepKind.welcome);

  /// Welcome → location.
  void start() => state = const OnboardingStep(OnboardingStepKind.location);

  /// Asks for approximate location and resolves it; a refusal or no fix is
  /// [OnboardingFailed].
  Future<void> useApproximateLocation() async {
    state = const OnboardingResolving();
    switch (await ref.read(contextUseCasesProvider.future)) {
      case Err(:final failure):
        state = OnboardingFailed(failure);
      case Ok(value: final useCases):
        state = switch (await useCases.locate()) {
          Ok(:final value) => _done(value),
          Err(:final failure) => OnboardingFailed(failure),
        };
    }
  }

  /// → manual place search.
  void choosePlace() => state = const OnboardingStep(OnboardingStepKind.place);

  /// A place was pinned in the place step.
  void placePinned(ResolvedContext context) => state = _done(context);

  /// Ends onboarding; Home takes over. The Athan is on from here (§15 D94),
  /// so the notification permission is asked for now (REQ-ALM-026).
  Future<void> finish() async {
    await ref.read(requestAthanGrantProvider).call(AthanGrant.notifications);
    ref.invalidate(scheduleProvider);
    await ref.read(completeFirstRunProvider).call();
  }

  static OnboardingState _done(ResolvedContext context) => OnboardingStep(
    OnboardingStepKind.done,
    placeLabel: context.context.place.label,
  );
}

/// The onboarding flow's state.
final onboardingProvider =
    NotifierProvider<OnboardingController, OnboardingState>(
      OnboardingController.new,
    );
