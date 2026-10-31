import 'dart:async';

import 'package:daily_muslim/features/radio/domain/radio_playback.dart';
import 'package:daily_muslim/features/radio/domain/radio_station.dart';
import 'package:daily_muslim/features/radio/presentation/radio_arch.dart';
import 'package:daily_muslim/features/radio/presentation/radio_player_card.dart';
import 'package:daily_muslim/features/radio/presentation/radio_providers.dart';
import 'package:daily_muslim/features/radio/presentation/radio_tokens.dart';
import 'package:daily_muslim/features/radio/presentation/radio_type.dart';
import 'package:daily_muslim/l10n/app_localizations.dart';
import 'package:dm_ui/dm_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Which stations the list shows.
enum RadioListFilter {
  /// Every station.
  all,

  /// The favorites only.
  favorites,
}

/// Search that ignores case, Arabic marks and tatweel, and the spelling
/// variants of alef, taa marbuta and alef maqsura (§15 D122).
abstract final class RadioSearch {
  static final _marks = RegExp('[ً-ٰٟـ]');

  /// [text] folded for matching.
  static String fold(String text) => text
      .toLowerCase()
      .replaceAll(_marks, '')
      .replaceAll(RegExp('[أإآٱ]'), 'ا')
      .replaceAll('ة', 'ه')
      .replaceAll('ى', 'ي')
      .replaceAll(
        RegExp(
          r'[\-_’'
          ']',
        ),
        ' ',
      )
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  /// Whether [station] matches [query] in either language.
  static bool matches(RadioStation station, String query) {
    final q = fold(query);
    if (q.isEmpty) return true;
    return fold(station.nameEn).contains(q) || fold(station.nameAr).contains(q);
  }
}

/// "Your stations" with the All and Favorites tabs (§15 D122).
final class RadioListHeader extends StatelessWidget {
  /// The heading with [filter] chosen.
  const new({required this.filter, required this.onFilter, super.key});

  /// The chosen tab.
  final RadioListFilter filter;

  /// Called with the tapped tab.
  final ValueChanged<RadioListFilter> onFilter;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = RadioTokens.of(context);
    final type = RadioType.of(context);
    return Row(
      children: [
        Expanded(
          child: Semantics(
            header: true,
            child: Text(
              l.radioYourStations,
              style: type.sectionTitle.copyWith(color: t.text),
            ),
          ),
        ),
        for (final f in RadioListFilter.values)
          _FilterTab(
            label: switch (f) {
              RadioListFilter.all => l.radioAll,
              RadioListFilter.favorites => l.radioFavorites,
            },
            selected: f == filter,
            onTap: () => onFilter(f),
          ),
      ],
    );
  }
}

final class _FilterTab extends StatelessWidget {
  const new({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = RadioTokens.of(context);
    final style = RadioType.of(context).label;
    return Semantics(
      button: true,
      selected: selected,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: style.copyWith(
                    color: selected ? t.text : t.textMuted,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    fontVariations: DmTheme.weightAxis(
                      selected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                // The chosen tab carries a gold bar: shape, not colour alone.
                Container(
                  width: 18,
                  height: 2,
                  color: selected ? t.gold : Colors.transparent,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The search field.
final class RadioSearchField extends StatelessWidget {
  /// The field over [controller].
  const new({required this.controller, super.key});

  /// The query.
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = RadioTokens.of(context);
    final type = RadioType.of(context);
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: t.border),
    );
    return TextField(
      controller: controller,
      textInputAction: TextInputAction.search,
      style: type.body.copyWith(color: t.text),
      cursorColor: t.green,
      decoration: InputDecoration(
        isDense: true,
        filled: true,
        fillColor: t.surface,
        hintText: l.radioSearchHint,
        hintStyle: type.body.copyWith(color: t.textMuted),
        prefixIcon: Icon(Icons.search, color: t.textMuted, size: 20),
        suffixIcon: ValueListenableBuilder(
          valueListenable: controller,
          builder: (context, value, _) => value.text.isEmpty
              ? const SizedBox.shrink()
              : IconButton(
                  tooltip: MaterialLocalizations.of(context)
                      .deleteButtonTooltip,
                  icon: Icon(Icons.close, color: t.textMuted, size: 18),
                  onPressed: controller.clear,
                ),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        border: border,
        enabledBorder: border,
        focusedBorder: border.copyWith(
          borderSide: BorderSide(color: t.gold, width: 1.2),
        ),
      ),
    );
  }
}

/// One station: its arch tile, name, line and heart. Tapping plays it.
final class RadioStationRow extends ConsumerWidget {
  /// The row for [station].
  const new({required this.station, required this.favorite, super.key});

  /// The station.
  final RadioStation station;

  /// Whether it is a favorite.
  final bool favorite;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = RadioTokens.of(context);
    final type = RadioType.of(context);
    final playback = ref.watch(
      radioPlaybackProvider.select((p) => p.value),
    );
    final selected =
        ref.watch(radioControllerProvider.select((v) => v.selectedId)) ==
        station.id;
    final mine = playback != null && playback.stationId == station.id;
    final phase = mine ? playback.phase : null;
    final name = station.nameIn(type.language);
    final line = switch (phase) {
      RadioPhase.playing => l.radioNowPlaying,
      final RadioPhase p
          when p == RadioPhase.connecting ||
              p == RadioPhase.paused ||
              p == RadioPhase.reconnecting ||
              p == RadioPhase.unavailable =>
        radioStatusLabel(l, p),
      _ => radioDescription(
        l,
        station,
        type.language,
      ),
    };
    final current = selected && (playback?.session ?? false);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: current ? t.selected : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => unawaited(
            ref
                .read(radioControllerProvider.notifier)
                .playStation(station, radioNowPlayingText(context, station)),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 64),
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(8, 8, 0, 8),
              child: Row(
                children: [
                  RadioArch(
                    width: 32,
                    height: 36,
                    color: current ? t.green : t.tile,
                    child: Icon(
                      current ? Icons.graphic_eq : Icons.sensors,
                      size: 16,
                      color: current ? t.gold : t.tileIcon,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Semantics(
                      selected: current,
                      button: true,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: type.rowName.copyWith(color: t.text),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            line,
                            style: type.secondary.copyWith(
                              color: t.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: favorite
                        ? l.radioFavoriteRemove(name)
                        : l.radioFavoriteAdd(name),
                    onPressed: () => unawaited(
                      ref.read(toggleRadioFavoriteProvider)(station.id),
                    ),
                    icon: Icon(
                      favorite ? Icons.favorite : Icons.favorite_border,
                      size: 22,
                      color: favorite ? t.goldIcon : t.text,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 48,
                      minHeight: 48,
                    ),
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

/// The discreet source credit (REQ-RADIO-013): MP3Quran supplies the
/// audio; nothing suggests the app is theirs or a reciter's.
final class RadioAttribution extends StatelessWidget {
  /// The credit.
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final t = RadioTokens.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.headphones_outlined, size: 16, color: t.textMuted),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              AppLocalizations.of(context).radioAttribution,
              textAlign: TextAlign.center,
              style: RadioType.of(context).label.copyWith(color: t.textMuted),
            ),
          ),
        ],
      ),
    );
  }
}
