import 'dart:math' as math;

import 'package:daily_muslim/features/contexts/domain/context_kind.dart';
import 'package:daily_muslim/features/home/domain/time_row_view.dart';
import 'package:daily_muslim/features/home/presentation/display_style.dart';
import 'package:daily_muslim/features/home/presentation/home_providers.dart';
import 'package:daily_muslim/features/home/presentation/home_state.dart';
import 'package:daily_muslim/features/home/presentation/time_rows.dart';
import 'package:daily_muslim/features/schedule/presentation/schedule_providers.dart';
import 'package:daily_muslim/features/shell/domain/app_route.dart';
import 'package:daily_muslim/l10n/app_localizations.dart';
import 'package:dm_ui/dm_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geo_salah_core/geo_salah_core.dart';
import 'package:go_router/go_router.dart';

/// Home's hero (§15 D89, D102): the Madinah artwork under a deep-green
/// veil, the place and Hijri date with the Moon, the next prayer's name and
/// time with the time left, and the day drawn as a mihrab with every prayer
/// at its instant and the Sun at now; a gold line inside the niche runs from
/// the previous prayer to the next. One semantics node reads the next
/// prayer, its time and the time left (REQ-UX-020).
final class HomeHourField extends ConsumerWidget {
  /// The hero for [content] in [light].
  const new({
    required this.content,
    required this.style,
    required this.light,
    super.key,
  });

  /// Today.
  final HomeContent content;

  /// Locale and digits.
  final DisplayStyle style;

  /// The hour light: a faint tint over the veil and the arc's Sun.
  final HourLight light;

  /// The bundled artwork (§15 D102), decorative and offline.
  static const String artwork = 'assets/art/madinah_hero.webp';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final now = switch (ref.watch(nowUtcMsProvider)) {
      AsyncData(:final value) => value,
      _ => ref.watch(clockProvider).nowUtcMs(),
    };
    final next = content.nextPrayer;
    final countdown = next == null ? '' : _countdown(l, next, now);
    final nextName = next == null
        ? null
        : DisplayStyle.eventName(l, next.event);
    return DecoratedBox(
      decoration: const BoxDecoration(color: RawdahPalette.emeraldDeep),
      child: Stack(
        children: [
          Positioned.fill(child: _Artwork(light: light)),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(
                DmScales.gutter,
                8,
                DmScales.gutter,
                44,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Header(content: content, style: style),
                  const SizedBox(height: 18),
                  if (next != null && nextName != null)
                    Semantics(
                      container: true,
                      label: [
                        l.homeNextPrayer(nextName),
                        style.digits.apply(TimeRows.timeText(l, next)),
                        countdown,
                      ].join(', '),
                      excludeSemantics: true,
                      child: _NextPrayer(
                        name: nextName,
                        time: style.digits.apply(TimeRows.timeText(l, next)),
                        countdown: countdown,
                      ),
                    )
                  else
                    Text(
                      l.homeNoNextPrayer,
                      style: const TextStyle(
                        color: RawdahPalette.ivory,
                        fontSize: 16,
                      ),
                    ),
                  const SizedBox(height: 4),
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 320),
                      child: _Mihrab(
                        content: content,
                        style: style,
                        light: light,
                        nowUtcMs: now,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _countdown(AppLocalizations l, TimeRowView next, int now) {
    final remaining = (next.displayedUtcMs ?? now) - now;
    final minutes = remaining <= 0 ? 0 : (remaining + 59999) ~/ 60000;
    return style.digits.apply(
      minutes < 60
          ? l.homeCountdownMinutes('$minutes')
          : l.homeCountdown('${minutes ~/ 60}', '${minutes % 60}'),
    );
  }
}

/// The place and the Hijri date with its Moon. The place is its name only
/// (the city a device fix is in, §15 D101), in a chip that opens the place
/// screen; the words "pinned", "manual" and "approximate" are for the
/// diagnostics, not for the header.
final class _Header extends ConsumerWidget {
  const new({required this.content, required this.style});

  final HomeContent content;
  final DisplayStyle style;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final place = content.place;
    final language = Localizations.localeOf(context).languageCode;
    final current = place.kind == ContextKind.current;
    final name = current
        ? ref.watch(currentPlaceNameProvider).value?.nameIn(language) ??
              l.homeCurrentPlace
        : place.label;
    const quiet = TextStyle(color: RawdahPalette.ivoryMuted, fontSize: 13);
    final hijri = content.hijri;
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8,
      runSpacing: 4,
      children: [
        Semantics(
          button: true,
          label: l.homePlaceChip(name),
          excludeSemantics: true,
          child: Material(
            color: RawdahPalette.emeraldDeep.withValues(alpha: 0.45),
            shape: StadiumBorder(
              side: BorderSide(
                color: RawdahPalette.gold.withValues(alpha: 0.45),
              ),
            ),
            child: InkWell(
              onTap: () => context.push(const PlaceRoute().location),
              customBorder: const StadiumBorder(),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 44),
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(10, 0, 8, 0),
                  // Wraps, never overflows, at 200 % text (REQ-UX-020).
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Icon(
                        current ? Icons.near_me : Icons.place,
                        size: DmScales.iconMedium,
                        color: RawdahPalette.gold,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        name,
                        style: const TextStyle(
                          color: RawdahPalette.ivory,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Icon(
                        Icons.expand_more,
                        size: DmScales.iconMedium,
                        color: RawdahPalette.goldLight,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        if (hijri != null)
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                style.digits.apply(
                  l.homeHijriDate(
                    '${hijri.day}',
                    l.hijriMonthName('${hijri.month}'),
                    '${hijri.year}',
                  ),
                ),
                style: quiet,
              ),
              const SizedBox(width: 6),
              MoonPhaseGlyph(hijriDay: hijri.day),
            ],
          ),
      ],
    );
  }
}

/// The next prayer: a small gold label, the name large in Naskh with the
/// time left under it, and the time at the end. At large text the time
/// wraps under the name instead of clipping (REQ-UX-020).
final class _NextPrayer extends StatelessWidget {
  const new({required this.name, required this.time, required this.countdown});

  final String name;
  final String time;
  final String countdown;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final arabic = Localizations.localeOf(context).languageCode == 'ar';
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.end,
      spacing: 12,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const Icon(
                  Icons.wb_sunny_outlined,
                  size: DmScales.iconSmall,
                  color: RawdahPalette.goldLight,
                ),
                const SizedBox(width: 6),
                Text(
                  arabic
                      ? l.homeNextPrayerLabel
                      : l.homeNextPrayerLabel.toUpperCase(),
                  style: TextStyle(
                    color: RawdahPalette.goldLight,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: arabic ? 0 : 1.4,
                  ),
                ),
              ],
            ),
            Text(
              name,
              style: DmTheme.naskh(
                size: 46,
                color: RawdahPalette.ivory,
                bold: true,
              ).copyWith(height: 1.25),
            ),
            Text(
              countdown,
              style: const TextStyle(
                color: RawdahPalette.ivoryMuted,
                fontSize: 17,
              ),
            ),
          ],
        ),
        Text(
          time,
          style: DmTheme.naskh(
            size: 44,
            color: RawdahPalette.ivory,
            bold: true,
          ).copyWith(height: 1.25),
        ),
      ],
    );
  }
}

