import 'package:daily_muslim/features/home/presentation/display_style.dart';
import 'package:daily_muslim/features/quran/domain/highlight_color.dart';
import 'package:daily_muslim/features/quran/domain/reader_preferences.dart';
import 'package:daily_muslim/features/quran/presentation/ayah_sheet.dart';
import 'package:daily_muslim/features/quran/presentation/go_to_page_dialog.dart';
import 'package:daily_muslim/features/quran/presentation/highlight_sheet.dart';
import 'package:daily_muslim/features/quran/presentation/mushaf_viewport_controller.dart';
import 'package:daily_muslim/features/quran/presentation/quran_format.dart';
import 'package:daily_muslim/features/quran/presentation/quran_index_sheet.dart';
import 'package:daily_muslim/features/quran/presentation/quran_providers.dart';
import 'package:daily_muslim/features/quran/presentation/reader_controller.dart';
import 'package:daily_muslim/features/quran/presentation/reading_mode_sheet.dart';
import 'package:daily_muslim/features/quran/presentation/surah_nav_bar.dart';
import 'package:daily_muslim/features/shell/domain/app_route.dart';
import 'package:daily_muslim/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// One tappable part of a title (§15 D114), at least 24 dp tall (WCAG 2.2
/// target size).
final class TitleTap extends StatelessWidget {
  /// [child], running [onTap]; [hint] tells a screen reader what it does.
  const new({
    required this.hint,
    required this.onTap,
    required this.child,
    super.key,
  });

  /// What a tap does.
  final String hint;

  /// The action.
  final VoidCallback onTap;

  /// The label.
  final Widget child;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    onTapHint: hint,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 24),
        child: Align(alignment: AlignmentDirectional.centerStart, child: child),
      ),
    ),
  );
}

/// The verses of [page] in the ayahs sheet (§15 D114).
Future<void> showPageAyahs(
  BuildContext context,
  WidgetRef ref,
  int page,
) async {
  final l = AppLocalizations.of(context);
  final verses = await ref.read(versesOnPageProvider(page).future);
  if (!context.mounted || verses.isEmpty) return;
  await showAyahSheet(
    context,
    title: l.quranAyahsOnPage,
    places: verses,
    hint: true,
  );
}

/// What the reader's menu offers.
enum ReaderMenuItem {
  /// Search the Quran.
  search,

  /// Switch between fit width and the whole page.
  fit,

  /// The reading-mode sheet (Tajweed colours, and why they are off).
  tajweed,

  /// The verses on this page.
  ayahs,

  /// The surah and juz index.
  contents,

  /// Go to a page number.
  goTo,

  /// Go to a verse of the surah.
  goToAyah,

  /// The first verse of the surah.
  surahStart,

  /// Zoom in one step.
  zoomIn,

  /// Zoom out one step.
  zoomOut,

  /// Bookmarks and highlights.
  notes,

  /// Draw a highlight.
  highlight,

  /// Show or hide saved highlights.
  showHighlights,

  /// Two facing pages on wide, tall windows.
  facing,

  /// Taps no longer hide the controls.
  keepControls,

  /// The Quran download and its storage.
  storage,

  /// Leave the reader for Home.
  home,
}

/// The reader's menu (§15 D123): everything the toolbar has no room for,
/// so the toolbar stays compact on a narrow window and nothing is lost.
/// [inBar] are the items the toolbar already shows.
final class ReaderMenu extends ConsumerWidget {
  /// The menu driving [viewport], in [color].
  const new({
    required this.viewport,
    required this.color,
    required this.landscape,
    this.inBar = const {},
    super.key,
  });

  /// The page surface, for the zoom items.
  final MushafViewportController viewport;

  /// The icon colour.
  final Color color;

  /// Whether the window is landscape (the fit item is per orientation, and
  /// Home is offered where the tab bar is not shown).
  final bool landscape;

