import 'package:daily_muslim/features/onboarding/presentation/alert_setup_controller.dart';
import 'package:daily_muslim/features/onboarding/presentation/alerts_section.dart';
import 'package:daily_muslim/features/onboarding/presentation/ivory_sheet.dart';
import 'package:daily_muslim/features/onboarding/presentation/onboarding_controller.dart';
import 'package:daily_muslim/features/onboarding/presentation/place_summary.dart';
import 'package:daily_muslim/features/onboarding/presentation/setup_actions.dart';
import 'package:daily_muslim/features/onboarding/presentation/welcome_action.dart';
import 'package:daily_muslim/features/onboarding/presentation/welcome_metrics.dart';
import 'package:daily_muslim/features/schedule/presentation/schedule_providers.dart';
import 'package:daily_muslim/features/shell/application/describe_failure.dart';
import 'package:daily_muslim/features/shell/presentation/remediation_copy.dart';
import 'package:daily_muslim/l10n/app_localizations.dart';
import 'package:dm_core_types/dm_core_types.dart';
import 'package:dm_ui/dm_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The ivory content of the setup-completion screen (§15 D127): the
/// selected place with *Change*, why the times are not ready when they
/// failed, *Prayer alerts* and the actions at the foot. Spare height goes
/// above the actions, so they sit near the lower safe edge.
final class SetupDonePanel extends ConsumerWidget {
  /// The panel.
  const new({
    required this.metrics,
    required this.type,
    required this.width,
    required this.bottomInset,
    required this.place,
    required this.failure,
    required this.landscape,
    super.key,
  });

  /// How the window is used.
  final WelcomeMetrics metrics;

  /// The type scale of the language shown.
  final WelcomeType type;

  /// The panel's width.
  final double width;

  /// What covers the bottom of the screen: the navigation bar.
  final double bottomInset;

  /// The selected place and its country, as shown.
  final String place;

  /// Why the times could not be calculated, or `null`.
  final Failure? failure;

  /// A landscape pane: the actions may sit side by side.
  final bool landscape;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(alertStatusProvider);
    return IvorySheet(
      width: width,
      side: metrics.sidePadding,
      top: 26,
      bottom: 16 + bottomInset,
      radius: 29,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PlaceSummary(
            place: place,
            type: type,
            onChange: ref.read(onboardingProvider.notifier).choosePlace,
          ),
          if (failure case final Failure problem) ...[
            const SizedBox(height: 16),
            _TimesProblem(failure: problem, type: type),
          ],
          SizedBox(height: 26 * metrics.gap),
          AlertsSection(status: status, type: type, note: !metrics.sideBySide),
          const SizedBox(height: 24),
          const Spacer(),
          SetupActions(
            status: status,
            type: type,
            landscape: landscape,
            width: IvorySheet.contentWidthOf(width, metrics.sidePadding),
          ),
        ],
      ),
    );
  }
}

/// Why the times could not be calculated, in words, with *Try again*.
final class _TimesProblem extends ConsumerWidget {
  const new({required this.failure, required this.type});

  final Failure failure;
  final WelcomeType type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final notice = const DescribeFailure()(failure);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: EmeraldPalette.wash,
        borderRadius: BorderRadius.circular(17),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Tooltip(
              message: l.needsAttentionCode(notice.code.wire),
              triggerMode: TooltipTriggerMode.longPress,
              child: Text(
                RemediationCopy.of(l, notice.remediation),
                style: type.paragraph.copyWith(color: EmeraldPalette.support),
              ),
            ),
            const SizedBox(height: 10),
            WelcomeAction(
              key: const Key('setupRetry'),
              kind: WelcomeActionKind.secondary,
              label: l.setupRetry,
              textStyle: type.action,
              icon: Icons.refresh,
              onPressed: () => ref.invalidate(scheduleProvider),
            ),
          ],
        ),
      ),
    );
  }
}
