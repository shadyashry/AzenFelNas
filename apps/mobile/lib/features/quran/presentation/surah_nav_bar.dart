import 'dart:async';

import 'package:daily_muslim/features/home/presentation/display_style.dart';
import 'package:daily_muslim/features/quran/domain/mushaf_index_entries.dart';
import 'package:daily_muslim/features/quran/domain/reader_preferences.dart';
import 'package:daily_muslim/features/quran/domain/surah_scope.dart';
import 'package:daily_muslim/features/quran/presentation/go_to_page_dialog.dart';
import 'package:daily_muslim/features/quran/presentation/mushaf_viewport_controller.dart';
import 'package:daily_muslim/features/quran/presentation/quran_format.dart';
import 'package:daily_muslim/features/quran/presentation/quran_providers.dart';
import 'package:daily_muslim/features/quran/presentation/reader_controller.dart';
import 'package:daily_muslim/features/quran/presentation/surah_pages_sheet.dart';
import 'package:daily_muslim/l10n/app_localizations.dart';
import 'package:dm_ui/dm_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// How much of the window the reader's controls may take (§15 D121),
/// chosen from the height the window actually has, never from a device
/// model: every step down gives the page more room.
enum ReaderDensity {
  /// A heading, the place in the surah, the slider, the verses of the page
  /// and the zoom buttons.
  full,

  /// The place in the surah on one line, the slider and the footer.
  compact,

  /// The place in the surah on one line only; the slider and zoom buttons
  /// give way to the page (pinch, keys and the menu still zoom).
  minimal;

  /// The density for a window [height] logical pixels tall.
  static ReaderDensity forHeight(double height) => height >= 800
      ? ReaderDensity.full
      : height >= 680
      ? ReaderDensity.compact
      : ReaderDensity.minimal;
}

/// The surah navigator under the page, outside it (§15 D120, D121,
/// REQ-QRN-024): the page and its place among the chosen surah's pages,
/// *All pages*, a slider over the surah's own pages that previews a page
/// while dragging and opens it on release, the verses of the surah on the
/// page, and the zoom buttons. *Beginning of the surah* and *Go to ayah*
/// are one tap away. Nothing while the scope is not known.
final class SurahNavBar extends ConsumerWidget {
  /// The navigator, driving [viewport] at [density].
  const new({
    required this.viewport,
    this.density = ReaderDensity.full,
    super.key,
  });

  /// The page surface, for the zoom buttons.
  final MushafViewportController viewport;

  /// How much room it may take.
  final ReaderDensity density;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scope = ref.watch(readerScopeProvider);
    if (scope == null) return const SizedBox.shrink();
    final l = AppLocalizations.of(context);
    final style = DisplayStyle.of(context, ref);
    final theme = Theme.of(context);
    final scheme = RawdahScheme.of(context);
    String n(int v) => QuranFormat.number(v, style);
    void pages() => showSurahPagesSheet(
      context,
      sura: scope.sura,
      page: scope.page,
      onGoToPage: () => showGoToPageDialog(context, ref),
    );
    final place = density == ReaderDensity.full
        ? _FullPlace(scope: scope)
        : Text(
            scope.single
                ? l.quranSurahOnePage(n(scope.page))
                : l.quranSurahPosition(
                    n(scope.page),
                    n(scope.position),
                    n(scope.count),
                  ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(color: scheme.ink),
          );
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final full = density == ReaderDensity.full;
              final actions = [
                if (!scope.single && full)
                  OutlinedButton.icon(
                    onPressed: pages,
                    icon: const Icon(Icons.grid_view, size: 18),
                    label: Text(l.quranAllPages),
                  ),
                if (!scope.single && !full)
                  IconButton(
                    tooltip: l.quranAllPages,
                    onPressed: pages,
                    icon: const Icon(Icons.grid_view),
                  ),
                _SurahActions(scope: scope),
              ];
              // A narrow column (a side panel, a split window) puts the
              // buttons under the place rather than squeezing it; shorter
              // windows keep one row.
              if (full && constraints.maxWidth < 380) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    place,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: actions,
                    ),
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(child: place),
                  const SizedBox(width: 4),
                  ...actions,
                ],
              );
            },
          ),
          if (!scope.single && density != ReaderDensity.minimal)
            _SurahSlider(scope: scope),
          if (density != ReaderDensity.minimal)
            _Footer(scope: scope, viewport: viewport),
        ],
      ),
    );
  }
}

/// *Within this surah*, the page number large and its place among the
/// surah's pages.
final class _FullPlace extends ConsumerWidget {
  const new({required this.scope});

