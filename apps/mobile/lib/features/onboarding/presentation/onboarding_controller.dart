import 'dart:ui';

import 'package:daily_muslim/features/contexts/domain/gazetteer_hit.dart';
import 'package:daily_muslim/features/contexts/domain/place_choice.dart';
import 'package:daily_muslim/features/contexts/domain/resolved_context.dart';
import 'package:daily_muslim/features/onboarding/application/complete_first_run.dart';
import 'package:daily_muslim/features/onboarding/presentation/onboarding_state.dart';
import 'package:daily_muslim/features/schedule/presentation/schedule_providers.dart';
import 'package:daily_muslim/features/settings/domain/setting_values.dart';
import 'package:daily_muslim/features/settings/presentation/settings_providers.dart';
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

  /// Asks for approximate location and resolves it; a refusal or no fix is
  /// [OnboardingFailed]. A fix is named after the place nearest it; a
  /// failure offers the largest place of the phone's time zone (§15 D100).
  /// One request runs at a time, and a city chosen while it runs stands
  /// (§15 D126).
  Future<void> useApproximateLocation() async {
    if (state is OnboardingResolving) return;
    state = const OnboardingResolving();
    final next = await _locate();
    if (state is OnboardingResolving) state = next;
  }

  Future<OnboardingState> _locate() async {
    switch (await ref.read(contextUseCasesProvider.future)) {
      case Err(:final failure):
        return OnboardingFailed(failure);
      case Ok(value: final useCases):
        switch (await useCases.locate()) {
          case Ok(:final value):
            final near = await useCases.nameNearest(value.context.place.point);
            return _done(value, name: near?.nameIn(_language));
          case Err(:final failure):
            final suggested = await useCases.suggest();
            return OnboardingFailed(
              failure,
              suggestion: suggested.firstOrNull?.namedIn(_language),
            );
        }
    }
  }

  /// Pins [place], the time zone's suggestion (§15 D100).
  Future<void> useSuggestion(GazetteerHit place) async {
    final failed = state;
    state = const OnboardingResolving();
    switch (await ref.read(contextUseCasesProvider.future)) {
      case Err(:final failure):
        state = OnboardingFailed(failure);
      case Ok(value: final useCases):
        state = switch (await useCases.pin(GazetteerChoice(place))) {
          Ok(:final value) => _done(value),
          Err(:final failure) => switch (failed) {
            OnboardingFailed(:final suggestion) => OnboardingFailed(
              failure,
              suggestion: suggestion,
            ),
            _ => OnboardingFailed(failure),
          },
        };
    }
  }

  /// The language of the app's text: the stored choice, else the device's.
  String get _language => switch (ref.read(localeSettingProvider).value) {
    LocaleSetting.ar => 'ar',
    LocaleSetting.en => 'en',
    LocaleSetting.system || null =>
      PlatformDispatcher.instance.locale.languageCode == 'ar' ? 'ar' : 'en',
  };

  /// The completion step a *Change* left, so Back from the city picker
  /// returns to it (§15 D127).
  OnboardingStep? _saved;

  /// → manual place search, from the welcome step or from *Change* on the
  /// completion step.
  void choosePlace() {
    _saved = switch (state) {
      final OnboardingStep step when step.step == OnboardingStepKind.done =>
        step,
      _ => null,
    };
    state = const OnboardingStep(OnboardingStepKind.place);
  }

  /// Back from the city picker: to the completion step it was opened from,
  /// else to the welcome step. The stored place is unchanged.
  void leavePlace() =>
      state = _saved ?? const OnboardingStep(OnboardingStepKind.welcome);

  /// Back to the welcome step.
  void backToWelcome() {
    _saved = null;
    state = const OnboardingStep(OnboardingStepKind.welcome);
  }

  /// A place was pinned in the place step.
  void placePinned(ResolvedContext context) {
    _saved = null;
    state = _done(context);
  }

  /// *View today's prayer times*: ends onboarding and Home takes over
  /// (§15 D127). The Athan is on from here (§15 D94) whether or not alerts
  /// were set up; nothing is asked for here, so skipping the optional setup
  /// never opens a prompt, and the notification permission (REQ-ALM-026) and
  /// exact alarms (§15 D96) are asked only by *Set up prayer alerts*.
  Future<void> showTimes() async {
    ref.invalidate(scheduleProvider);
    await ref.read(completeFirstRunProvider).call();
  }

  static OnboardingState _done(ResolvedContext context, {String? name}) =>
      OnboardingStep(
        OnboardingStepKind.done,
        placeLabel: name ?? context.context.place.label,
      );
}

/// The onboarding flow's state.
final onboardingProvider =
    NotifierProvider<OnboardingController, OnboardingState>(
      OnboardingController.new,
    );
