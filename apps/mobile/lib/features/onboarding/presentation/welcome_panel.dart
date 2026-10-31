import 'package:daily_muslim/features/onboarding/presentation/ivory_sheet.dart';
import 'package:daily_muslim/features/onboarding/presentation/location_notice.dart';
import 'package:daily_muslim/features/onboarding/presentation/onboarding_controller.dart';
import 'package:daily_muslim/features/onboarding/presentation/onboarding_state.dart';
import 'package:daily_muslim/features/onboarding/presentation/preferred_break_text.dart';
import 'package:daily_muslim/features/onboarding/presentation/welcome_action.dart';
import 'package:daily_muslim/features/onboarding/presentation/welcome_features.dart';
import 'package:daily_muslim/features/onboarding/presentation/welcome_metrics.dart';
import 'package:daily_muslim/features/shell/application/describe_failure.dart';
import 'package:daily_muslim/l10n/app_localizations.dart';
import 'package:dm_ui/dm_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The ivory panel of the welcome screen (§15 D126): the heading, the
/// paragraph, why location failed when it did, *Use my location*, *Choose
/// a city instead*, the privacy sentence, a quiet divider and the three
/// features. Fills the height it is given; spare height goes above the
/// divider, so the features sit at the foot of the screen.
final class WelcomePanel extends ConsumerWidget {
  /// The panel for [state]: the welcome step, resolving or failed.
  const new({
    required this.state,
    required this.metrics,
    required this.type,
    required this.width,
    required this.bottomInset,
    super.key,
  });

  /// The onboarding state shown.
  final OnboardingState state;

  /// How the window is used.
  final WelcomeMetrics metrics;

  /// The type scale of the language shown.
  final WelcomeType type;

  /// The panel's width.
  final double width;

  /// What covers the bottom of the screen: the navigation bar.
  final double bottomInset;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final controller = ref.read(onboardingProvider.notifier);
    final contentWidth = IvorySheet.contentWidthOf(
      width,
      metrics.sidePadding,
    );
    return IvorySheet(
      width: width,
      side: metrics.sidePadding,
      top: 27,
      bottom: 16 + bottomInset,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            header: true,
            child: Text(
              l.welcomeHeading,
              style: type.heading.copyWith(color: EmeraldPalette.ink),
            ),
          ),
          const SizedBox(height: 6),
          PreferredBreakText(
            l.welcomeBody,
            width: contentWidth,
            style: type.paragraph.copyWith(
              color: EmeraldPalette.inkMuted,
            ),
          ),
          if (state case OnboardingFailed(
            :final failure,
            :final suggestion,
          )) ...[
            const SizedBox(height: 18),
            LocationNotice(
              notice: const DescribeFailure()(failure),
              suggestion: suggestion,
              type: type,
            ),
          ],
          const SizedBox(height: 23),
          WelcomeAction(
            key: const Key('onboardingDetect'),
            kind: WelcomeActionKind.primary,
            label: l.welcomeUseLocation,
            textStyle: type.action,
            icon: Icons.my_location,
            trailing: Icons.arrow_forward,
            loading: state is OnboardingResolving,
            loadingLabel: l.onboardingResolving,
            onPressed: controller.useApproximateLocation,
          ),
          const SizedBox(height: 10),
          // Stays available while location is found (§15 D126).
          WelcomeAction(
            key: const Key('onboardingChooseCity'),
            kind: WelcomeActionKind.secondary,
            label: l.welcomeChooseCity,
            textStyle: type.action,
            icon: Icons.location_on_outlined,
            trailing: Icons.chevron_right,
            onPressed: controller.choosePlace,
          ),
          const SizedBox(height: 16),
          _Privacy(type: type),
          SizedBox(height: 22 * metrics.gap),
          const Spacer(),
          const ExcludeSemantics(
            child: Divider(
              height: 1,
              thickness: 1,
              color: EmeraldPalette.divider,
            ),
          ),
          SizedBox(height: 18 * metrics.gap),
          WelcomeFeatures(type: type),
        ],
      ),
    );
  }
}

/// The shield and the privacy sentence, centred.
final class _Privacy extends StatelessWidget {
  const new({required this.type});

  final WelcomeType type;

  @override
  Widget build(BuildContext context) => MergeSemantics(
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.verified_user_outlined,
          size: 16,
          color: EmeraldPalette.inkMuted,
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            AppLocalizations.of(context).welcomePrivacy,
            textAlign: TextAlign.center,
            style: type.privacy.copyWith(color: EmeraldPalette.inkMuted),
          ),
        ),
      ],
    ),
  );
}
