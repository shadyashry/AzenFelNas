import 'package:daily_muslim/features/home/domain/day_view.dart';
import 'package:daily_muslim/features/home/domain/time_row_view.dart';
import 'package:daily_muslim/features/home/presentation/clock_text.dart';
import 'package:daily_muslim/features/home/presentation/display_style.dart';
import 'package:daily_muslim/features/shell/domain/app_route.dart';
import 'package:daily_muslim/l10n/app_localizations.dart';
import 'package:dm_ui/dm_ui.dart';
import 'package:flutter/material.dart';
import 'package:geo_salah_core/geo_salah_core.dart';
import 'package:go_router/go_router.dart';

/// The day's five prayers side by side (§15 D105, D109), in day order from
/// the reading start: each column the prayer's name, its time and the
/// AM/PM marker under it, divided by hairlines; the next prayer on a
/// pale-gold tile with dark-green text, set in the same column width as
/// its neighbours. Each cell reads "prayer, time, confidence" and opens
/// its Passport entry, like the full list below (US-05, REQ-UX-001). At
/// large text the columns grow taller and the words wrap; nothing shrinks.
final class PrayerStrip extends StatelessWidget {
  /// The strip of [day] in [style], with [next] marked.
  const new({required this.day, required this.style, this.next, super.key});

  /// The day.
  final DayView day;

  /// Locale and digits.
  final DisplayStyle style;

  /// The next prayer; `null` marks none.
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
    final type = DmType.of(style.locale);
    final rows = [
      for (final event in events)
        ...day.rows.where((row) => row.event == event),
    ];
    final divider = RawdahScheme.of(context).hairline;
    Widget cell(TimeRowView row) => _Cell(
      name: DisplayStyle.eventName(l, row.event),
      time: ClockText.of(context, l, row, style),
      chip: StatusCopy.chip(row.confidence, style.locale, digits: style.digits),
      type: type,
      isNext: row.event == next,
      onTap: () => context.push(
        CalculationRoute(day.calculationId, event: row.event).location,
      ),
    );
    // The width the widest time and name need at the reader's text size,
    // measured, so the columns reflow only when they truly do not fit.
    final scaler = MediaQuery.textScalerOf(context);
    double widthOf(String text, TextStyle style) {
      final painter = TextPainter(
        text: TextSpan(text: text, style: style),
        textDirection: Directionality.of(context),
        textScaler: scaler,
        maxLines: 1,
      )..layout();
      final width = painter.width;
      painter.dispose();
      return width;
    }

    // Plus the cell's own horizontal padding (2 on each side).
    final needed =
        4 +
        [
          for (final row in rows) ...[
            widthOf(
              [
                ClockText.of(context, l, row, style).clock,
                ?ClockText.of(context, l, row, style).offset,
              ].join(' '),
              type.rowTime,
            ),
            widthOf(DisplayStyle.eventName(l, row.event), type.rowName),
          ],
        ].fold(0.0, (a, b) => a > b ? a : b);
    return LayoutBuilder(
      builder: (context, box) {
        // Five columns and the four hairlines between them.
        if (needed * rows.length + rows.length - 1 <= box.maxWidth) {
          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
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
                  Expanded(child: cell(row)),
                ],
              ],
            ),
          );
        }
        // Large text: as many equal columns as fit, the rest on more rows.
        final columns = (box.maxWidth / needed).floor().clamp(1, rows.length);
        final width = box.maxWidth / columns;
        return Wrap(
          children: [
            for (final row in rows) SizedBox(width: width, child: cell(row)),
          ],
        );
      },
    );
  }
}

final class _Cell extends StatelessWidget {
  const new({
    required this.name,
    required this.time,
    required this.chip,
    required this.type,
    required this.isNext,
    required this.onTap,
  });

  final String name;
  final ClockText time;
  final String chip;
  final DmType type;
  final bool isNext;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final r = RawdahScheme.of(context);
    final dark = Theme.of(context).brightness == Brightness.dark;
    // Light gold under dark-green ink by day; a deep gold wash at night.
    final tile = dark
        ? RawdahPalette.gold.withValues(alpha: 0.22)
        : Color.alphaBlend(
            RawdahPalette.goldLight.withValues(alpha: 0.5),
            r.panel,
          );
    return Semantics(
      label: '$name, ${time.plain}, $chip',
      button: true,
      selected: isNext,
      excludeSemantics: true,
      onTap: onTap,
      child: Material(
        color: isNext ? tile : Colors.transparent,
        borderRadius: BorderRadius.circular(DmScales.radiusControl),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    name,
                    textAlign: TextAlign.center,
                    style: type.rowName.copyWith(
                      color: isNext ? r.ink : r.inkMuted,
                    ),
                  ),
                  // Left to right inside Arabic, so the colon never flips.
                  Text(
                    [time.clock, ?time.offset].join(' '),
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.ltr,
                    style: type.rowTime.copyWith(color: r.ink),
                  ),
                  if (time.period case final period?)
                    Text(
                      period,
                      textAlign: TextAlign.center,
                      style: type.rowPeriod.copyWith(color: r.inkMuted),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