  final SurahScope scope;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final style = DisplayStyle.of(context, ref);
    final theme = Theme.of(context);
    final scheme = RawdahScheme.of(context);
    String n(int v) => QuranFormat.number(v, style);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l.quranWithinSurah,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.labelSmall?.copyWith(
            color: scheme.caption,
            letterSpacing: 1.2,
          ),
        ),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.end,
          spacing: 8,
          children: [
            Text(
              l.quranPage(n(scope.page)),
              style: theme.textTheme.titleLarge?.copyWith(
                color: scheme.primary,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Text(
                scope.single
                    ? l.quranSurahWholePage
                    : l.quranSurahPageOf(n(scope.position), n(scope.count)),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.inkMuted,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// *Beginning of the surah* and *Go to ayah*, in one menu so the row keeps
/// its room on narrow windows.
final class _SurahActions extends ConsumerWidget {
  const new({required this.scope});

  final SurahScope scope;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return PopupMenuButton<bool>(
      tooltip: l.quranSurahActions,
      icon: const Icon(Icons.more_horiz),
      onSelected: (start) => start
          ? openSurah(ref, scope.sura)
          : showGoToAyahDialog(context, ref, scope.sura),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: true,
          child: ListTile(
            leading: const Icon(Icons.vertical_align_top),
            title: Text(l.quranSurahStart),
          ),
        ),
        PopupMenuItem(
          value: false,
          child: ListTile(
            leading: const Icon(Icons.format_list_numbered_rtl),
            title: Text(l.quranGoToAyah),
          ),
        ),
      ],
    );
  }
}

/// A slider over the surah's own pages, first page on the right as in the
/// Mushaf. Dragging previews the page number; the page opens on release,
/// so the pages in between are never loaded.
final class _SurahSlider extends ConsumerStatefulWidget {
  const new({required this.scope});

  final SurahScope scope;

  @override
  ConsumerState<_SurahSlider> createState() => _SurahSliderState();
}

final class _SurahSliderState extends ConsumerState<_SurahSlider> {
  double? _drag;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final style = DisplayStyle.of(context, ref);
    final scope = widget.scope;
    String label(double v) => l.quranPage(QuranFormat.number(v.round(), style));
    final value = (_drag ?? scope.page.toDouble())
        .clamp(scope.first, scope.last)
        .toDouble();
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Slider(
        value: value,
        min: scope.first.toDouble(),
        max: scope.last.toDouble(),
        divisions: scope.count - 1,
        label: label(value),
        semanticFormatterCallback: label,
        onChanged: (v) => setState(() => _drag = v),
        onChangeEnd: (v) {
          setState(() => _drag = null);
          ref.read(readerProvider.notifier).goTo(v.round());
        },
      ),
    );
  }
}

/// The surah's verses on the page, whether the position is saved, and the
/// zoom buttons.
final class _Footer extends ConsumerWidget {
  const new({required this.scope, required this.viewport});

  final SurahScope scope;
  final MushafViewportController viewport;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final style = DisplayStyle.of(context, ref);
    final theme = Theme.of(context);
    final scheme = RawdahScheme.of(context);
    final saved = ref.watch(readerProvider.select((s) => s.positionSaved));
    final fit = ref.watch(readerProvider.select((s) => s.preferences.fit));
    final ayahs = ref
        .watch(surahPageAyahsProvider(scope.sura.number))
        .value?[scope.page];
    String n(int v) => QuranFormat.number(v, style);
    final small = theme.textTheme.bodySmall?.copyWith(color: scheme.inkMuted);
    return Row(
      children: [
        Expanded(
          child: Wrap(
            spacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (ayahs != null)
                Text(
                  ayahs.first == ayahs.last
                      ? l.quranPageFirstAyah(n(ayahs.first))
                      : l.quranAyahRange(n(ayahs.first), n(ayahs.last)),
                  style: small,
                ),
              if (saved)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check, size: 14, color: scheme.inkMuted),
                    const SizedBox(width: 4),
                    Text(l.quranPositionSaved, style: small),
                  ],
                ),
            ],
          ),
        ),
        ListenableBuilder(
          listenable: viewport,
          builder: (context, _) => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: l.quranZoomOut,
                onPressed: viewport.scale > 1
                    ? () => viewport.send(ViewportCommand.zoomOut)
                    : null,
                icon: const Icon(Icons.zoom_out),
              ),
              IconButton(
                tooltip: l.quranZoomIn,
                onPressed: viewport.scale < 4
                    ? () => viewport.send(ViewportCommand.zoomIn)
                    : null,
                icon: const Icon(Icons.zoom_in),
              ),
              IconButton(
                tooltip: fit == PageFit.page ? l.quranFitWidth : l.quranFitPage,
                onPressed: () {
                  final prefs = ref.read(readerProvider).preferences;
                  ref
                      .read(readerProvider.notifier)
                      .setPreferences(
                        prefs.copyWith(
                          fit: fit == PageFit.page
                              ? PageFit.width
                              : PageFit.page,
                        ),
                      );
                },
                icon: Icon(
                  fit == PageFit.page ? Icons.width_full : Icons.fit_screen,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// The surah after the scope's when the current page is its last, so the
/// reader's *Next page* becomes *Continue to* it; `null` otherwise.
SuraEntry? continueAfter(SurahScope? scope, List<SuraEntry> suras) {
  if (scope == null || !scope.atEnd) return null;
  for (final s in suras) {
    if (s.number == scope.sura.number + 1) return s;
  }
  return null;
}

/// Opens the first verse of [sura] with its lines outlined; it becomes the
/// navigator's surah even when it starts on the page already shown.
void openSurah(WidgetRef ref, SuraEntry sura) => unawaited(
  ref
      .read(readerProvider.notifier)
      .showVerseAt(sura.number, 1, fallbackPage: sura.startPage),
);
