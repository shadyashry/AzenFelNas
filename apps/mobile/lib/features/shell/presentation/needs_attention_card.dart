import 'package:daily_muslim/features/shell/domain/needs_attention.dart';
import 'package:daily_muslim/features/shell/presentation/remediation_action.dart';
import 'package:daily_muslim/features/shell/presentation/remediation_copy.dart';
import 'package:daily_muslim/l10n/app_localizations.dart';
import 'package:dm_ui/dm_ui.dart';
import 'package:flutter/material.dart';

/// A `Needs attention` notice (§10.2) in the app's Rawdah style: what to do,
/// and a button when the fix is a system setting (§15 D97). The Appendix J
/// code is for support, not for the reader: it is shown on a long press of
/// the title and recorded in the diagnostics (§15 D98). Read by screen
/// readers as one node.
final class NeedsAttentionCard extends StatelessWidget {
  /// The card for [notice].
  const new(this.notice, {this.onReturn, super.key});

  /// The notice.
  final NeedsAttention notice;

  /// Called once the user is back from the settings the button opened.
  final VoidCallback? onReturn;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Semantics(
      container: true,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: RawdahPalette.gold.withValues(alpha: 0.6)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.info_outline, color: RawdahPalette.gold),
                const SizedBox(width: 10),
                Expanded(
                  child: Tooltip(
                    message: l.needsAttentionCode(notice.code.wire),
                    triggerMode: TooltipTriggerMode.longPress,
                    child: Text(
                      l.needsAttentionTitle,
                      style: DmTheme.naskh(
                        size: 20,
                        color: theme.colorScheme.primary,
                        bold: true,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              RemediationCopy.of(l, notice.remediation),
              style: theme.textTheme.bodyLarge,
            ),
            if (RemediationAction.hasAction(notice.remediation)) ...[
              const SizedBox(height: 14),
              RemediationAction(notice.remediation, onReturn: onReturn),
            ],
          ],
        ),
      ),
    );
  }
}
