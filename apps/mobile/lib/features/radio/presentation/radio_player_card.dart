import 'dart:async';

import 'package:daily_muslim/features/radio/domain/radio_playback.dart';
import 'package:daily_muslim/features/radio/domain/radio_station.dart';
import 'package:daily_muslim/features/radio/presentation/radio_arch.dart';
import 'package:daily_muslim/features/radio/presentation/radio_controller.dart';
import 'package:daily_muslim/features/radio/presentation/radio_providers.dart';
import 'package:daily_muslim/features/radio/presentation/radio_sleep_sheet.dart';
import 'package:daily_muslim/features/radio/presentation/radio_tokens.dart';
import 'package:daily_muslim/features/radio/presentation/radio_type.dart';
import 'package:daily_muslim/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The words the native player shows for [station] in [context]'s language.
RadioNowPlayingText radioNowPlayingText(
  BuildContext context,
  RadioStation station,
) {
  final l = AppLocalizations.of(context);
  return (
    title: station.nameIn(RadioType.of(context).language),
    subtitle: l.radioNowPlayingSubtitle,
  );
}

/// The main player (§15 D122): the true state, the source, the arch, the
/// chosen station and what is known about it, Favorite, Play/Pause, Stop
/// and the sleep timer. No programme, track or level is shown: the app
/// does not know them (REQ-RADIO-013). [compact] (short landscape
/// windows) puts a smaller arch beside the name, without its ring, so the
/// controls stay in view: decoration gives way before the controls do.
final class RadioPlayerCard extends ConsumerWidget {
  /// The card.
  const new({this.compact = false, super.key});

