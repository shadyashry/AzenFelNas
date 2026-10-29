import 'package:daily_muslim/features/contexts/presentation/manual_place_view.dart';
import 'package:daily_muslim/features/onboarding/presentation/onboarding_controller.dart';
import 'package:daily_muslim/features/onboarding/presentation/onboarding_state.dart';
import 'package:daily_muslim/features/settings/domain/app_settings.dart';
import 'package:daily_muslim/features/settings/domain/setting_values.dart';
import 'package:daily_muslim/features/settings/presentation/settings_providers.dart';
import 'package:daily_muslim/features/shell/application/describe_failure.dart';
import 'package:daily_muslim/features/shell/domain/needs_attention.dart';
import 'package:daily_muslim/features/shell/presentation/remediation_action.dart';
import 'package:daily_muslim/features/shell/presentation/remediation_copy.dart';
import 'package:daily_muslim/l10n/app_localizations.dart';
import 'package:dm_ui/dm_ui.dart';
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
    final state = ref.watch(onboardingProvider);
    // The welcome step carries the logo, which already says the name.
    final welcome =
        state is OnboardingStep && state.step == OnboardingStepKind.welcome;
    return Scaffold(
      appBar: welcome ? null : AppBar(title: Text(l.appTitle)),
      body: SafeArea(
        child: switch (state) {
          OnboardingStep(step: OnboardingStepKind.welcome) => _Step(
            hero: Semantics(
              image: true,
              label: l.appTitle,
              child: Image.asset(
                'assets/brand/logo.png',
                width: 220,
                excludeFromSemantics: true,
              ),
            ),
            title: l.onboardingWelcomeTitle,
            body: l.onboardingWelcomeBody,
            // One tap to the times: the place is asked for right here
            // (§15 D98).
            actions: [
              const LanguageChoice(),
              FilledButton.icon(
                onPressed: controller.useApproximateLocation,
                icon: const Icon(Icons.my_location),
                label: Text(l.onboardingUseLocation),
              ),
              OutlinedButton.icon(
                onPressed: controller.choosePlace,
                icon: const Icon(Icons.search),
                label: Text(l.onboardingChoosePlace),
              ),
            ],
          ),
          OnboardingStep(step: OnboardingStepKind.place) => ManualPlaceView(
            onPinned: controller.placePinned,
          ),
          OnboardingStep(step: OnboardingStepKind.done, :final placeLabel) =>
            _Step(
              hero: const ReadinessMedallion(
                glyph: RawdahGlyphKind.mihrab,
                tone: MedallionTone.ready,
                size: 120,
              ),
              title: l.onboardingDoneTitle,
              body: [
                if (placeLabel.isEmpty)
                  l.homeCurrentPlace
                else
                  l.onboardingDoneBody(placeLabel),
                l.onboardingAthanPermissions,
              ].join('\n\n'),
              actions: [
                FilledButton(
                  onPressed: controller.finish,
                  child: Text(l.onboardingShowTimes),
                ),
              ],
            ),
          OnboardingResolving() => _Step(
            hero: const ReadinessMedallion(
              glyph: RawdahGlyphKind.starCompass,
              tone: null,
              size: 120,
            ),
            title: l.onboardingResolving,
            body: '',
            actions: const [Center(child: CircularProgressIndicator())],
          ),
          OnboardingFailed(:final failure) => _failed(
            l,
            controller,
            const DescribeFailure()(failure),
          ),
        },
      ),
    );
  }
}

/// Location did not work: the same Rawdah step as the rest of the first run
/// (§15 D98), the fix in words, its system-setting button when there is one
/// (back from it, location is tried again, §15 D97), then a place or a retry.
Widget _failed(
  AppLocalizations l,
  OnboardingController controller,
  NeedsAttention notice,
) {
  final settings = RemediationAction.hasAction(notice.remediation);
  final choosePlace = (
    icon: const Icon(Icons.search),
    label: Text(l.onboardingChoosePlace),
  );
  return _Step(
    hero: const ReadinessMedallion(
      glyph: RawdahGlyphKind.starCompass,
      tone: MedallionTone.limited,
      size: 120,
    ),
    title: l.onboardingFailedTitle,
    body: RemediationCopy.of(l, notice.remediation),
    titleTooltip: l.needsAttentionCode(notice.code.wire),
    actions: [
      if (settings) ...[
        RemediationAction(
          notice.remediation,
          onReturn: controller.useApproximateLocation,
        ),
        OutlinedButton.icon(
          onPressed: controller.choosePlace,
          icon: choosePlace.icon,
          label: choosePlace.label,
        ),
      ] else
        FilledButton.icon(
          onPressed: controller.choosePlace,
          icon: choosePlace.icon,
          label: choosePlace.label,
        ),
      TextButton(
        onPressed: controller.useApproximateLocation,
        child: Text(l.onboardingTryAgain),
      ),
    ],
  );
}

final class _Step extends StatelessWidget {
  const new({
    required this.title,
    required this.body,
    required this.actions,
    this.hero,
    this.titleTooltip,
  });

  /// Support detail shown on a long press of the title (the failure code,
  /// §15 D98).
  final String? titleTooltip;

  /// The brand mark above the welcome title (§15 D89).
  final Widget? hero;
  final String title;
  final String body;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        if (hero case final Widget mark) ...[
          Center(child: mark),
          const SizedBox(height: 28),
        ],
        Tooltip(
          message: titleTooltip ?? '',
          triggerMode: titleTooltip == null
              ? TooltipTriggerMode.manual
              : TooltipTriggerMode.longPress,
          child: Text(
            title,
            style: DmTheme.naskh(
              size: 28,
              color: Theme.of(context).colorScheme.primary,
              bold: true,
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (body.isNotEmpty) Text(body, style: text.bodyLarge),
        const SizedBox(height: 24),
        for (final action in actions)
          Padding(padding: const EdgeInsets.only(bottom: 12), child: action),
      ],
    );
  }
}

/// The language of the app, chosen on the first screen (§15 D97): Arabic or
/// English, starting from the device language; it is the Settings choice.
final class LanguageChoice extends ConsumerWidget {
  /// The choice.
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final shown = Localizations.localeOf(context).languageCode == 'ar'
        ? LocaleSetting.ar
        : LocaleSetting.en;
    return Semantics(
      label: l.settingsLanguage,
      child: SegmentedButton<LocaleSetting>(
        segments: const [
          // Each language is named in its own script.
          ButtonSegment(value: LocaleSetting.ar, label: Text('العربية')),
          ButtonSegment(value: LocaleSetting.en, label: Text('English')),
        ],
        selected: {shown},
        showSelectedIcon: false,
        onSelectionChanged: (choice) => ref
            .read(writeSettingProvider)
            .write(AppSettings.locale, choice.single),
      ),
    );
  }
}
