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

/// Home's hour-light field (§15 D89): the place and Hijri date with the
/// Moon, the day drawn as a mihrab with every prayer at its instant and the
/// Sun at now, the next prayer in the niche, and the time left with a gold
/// line from the previous prayer. One semantics node reads the next prayer,
/// its time and the time left (REQ-UX-020).
final class HomeHourField extends ConsumerWidget {
  /// The field for [content] in [light].
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

  /// The hour light.
  final HourLight light;

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
    return Column(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [light.top, light.bottom],
            ),
          ),
          child: CustomPaint(
            painter: _FieldPainter(light),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
                child: Column(
                  children: [
                    _Header(content: content, style: style),
                    const SizedBox(height: 6),
                    Semantics(
                      container: true,
                      label: [
                        if (nextName != null) l.homeNextPrayer(nextName),
                        if (next != null)
                          style.digits.apply(TimeRows.timeText(l, next)),
                        countdown,
                      ].join(', '),
                      excludeSemantics: true,
                      child: _Mihrab(
                        content: content,
                        style: style,
                        light: light,
                        nowUtcMs: now,
                      ),
                    ),
                    if (next != null)
                      _Progress(
                        content: content,
                        next: next,
                        nowUtcMs: now,
                        countdown: countdown,
                      )
                    else
                      Text(
                        l.homeNoNextPrayer,
                        style: const TextStyle(color: RawdahPalette.ivory),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const DecoratedBox(
          decoration: BoxDecoration(gradient: RawdahPalette.gilded),
          child: SizedBox(height: 3, width: double.infinity),
        ),
      ],
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
    const ivory = TextStyle(color: Color(0xFFE5EEE6), fontSize: 13);
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
            color: RawdahPalette.emeraldDeep.withValues(alpha: 0.35),
            shape: StadiumBorder(
              side: BorderSide(
                color: RawdahPalette.goldLight.withValues(alpha: 0.6),
              ),
            ),
            child: InkWell(
              onTap: () => context.push(const PlaceRoute().location),
              customBorder: const StadiumBorder(),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 44),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  // Wraps, never overflows, at 200 % text (REQ-UX-020).
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Icon(
                        current ? Icons.near_me_outlined : Icons.place_outlined,
                        size: 16,
                        color: RawdahPalette.goldLight,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        name,
                        style: ivory.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Icon(
                        Icons.expand_more,
                        size: 18,
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
                style: ivory,
              ),
              const SizedBox(width: 6),
              MoonPhaseGlyph(hijriDay: hijri.day),
            ],
          ),
      ],
    );
  }
}

/// The arch with the niche: cartouche and the next prayer's time.
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
      fontSize: 10.5,
      color: const Color(0xD9E9EFE7),
    );
    return Stack(
      alignment: Alignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: MihrabArch(
            marks: marks,
            sun: position(nowUtcMs),
            light: light,
            labelStyle: labelStyle,
          ),
        ),
        if (next != null)
          Positioned.fill(
            top: 70,
            bottom: 30,
            child: _Niche(next: next, style: style, light: light),
          ),
      ],
    );
  }
}

final class _Niche extends StatelessWidget {
  const new({required this.next, required this.style, required this.light});

  final TimeRowView next;
  final DisplayStyle style;
  final HourLight light;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    // The niche scales its content to the arch, so 200 % text shrinks the
    // display numerals instead of clipping them (REQ-UX-020).
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Cartouche(
            child: Text(
              l.homeCartouche(DisplayStyle.eventName(l, next.event)),
              style: DmTheme.naskh(size: 20, color: RawdahPalette.ivory),
            ),
          ),
          Text(
            style.digits.apply(TimeRows.timeText(l, next)),
            style:
                DmTheme.naskh(
                  size: 72,
                  color: RawdahPalette.ivory,
                  bold: true,
                ).copyWith(
                  height: 1.25,
                  shadows: [
                    Shadow(
                      color: light.glow.withValues(alpha: 0.45),
                      blurRadius: 28,
                    ),
                  ],
                ),
          ),
        ],
      ),
    );
  }
}

/// The time left and a gold line from the previous prayer to the next.
final class _Progress extends StatelessWidget {
  const new({
    required this.content,
    required this.next,
    required this.nowUtcMs,
    required this.countdown,
  });

  final HomeContent content;
  final TimeRowView next;
  final int nowUtcMs;
  final String countdown;

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
    const ivory = TextStyle(color: Color(0xFFE5EEE6), fontSize: 13);
    return Column(
      children: [
        Text(countdown, style: ivory.copyWith(fontSize: 15)),
        if (fraction != null && previous != null) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: _GoldLine(fraction: fraction),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DisplayStyle.eventName(l, previous.event),
                  style: ivory.copyWith(fontSize: 11),
                ),
                Text(
                  DisplayStyle.eventName(l, next.event),
                  style: ivory.copyWith(fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ],
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

/// Glow behind the niche, stars at night and a gold girih.
final class _FieldPainter extends CustomPainter {
  const new(this.light);

  final HourLight light;

  static const List<(double, double, double)> _stars = [
    (0.10, 0.07, 1.0),
    (0.23, 0.14, 0.8),
    (0.77, 0.09, 1.1),
    (0.64, 0.20, 0.7),
    (0.15, 0.33, 0.9),
    (0.85, 0.30, 0.8),
    (0.51, 0.05, 0.7),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final glowCentre = Offset(size.width / 2, size.height * 0.48);
    canvas.drawCircle(
      glowCentre,
      size.width * 0.62,
      Paint()
        ..shader =
            RadialGradient(
              colors: [
                light.glow.withValues(alpha: 0.30),
                light.glow.withValues(alpha: 0),
              ],
            ).createShader(
              Rect.fromCircle(center: glowCentre, radius: size.width * 0.62),
            ),
    );
    final girih = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7
      ..color = RawdahPalette.goldLight.withValues(alpha: 0.13);
    const tile = 56.0;
    for (var y = tile / 2; y < size.height + tile; y += tile) {
      for (var x = tile / 2; x < size.width + tile; x += tile) {
        canvas.drawPath(
          OrnamentPaths.girihTile(Offset(x, y), tile * 0.215),
          girih,
        );
      }
    }
    if (light.stars) {
      final star = Paint()..color = const Color(0xB3FFFFFF);
      for (final (x, y, r) in _stars) {
        canvas.drawCircle(Offset(size.width * x, size.height * y), r, star);
      }
    }
  }

  @override
  bool shouldRepaint(_FieldPainter old) => old.light != light;
}
