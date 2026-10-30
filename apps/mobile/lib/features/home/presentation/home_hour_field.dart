import 'dart:math' as math;

import 'package:daily_muslim/features/contexts/domain/context_kind.dart';
import 'package:daily_muslim/features/home/domain/prayer_timeline.dart';
import 'package:daily_muslim/features/home/domain/time_row_view.dart';
import 'package:daily_muslim/features/home/presentation/display_style.dart';
import 'package:daily_muslim/features/home/presentation/home_providers.dart';
import 'package:daily_muslim/features/home/presentation/home_state.dart';
import 'package:daily_muslim/features/home/presentation/time_rows.dart';
import 'package:daily_muslim/features/schedule/presentation/schedule_providers.dart';
import 'package:daily_muslim/features/shell/domain/app_route.dart';
import 'package:daily_muslim/features/shell/presentation/app_tab_bar.dart';
import 'package:daily_muslim/l10n/app_localizations.dart';
import 'package:dm_ui/dm_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Home's hero, the Horizon composition (§15 D105): on the forest-green
/// field with the Madinah artwork at its foot, the place and Settings, the
/// day's five prayers as a thin gold arc, and under it, centred, the next
/// prayer's name, its time and the time left — the strongest text on the
/// screen. The hero takes a share of a portrait screen's height, never
/// less than its content, so the cream section shows below it on an
/// ordinary phone. One semantics node reads the next prayer, its time and
/// the time left (REQ-UX-020).
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

  /// The hour light: a faint tint over the sky.
  final HourLight light;

  /// The bundled artwork (§15 D102), decorative and offline.
  static const String artwork = 'assets/art/madinah_hero.webp';

  /// How far the cream section rises over the hero's foot.
  static const double sheetOverlap = 28;

  /// The hero's share of a portrait screen's height.
  static const double _portraitShare = 0.6;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final now = switch (ref.watch(nowUtcMsProvider)) {
      AsyncData(:final value) => value,
      _ => ref.watch(clockProvider).nowUtcMs(),
    };
    final next = content.nextPrayer;
    final timeline = PrayerTimeline.of(
      rows: content.day.rows,
      nextPrayer: next,
      nowUtcMs: now,
    );
    final screen = MediaQuery.sizeOf(context);
    // Portrait: a share of the height, the arc over the next prayer.
    // Landscape: as tall as the content, the next prayer at the start and
    // the arc beside it, so nothing falls under the navigation bar.
    final landscape = screen.width > screen.height;
    final minHeight = landscape ? 0.0 : screen.height * _portraitShare;
    final arc = PrayerArc(
      labels: [
        for (final event in PrayerTimeline.events)
          DisplayStyle.eventName(l, event),
      ],
      next: timeline.next,
      progress: timeline.progress,
      labelStyle: TextStyle(
        fontFamily: DmTheme.naskhFamily,
        fontSize: 14,
        color: RawdahPalette.ivory.withValues(alpha: 0.9),
      ),
    );
    final nextPrayer = next == null
        ? Text(
            l.homeNoNextPrayer,
            textAlign: TextAlign.center,
            style: DmTheme.naskh(size: 22, color: RawdahPalette.ivory),
          )
        : _NextPrayer(
            name: DisplayStyle.eventName(l, next.event),
            time: style.digits.apply(TimeRows.timeText(l, next)),
            countdown: _countdown(l, next, now),
          );
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: minHeight),
      child: Stack(
        children: [
          Positioned.fill(
            child: _Artwork(light: light, compact: landscape),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(
                DmScales.gutter,
                4,
                DmScales.gutter,
                sheetOverlap + 16,
              ),
              child: Column(
                children: [
                  _Header(content: content),
                  if (content.hijri case final hijri?)
                    _Hijri(
                      day: hijri.day,
                      text: style.digits.apply(
                        l.homeHijriDate(
                          '${hijri.day}',
                          l.hijriMonthName('${hijri.month}'),
                          '${hijri.year}',
                        ),
                      ),
                    ),
                  SizedBox(height: landscape ? 4 : 12),
                  if (landscape)
                    Row(
                      children: [
                        Expanded(child: nextPrayer),
                        const SizedBox(width: DmScales.gutter),
                        Expanded(
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(
                                maxWidth: 420,
                              ),
                              child: arc,
                            ),
                          ),
                        ),
                      ],
                    )
                  else ...[
                    SizedBox(
                      width: math.min(screen.width - 2 * DmScales.gutter, 460),
                      child: arc,
                    ),
                    nextPrayer,
                  ],
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

/// The place, by its name only (the city a device fix is in, §15 D101; a
/// chosen place in the reader's language, D104), opening the place screen;
/// Settings at the end. The words "pinned", "manual" and "approximate" are
/// for the diagnostics, not for the header.
final class _Header extends ConsumerWidget {
  const new({required this.content});

  final HomeContent content;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final place = content.place;
    final language = Localizations.localeOf(context).languageCode;
    final current = place.kind == ContextKind.current;
    // In the reader's language when the gazetteer knows the place (§15
    // D104); a typed name as typed.
    final name =
        ref.watch(placeNameProvider).value?.nameIn(language) ??
        (current ? l.homeCurrentPlace : place.label);
    return Row(
      children: [
        Expanded(
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: Semantics(
              button: true,
              label: l.homePlaceChip(name),
              excludeSemantics: true,
              child: InkWell(
                onTap: () => context.push(const PlaceRoute().location),
                customBorder: const StadiumBorder(),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 48),
                  child: Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(2, 4, 8, 4),
                    // Wraps, never overflows, at 200 % text (REQ-UX-020).
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Icon(
                          current ? Icons.near_me : Icons.place,
                          size: DmScales.iconLarge,
                          color: RawdahPalette.gold,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          name,
                          style: DmTheme.naskh(
                            size: 20,
                            color: RawdahPalette.ivory,
                          ).copyWith(height: 1.2),
                        ),
                        const SizedBox(width: 2),
                        const Icon(
                          Icons.expand_more,
                          size: DmScales.iconMedium,
                          color: RawdahPalette.ivory,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        IconButton(
          onPressed: () => context.go(AppTabBar.locationOf(RawdahTab.settings)),
          tooltip: l.navSettings,
          icon: const Icon(
            Icons.settings_outlined,
            size: DmScales.iconLarge,
            color: RawdahPalette.ivory,
          ),
        ),
      ],
    );
  }
}

/// The Hijri date with its Moon, quiet under the header.
final class _Hijri extends StatelessWidget {
  const new({required this.day, required this.text});

  final int day;
  final String text;

  @override
  Widget build(BuildContext context) => Wrap(
    alignment: WrapAlignment.center,
    crossAxisAlignment: WrapCrossAlignment.center,
    children: [
      MoonPhaseGlyph(hijriDay: day),
      const SizedBox(width: 8),
      Text(
        text,
        style: const TextStyle(color: RawdahPalette.ivoryMuted, fontSize: 13),
      ),
    ],
  );
}

/// The next prayer, centred under the arc: its name, its time large with
/// any "+1" set smaller, and the time left.
final class _NextPrayer extends StatelessWidget {
  const new({required this.name, required this.time, required this.countdown});

  final String name;
  final String time;
  final String countdown;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final cut = time.indexOf(' ');
    final (clock, suffix) = cut < 0
        ? (time, '')
        : (time.substring(0, cut), time.substring(cut));
    return Semantics(
      container: true,
      label: [l.homeNextPrayer(name), time, countdown].join(', '),
      excludeSemantics: true,
      // A soft green shadow lifts the ivory off lit architecture.
      child: DefaultTextStyle.merge(
        style: const TextStyle(
          shadows: [Shadow(color: Color(0xB3062E25), blurRadius: 14)],
        ),
        child: Column(
          children: [
            Text(
              name,
              textAlign: TextAlign.center,
              style: DmTheme.naskh(
                size: 34,
                color: RawdahPalette.ivory,
                bold: true,
              ).copyWith(height: 1.2),
            ),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: clock),
                  if (suffix.isNotEmpty)
                    TextSpan(
                      text: suffix,
                      style: DmTheme.naskh(
                        size: 30,
                        color: RawdahPalette.ivory,
                      ),
                    ),
                ],
              ),
              textAlign: TextAlign.center,
              style: DmTheme.naskh(
                size: 68,
                color: RawdahPalette.ivory,
                bold: true,
              ).copyWith(height: 1.1),
            ),
            const SizedBox(height: 4),
            Text(
              countdown,
              textAlign: TextAlign.center,
              style: DmTheme.naskh(size: 22, color: RawdahPalette.ivory),
            ),
          ],
        ),
      ),
    );
  }
}