  /// Items already on the toolbar.
  final Set<ReaderMenuItem> inBar;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final state = ref.watch(readerProvider);
    final controller = ref.read(readerProvider.notifier);
    final prefs = state.preferences;
    final fit = prefs.fitFor(landscape: landscape);
    final scope = ref.watch(readerScopeProvider);
    PopupMenuEntry<ReaderMenuItem> item(
      ReaderMenuItem value,
      IconData icon,
      String label,
    ) => PopupMenuItem(
      value: value,
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(icon),
        title: Text(label),
      ),
    );
    PopupMenuEntry<ReaderMenuItem> check(
      ReaderMenuItem value,
      String label, {
      required bool checked,
    }) => CheckedPopupMenuItem(
      value: value,
      checked: checked,
      child: Text(label),
    );
    return PopupMenuButton<ReaderMenuItem>(
      tooltip: l.quranMore,
      iconColor: color,
      icon: const Icon(Icons.more_vert),
      onSelected: (selected) => switch (selected) {
        ReaderMenuItem.search => context.push(
          const QuranSearchRoute().location,
        ),
        ReaderMenuItem.fit => toggleFit(ref, landscape: landscape),
        ReaderMenuItem.tajweed => showReadingModeSheet(context),
        ReaderMenuItem.ayahs => showPageAyahs(context, ref, state.page),
        ReaderMenuItem.contents => showQuranIndexSheet(
          context,
          currentSura: scope?.sura.number,
        ),
        ReaderMenuItem.goTo => showGoToPageDialog(context, ref),
        ReaderMenuItem.goToAyah =>
          scope == null ? null : showGoToAyahDialog(context, ref, scope.sura),
        ReaderMenuItem.surahStart =>
          scope == null ? null : openSurah(ref, scope.sura),
        ReaderMenuItem.zoomIn => viewport.send(ViewportCommand.zoomIn),
        ReaderMenuItem.zoomOut => viewport.send(ViewportCommand.zoomOut),
        ReaderMenuItem.notes => context.push(const QuranNotesRoute().location),
        ReaderMenuItem.highlight => controller.startDraft(
          HighlightColor.yellow,
        ),
        ReaderMenuItem.showHighlights => controller.toggleHighlights(),
        ReaderMenuItem.facing => controller.setPreferences(
          prefs.copyWith(facingPages: !prefs.facingPages),
        ),
        ReaderMenuItem.keepControls => controller.setPreferences(
          prefs.copyWith(keepControls: !prefs.keepControls),
        ),
        ReaderMenuItem.storage => context.push(
          const QuranStorageRoute().location,
        ),
        ReaderMenuItem.home => context.go(const HomeRoute().location),
      },
      itemBuilder: (context) => [
        if (!inBar.contains(ReaderMenuItem.search))
          item(ReaderMenuItem.search, Icons.search, l.quranSearch),
        if (!inBar.contains(ReaderMenuItem.fit))
          item(
            ReaderMenuItem.fit,
            fit == PageFit.page ? Icons.width_full : Icons.fit_screen,
            fit == PageFit.page ? l.quranFitWidth : l.quranFitPage,
          ),
        if (!inBar.contains(ReaderMenuItem.tajweed))
          item(ReaderMenuItem.tajweed, Icons.palette_outlined, l.quranTajweed),
        item(
          ReaderMenuItem.ayahs,
          Icons.format_list_numbered_rtl,
          l.quranAyahsOnPage,
        ),
        item(ReaderMenuItem.contents, Icons.toc, l.quranIndex),
        item(ReaderMenuItem.goTo, Icons.tag, l.quranGoToPage),
        if (scope != null) ...[
          item(ReaderMenuItem.goToAyah, Icons.pin_outlined, l.quranGoToAyah),
          item(
            ReaderMenuItem.surahStart,
            Icons.vertical_align_top,
            l.quranSurahStart,
          ),
        ],
        item(ReaderMenuItem.zoomIn, Icons.zoom_in, l.quranZoomIn),
        item(ReaderMenuItem.zoomOut, Icons.zoom_out, l.quranZoomOut),
        const PopupMenuDivider(),
        item(ReaderMenuItem.notes, Icons.bookmarks_outlined, l.quranNotes),
        item(
          ReaderMenuItem.highlight,
          Icons.border_color_outlined,
          l.quranHighlight,
        ),
        check(
          ReaderMenuItem.showHighlights,
          l.quranShowHighlights,
          checked: state.showHighlights,
        ),
        check(
          ReaderMenuItem.facing,
          l.quranFacingPages,
          checked: prefs.facingPages,
        ),
        check(
          ReaderMenuItem.keepControls,
          l.quranKeepControls,
          checked: prefs.keepControls,
        ),
        const PopupMenuDivider(),
        item(
          ReaderMenuItem.storage,
          Icons.download_done_outlined,
          l.quranStorage,
        ),
        if (landscape)
          item(ReaderMenuItem.home, Icons.home_outlined, l.navHome),
      ],
    );
  }
}

/// Switches the fit of [landscape] windows between fit width and the whole
/// page, and saves it.
void toggleFit(WidgetRef ref, {required bool landscape}) {
  final prefs = ref.read(readerProvider).preferences;
  final fit = prefs.fitFor(landscape: landscape);
  ref
      .read(readerProvider.notifier)
      .setPreferences(
        prefs.withFit(
          landscape: landscape,
          value: fit == PageFit.page ? PageFit.width : PageFit.page,
        ),
      );
}

final class _Command extends StatelessWidget {
  const new(this.viewport, this.command, this.icon, this.label);

  final MushafViewportController viewport;
  final ViewportCommand command;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: label,
    iconSize: 28,
    constraints: const BoxConstraints(minWidth: 52, minHeight: 52),
    onPressed: () => viewport.send(command),
    icon: Icon(icon, semanticLabel: label),
  );
}

/// The bar while drawing a highlight: what an area highlight is, the
/// colour, undo, cancel and save, and the page buttons to continue on
/// another page. *Next page* is on the left, as in the Mushaf.
final class DrawBar extends ConsumerWidget {
  /// The bar driving [viewport].
  const new({required this.viewport, super.key});

  /// The page surface.
  final MushafViewportController viewport;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final style = DisplayStyle.of(context, ref);
    final draft = ref.watch(readerProvider.select((s) => s.draft));
    final controller = ref.read(readerProvider.notifier);
    if (draft == null) return const SizedBox.shrink();
    final count = draft.regions.length;
    final boxes = QuranFormat.number(count, style);
    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(22),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l.quranAreaExplain,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 6),
            HighlightColorRow(
              selected: draft.color,
              onSelected: controller.setDraftColor,
            ),
            Directionality(
              textDirection: TextDirection.ltr,
              child: Row(
                children: [
                  _Command(
                    viewport,
                    ViewportCommand.next,
                    Icons.arrow_back,
                    l.quranNextPage,
                  ),
                  const Spacer(),
                  IconButton(
                    tooltip: l.quranHighlightUndo,
                    onPressed: count == 0 ? null : controller.undoRegion,
                    icon: const Icon(Icons.undo),
                  ),
                  TextButton(
                    onPressed: controller.cancelDraft,
                    child: Text(l.quranHighlightCancel),
                  ),
                  Flexible(
                    child: FilledButton(
                      onPressed: count == 0 ? null : controller.saveDraft,
                      child: Text(
                        '${l.quranHighlightSave} · '
                        '${l.quranHighlightBoxes(count, boxes)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const Spacer(),
                  _Command(
                    viewport,
                    ViewportCommand.previous,
                    Icons.arrow_forward,
                    l.quranPreviousPage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
