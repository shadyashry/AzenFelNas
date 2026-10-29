import 'package:daily_muslim/features/home/presentation/display_style.dart';
import 'package:daily_muslim/features/home/presentation/home_providers.dart';
import 'package:daily_muslim/features/home/presentation/time_rows.dart';
import 'package:daily_muslim/features/home/presentation/timeline_state.dart';
import 'package:daily_muslim/features/shell/application/describe_failure.dart';
import 'package:daily_muslim/features/shell/presentation/needs_attention_card.dart';
import 'package:daily_muslim/l10n/app_localizations.dart';
import 'package:dm_ui/dm_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The day timeline (§18.4): today and the following days.
final class TimelinePage extends ConsumerWidget {
  /// The page.
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final style = DisplayStyle.of(context, ref);
    return Scaffold(
      appBar: AppBar(title: Text(l.timelineTitle)),
      body: switch (ref.watch(timelineStateProvider)) {
        TimelineLoading() => const Center(child: CircularProgressIndicator()),
        TimelineReady(:final days) => ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            // One illuminated section per day, the date as its heading
            // (§15 D89).
            for (final day in days)
              RawdahSection(
                title: style.digits.apply(
                  MaterialLocalizations.of(context).formatFullDate(
                    DateTime.utc(day.date.year, day.date.month, day.date.day),
                  ),
                ),
                children: [TimeRows(day: day, style: style)],
              ),
          ],
        ),
        // The same notice as everywhere else; the code is for support
        // (§15 D98).
        TimelineError(:final failure) => ListView(
          padding: const EdgeInsets.all(16),
          children: [NeedsAttentionCard(const DescribeFailure()(failure))],
        ),
      },
    );
  }
}
