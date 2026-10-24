import 'package:daily_muslim/features/settings/presentation/diagnostics_providers.dart';
import 'package:daily_muslim/features/shell/application/describe_failure.dart';
import 'package:daily_muslim/features/shell/domain/needs_attention.dart';
import 'package:daily_muslim/features/shell/presentation/needs_attention_card.dart';
import 'package:daily_muslim/l10n/app_localizations.dart';
import 'package:dm_core_types/dm_core_types.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Diagnostics (§18.4 `exporting`, US-19): the whole redacted bundle is
/// shown before the user can copy it (REQ-PRIV-005).
final class DiagnosticsPage extends ConsumerStatefulWidget {
  /// The page.
  const new({super.key});

  @override
  ConsumerState<DiagnosticsPage> createState() => _DiagnosticsPageState();
}

final class _DiagnosticsPageState extends ConsumerState<DiagnosticsPage> {
  bool _exporting = false;
  FailureCode? _failure;

  Future<void> _export(String text) async {
    setState(() => _exporting = true);
    final result = await ref.read(exportDiagnosticBundleProvider).call(text);
    if (!mounted) return;
    setState(() {
      _exporting = false;
      _failure = switch (result) {
        Ok() => null,
        Err(:final failure) => failure,
      };
    });
    if (result is Ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).diagnosticsCopied)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = ref.watch(diagnosticTextProvider);
    final failure = _failure;
    return Scaffold(
      appBar: AppBar(title: Text(l.diagnosticsTitle)),
      body: switch (text) {
        AsyncData(:final value) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(l.diagnosticsIntro),
            const SizedBox(height: 12),
            if (failure != null) ...[
              NeedsAttentionCard(
                NeedsAttention(
                  code: failure,
                  remediation: DescribeFailure.of(failure),
                ),
              ),
              const SizedBox(height: 12),
            ],
            FilledButton(
              onPressed: _exporting ? null : () => _export(value),
              child: Text(l.diagnosticsCopy),
            ),
            const SizedBox(height: 12),
            DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: SelectableText(
                  value,
                  key: const Key('diagnosticsContents'),
                  textDirection: TextDirection.ltr,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ),
            ),
          ],
        ),
        AsyncError() => Center(child: Text(l.diagnosticsUnavailable)),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}