/// The artwork under a deep-green veil: darker at the top behind the
/// header, at the reading start behind the next prayer, and at the bottom
/// behind the arc labels, so ivory text keeps its contrast. The hour light
/// tints the veil faintly.
final class _Artwork extends StatelessWidget {
  const new({required this.light});

  final HourLight light;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          HomeHourField.artwork,
          fit: BoxFit.cover,
          alignment: const Alignment(0.55, 0.1),
          gaplessPlayback: true,
        ),
        ColoredBox(color: light.top.withValues(alpha: 0.16)),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                RawdahPalette.emeraldDeep.withValues(alpha: 0.80),
                RawdahPalette.emeraldDeep.withValues(alpha: 0.38),
                RawdahPalette.emeraldDeep.withValues(alpha: 0.72),
                RawdahPalette.emeraldDeep.withValues(alpha: 0.97),
              ],
              stops: const [0, 0.3, 0.55, 1],
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: AlignmentDirectional.centerStart,
              end: AlignmentDirectional.centerEnd,
              colors: [
                RawdahPalette.forest.withValues(alpha: 0.55),
                RawdahPalette.forest.withValues(alpha: 0),
              ],
              stops: const [0, 0.75],
            ),
          ),
        ),
      ],
    ),
  );
}

/// The arch with the niche: the gold line from the previous prayer to the
/// next.
final class _Mihrab extends StatelessWidget {
  const new({
    required this.content,
    required this.style,
    required this.light,
    required this.nowUtcMs,
  });

