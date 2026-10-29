import 'package:daily_muslim/features/shell/domain/needs_attention.dart';
import 'package:daily_muslim/features/shell/domain/open_system_settings.dart';
import 'package:daily_muslim/features/shell/domain/remediation.dart';
import 'package:daily_muslim/features/shell/presentation/remediation_copy.dart';
import 'package:daily_muslim/features/shell/presentation/shell_providers.dart';
import 'package:daily_muslim/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A `Needs attention` notice (§10.2): what to do, and the Appendix J code
/// for support. Read by screen readers as one node. A remediation that is a
/// system setting has a button that opens it (§15 D97); [onReturn] runs when
/// the user comes back from that screen.
final class NeedsAttentionCard extends ConsumerStatefulWidget {
  /// The card for [notice].
  const new(this.notice, {this.onReturn, super.key});

  /// The notice.
  final NeedsAttention notice;

  /// Called once the user is back from the settings the button opened.
  final VoidCallback? onReturn;

  @override
  ConsumerState<NeedsAttentionCard> createState() => _NeedsAttentionState();
}

final class _NeedsAttentionState extends ConsumerState<NeedsAttentionCard> {
  late final AppLifecycleListener _lifecycle;

  /// Whether the button sent the user to system settings.
  bool _awaitingReturn = false;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(onResume: _resumed);
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  void _resumed() {
    if (!_awaitingReturn) return;
    _awaitingReturn = false;
    widget.onReturn?.call();
  }

  Future<void> _open(Future<void> Function() open) async {
    _awaitingReturn = true;
    await open();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final notice = widget.notice;
    OpenSystemSettings settings() => ref.read(openSystemSettingsProvider);
    final action = switch (notice.remediation) {
      Remediation.turnOnLocationServices => (
        l.remediationActionTurnOnLocation,
        () => settings().location(),
      ),
      Remediation.grantLocationPermission => (
        l.remediationActionOpenSettings,
        () => settings().app(),
      ),
      Remediation.chooseManualPlace ||
      Remediation.waitForDataUpdate ||
      Remediation.retryWhenOnline ||
      Remediation.freeUpStorage ||
      Remediation.tryAgain ||
      Remediation.updateApp ||
      Remediation.grantAlarmPermission ||
      Remediation.openAthanHealth ||
      Remediation.checkDeviceClock => null,
    };
    return Semantics(
      container: true,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l.needsAttentionTitle, style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(RemediationCopy.of(l, notice.remediation)),
              const SizedBox(height: 8),
              Text(
                l.needsAttentionCode(notice.code.wire),
                style: theme.textTheme.bodySmall,
              ),
              if (action case (final String label, final open)) ...[
                const SizedBox(height: 12),
                FilledButton.tonal(
                  onPressed: () => _open(open),
                  child: Text(label),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
