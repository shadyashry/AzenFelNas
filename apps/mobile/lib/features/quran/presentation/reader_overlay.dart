import 'dart:async';

import 'package:daily_muslim/features/home/presentation/display_style.dart';
import 'package:daily_muslim/features/quran/domain/hizb_quarter.dart';
import 'package:daily_muslim/features/quran/domain/mushaf_index_entries.dart';
import 'package:daily_muslim/features/quran/domain/quran_edition_pin.dart';
import 'package:daily_muslim/features/quran/domain/reader_preferences.dart';
import 'package:daily_muslim/features/quran/presentation/go_to_page_dialog.dart';
import 'package:daily_muslim/features/quran/presentation/mushaf_viewport_controller.dart';
import 'package:daily_muslim/features/quran/presentation/quran_format.dart';
import 'package:daily_muslim/features/quran/presentation/quran_index_sheet.dart';
import 'package:daily_muslim/features/quran/presentation/quran_providers.dart';
import 'package:daily_muslim/features/quran/presentation/reader_bars.dart';
import 'package:daily_muslim/features/quran/presentation/reader_controller.dart';
import 'package:daily_muslim/features/quran/presentation/reading_mode_sheet.dart';
import 'package:daily_muslim/features/quran/presentation/surah_nav_bar.dart';
import 'package:daily_muslim/features/quran/presentation/surah_pages_sheet.dart';
import 'package:daily_muslim/features/schedule/presentation/schedule_providers.dart';
import 'package:daily_muslim/features/shell/domain/app_route.dart';
import 'package:daily_muslim/l10n/app_localizations.dart';
import 'package:dm_ui/dm_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// The reader's toolbar (§15 D123): the index, the surah and the edition,
/// the fit, Tajweed colours, search, the bookmark, the menu and a button
/// that hides the controls. It floats over the reading surface while the
/// controls are shown and takes no room from the page; actions the width
/// cannot hold move into the menu, never off the screen.
final class ReaderToolbar extends ConsumerWidget {
  /// The toolbar for [page] in a [landscape] window, driving [viewport].
  const new({
    required this.page,
    required this.viewport,
    required this.landscape,
    super.key,
  });

  /// Its height under the status bar.
  static const double height = 60;

  /// The current page.
  final int page;

  /// The page surface.
  final MushafViewportController viewport;

