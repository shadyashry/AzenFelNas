import 'package:daily_muslim/features/home/presentation/display_style.dart';
import 'package:daily_muslim/features/home/presentation/home_providers.dart';
import 'package:daily_muslim/features/home/presentation/time_rows.dart';
import 'package:daily_muslim/features/home/presentation/timeline_state.dart';
import 'package:daily_muslim/l10n/app_localizations.dart';
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
          children: [
            for (final day in days) ...[
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 4),
                child: Text(
                  style.digits.apply(
                    MaterialLocalizations.of(context).formatFullDate(
                      DateTime.utc(day.date.year, day.date.month, day.date.day),
                    ),
                  ),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              TimeRows(day: day, style: style),
            ],
          ],
        ),
        TimelineError(:final failure) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              l.timelineError(failure.code.wire),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      },
    );
  }
}
