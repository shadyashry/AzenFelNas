import 'package:daily_muslim/features/contexts/domain/gazetteer_hit.dart';
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
/// Each step keeps its actions in a fixed panel at the bottom, so a change of
/// language or a longer text never moves a button (§15 D100).
final class OnboardingPage extends ConsumerWidget {
  /// The page.
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final controller = ref.read(onboardingProvider.notifier);
    final state = ref.watch(onboardingProvider);
    final place =
        state is OnboardingStep && state.step == OnboardingStepKind.place;
    return Scaffold(
      appBar: place
          ? AppBar(
              title: Text(l.onboardingChooseCity),
              leading: BackButton(onPressed: controller.backToWelcome),
            )
          : null,
      body: GirihBackdrop(
        ground: RawdahScheme.of(context).ground,
        ink: RawdahPalette.gold,
        // A whisper of pattern on the first run only (§15 D102).
        opacity: 0.05,
        tile: 72,
        child: SafeArea(
          child: switch (state) {
            OnboardingStep(step: OnboardingStepKind.welcome) => _Step(
              top: const Center(child: LanguageChoice()),
              hero: Semantics(
                image: true,
                label: l.appTitle,
                child: Image.asset(
                  'assets/brand/logo.png',
                  height: 210,
                  excludeFromSemantics: true,
                ),
              ),
              title: l.onboardingWelcomeTitle,
              body: l.onboardingWelcomeBody,
              extra: const _Features(),
              // One tap to the times: the place is found, not asked for
              // (§15 D98, D100).
              actions: [
                FilledButton.icon(
                  key: const Key('onboardingDetect'),
                  onPressed: controller.useApproximateLocation,
                  icon: const Icon(Icons.my_location),
                  label: Text(l.onboardingDetect),
                ),
                TextButton(
                  onPressed: controller.choosePlace,
                  child: Text(l.onboardingChooseCityMyself),
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
            OnboardingResolving() => _Step(
              hero: const SizedBox.square(
                dimension: 148,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox.square(
                      dimension: 148,
                      child: CircularProgressIndicator(strokeWidth: 3),
                    ),
                    ReadinessMedallion(
                      glyph: RawdahGlyphKind.starCompass,
                      tone: null,
                      size: 120,
                    ),
                  ],
                ),
              ),
              title: l.onboardingResolving,
              body: l.onboardingResolvingBody,
              actions: const [],
            ),
            OnboardingFailed(:final failure, :final suggestion) => _failed(
              l,
              controller,
              const DescribeFailure()(failure),
              suggestion,
            ),
          },
        ),
      ),
    );
  }
}

/// Location did not work: the same Rawdah step as the rest of the first run
/// (§15 D98), the fix in words, and the shortest way on: the city the
/// phone's time zone suggests (one tap, §15 D100), the system setting that
/// fixes location (back from it, location is tried again, §15 D97), or
/// another city.
Widget _failed(
  AppLocalizations l,
  OnboardingController controller,
  NeedsAttention notice,
  GazetteerHit? suggestion,
) {
  final settings = RemediationAction.hasAction(notice.remediation);
  return _Step(
    hero: const ReadinessMedallion(
      glyph: RawdahGlyphKind.starCompass,
      tone: MedallionTone.limited,
      size: 120,
    ),
    title: l.onboardingFailedTitle,
    body: RemediationCopy.of(l, notice.remediation),
    titleTooltip: l.needsAttentionCode(notice.code.wire),
    extra: suggestion == null
        ? null
        : _Note(
            icon: Icons.place_outlined,
            text: l.onboardingSuggestion(suggestion.displayName),
            detail: subtitleOf(suggestion),
          ),
    actions: [
      if (suggestion case final GazetteerHit place)
        FilledButton.icon(
          key: const Key('onboardingUseSuggestion'),
          onPressed: () => controller.useSuggestion(place),
          icon: const Icon(Icons.check),
          label: Text(l.onboardingUseSuggestion(place.displayName)),
        ),
      if (settings)
        RemediationAction(
          notice.remediation,
          onReturn: controller.useApproximateLocation,
          secondary: suggestion != null,
        ),
      if (suggestion == null && !settings)
        FilledButton.icon(
          onPressed: controller.choosePlace,
          icon: const Icon(Icons.search),
          label: Text(l.onboardingOtherCity),
        )
      else
        OutlinedButton.icon(
          onPressed: controller.choosePlace,
          icon: const Icon(Icons.search),
          label: Text(l.onboardingOtherCity),
        ),
      TextButton(
        onPressed: controller.useApproximateLocation,
        child: Text(l.onboardingTryAgain),
      ),
    ],
  );
}

/// One first-run step: [top] fixed above, the hero, title, body and [extra]
/// scrolling in the middle, and [actions] in a fixed panel at the bottom.
final class _Step extends StatelessWidget {
  const new({
    required this.title,
    required this.body,
    required this.actions,
    this.hero,
    this.top,
    this.extra,
    this.titleTooltip,
  });

  /// Support detail shown on a long press of the title (the failure code,
  /// §15 D98).
  final String? titleTooltip;

  /// The brand mark or the step's medallion (§15 D89).
  final Widget? hero;

  /// Fixed above the content: the language choice.
  final Widget? top;

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
        if (top case final Widget bar)
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
            child: bar,
          ),
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
                  Tooltip(
                    message: titleTooltip ?? '',
                    triggerMode: titleTooltip == null
                        ? TooltipTriggerMode.manual
                        : TooltipTriggerMode.longPress,
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: DmTheme.naskh(
                        size: 28,
                        color: r.primary,
                        bold: true,
                      ),
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

/// What the app does, in three marks under the welcome text.
final class _Features extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _Feature(
            icon: Icons.cloud_off_outlined,
            label: l.onboardingFeatureOffline,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _Feature(
            icon: Icons.notifications_active_outlined,
            label: l.onboardingFeatureAthan,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _Feature(
            icon: Icons.explore_outlined,
            label: l.onboardingFeatureQibla,
          ),
        ),
      ],
    );
  }
}

final class _Feature extends StatelessWidget {
  const new({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final r = RawdahScheme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: r.panel,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: r.hairline),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 14),
        child: Column(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(color: r.wash, shape: BoxShape.circle),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Icon(icon, color: r.primary, size: 22),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ],
        ),
      ),
    );
  }
}

/// A panel with an icon, a line and an optional [detail].
final class _Note extends StatelessWidget {
  const new({required this.icon, required this.text, this.detail});

  final IconData icon;
  final String text;
  final String? detail;

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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(text, style: style.bodyMedium),
                  if (detail case final String line)
                    Text(
                      line,
                      style: style.labelMedium?.copyWith(color: r.inkMuted),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The language of the app, chosen on the first screen (§15 D97): Arabic or
/// English, starting from the device language; it is the Settings choice.
/// The control is laid out left to right in both languages and each half has
/// a fixed width, so switching moves nothing on screen (§15 D100).
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
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: SizedBox(
          width: 248,
          child: SegmentedButton<LocaleSetting>(
            segments: const [
              // Each language is named in its own script.
              ButtonSegment(value: LocaleSetting.en, label: Text('English')),
              ButtonSegment(value: LocaleSetting.ar, label: Text('العربية')),
            ],
            selected: {shown},
            showSelectedIcon: false,
            onSelectionChanged: (choice) => ref
                .read(writeSettingProvider)
                .write(AppSettings.locale, choice.single),
          ),
        ),
      ),
    );
  }
}