  /// Whether the window is landscape.
  final bool landscape;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final style = DisplayStyle.of(context, ref);
    final palette = MushafPalette.of(context);
    final suras = ref.watch(surasProvider).value ?? const <SuraEntry>[];
    final juz = ref.watch(juzProvider).value ?? const <JuzEntry>[];
    final sura =
        ref.watch(readerScopeProvider)?.sura ??
        suras.lastWhereOrNull((s) => s.startPage <= page);
    final part = juz.lastWhereOrNull((j) => j.page <= page);
    final marked =
        ref.watch(bookmarksProvider).value?.any((b) => b.page == page) ?? false;
    final fit = ref.watch(
      readerProvider.select((s) => s.preferences.fitFor(landscape: landscape)),
    );
    final arabic = style.locale == StatusLocale.ar;
    final caption = Theme.of(
      context,
    ).textTheme.bodySmall?.copyWith(color: palette.onBarMuted, height: 1.2);
    final insets = MediaQuery.paddingOf(context);
    return Material(
      color: palette.bar,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: palette.gold.withValues(alpha: 0.55)),
          ),
        ),
        child: Padding(
          padding: EdgeInsetsDirectional.only(
            top: insets.top,
            start: insets.left,
            end: insets.right,
          ),
          child: SizedBox(
            height: height,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final fitLabelled = width >= 840;
                final fitShown = width >= 520;
                final tajweedShown = width >= 760;
                final searchShown = width >= 400;
                final inBar = {
                  if (fitShown) ReaderMenuItem.fit,
                  if (tajweedShown) ReaderMenuItem.tajweed,
                  if (searchShown) ReaderMenuItem.search,
                };
                final iconColor = palette.onBar;
                return Row(
                  children: [
                    const SizedBox(width: 4),
                    IconButton(
                      tooltip: l.quranIndex,
                      color: iconColor,
                      icon: const Icon(Icons.format_list_bulleted),
                      onPressed: () => showQuranIndexSheet(
                        context,
                        currentSura: sura?.number,
                      ),
                    ),
                    Expanded(
                      child: _Title(
                        sura: sura,
                        part: part,
                        arabic: arabic,
                        caption: caption,
                        showEdition: width >= 560,
                      ),
                    ),
                    if (fitShown)
                      _FitButton(
                        fit: fit,
                        labelled: fitLabelled,
                        onPressed: () => toggleFit(ref, landscape: landscape),
                      ),
                    if (tajweedShown) const _TajweedToggle(),
                    if (searchShown)
                      IconButton(
                        tooltip: l.quranSearch,
                        color: iconColor,
                        icon: const Icon(Icons.search),
                        onPressed: () =>
                            context.push(const QuranSearchRoute().location),
                      ),
                    IconButton(
                      tooltip: marked
                          ? l.quranBookmarkRemove
                          : l.quranBookmarkAdd,
                      isSelected: marked,
                      color: iconColor,
                      icon: const Icon(Icons.bookmark_border),
                      selectedIcon: Icon(Icons.bookmark, color: palette.gold),
                      onPressed: () => ref
                          .read(bookmarkStoreProvider)
                          .toggleBookmark(
                            QuranEditionPin.layoutId,
                            page,
                            nowUtcMs: ref.read(clockProvider).nowUtcMs(),
                          ),
                    ),
                    ReaderMenu(
                      viewport: viewport,
                      color: iconColor,
                      landscape: landscape,
                      inBar: inBar,
                    ),
                    IconButton(
                      tooltip: l.quranHideControls,
                      color: iconColor,
                      icon: const Icon(Icons.close),
                      onPressed: ref.read(readerProvider.notifier).hideChrome,
                    ),
                    const SizedBox(width: 4),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// The surah (tap for the surah index at it), then the edition and the juz
/// (tap for the juz index at it).
final class _Title extends ConsumerWidget {
  const new({
    required this.sura,
    required this.part,
    required this.arabic,
    required this.caption,
    required this.showEdition,
  });

  final SuraEntry? sura;
  final JuzEntry? part;
  final bool arabic;
  final TextStyle? caption;
  final bool showEdition;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final style = DisplayStyle.of(context, ref);
    final palette = MushafPalette.of(context);
    final sura = this.sura;
    final part = this.part;
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (sura != null)
          TitleTap(
            hint: l.quranIndex,
            onTap: () => showQuranIndexSheet(context, currentSura: sura.number),
            child: Text(
              arabic ? sura.header : QuranFormat.surahName(sura, style),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: DmTheme.naskh(
                size: arabic ? 22 : 21,
                color: palette.onBar,
                bold: !arabic,
              ).copyWith(height: 1.15),
            ),
          ),
        Row(
          children: [
            if (showEdition)
              Flexible(
                child: Text(
                  part == null
                      ? l.quranEditionShort
                      : '${l.quranEditionShort} · ',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: caption,
                ),
              ),
            if (part != null)
              Flexible(
                child: TitleTap(
                  hint: l.quranIndex,
                  onTap: () =>
                      showQuranIndexSheet(context, currentJuz: part.number),
                  child: Text(
                    l.quranJuz(QuranFormat.number(part.number, style)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: caption,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

/// *Fit width* / *Whole page*: shows the fit in use, switches on a tap.
final class _FitButton extends StatelessWidget {
  const new({
    required this.fit,
    required this.labelled,
    required this.onPressed,
  });

  final PageFit fit;
  final bool labelled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final palette = MushafPalette.of(context);
    final name = fit == PageFit.width ? l.quranFitWidth : l.quranFitPage;
    final other = fit == PageFit.width ? l.quranFitPage : l.quranFitWidth;
    final icon = Icon(
      fit == PageFit.width ? Icons.fit_screen : Icons.crop_portrait,
      size: 20,
    );
    final tooltip = l.quranFitSwitchTo(other);
    if (!labelled) {
      return IconButton(
        tooltip: tooltip,
        color: palette.onBar,
        icon: icon,
        onPressed: onPressed,
      );
    }
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 8),
      child: Tooltip(
        message: tooltip,
        child: OutlinedButton.icon(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: palette.onBar,
            side: BorderSide(color: palette.gold.withValues(alpha: 0.8)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            minimumSize: const Size(0, 44),
          ),
          icon: icon,
          label: Text(name),
        ),
      ),
    );
  }
}

/// *Tajweed colours*, shown off: no permitted source matches these pages
/// yet (§15 D120), so a tap explains why instead of turning it on.
final class _TajweedToggle extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final palette = MushafPalette.of(context);
    return Semantics(
      toggled: false,
      button: true,
      label: l.quranTajweed,
      value: l.quranTajweedUnavailableShort,
      excludeSemantics: true,
      child: InkWell(
        onTap: () => showReadingModeSheet(context),
        borderRadius: BorderRadius.circular(12),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 30,
                  height: 16,
                  padding: const EdgeInsets.all(2),
                  alignment: AlignmentDirectional.centerStart,
                  decoration: BoxDecoration(
                    color: palette.onBar.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: palette.bar,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  l.quranTajweed,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: palette.onBar),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The page navigator (§15 D123, REQ-QRN-020, REQ-QRN-024): a rounded bar
/// floating above the bottom edge with the Mushaf page, its place in the
/// chosen surah (and a hizb quarter that starts on it), *Next* and
/// *Previous* around a slider over the surah's pages, and *Pages*. The
/// arrows and the slider keep the Mushaf's direction in both languages:
/// *Next* on the left; the information and *Pages* follow the interface.
final class ReaderNavPanel extends ConsumerWidget {
  /// The navigator for [page], driving [viewport].
  const new({required this.page, required this.viewport, super.key});

  /// Height of the bar in one row.
  static const double height = 72;

  /// Height of the bar in two rows: the page details and *Pages* above
  /// the page buttons and the slider.
  static const double twoRowHeight = 124;

  /// Whether a bar [width] wide takes two rows, so the slider keeps room.
  static bool twoRows(double width) => width < 560;

  /// The bar's height at [width].
  static double heightAt(double width) =>
      twoRows(width) ? twoRowHeight : height;

  /// Room around it.
  static const double margin = 12;

  /// The current page.
  final int page;

  /// The page surface.
  final MushafViewportController viewport;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final style = DisplayStyle.of(context, ref);
    final palette = MushafPalette.of(context);
    final theme = Theme.of(context);
    final scope = ref.watch(readerScopeProvider);
    final suras = ref.watch(surasProvider).value ?? const <SuraEntry>[];
    final quarter = HizbQuarter.on(
      ref.watch(quartersProvider).value ?? const <HizbQuarter>[],
      page,
    );
    final next = continueAfter(scope, suras);
    String n(int v) => QuranFormat.number(v, style);
    final place = scope == null
        ? null
        : scope.single
        ? l.quranWholeSurahHere
        : l.quranPlaceInSurah(n(scope.position), n(scope.count));
    final hizb = quarter == null ? null : _quarterLabel(l, quarter, n);
    final details = [?place, ?hizb].join(' · ');
    void pages() {
      if (scope == null) {
        unawaited(showGoToPageDialog(context, ref));
      } else {
        unawaited(
          showSurahPagesSheet(
            context,
            sura: scope.sura,
            page: scope.page,
            onGoToPage: () => showGoToPageDialog(context, ref),
          ),
        );
      }
    }

    final nextLabel = next == null
        ? l.quranNextPage
        : next.startPage == scope?.page
        ? l.quranNextSurahSamePage(QuranFormat.surahName(next, style))
        : l.quranNextSurah(QuranFormat.surahName(next, style));
    final info = TitleTap(
      hint: l.quranAllPages,
      onTap: pages,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.quranPage(n(page)),
            maxLines: 1,
            style: theme.textTheme.titleMedium?.copyWith(
              color: palette.onBar,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (details.isNotEmpty)
            Text(
              details,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: palette.onBarMuted,
              ),
            ),
        ],
      ),
    );
    Widget pagesButton({required bool labelled}) => labelled
        ? OutlinedButton.icon(
            onPressed: pages,
            style: OutlinedButton.styleFrom(
              foregroundColor: palette.onBar,
              side: BorderSide(color: palette.gold.withValues(alpha: 0.8)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              minimumSize: const Size(0, 48),
            ),
            icon: const Icon(Icons.grid_view, size: 20),
            label: Text(l.quranPagesButton),
          )
        : IconButton(
            tooltip: l.quranPagesButton,
            color: palette.onBar,
            onPressed: pages,
            icon: const Icon(Icons.grid_view),
          );
    // Next on the left, as in the Mushaf, in both languages.
    Widget turns({required bool slider}) => Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        children: [
          _RoundButton(
            tooltip: nextLabel,
            icon: Icons.chevron_left,
            onPressed: next == null
                ? () => viewport.send(ViewportCommand.next)
                : () => openSurah(ref, next),
          ),
          if (slider && scope != null)
            Expanded(
              child: SurahSlider(
                scope: scope,
                active: palette.gold,
                inactive: palette.track,
              ),
            )
          else
            const Spacer(),
          _RoundButton(
            tooltip: l.quranPreviousPage,
            icon: Icons.chevron_right,
            onPressed: () => viewport.send(ViewportCommand.previous),
          ),
        ],
      ),
    );
    return Material(
      color: palette.bar,
      borderRadius: BorderRadius.circular(22),
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final slider = scope != null && !scope.single && width >= 300;
          if (twoRows(width)) {
            return ConstrainedBox(
              constraints: const BoxConstraints(minHeight: twoRowHeight),
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(18, 8, 8, 6),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(child: info),
                        pagesButton(labelled: width >= 360),
                      ],
                    ),
                    const SizedBox(height: 4),
                    turns(slider: slider),
                  ],
                ),
              ),
            );
          }
          return ConstrainedBox(
            constraints: const BoxConstraints(minHeight: height),
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(18, 6, 10, 6),
              child: Row(
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: width * 0.34),
                    child: info,
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: turns(slider: slider)),
                  const SizedBox(width: 8),
                  pagesButton(labelled: true),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  static String _quarterLabel(
    AppLocalizations l,
    HizbQuarter q,
    String Function(int) n,
  ) => switch (q.part) {
    HizbPart.start => l.quranHizbStart(n(q.hizb)),
    HizbPart.quarter => l.quranHizbQuarter(n(q.hizb)),
    HizbPart.half => l.quranHizbHalf(n(q.hizb)),
    HizbPart.threeQuarters => l.quranHizbThreeQuarters(n(q.hizb)),
  };
}

/// A round page button.
final class _RoundButton extends StatelessWidget {
  const new({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final palette = MushafPalette.of(context);
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      style: IconButton.styleFrom(
        backgroundColor: palette.onBar.withValues(alpha: 0.08),
        foregroundColor: palette.onBar,
        fixedSize: const Size(52, 52),
      ),
      icon: Icon(icon, size: 26, semanticLabel: tooltip),
    );
  }
}

/// The small *…* in the lower reading margin that brings the controls back
/// (§15 D123): a quiet pill drawn inside that margin (28 dp in landscape),
/// never over a word; its touch target is 48 dp tall and reaches up over
/// the page without drawing there. Tooltip and label for screen readers.
final class ReaderHandle extends StatelessWidget {
  /// The handle running [onPressed].
  const new({required this.onPressed, super.key});

  /// Shows the controls.
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final palette = MushafPalette.of(context);
    return Tooltip(
      message: l.quranShowControls,
      excludeFromSemantics: true,
      child: Semantics(
        button: true,
        label: l.quranShowControls,
        excludeSemantics: true,
        child: InkResponse(
          onTap: onPressed,
          radius: 28,
          child: SizedBox(
            width: 64,
            height: 48,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: 52,
                height: 22,
                margin: const EdgeInsets.only(bottom: 3),
                decoration: BoxDecoration(
                  color: palette.handle.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.more_horiz, size: 20, color: palette.gold),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

extension<T> on List<T> {
  T? lastWhereOrNull(bool Function(T) test) {
    for (var i = length - 1; i >= 0; i--) {
      if (test(this[i])) return this[i];
    }
    return null;
  }
}
