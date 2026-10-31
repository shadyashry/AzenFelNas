import 'package:daily_muslim/features/athan/domain/athan_grant.dart';
import 'package:daily_muslim/features/onboarding/domain/alert_status.dart';
import 'package:daily_muslim/l10n/app_localizations.dart';
import 'package:dm_ui/dm_ui.dart';
import 'package:flutter/material.dart';

/// *Prayer alerts* on the setup-completion screen (§15 D127): a bell, the
/// title, a status in words, what it means and, while alerts are not on,
/// that the times do not need them ([note]). The text is the phone's
/// answer, read out when it changes.
final class AlertsSection extends StatelessWidget {
  /// The section for [status].
  const new({
    required this.status,
    required this.type,
    required this.note,
    super.key,
  });

  /// Where alerts stand.
  final AlertStatus status;

  /// The type scale of the language shown.
  final WelcomeType type;

  /// Shows *You can view prayer times without enabling alerts.* while
  /// alerts are not on; a short landscape pane leaves it out.
  final bool note;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final small = type.privacy.copyWith(
      color: EmeraldPalette.inkMuted,
      fontSize: 13,
      height: 20 / 13,
    );
    final (label, body, helper) = switch (status) {
      AlertsChecking() => (l.setupChecking, l.setupPendingBody, null),
      AlertsPending() => (
        l.setupOptional,
        l.setupPendingBody,
        l.setupPendingHelper,
      ),
      AlertsEnabled() => (
        l.setupEnabled,
        l.setupEnabledBody,
        l.setupEnabledHelper,
      ),
      AlertsNeedAttention(:final grant) => (
        l.setupAttention,
        switch (grant) {
          AthanGrant.notifications => l.setupMissingNotifications,
          AthanGrant.exactAlarms => l.setupMissingExactAlarms,
          AthanGrant.appSettings => l.setupMissingAppSettings,
          null => l.setupMissingUnknown,
        },
        null,
      ),
    };
    final showNote = note && status is! AlertsEnabled;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const ExcludeSemantics(
              child: Icon(
                Icons.notifications_active_outlined,
                size: 24,
                color: RawdahPalette.goldInk,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Semantics(
                header: true,
                child: Text(
                  l.setupAlertsTitle,
                  style: type.heading.copyWith(color: EmeraldPalette.ink),
                ),
              ),
            ),
            const SizedBox(width: 8),
            _Status(
              label: label,
              checking: status is AlertsChecking,
              style: type.caption.copyWith(color: EmeraldPalette.inkMuted),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Semantics(
          liveRegion: true,
          child: Text(
            body,
            key: const Key('setupAlertsBody'),
            style: type.paragraph.copyWith(color: EmeraldPalette.support),
          ),
        ),
        if (helper case final String line) ...[
          const SizedBox(height: 8),
          Text(line, style: small),
        ],
        if (showNote) ...[
          const SizedBox(height: 22),
          const ExcludeSemantics(
            child: Divider(
              height: 1,
              thickness: 1,
              color: EmeraldPalette.divider,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              const ExcludeSemantics(
                child: Icon(
                  Icons.info_outline,
                  size: 18,
                  color: EmeraldPalette.inkMuted,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(l.setupWithoutAlerts, style: small)),
            ],
          ),
        ],
      ],
    );
  }
}

/// The status in a quiet pill.
final class _Status extends StatelessWidget {
  const new({
    required this.label,
    required this.checking,
    required this.style,
  });

  final String label;
  final bool checking;
  final TextStyle style;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: EmeraldPalette.wash,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (checking) ...[
            const SizedBox.square(
              dimension: 12,
              child: CircularProgressIndicator(
                strokeWidth: 1.5,
                color: EmeraldPalette.inkMuted,
              ),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            key: const Key('setupAlertsStatus'),
            style: style,
          ),
        ],
      ),
    ),
  );
}
