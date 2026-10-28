import 'package:daily_muslim/features/home/domain/day_view.dart';
import 'package:daily_muslim/features/home/domain/time_row_view.dart';
import 'package:daily_muslim/features/home/presentation/display_style.dart';
import 'package:daily_muslim/features/shell/domain/app_route.dart';
import 'package:daily_muslim/l10n/app_localizations.dart';
import 'package:dm_ui/dm_ui.dart';
import 'package:flutter/material.dart';
import 'package:geo_salah_core/geo_salah_core.dart';
import 'package:go_router/go_router.dart';

/// The rows of one [day], each with its confidence label (REQ-UX-001);
/// tapping a row opens its Passport entry, `<calcId>#<event>` (US-05).
final class TimeRows extends StatelessWidget {
  /// The rows of [day] in [style]; [next] is washed in [light] (§15 D89).
  const new({
    required this.day,
    required this.style,
    this.next,
    this.light,
    super.key,
  });

  /// The day.
  final DayView day;

  /// Locale and digits.
  final DisplayStyle style;

  /// The next prayer, highlighted; `null` highlights none.
  final PrayerEvent? next;

  /// The hour light of the highlight.
  final HourLight? light;

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
            swatch: HourLight.swatchOf(row.event),
            minor:
                row.event == PrayerEvent.sunrise ||
                row.event == PrayerEvent.imsak,
            // The hour's glow over the scheme's wash; half as much at night,
            // where a bright band would glare (§15 D89).
            highlight: row.event == next
                ? Color.alphaBlend(
                    (light ?? HourLight.day).glow.withValues(
                      alpha: Theme.of(context).brightness == Brightness.dark
                          ? 0.16
                          : 0.32,
                    ),
                    RawdahScheme.of(context).wash,
                  )
                : null,
            onTap: () => context.push(
              CalculationRoute(day.calculationId, event: row.event).location,
            ),
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
