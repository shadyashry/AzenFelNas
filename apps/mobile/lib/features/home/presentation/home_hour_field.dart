import 'package:daily_muslim/features/athan/application/athan_preferences.dart';
import 'package:daily_muslim/features/contexts/domain/context_kind.dart';
import 'package:daily_muslim/features/home/domain/time_row_view.dart';
import 'package:daily_muslim/features/home/presentation/display_style.dart';
import 'package:daily_muslim/features/home/presentation/home_providers.dart';
import 'package:daily_muslim/features/home/presentation/home_state.dart';
import 'package:daily_muslim/features/home/presentation/time_rows.dart';
import 'package:daily_muslim/features/schedule/presentation/schedule_providers.dart';
import 'package:daily_muslim/features/settings/presentation/settings_providers.dart';
import 'package:daily_muslim/features/shell/domain/app_route.dart';
import 'package:daily_muslim/features/shell/presentation/app_tab_bar.dart';
import 'package:daily_muslim/l10n/app_localizations.dart';
import 'package:dm_ui/dm_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Home's hero (§15 D89, D102, D103): the Madinah artwork under a green
/// veil that is deepest at the reading start, the place with the Athan and
/// Settings shortcuts, the Hijri date, then the next prayer stacked at the
/// start: a spaced label, its name large in Naskh, the time left, its time,
/// and whether its Athan is on. The day's five prayers follow in
/// `PrayerStrip`, which rises over the hero's lower edge. One semantics node
/// reads the next prayer, its time and the time left (REQ-UX-020).
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

  /// The hour light: a faint tint over the veil.
  final HourLight light;

  /// The bundled artwork (§15 D102), decorative and offline.
  static const String artwork = 'assets/art/madinah_hero.webp';

  /// The room left under the hero for the strip that rises over it.
  static const double stripRoom = 64;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final now = switch (ref.watch(nowUtcMsProvider)) {
      AsyncData(:final value) => value,
      _ => ref.watch(clockProvider).nowUtcMs(),
    };
    final next = content.nextPrayer;
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
                4,
                DmScales.gutter,
                stripRoom + 8,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Header(content: content),
                  if (content.hijri case final hijri?)
                    Padding(
                      padding: const EdgeInsetsDirectional.only(start: 4),
                      child: _Hijri(
                        day: hijri.day,
                        text: style.digits.apply(
                          l.homeHijriDate(
                            '${hijri.day}',
                            l.hijriMonthName('${hijri.month}'),
                            '${hijri.year}',
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 22),
                  if (next != null)
                    _NextPrayer(
                      next: next,
                      name: DisplayStyle.eventName(l, next.event),
                      time: style.digits.apply(TimeRows.timeText(l, next)),
                      countdown: _countdown(l, next, now),
                    )
                  else
                    Text(
                      l.homeNoNextPrayer,
                      style: DmTheme.naskh(
                        size: 22,
                        color: RawdahPalette.ivory,
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

/// The place, by its name only (the city a device fix is in, §15 D101; a
/// chosen place in the reader's language, D104), opening the place screen;
/// then the Athan and Settings shortcuts at the end. The words "pinned",
/// "manual" and "approximate" are for the diagnostics, not for the header.
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
        Flexible(
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
                  padding: const EdgeInsetsDirectional.fromSTEB(4, 4, 8, 4),
                  // Wraps, never overflows, at 200 % text (REQ-UX-020).
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Icon(
                        current ? Icons.near_me : Icons.place,
                        size: DmScales.iconLarge,
                        color: RawdahPalette.goldLight,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        name,
                        style: DmTheme.naskh(
                          size: 22,
                          color: RawdahPalette.ivory,
                          bold: true,
                        ).copyWith(height: 1.2),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.expand_more,
                        size: DmScales.iconLarge,
                        color: RawdahPalette.ivory,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        const Spacer(),
        _Shortcut(
          icon: Icons.notifications,
          label: l.navAthan,
          onTap: () => context.go(AppTabBar.locationOf(RawdahTab.athan)),
        ),
        const SizedBox(width: 8),
        _Shortcut(
          icon: Icons.settings_outlined,
          label: l.navSettings,
          onTap: () => context.go(AppTabBar.locationOf(RawdahTab.settings)),
        ),
      ],
    );
  }
}

/// A gold icon button to an existing tab.
final class _Shortcut extends StatelessWidget {
  const new({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => IconButton(
    onPressed: onTap,
    tooltip: label,
    // A soft green backing keeps the gold readable over lit architecture.
    style: IconButton.styleFrom(
      backgroundColor: RawdahPalette.emeraldDeep.withValues(alpha: 0.45),
    ),
    icon: Icon(icon, size: DmScales.iconLarge, color: RawdahPalette.goldLight),
  );
}

/// The Hijri date with its Moon, quiet under the place.
final class _Hijri extends StatelessWidget {
  const new({required this.day, required this.text});

  final int day;
  final String text;

  @override
  Widget build(BuildContext context) => Wrap(
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

/// The next prayer stacked at the start: a spaced label, the name, the
/// time left, the time, and its Athan pill.
final class _NextPrayer extends ConsumerWidget {
  const new({
    required this.next,
    required this.name,
    required this.time,
    required this.countdown,
  });

  final TimeRowView next;
  final String name;
  final String time;
  final String countdown;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final arabic = Localizations.localeOf(context).languageCode == 'ar';
    final athanOn = AthanPreferences.enabledOf(
      ref.watch(athanEnabledSettingProvider).value ?? const {},
    ).contains(next.event);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          container: true,
          label: [l.homeNextPrayer(name), time, countdown].join(', '),
          excludeSemantics: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                arabic
                    ? l.homeNextPrayerLabel
                    : l.homeNextPrayerLabel.toUpperCase(),
                style: TextStyle(
                  color: RawdahPalette.ivory,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: arabic ? 0 : 3.2,
                ),
              ),
              Text(
                name,
                style: DmTheme.naskh(
                  size: 64,
                  color: RawdahPalette.ivory,
                  bold: true,
                ).copyWith(height: 1.15),
              ),
              Text(
                countdown,
                style: DmTheme.naskh(size: 24, color: RawdahPalette.ivory),
              ),
              const SizedBox(height: 4),
              Text(
                time,
                style: DmTheme.naskh(
                  size: 52,
                  color: RawdahPalette.ivory,
                  bold: true,
                ).copyWith(height: 1.15),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _AthanPill(on: athanOn),
      ],
    );
  }
}

/// Whether the next prayer's Athan is on, from the user's Athan choices
/// (US-10); opens the Athan tab. The icon and the words say it, not the
/// colour alone.
final class _AthanPill extends StatelessWidget {
  const new({required this.on});

  final bool on;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return OutlinedButton.icon(
      onPressed: () => context.go(AppTabBar.locationOf(RawdahTab.athan)),
      style: OutlinedButton.styleFrom(
        foregroundColor: RawdahPalette.goldLight,
        backgroundColor: RawdahPalette.emeraldDeep.withValues(alpha: 0.35),
        side: const BorderSide(color: RawdahPalette.gold, width: 1.4),
        minimumSize: const Size(48, 48),
        padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 20, 8),
        textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
      ),
      icon: Icon(on ? Icons.volume_up : Icons.volume_off, size: 22),
      label: Text(on ? l.homeAthanOn : l.homeAthanOff),
    );
  }
}

/// The whole artwork, never zoomed: it spans the hero's width at its own
/// proportions and stands on the hero's bottom edge; above it the sky
/// continues in the artwork's own top colours, and the seam fades. Over it
/// a green veil, deepest at the reading start behind the text and at the
/// bottom where the strip rises, so ivory text keeps its contrast. The hour
/// light tints the sky faintly.
final class _Artwork extends StatelessWidget {
  const new({required this.light});

  final HourLight light;

  /// The artwork's proportions (1536 × 1024).
  static const double _aspect = 1536 / 1024;

  /// The sky along the artwork's top edge, left and right (sampled).
  static const Color _skyLeft = Color(0xFF0D3427);
  static const Color _skyRight = Color(0xFF224B36);

  @override
  Widget build(BuildContext context) {
    // Resolved here: a directional gradient on a box decoration is painted
    // without the text direction and would stay on the left in Arabic.
    final rtl = Directionality.of(context) == TextDirection.rtl;
    return ExcludeSemantics(
      child: Stack(
        fit: StackFit.expand,
        children: [
          // The sky is the picture's own, so it does not mirror.
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [_skyLeft, _skyRight]),
            ),
          ),
          ColoredBox(color: light.top.withValues(alpha: 0.10)),
          // Full width at its own proportions, on the bottom edge; on a
          // wide, short hero its top is cut, never its sides.
          LayoutBuilder(
            builder: (context, box) => Stack(
              children: [
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: box.maxWidth / _aspect,
                  child: ShaderMask(
                    // Fades the artwork's top edge into the sky above it.
                    shaderCallback: (rect) => const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0x00000000), Color(0xFF000000)],
                      stops: [0, 0.12],
                    ).createShader(rect),
                    blendMode: BlendMode.dstIn,
                    child: Image.asset(
                      HomeHourField.artwork,
                      fit: BoxFit.cover,
                      gaplessPlayback: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: rtl ? Alignment.centerRight : Alignment.centerLeft,
                end: rtl ? Alignment.centerLeft : Alignment.centerRight,
                colors: [
                  RawdahPalette.forest.withValues(alpha: 0.85),
                  RawdahPalette.forest.withValues(alpha: 0.35),
                  RawdahPalette.forest.withValues(alpha: 0),
                ],
                stops: const [0, 0.4, 0.7],
              ),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  RawdahPalette.emeraldDeep.withValues(alpha: 0),
                  RawdahPalette.emeraldDeep.withValues(alpha: 0.85),
                ],
                stops: const [0.78, 1],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