/// The artwork at the hero's foot, never stretched: at least the full
/// width at its own proportions, taller on a tall hero so the dome and
/// minarets stand large, cropped from the quiet sky and palms at the left
/// rather than from the building. Above it the sky continues in the
/// artwork's own top colours and the seam fades. A green veil keeps the
/// arc and text readable at the top and closes at the foot where the cream
/// rises. The hour light tints the sky faintly.
final class _Artwork extends StatelessWidget {
  const new({required this.light, required this.compact});

  final HourLight light;

  /// A short, wide hero, where text crosses the building: an even veil.
  final bool compact;

  /// The artwork's proportions (1536 × 1024).
  static const double _aspect = 1536 / 1024;

  /// The sky along the artwork's top edge, left and right (sampled).
  static const Color _skyLeft = Color(0xFF0D3427);
  static const Color _skyRight = Color(0xFF224B36);

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: LayoutBuilder(
      builder: (context, box) {
        // The picture fills at least the width and 60 % of the hero's
        // height; it is anchored on the right, where the building stands,
        // so any crop takes sky and palms, not the dome.
        final height = math.max(box.maxWidth / _aspect, box.maxHeight * 0.6);
        return Stack(
          children: [
            // The sky is the picture's own, so it does not mirror.
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [_skyLeft, _skyRight]),
                ),
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              width: height * _aspect,
              height: height,
              child: ShaderMask(
                // Fades the artwork's top edge into the sky above it.
                shaderCallback: (rect) => const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x00000000), Color(0xFF000000)],
                  stops: [0, 0.14],
                ).createShader(rect),
                blendMode: BlendMode.dstIn,
                child: Image.asset(
                  HomeHourField.artwork,
                  fit: BoxFit.fill,
                  gaplessPlayback: true,
                ),
              ),
            ),
            Positioned.fill(
              child: ColoredBox(color: light.top.withValues(alpha: 0.08)),
            ),
            if (compact)
              Positioned.fill(
                child: ColoredBox(
                  color: RawdahPalette.emeraldDeep.withValues(alpha: 0.5),
                ),
              ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      RawdahPalette.emeraldDeep.withValues(alpha: 0.55),
                      RawdahPalette.emeraldDeep.withValues(alpha: 0.4),
                      RawdahPalette.emeraldDeep.withValues(alpha: 0.3),
                      RawdahPalette.emeraldDeep.withValues(alpha: 0),
                      RawdahPalette.emeraldDeep.withValues(alpha: 0.55),
                    ],
                    stops: const [0, 0.35, 0.62, 0.82, 1],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    ),
  );
}