  final HomeContent content;
  final DisplayStyle style;
  final HourLight light;
  final int nowUtcMs;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final next = content.nextPrayer;
    final rows = content.day.rows;
    int? at(PrayerEvent event) => rows
        .where((row) => row.event == event)
        .map((row) => row.displayedUtcMs)
        .firstOrNull;
    final sunrise = at(PrayerEvent.sunrise);
    final sunset = at(PrayerEvent.maghrib);
    ArchPosition position(int utcMs) {
      if (sunrise == null || sunset == null || sunset <= sunrise) {
        return const OnArch(0.5);
      }
      if (utcMs < sunrise) return const BeforeSunrise();
      if (utcMs > sunset) return const AfterSunset();
      return OnArch((utcMs - sunrise) / (sunset - sunrise));
    }

    final marks = [
      for (final row in rows)
        if (row.event != PrayerEvent.imsak)
          if (row.displayedUtcMs case final int utcMs)
            ArchMark(
              label: DisplayStyle.eventName(l, row.event),
              position: switch (row.event) {
                PrayerEvent.fajr => const BeforeSunrise(),
                PrayerEvent.isha => const AfterSunset(),
                _ => position(utcMs),
              },
              isNext: next?.event == row.event,
            ),
    ];
    final labelStyle = TextStyle(
      fontFamily: style.locale == StatusLocale.ar
          ? DmTheme.arabicFamily
          : DmTheme.latinFamily,
      fontSize: 11,
      color: RawdahPalette.ivoryMuted,
    );
    return Stack(
      alignment: Alignment.center,
      children: [
        MihrabArch(
          marks: marks,
          sun: position(nowUtcMs),
          light: light,
          labelStyle: labelStyle,
        ),
        if (next != null)
          Positioned.fill(
            top: 96,
            bottom: 40,
            left: 70,
            right: 70,
            child: Center(
              child: _Progress(
                content: content,
                next: next,
                nowUtcMs: nowUtcMs,
              ),
            ),
          ),
      ],
    );
  }
}

/// A gold line from the previous prayer to the next, with their names.
final class _Progress extends StatelessWidget {
  const new({
    required this.content,
    required this.next,
    required this.nowUtcMs,
  });

  final HomeContent content;
  final TimeRowView next;
  final int nowUtcMs;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final previous = content.day.rows
        .where(
          (row) =>
              row.event != PrayerEvent.imsak &&
              (row.displayedUtcMs ?? nowUtcMs + 1) <= nowUtcMs,
        )
        .lastOrNull;
    final from = previous?.displayedUtcMs;
    final to = next.displayedUtcMs;
    final fraction = from != null && to != null && to > from
        ? ((nowUtcMs - from) / (to - from)).clamp(0.0, 1.0)
        : null;
    if (fraction == null || previous == null) return const SizedBox.shrink();
    const quiet = TextStyle(color: RawdahPalette.ivoryMuted, fontSize: 11);
    // At least 150 wide, as wide as its names need, and scaled down to the
    // niche rather than clipped at large text (REQ-UX-020).
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: IntrinsicWidth(
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 150),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _GoldLine(fraction: fraction),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(DisplayStyle.eventName(l, previous.event), style: quiet),
                  const SizedBox(width: 12),
                  Text(DisplayStyle.eventName(l, next.event), style: quiet),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

final class _GoldLine extends StatelessWidget {
  const new({required this.fraction});

  final double fraction;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: SizedBox(
      height: 10,
      width: double.infinity,
      child: CustomPaint(
        painter: _GoldLinePainter(
          fraction: fraction,
          rtl: Directionality.of(context) == TextDirection.rtl,
        ),
      ),
    ),
  );
}

final class _GoldLinePainter extends CustomPainter {
  const new({required this.fraction, required this.rtl});

  final double fraction;
  final bool rtl;

  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height / 2;
    final start = rtl ? size.width : 0.0;
    final end = rtl ? 0.0 : size.width;
    final at = start + (end - start) * fraction;
    canvas
      ..drawLine(
        Offset(0, y),
        Offset(size.width, y),
        Paint()
          ..color = RawdahPalette.goldLight.withValues(alpha: 0.25)
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round,
      )
      ..drawLine(
        Offset(start, y),
        Offset(at, y),
        Paint()
          ..shader = RawdahPalette.gilded.createShader(
            Offset.zero & size,
          )
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round,
      )
      ..save()
      ..translate(at, y)
      ..rotate(math.pi / 4)
      ..drawRect(
        const Rect.fromLTWH(-4, -4, 8, 8),
        Paint()..color = RawdahPalette.goldLight,
      )
      ..restore();
  }

  @override
  bool shouldRepaint(_GoldLinePainter old) =>
      old.fraction != fraction || old.rtl != rtl;
}
