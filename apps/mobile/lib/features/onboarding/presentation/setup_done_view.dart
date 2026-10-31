import 'package:daily_muslim/features/contexts/domain/country_names.dart';
import 'package:daily_muslim/features/home/presentation/home_providers.dart';
import 'package:daily_muslim/features/onboarding/presentation/emerald_frame.dart';
import 'package:daily_muslim/features/onboarding/presentation/onboarding_controller.dart';
import 'package:daily_muslim/features/onboarding/presentation/setup_done_hero.dart';
import 'package:daily_muslim/features/onboarding/presentation/setup_done_panel.dart';
import 'package:daily_muslim/features/onboarding/presentation/times_progress.dart';
import 'package:daily_muslim/features/onboarding/presentation/welcome_metrics.dart';
import 'package:daily_muslim/features/schedule/presentation/schedule_providers.dart';
import 'package:daily_muslim/l10n/app_localizations.dart';
import 'package:dm_core_types/dm_core_types.dart';
import 'package:dm_ui/dm_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The setup-completion screen (§15 D127): the place is saved; the prayer
/// times are ready once calculated; prayer alerts are a separate, optional
/// step whose state is read from the phone. In an [EmeraldFrame], so it
/// follows the window like the welcome screen. Back returns to the welcome
/// step; the stored place stays.
final class SetupDoneView extends ConsumerWidget {
  /// The screen; [placeLabel] names the place until the gazetteer does.
  const new({required this.placeLabel, super.key});

  /// The name the place was stored under (§15 D100).
  final String placeLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = Localizations.localeOf(context).languageCode;
    final textScale = MediaQuery.textScalerOf(context).scale(16) / 16;
    final metrics = WelcomeMetrics.of(MediaQuery.sizeOf(context), textScale);
    final type = WelcomeType.of(
      language == 'ar' ? StatusLocale.ar : StatusLocale.en,
      compact: metrics.compactType,
    );
    final (progress, failure) = switch (ref.watch(scheduleProvider)) {
      AsyncData(value: Ok()) => (TimesProgress.ready, null),
      AsyncData(value: Err(:final failure)) => (TimesProgress.failed, failure),
      AsyncError() => (TimesProgress.failed, null),
      AsyncLoading() => (TimesProgress.preparing, null),
    };
    final controller = ref.read(onboardingProvider.notifier);
    final place = _placeName(context, ref, language);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) controller.backToWelcome();
      },
      child: EmeraldFrame(
        key: const Key('setupDone'),
        sideBySide: metrics.sideBySide,
        heroShare: 0,
        heroPaneShare: 0.36,
        hero: (minHeight, width, topInset) => SetupDoneHero(
          metrics: metrics,
          type: type,
          progress: progress,
          minHeight: minHeight,
          width: width,
          topInset: topInset,
          onBack: controller.backToWelcome,
        ),
        panel: (width, bottomInset) => SetupDonePanel(
          metrics: metrics,
          type: type,
          width: width,
          bottomInset: bottomInset,
          place: place,
          failure: failure,
          landscape: metrics.sideBySide,
        ),
      ),
    );
  }

  /// The place in the reader's language with its country, from the
  /// gazetteer (§15 D104, D127): «القاهرة، مصر». A name the gazetteer does
  /// not know, such as one typed with coordinates, is shown as stored,
  /// isolated so a Latin name keeps its order in Arabic.
  String _placeName(BuildContext context, WidgetRef ref, String language) {
    final l = AppLocalizations.of(context);
    final hit = ref.watch(placeNameProvider).value;
    if (hit == null) {
      return placeLabel.isEmpty
          ? l.homeCurrentPlace
          : _isolated(placeLabel, language);
    }
    final city = _isolated(hit.nameIn(language), language);
    return switch (CountryNames.of(hit.country, language)) {
      final String country => l.setupPlace(city, country),
      null => city,
    };
  }

  static final _arabic = RegExp('[؀-ۿ]');

  /// [name] wrapped in a first-strong isolate when its script differs from
  /// the page's, so a Latin name keeps its order inside Arabic and the
  /// comma after it stays in place; never reversed by hand.
  static String _isolated(String name, String language) =>
      _arabic.hasMatch(name) == (language == 'ar') ? name : '\u2068$name\u2069';
}
