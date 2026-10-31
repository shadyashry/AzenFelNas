import 'package:daily_muslim/features/onboarding/domain/alert_status.dart';
import 'package:daily_muslim/features/onboarding/presentation/alert_setup_controller.dart';
import 'package:daily_muslim/features/onboarding/presentation/onboarding_controller.dart';
import 'package:daily_muslim/features/onboarding/presentation/welcome_action.dart';
import 'package:daily_muslim/l10n/app_localizations.dart';
import 'package:dm_ui/dm_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The actions of the setup-completion screen (§15 D127), each tied to
/// what it does:
///
/// - **Pending:** *Set up prayer alerts* asks for the missing grants, then
///   the screen reads the phone again; *View today's prayer times* ends
///   setup and asks for nothing.
/// - **Enabled:** *View today's prayer times* only.
/// - **Needs attention:** *Review alert settings* opens the screen that
///   fixes the first missing capability, beside *View today's prayer
///   times*; with nothing to open, only the times.
///
/// In a [landscape] pane the two sit side by side, labels at 15, when both
/// full labels fit [width]; otherwise the secondary action sits under the
/// primary one. Labels are never cut or shrunk to fit.
final class SetupActions extends ConsumerWidget {
  /// The actions for [status].
  const new({
    required this.status,
    required this.type,
    required this.landscape,
    required this.width,
    super.key,
  });

  /// Where alerts stand.
  final AlertStatus status;

  /// The type scale of the language shown.
  final WelcomeType type;

  /// A landscape pane.
  final bool landscape;

  /// The width the actions are laid out in.
  final double width;

  /// The labels' style in a landscape row.
  TextStyle get _rowStyle => type.action.copyWith(
    fontSize: 15,
    height: (type.action.height ?? 1) * 16 / 15,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final busy = ref.watch(alertSetupProvider).busy;
    final alerts = ref.read(alertSetupProvider.notifier);
    final onboarding = ref.read(onboardingProvider.notifier);
    final flexes = landscape ? _rowFlexes(context, status, l) : null;
    final row = flexes != null;
    final style = row ? _rowStyle : type.action;
    WelcomeAction primary(String label, {VoidCallback? onPressed}) =>
        WelcomeAction(
          key: const Key('setupPrimary'),
          kind: WelcomeActionKind.primary,
          label: label,
          textStyle: style,
          trailing: Icons.arrow_forward,
          loading: busy || status is AlertsChecking,
          loadingLabel: l.setupChecking,
          onPressed: onPressed,
        );
    final times = primary(l.setupViewTimes, onPressed: onboarding.showTimes);
    final (main, secondary) = switch (status) {
      AlertsChecking() => (primary(l.setupAlertsAction), true),
      AlertsPending(:final grants) => (
        primary(l.setupAlertsAction, onPressed: () => alerts.setUp(grants)),
        true,
      ),
      AlertsEnabled() || AlertsNeedAttention(grant: null) => (times, false),
      AlertsNeedAttention(grant: final grant?) => (
        primary(l.setupReview, onPressed: () => alerts.review(grant)),
        true,
      ),
    };
    if (!secondary) return main;
    final other = _ViewTimes(
      style: style,
      outlined: row,
      onPressed: onboarding.showTimes,
    );
    return switch (flexes) {
      (final first, final second) => Row(
        children: [
          Expanded(flex: first, child: main),
          const SizedBox(width: 12),
          Expanded(flex: second, child: other),
        ],
      ),
      null => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [main, const SizedBox(height: 8), other],
      ),
    };
  }

  /// The shares of a row in which both full labels fit, the primary one
  /// with its padding and arrow and the secondary one with its padding, or
  /// `null` when they do not fit side by side.
  (int, int)? _rowFlexes(
    BuildContext context,
    AlertStatus status,
    AppLocalizations l,
  ) {
    final first = switch (status) {
      AlertsChecking() || AlertsPending() => l.setupAlertsAction,
      AlertsNeedAttention(grant: _?) => l.setupReview,
      AlertsEnabled() || AlertsNeedAttention(grant: null) => null,
    };
    if (first == null) return null;
    double measure(String text) {
      final painter = TextPainter(
        text: TextSpan(text: text, style: _rowStyle),
        textDirection: Directionality.of(context),
        textScaler: MediaQuery.textScalerOf(context),
        maxLines: 1,
      )..layout();
      final w = painter.width;
      painter.dispose();
      return w;
    }

    final primary = measure(first) + 80;
    final secondary = measure(l.setupViewTimes) + 36;
    if (primary + secondary + 12 > width) return null;
    return (primary.ceil(), secondary.ceil());
  }
}

/// *View today's prayer times* as the second action: a quiet text button
/// under the primary one, or an outlined button beside it.
final class _ViewTimes extends StatelessWidget {
  const new({
    required this.style,
    required this.outlined,
    required this.onPressed,
  });

  final TextStyle style;
  final bool outlined;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final label = AppLocalizations.of(context).setupViewTimes;
    if (outlined) {
      return WelcomeAction(
        key: const Key('setupViewTimes'),
        kind: WelcomeActionKind.secondary,
        label: label,
        textStyle: style,
        onPressed: onPressed,
      );
    }
    return TextButton(
      key: const Key('setupViewTimes'),
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: EmeraldPalette.ink,
        minimumSize: const Size(64, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
        textStyle: style,
      ),
      child: Text(label, textAlign: TextAlign.center),
    );
  }
}