  /// The short form.
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = RadioTokens.of(context);
    final type = RadioType.of(context);
    final dark = Theme.of(context).brightness == Brightness.dark;
    final view = ref.watch(radioControllerProvider);
    final playback = ref.watch(radioPlaybackProvider).value;
    final station = view.selected;
    final mine =
        playback != null && station != null && playback.stationId == station.id;
    final phase = mine ? playback.phase : RadioPhase.ready;
    final favorite =
        station != null &&
        (ref.watch(radioFavoritesProvider).value?.contains(station.id) ??
            false);
    final controller = ref.read(radioControllerProvider.notifier);
    final wantsSound = mine && playback.wantsSound;
    final canStop =
        mine && (playback.session || phase == RadioPhase.unavailable);
    final sleep = mine ? playback.sleep : null;
    final arch = RadioArch(
      width: compact ? 52 : 74,
      height: compact ? 56 : 80,
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: dark
            ? const [Color(0xFF2A6B53), Color(0xFF184634)]
            : const [Color(0xFF22604B), Color(0xFF123E31)],
      ),
      border: BorderSide(color: t.gold, width: 1.4),
      ring: compact ? null : t.gold.withValues(alpha: 0.35),
      child: Icon(
        Icons.graphic_eq,
        size: compact ? 18 : 22,
        color: t.gold.withValues(alpha: 0.9),
      ),
    );
    List<Widget> identity(TextAlign align) => [
      Semantics(
        header: true,
        child: Text(
          station?.nameIn(type.language) ?? l.radioChooseStation,
          textAlign: align,
          style: type.stationTitle.copyWith(color: t.text),
        ),
      ),
      if (station != null) ...[
        const SizedBox(height: 6),
        Text(
          radioDescription(l, station, type.language),
          textAlign: align,
          style: type.secondary.copyWith(color: t.textMuted),
        ),
      ],
    ];

    return DecoratedBox(
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: t.border),
        boxShadow: dark
            ? null
            : const [
                BoxShadow(
                  color: Color(0x14233D32),
                  blurRadius: 18,
                  offset: Offset(0, 6),
                ),
              ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 6),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: _StatusChip(phase: phase)),
                const SizedBox(width: 8),
                Text(
                  l.radioSource,
                  style: type.label.copyWith(color: t.textMuted),
                ),
              ],
            ),
            SizedBox(height: compact ? 10 : 14),
            if (compact)
              Row(
                children: [
                  arch,
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: identity(TextAlign.start),
                    ),
                  ),
                ],
              )
            else ...[
              arch,
              const SizedBox(height: 16),
              ...identity(TextAlign.center),
            ],
            SizedBox(height: compact ? 8 : 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _RoundAction(
                  tooltip: station == null
                      ? l.radioFavorites
                      : favorite
                      ? l.radioFavoriteRemove(station.nameIn(type.language))
                      : l.radioFavoriteAdd(station.nameIn(type.language)),
                  icon: favorite ? Icons.favorite : Icons.favorite_border,
                  color: t.goldIcon,
                  onPressed: station == null
                      ? null
                      : () => unawaited(
                          ref.read(toggleRadioFavoriteProvider)(station.id),
                        ),
                ),
                const SizedBox(width: 28),
                _PlayButton(
                  wantsSound: wantsSound,
                  onPressed: station == null
                      ? null
                      : () => unawaited(
                          controller.togglePlay(
                            (s) => radioNowPlayingText(context, s),
                          ),
                        ),
                ),
                const SizedBox(width: 28),
                _RoundAction(
                  tooltip: l.radioStop,
                  icon: Icons.stop_outlined,
                  color: t.text,
                  onPressed: canStop
                      ? () => unawaited(controller.stop())
                      : null,
                ),
              ],
            ),
            if (phase == RadioPhase.unavailable) ...[
              const SizedBox(height: 10),
              Text(
                l.radioUnavailableHint,
                textAlign: TextAlign.center,
                style: type.secondary.copyWith(color: t.textMuted),
              ),
            ],
            const SizedBox(height: 14),
            Divider(height: 1, color: t.border),
            _SleepRow(
              label: l.radioSleepLabel(
                radioSleepValue(l, sleep?.option ?? RadioSleepOption.off),
              ),
              onTap: mine && playback.session
                  ? () => unawaited(showRadioSleepSheet(context, ref))
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

/// The sleep timer's row: its label wraps rather than overflows at large
/// text sizes.
final class _SleepRow extends StatelessWidget {
  const new({required this.label, required this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = RadioTokens.of(context);
    final color = onTap == null ? t.textMuted : t.text;
    return Semantics(
      button: true,
      enabled: onTap != null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.bedtime_outlined, size: 18, color: color),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: RadioType.of(context).body.copyWith(color: color),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

final class _StatusChip extends StatelessWidget {
  const new({required this.phase});

  final RadioPhase phase;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = RadioTokens.of(context);
    final live = phase == RadioPhase.playing;
    return Semantics(
      liveRegion: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: live ? const Color(0xFF4E9A63) : null,
              border: live ? null : Border.all(color: t.textMuted),
            ),
          ),
          const SizedBox(width: 7),
          Flexible(
            child: Text(
              radioStatusLabel(l, phase),
              style: RadioType.of(context).label.copyWith(color: t.textMuted),
            ),
          ),
        ],
      ),
    );
  }
}

final class _PlayButton extends StatelessWidget {
  const new({required this.wantsSound, required this.onPressed});

  final bool wantsSound;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = RadioTokens.of(context);
    final dark = Theme.of(context).brightness == Brightness.dark;
    final label = wantsSound ? l.radioPause : l.radioPlay;
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: Tooltip(
        message: label,
        child: SizedBox.square(
          dimension: 64,
          child: Center(
            child: Material(
              color: onPressed == null
                  ? t.green.withValues(alpha: 0.45)
                  : t.green,
              shape: CircleBorder(
                side: dark
                    ? BorderSide(color: t.gold, width: 1.2)
                    : BorderSide.none,
              ),
              elevation: dark ? 0 : 3,
              shadowColor: const Color(0x55174D3C),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onPressed,
                child: SizedBox.square(
                  dimension: 54,
                  child: Icon(
                    wantsSound ? Icons.pause : Icons.play_arrow,
                    color: t.onGreen,
                    size: 26,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

final class _RoundAction extends StatelessWidget {
  const new({
    required this.tooltip,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final Color color;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: tooltip,
    onPressed: onPressed,
    icon: Icon(icon, size: 24),
    color: color,
    disabledColor: RadioTokens.of(context).textMuted.withValues(alpha: 0.5),
    constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
  );
}
