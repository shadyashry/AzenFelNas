import 'package:daily_muslim/features/home/presentation/display_style.dart';
import 'package:daily_muslim/features/quran/domain/highlight_color.dart';
import 'package:daily_muslim/features/quran/domain/mushaf_index_entries.dart';
import 'package:daily_muslim/features/quran/domain/quran_edition_pin.dart';
import 'package:daily_muslim/features/quran/domain/reader_preferences.dart';
import 'package:daily_muslim/features/quran/presentation/ayah_sheet.dart';
import 'package:daily_muslim/features/quran/presentation/go_to_page_dialog.dart';
import 'package:daily_muslim/features/quran/presentation/highlight_sheet.dart';
import 'package:daily_muslim/features/quran/presentation/mushaf_viewport_controller.dart';
import 'package:daily_muslim/features/quran/presentation/quran_format.dart';
import 'package:daily_muslim/features/quran/presentation/quran_index_sheet.dart';
import 'package:daily_muslim/features/quran/presentation/quran_providers.dart';
import 'package:daily_muslim/features/quran/presentation/reader_controller.dart';
import 'package:daily_muslim/features/quran/presentation/surah_pages_sheet.dart';
import 'package:daily_muslim/features/schedule/presentation/schedule_providers.dart';
import 'package:daily_muslim/features/shell/domain/app_route.dart';
import 'package:daily_muslim/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// The bar above the page: the surah of the page (tap for the surah index
/// at it), the juz (tap for the juz index at it) and the page number (tap
/// for the pages of the surah), the bookmark, search and the menu.
final class ReaderTopBar extends ConsumerWidget {
  /// The bar for [page].
  const new({required this.page, super.key});

  /// The current page.
  final int page;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final style = DisplayStyle.of(context, ref);
    final theme = Theme.of(context);
    final suras = ref.watch(surasProvider).value ?? const <SuraEntry>[];
    final juz = ref.watch(juzProvider).value ?? const <JuzEntry>[];
    final sura = suras.lastWhereOrNull((s) => s.startPage <= page);
    final part = juz.lastWhereOrNull((j) => j.page <= page);
    final marked =
        ref.watch(bookmarksProvider).value?.any((b) => b.page == page) ?? false;
    final font = ref.watch(quranFontProvider).value ?? false;
    return Material(
      color: theme.colorScheme.surface,
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(12, 4, 4, 4),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (sura != null)
                    _TitleTap(
                      hint: l.quranIndex,
                      onTap: () => showQuranIndexSheet(
                        context,
                        currentSura: sura.number,
                      ),
                      child: Text(
                        sura.header,
                        textDirection: TextDirection.rtl,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: font ? QuranFont.family : null,
                          fontSize: 20,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  Row(
                    children: [
                      if (part != null) ...[
                        _TitleTap(
                          hint: l.quranIndex,
                          onTap: () => showQuranIndexSheet(
                            context,
                            currentJuz: part.number,
                          ),
                          child: Text(
                            l.quranJuz(QuranFormat.number(part.number, style)),
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                        Text(' · ', style: theme.textTheme.bodySmall),
                      ],
                      Flexible(
                        child: _TitleTap(
                          hint: l.quranGoToPage,
                          onTap: () => sura == null
                              ? showGoToPageDialog(context, ref)
                              : showSurahPagesSheet(
                                  context,
                                  sura: sura,
                                  page: page,
                                  onGoToPage: () =>
                                      showGoToPageDialog(context, ref),
                                ),
                          child: Text(
                            l.quranPage(QuranFormat.number(page, style)),
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: marked ? l.quranBookmarkRemove : l.quranBookmarkAdd,
              isSelected: marked,
              icon: const Icon(Icons.bookmark_border),
              selectedIcon: const Icon(Icons.bookmark),
              onPressed: () => ref
                  .read(bookmarkStoreProvider)
                  .toggleBookmark(
                    QuranEditionPin.layoutId,
                    page,
                    nowUtcMs: ref.read(clockProvider).nowUtcMs(),
                  ),
            ),
            IconButton(
              tooltip: l.quranSearch,
              icon: const Icon(Icons.search),
              onPressed: () => context.push(const QuranSearchRoute().location),
            ),
            const _ReaderMenu(),
          ],
        ),
      ),
    );
  }
}

/// One tappable part of the title (§15 D114), at least 24 dp tall (WCAG
/// 2.2 target size).
final class _TitleTap extends StatelessWidget {
  const new({required this.hint, required this.onTap, required this.child});

  final String hint;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    onTapHint: hint,
    child: InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 24),
        child: Align(alignment: AlignmentDirectional.centerStart, child: child),
      ),
    ),
  );
}

