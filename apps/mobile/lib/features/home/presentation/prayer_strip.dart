import 'package:daily_muslim/features/home/domain/day_view.dart';
import 'package:daily_muslim/features/home/presentation/display_style.dart';
import 'package:daily_muslim/features/home/presentation/time_rows.dart';
import 'package:daily_muslim/features/shell/domain/app_route.dart';
import 'package:daily_muslim/l10n/app_localizations.dart';
import 'package:dm_ui/dm_ui.dart';
import 'package:flutter/material.dart';
import 'package:geo_salah_core/geo_salah_core.dart';
import 'package:go_router/go_router.dart';

/// The day's five prayers side by side on a deep-green band (§15 D103),
/// laid over the hero's lower edge. The next prayer is framed in gold and
/// set bold (not colour alone). Each cell reads "prayer, time, confidence"
/// and opens its Passport entry, like the full list below (US-05,
/// REQ-UX-001); at large text a cell scales its words down to its width
/// rather than clipping them (REQ-UX-020).
final class PrayerStrip extends StatelessWidget {
  /// The strip of [day] in [style], with [next] framed.
  const new({required this.day, required this.style, this.next, super.key});

  /// The day.
  final DayView day;

  /// Locale and digits.
  final DisplayStyle style;

  /// The next prayer; `null` frames none.
  final PrayerEvent? next;

  /// The prayers the strip shows, in the day's order.
  static const List<PrayerEvent> events = [
    PrayerEvent.fajr,
    PrayerEvent.dhuhr,
    PrayerEvent.asr,
    PrayerEvent.maghrib,
    PrayerEvent.isha,
  ];

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final rows = [
      for (final event in events)
        ...day.rows.where((row) => row.event == event),
    ];
    final divider = RawdahPalette.gold.withValues(alpha: 0.25);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: RawdahPalette.forest,
        borderRadius: BorderRadius.circular(DmScales.radiusCard),
        border: Border.all(color: RawdahPalette.gold.withValues(alpha: 0.35)),
        boxShadow: DmElevation.raised,
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: IntrinsicHeight(
          child: Row(
            children: [
              for (final (i, row) in rows.indexed) ...[
                if (i > 0)
                  VerticalDivider(
                    width: 1,
                    thickness: 1,
                    indent: 14,
                    endIndent: 14,
                    color: row.event == next || rows[i - 1].event == next
                        ? Colors.transparent
                        : divider,
                  ),
                Expanded(
                  child: _Cell(
                    name: DisplayStyle.eventName(l, row.event),
                    time: style.digits.apply(TimeRows.timeText(l, row)),
                    chip: StatusCopy.chip(
                      row.confidence,
                      style.locale,
                      digits: style.digits,
                    ),
                    isNext: row.event == next,
                    onTap: () => context.push(
                      CalculationRoute(
                        day.calculationId,
                        event: row.event,
                      ).location,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

final class _Cell extends StatelessWidget {
  const new({
    required this.name,
    required this.time,
    required this.chip,
    required this.isNext,
    required this.onTap,
  });

  final String name;
  final String time;
  final String chip;
  final bool isNext;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isNext ? RawdahPalette.goldLight : RawdahPalette.ivory;
    return Semantics(
      label: '$name, $time, $chip',
      button: true,
      selected: isNext,
      excludeSemantics: true,
      onTap: onTap,
      child: Material(
        color: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DmScales.radiusControl),
          side: isNext
              ? const BorderSide(color: RawdahPalette.goldLight, width: 1.6)
              : BorderSide.none,
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 72),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      name,
                      style: DmTheme.naskh(
                        size: 17,
                        color: isNext ? color : RawdahPalette.ivoryMuted,
                        bold: isNext,
                      ).copyWith(height: 1.3),
                    ),
                    Text(
                      time,
                      style: DmTheme.naskh(
                        size: 24,
                        color: color,
                        bold: isNext,
                      ).copyWith(height: 1.2),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
