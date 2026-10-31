import 'dart:async';

import 'package:daily_muslim/features/radio/domain/radio_playback.dart';
import 'package:daily_muslim/features/radio/presentation/radio_arch.dart';
import 'package:daily_muslim/features/radio/presentation/radio_player_card.dart';
import 'package:daily_muslim/features/radio/presentation/radio_providers.dart';
import 'package:daily_muslim/features/radio/presentation/radio_tokens.dart';
import 'package:daily_muslim/features/radio/presentation/radio_type.dart';
import 'package:daily_muslim/features/shell/domain/app_route.dart';
import 'package:daily_muslim/l10n/app_localizations.dart';
import 'package:dm_ui/dm_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// The mini player above the tabs on every tab but Radio (§15 D122,
/// REQ-RADIO-012): shown while a station connects, plays, pauses or
/// reconnects; nothing otherwise. The title and arch open Radio; Play or
/// Pause and Close are separate buttons, and Close stops the radio. It is
/// a second view of the one player, never a second stream.
final class RadioMiniPlayer extends ConsumerWidget {
  /// The mini player.
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playback = ref.watch(radioPlaybackProvider).value;
    if (playback == null || !playback.session) return const SizedBox.shrink();
    final l = AppLocalizations.of(context);
    final type = RadioType.of(context);
    final view = ref.watch(radioControllerProvider);
    final id = playback.stationId;
    final station = id == null ? null : view.catalog?.byId(id);
    final title = station?.nameIn(type.language) ?? l.radioTitle;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final controller = ref.read(radioControllerProvider.notifier);
    final wantsSound = playback.wantsSound;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      child: Material(
        color: dark ? RadioMiniTokens.surfaceOnDark : RadioMiniTokens.surface,
        elevation: 3,
        shadowColor: const Color(0x40000000),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(13),
          side: const BorderSide(color: RadioMiniTokens.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 4, 0),
          child: Row(
            children: [
              Expanded(
                child: Semantics(
                  button: true,
                  label: l.radioOpenPlayer(title),
                  excludeSemantics: true,
                  child: InkWell(
                    onTap: () => context.go(const RadioRoute().location),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 60),
                      child: Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                          12,
                          8,
                          8,
                          8,
                        ),
                        child: Row(
                          children: [
                            RadioArch(
                              width: 34,
                              height: 40,
                              border: BorderSide(
                                color: RadioMiniTokens.border.withValues(
                                  alpha: 0.9,
                                ),
                              ),
                              child: const RawdahGlyph(
                                kind: RawdahGlyphKind.radio,
                                color: RadioMiniTokens.text,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: type.miniTitle.copyWith(
                                      color: RadioMiniTokens.text,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  _StatusLine(phase: playback.phase),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Tooltip(
                message: wantsSound ? l.radioPause : l.radioPlay,
                child: Semantics(
                  button: true,
                  label: wantsSound ? l.radioPause : l.radioPlay,
                  excludeSemantics: true,
                  child: InkResponse(
                    radius: 26,
                    onTap: () => unawaited(
                      wantsSound
                          ? controller.pause()
                          : controller.resumeOrPlay(
                              (s) => radioNowPlayingText(context, s),
                            ),
                    ),
                    child: SizedBox.square(
                      dimension: 48,
                      child: Center(
                        child: DecoratedBox(
                          decoration: const BoxDecoration(
                            color: RadioMiniTokens.control,
                            shape: BoxShape.circle,
                          ),
                          child: SizedBox.square(
                            dimension: 40,
                            child: Icon(
                              wantsSound ? Icons.pause : Icons.play_arrow,
                              color: RadioMiniTokens.onControl,
                              size: 22,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                tooltip: l.radioClose,
                onPressed: () => unawaited(controller.stop()),
                icon: const Icon(Icons.close, size: 22),
                color: RadioMiniTokens.text,
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

final class _StatusLine extends StatelessWidget {
  const new({required this.phase});

  final RadioPhase phase;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final live = phase == RadioPhase.playing;
    return Row(
      children: [
        Container(
          width: 5,
          height: 5,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: live ? RadioMiniTokens.live : null,
            border: live ? null : Border.all(color: RadioMiniTokens.textMuted),
          ),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            '${radioStatusLabel(l, phase)} · ${l.radioSource}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: RadioType.of(context).miniStatus.copyWith(
              color: RadioMiniTokens.textMuted,
            ),
          ),
        ),
      ],
    );
  }
}