/// The verses of [page] in the ayahs sheet (§15 D114).
Future<void> _showPageAyahs(
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

enum _MenuItem {
  ayahs,
  contents,
  goTo,
  notes,
  highlight,
  fit,
  facing,
  showHighlights,
  storage,
}

final class _ReaderMenu extends ConsumerWidget {
  const new();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final state = ref.watch(readerProvider);
    final controller = ref.read(readerProvider.notifier);
    final prefs = state.preferences;
    return PopupMenuButton<_MenuItem>(
      tooltip: l.quranMore,
      icon: const Icon(Icons.more_vert),
      onSelected: (item) => switch (item) {
        _MenuItem.ayahs => _showPageAyahs(context, ref, state.page),
        _MenuItem.contents => showQuranIndexSheet(context),
        _MenuItem.goTo => showGoToPageDialog(context, ref),
        _MenuItem.notes => context.push(const QuranNotesRoute().location),
        _MenuItem.highlight => controller.startDraft(HighlightColor.yellow),
        _MenuItem.fit => controller.setPreferences(
          prefs.copyWith(
            fit: prefs.fit == PageFit.page ? PageFit.width : PageFit.page,
          ),
        ),
        _MenuItem.facing => controller.setPreferences(
          prefs.copyWith(facingPages: !prefs.facingPages),
        ),
        _MenuItem.showHighlights => controller.toggleHighlights(),
        _MenuItem.storage => context.push(const QuranStorageRoute().location),
      },
      itemBuilder: (context) => [
        PopupMenuItem(value: _MenuItem.ayahs, child: Text(l.quranAyahsOnPage)),
        PopupMenuItem(value: _MenuItem.contents, child: Text(l.quranIndex)),
        PopupMenuItem(value: _MenuItem.goTo, child: Text(l.quranGoToPage)),
        PopupMenuItem(value: _MenuItem.notes, child: Text(l.quranNotes)),
        PopupMenuItem(
          value: _MenuItem.highlight,
          child: Text(l.quranHighlight),
        ),
        PopupMenuItem(
          value: _MenuItem.fit,
          child: Text(
            prefs.fit == PageFit.page ? l.quranFitWidth : l.quranFitPage,
          ),
        ),
        CheckedPopupMenuItem(
          value: _MenuItem.facing,
          checked: prefs.facingPages,
          child: Text(l.quranFacingPages),
        ),
        CheckedPopupMenuItem(
          value: _MenuItem.showHighlights,
          checked: state.showHighlights,
          child: Text(l.quranShowHighlights),
        ),
        PopupMenuItem(value: _MenuItem.storage, child: Text(l.quranStorage)),
      ],
    );
  }
}

/// The bar below the page. Its order is the Mushaf's, not the interface's:
/// *Next page* is always on the left and points left, *Previous page* on the
/// right, in Arabic and in English (REQ-QRN-020).
final class ReaderBottomBar extends StatelessWidget {
  /// The bar driving [viewport].
  const new({required this.viewport, super.key});

  /// The page surface.
  final MushafViewportController viewport;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: ListenableBuilder(
        listenable: viewport,
        builder: (context, _) => Directionality(
          textDirection: TextDirection.ltr,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _Command(
                viewport,
                ViewportCommand.next,
                Icons.arrow_back,
                l.quranNextPage,
              ),
              _Command(
                viewport,
                ViewportCommand.zoomOut,
                Icons.zoom_out,
                l.quranZoomOut,
                enabled: viewport.scale > 1,
              ),
              _Command(
                viewport,
                ViewportCommand.reset,
                Icons.fit_screen,
                l.quranResetZoom,
                enabled: viewport.scale > 1,
              ),
              _Command(
                viewport,
                ViewportCommand.zoomIn,
                Icons.zoom_in,
                l.quranZoomIn,
                enabled: viewport.scale < 4,
              ),
              _Command(
                viewport,
                ViewportCommand.previous,
                Icons.arrow_forward,
                l.quranPreviousPage,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

final class _Command extends StatelessWidget {
  const new(
    this.viewport,
    this.command,
    this.icon,
    this.label, {
    this.enabled = true,
  });

  final MushafViewportController viewport;
  final ViewportCommand command;
  final IconData icon;
  final String label;
  final bool enabled;

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: label,
    iconSize: 28,
    constraints: const BoxConstraints(minWidth: 52, minHeight: 52),
    onPressed: enabled ? () => viewport.send(command) : null,
    icon: Icon(icon, semanticLabel: label),
  );
}

/// The bar while drawing a highlight: what an area highlight is, the
/// colour, undo, cancel and save, and the page buttons to continue on
/// another page.
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
                  FilledButton(
                    onPressed: count == 0 ? null : controller.saveDraft,
                    child: Text(
                      '${l.quranHighlightSave} · '
                      '${l.quranHighlightBoxes(count, boxes)}',
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

extension<T> on List<T> {
  T? lastWhereOrNull(bool Function(T) test) {
    for (var i = length - 1; i >= 0; i--) {
      if (test(this[i])) return this[i];
    }
    return null;
  }
}
