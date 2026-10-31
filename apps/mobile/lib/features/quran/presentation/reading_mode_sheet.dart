import 'package:daily_muslim/l10n/app_localizations.dart';
import 'package:dm_ui/dm_ui.dart';
import 'package:flutter/material.dart';

/// The reading mode (§15 D120, D121): the calm, monochrome Mushaf as
/// printed is the only mode, and the *Tajweed colours* switch is shown off
/// and disabled, with why: no permitted Tajweed source matching these
/// pages exists yet, and the app never colours letters or marks itself.
Future<void> showReadingModeSheet(BuildContext context) =>
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => const _ReadingMode(),
    );

final class _ReadingMode extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = RawdahScheme.of(context);
    final body = theme.textTheme.bodyMedium?.copyWith(color: scheme.inkMuted);
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l.quranReadingMode, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(l.quranCalmReading, style: body),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: false,
              onChanged: null,
              title: Text(l.quranTajweed),
              subtitle: Text(l.quranTajweedUnavailableShort),
            ),
            Text(l.quranTajweedUnavailable, style: body),
          ],
        ),
      ),
    );
  }
}
