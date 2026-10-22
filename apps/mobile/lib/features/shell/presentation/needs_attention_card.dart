import 'package:daily_muslim/features/shell/domain/needs_attention.dart';
import 'package:daily_muslim/features/shell/presentation/remediation_copy.dart';
import 'package:daily_muslim/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// A `Needs attention` notice (§10.2): what to do, and the Appendix J code
/// for support. Read by screen readers as one node.
final class NeedsAttentionCard extends StatelessWidget {
  /// The card for [notice].
  const new(this.notice, {super.key});

  /// The notice.
  final NeedsAttention notice;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
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
            ],
          ),
        ),
      ),
    );
  }
}
