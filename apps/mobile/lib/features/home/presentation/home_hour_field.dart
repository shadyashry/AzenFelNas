import 'dart:math' as math;

import 'package:daily_muslim/features/contexts/domain/context_kind.dart';
import 'package:daily_muslim/features/home/domain/prayer_timeline.dart';
import 'package:daily_muslim/features/home/domain/time_row_view.dart';
import 'package:daily_muslim/features/home/presentation/clock_text.dart';
import 'package:daily_muslim/features/home/presentation/display_style.dart';
import 'package:daily_muslim/features/home/presentation/home_providers.dart';
import 'package:daily_muslim/features/home/presentation/home_state.dart';
import 'package:daily_muslim/features/schedule/presentation/schedule_providers.dart';
import 'package:daily_muslim/features/shell/domain/app_route.dart';
import 'package:daily_muslim/features/shell/presentation/app_tab_bar.dart';
import 'package:daily_muslim/l10n/app_localizations.dart';
import 'package:dm_ui/dm_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// A soft green shadow that lifts the hero's ivory text, the arc's labels
/// too, off the lit architecture behind it (§15 D116).
const List<Shadow> _lift = [Shadow(color: Color(0xB3062E25), blurRadius: 14)];

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

  /// The hero's share of a portrait screen's height: compact enough that
  /// the day's row and Continue Quran show below it on a 390 x 844 phone
  /// (§15 D109).
  static const double _portraitShare = 0.5;

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
    final type = DmType.of(style.locale);
    final padding = DmScales.paddingFor(screen.width);
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
      labelStyle: type.arcLabel.copyWith(
        color: RawdahPalette.ivory.withValues(alpha: 0.9),
        shadows: _lift,
      ),
    );
    final nextPrayer = next == null
        ? Text(
            l.homeNoNextPrayer,
            textAlign: TextAlign.center,
            style: type.countdown.copyWith(color: RawdahPalette.ivory),
          )
        : _NextPrayer(
            name: DisplayStyle.eventName(l, next.event),
            time: ClockText.of(context, l, next, style),
            countdown: _countdown(l, next, now),
            type: type,
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
              padding: EdgeInsetsDirectional.fromSTEB(
                padding,
                0,
                padding,
                sheetOverlap + DmScales.sectionGap,
              ),
              child: Column(
                children: [
                  _Header(content: content, type: type),
                  if (content.hijri case final hijri?)
                    _Hijri(
                      day: hijri.day,
                      style: type.supporting,
                      text: style.digits.apply(
                        l.homeHijriDate(
                          '${hijri.day}',
                          l.hijriMonthName('${hijri.month}'),
                          '${hijri.year}',
                        ),
                      ),
                    ),
                  const SizedBox(height: DmScales.lineGap),
                  if (landscape)
                    Row(
                      children: [
                        Expanded(child: nextPrayer),
                        SizedBox(width: padding),
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
                      width: math.min(screen.width - 2 * padding, 460),
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
          ? l.homeCountdownMinutes(minutes)
          : l.homeCountdown(minutes ~/ 60, minutes % 60),
    );
  }
}

/// The place, by its name only (the city a device fix is in, §15 D101; a
/// chosen place in the reader's language, D104), opening the place screen;
/// Settings at the end. The words "pinned", "manual" and "approximate" are
/// for the diagnostics, not for the header.
final class _Header extends ConsumerWidget {
  const new({required this.content, required this.type});

  final HomeContent content;
  final DmType type;

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
                    padding: const EdgeInsetsDirectional.fromSTEB(0, 4, 8, 4),
                    // Wraps, never overflows, at 200 % text (REQ-UX-020).
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Icon(
                          current ? Icons.near_me : Icons.place,
                          size: DmScales.iconLarge,
                          color: RawdahPalette.gold,
                        ),
                        const SizedBox(width: DmScales.iconGap),
                        Text(
                          name,
                          style: type.location.copyWith(
                            color: RawdahPalette.ivory,
                          ),
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
  const new({required this.day, required this.text, required this.style});

  final int day;
  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) => Wrap(
    alignment: WrapAlignment.center,
    crossAxisAlignment: WrapCrossAlignment.center,
    children: [
      MoonPhaseGlyph(hijriDay: day),
      const SizedBox(width: 8),
      Text(
        text,
        style: style.copyWith(color: RawdahPalette.ivoryMuted),
      ),
    ],
  );
}

/// The next prayer, centred under the arc: its name, its time large with
/// the AM/PM marker small on the same baseline, and the time left. The
/// digits keep their own left-to-right order inside Arabic text, so the
/// marker sits after them in reading order («٣:٤٢ م»). The digits are
/// tabular and every line has a fixed height, so the countdown
/// ticking never moves anything (§15 D109).
final class _NextPrayer extends StatelessWidget {
  const new({
    required this.name,
    required this.time,
    required this.countdown,
    required this.type,
  });

  final String name;
  final ClockText time;
  final String countdown;
  final DmType type;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    const ivory = RawdahPalette.ivory;
    final marker = type.nextPeriod.copyWith(color: ivory);
    return Semantics(
      container: true,
      label: [l.homeNextPrayer(name), time.plain, countdown].join(', '),
      excludeSemantics: true,
      child: DefaultTextStyle.merge(
        style: const TextStyle(shadows: _lift),
        child: Column(
          children: [
            Text(
              name,
              textAlign: TextAlign.center,
              style: type.nextName.copyWith(color: ivory),
            ),
            // One paragraph: the marker shares the digits' baseline and,
            // at large text, wraps under them instead of overflowing.
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: time.clock),
                  if (time.period case final period?)
                    TextSpan(text: ' $period', style: marker),
                  if (time.offset case final offset?)
                    TextSpan(text: ' $offset', style: marker),
                ],
              ),
              textAlign: TextAlign.center,
              style: type.nextTime.copyWith(color: ivory),
            ),
            Text(
              countdown,
              textAlign: TextAlign.center,
              style: type.countdown.copyWith(color: ivory),
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

  /// The dark appearance's veil: the page ground of Horizon Dark.
  static const Color _nightVeil = Color(0xFF061A15);

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
            // Horizon Dark (§15 D119): a deeper green over the artwork that
            // calms the lit minarets and the orange glow; the dome and the
            // minarets stay. It lies under the text, never over it.
            if (Theme.of(context).brightness == Brightness.dark)
              Positioned.fill(
                child: ColoredBox(
                  color: _nightVeil.withValues(alpha: 0.38),
                ),
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
