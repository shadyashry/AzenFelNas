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
import 'package:daily_muslim/features/quran/presentation/reading_mode_sheet.dart';
import 'package:daily_muslim/features/quran/presentation/surah_pages_sheet.dart';
import 'package:daily_muslim/features/schedule/presentation/schedule_providers.dart';
import 'package:daily_muslim/features/shell/domain/app_route.dart';
import 'package:daily_muslim/l10n/app_localizations.dart';
import 'package:dm_ui/dm_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// The reader's header above the page, in the deep Madinah green of
/// Horizon whatever the mode (§15 D121): the surah (tap for the surah index
/// at it), the edition, the juz (tap for the juz index at it) and the page
/// number (tap for the pages of the surah), then the bookmark, search and
/// the menu. It draws under the status bar and keeps to two short lines.
final class ReaderTopBar extends ConsumerWidget {
  /// The header for [page].
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
    // The surah the reader chose, while this page is one of its pages
    // (§15 D120); otherwise the last surah whose header is at or before it.
    final sura =
        ref.watch(readerScopeProvider)?.sura ??
        suras.lastWhereOrNull((s) => s.startPage <= page);
    final part = juz.lastWhereOrNull((j) => j.page <= page);
    final marked =
        ref.watch(bookmarksProvider).value?.any((b) => b.page == page) ?? false;
    final font = ref.watch(quranFontProvider).value ?? false;
    // Ivory, sage and gold on green: Horizon's night tokens, which are
    // made for a green ground (REQ-UX-010).
    const on = RawdahScheme.night;
    final arabic = style.locale == StatusLocale.ar;
    final quranFont = font ? QuranFont.family : null;
    final caption = theme.textTheme.bodySmall?.copyWith(color: on.inkMuted);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Material(
        color: RawdahScheme.of(context).navBar,
        child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(
            16,
            MediaQuery.paddingOf(context).top + 4,
            4,
            6,
          ),
          child: Row(
            children: [
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) => Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (sura != null)
                        _TitleTap(
                          hint: l.quranIndex,
                          onTap: () => showQuranIndexSheet(
                            context,
                            currentSura: sura.number,
                          ),
                          child: arabic
                              ? Text(
                                  sura.header,
                                  textDirection: TextDirection.rtl,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: quranFont,
                                    fontSize: 21,
                                    color: on.ink,
                                  ),
                                )
                              : Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        QuranFormat.surahName(sura, style),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                              color: on.ink,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      sura.header,
                                      textDirection: TextDirection.rtl,
                                      maxLines: 1,
                                      style: TextStyle(
                                        fontFamily: quranFont,
                                        fontSize: 16,
                                        color: on.accent,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      Row(
                        children: [
                          if (constraints.maxWidth >= 240)
                            Flexible(
                              child: Text(
                                '${l.quranEditionShort} · ',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: caption,
                              ),
                            ),
                          if (part != null) ...[
                            _TitleTap(
                              hint: l.quranIndex,
                              onTap: () => showQuranIndexSheet(
                                context,
                                currentJuz: part.number,
                              ),
                              child: Text(
                                l.quranJuz(
                                  QuranFormat.number(part.number, style),
                                ),
                                style: caption,
                              ),
                            ),
                            Text(' · ', style: caption),
                          ],
                          _TitleTap(
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
                              style: caption,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              IconButton(
                tooltip: marked ? l.quranBookmarkRemove : l.quranBookmarkAdd,
                isSelected: marked,
                color: on.ink,
                icon: const Icon(Icons.bookmark_border),
                selectedIcon: Icon(Icons.bookmark, color: on.accent),
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
                color: on.ink,
                icon: const Icon(Icons.search),
                onPressed: () =>
                    context.push(const QuranSearchRoute().location),
              ),
              _ReaderMenu(color: on.ink),
            ],
          ),
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
  tajweed,
  storage,
}

final class _ReaderMenu extends ConsumerWidget {
  const new({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final state = ref.watch(readerProvider);
    final controller = ref.read(readerProvider.notifier);
    final prefs = state.preferences;
    return PopupMenuButton<_MenuItem>(
      tooltip: l.quranMore,
      iconColor: color,
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
        _MenuItem.tajweed => showReadingModeSheet(context),
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
        PopupMenuItem(value: _MenuItem.tajweed, child: Text(l.quranTajweed)),
        PopupMenuItem(value: _MenuItem.storage, child: Text(l.quranStorage)),
      ],
    );
  }
}

/// The page buttons below the page, labelled in words (§15 D121). Their
/// order is the Mushaf's, not the interface's: *Next page* is always on
/// the left and points left, *Previous page* on the right, in Arabic and in
/// English (REQ-QRN-020). On the chosen surah's last page *Next page*
/// becomes [continueLabel], which runs [onContinue].
final class ReaderBottomBar extends StatelessWidget {
  /// The buttons driving [viewport].
  const new({
    required this.viewport,
    this.continueLabel,
    this.continueShort,
    this.onContinue,
    this.dense = false,
    super.key,
  });

  /// The page surface.
  final MushafViewportController viewport;

  /// Short labels on one line, for short windows; the full wording stays
  /// in the tooltip and for screen readers.
  final bool dense;

  /// *Continue to* the next surah, in place of *Next page*.
  final String? continueLabel;

  /// The next surah's name, for [dense].
  final String? continueShort;

  /// Opens the next surah.
  final VoidCallback? onContinue;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final next = continueLabel ?? l.quranNextPage;
    final nextShort = continueLabel == null
        ? l.quranNextShort
        : continueShort ?? next;
    // The row is laid out left to right like the Mushaf, but each label
    // reads in the interface's own direction and may take two lines
    // rather than lose its end.
    final reading = Directionality.of(context);
    Widget label(String text, String short) => Semantics(
      label: text,
      excludeSemantics: true,
      child: Text(
        dense ? short : text,
        textDirection: reading,
        textAlign: TextAlign.center,
        maxLines: dense ? 1 : 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Row(
          children: [
            Expanded(
              child: Tooltip(
                message: next,
                excludeFromSemantics: true,
                child: FilledButton.icon(
                  onPressed:
                      onContinue ?? () => viewport.send(ViewportCommand.next),
                  icon: const Icon(Icons.arrow_back),
                  label: label(next, nextShort),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Tooltip(
                message: l.quranPreviousPage,
                excludeFromSemantics: true,
                child: OutlinedButton.icon(
                  onPressed: () => viewport.send(ViewportCommand.previous),
                  iconAlignment: IconAlignment.end,
                  icon: const Icon(Icons.arrow_forward),
                  label: label(l.quranPreviousPage, l.quranPreviousShort),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
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
