import 'package:daily_muslim/features/home/domain/day_view.dart';
import 'package:daily_muslim/features/home/domain/time_row_view.dart';
import 'package:daily_muslim/features/home/presentation/display_style.dart';
import 'package:daily_muslim/l10n/app_localizations.dart';
import 'package:dm_ui/dm_ui.dart';
import 'package:flutter/material.dart';

/// The rows of one [day], each with its confidence label (REQ-UX-001).
final class TimeRows extends StatelessWidget {
  /// The rows of [day] in [style].
  const new({required this.day, required this.style, super.key});

  /// The day.
  final DayView day;

  /// Locale and digits.
  final DisplayStyle style;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final row in day.rows)
          TimeRow(
            eventName: DisplayStyle.eventName(l, row.event),
            timeText: timeText(l, row),
            label: row.confidence,
            locale: style.locale,
            digits: style.digits,
          ),
      ],
    );
  }

  /// `HH:mm`, with "+1"/"−1" when the time falls on the next or previous
  /// civil day (US-04), or a dash when the event has no time.
  static String timeText(AppLocalizations l, TimeRowView row) =>
      switch ((row.localTime, row.dayOffset)) {
        (null, _) => l.noTimeText,
        (final String time, 0) => time,
        (final String time, final offset) when offset > 0 => '$time +$offset',
        (final String time, final offset) => '$time $offset',
      };
}
