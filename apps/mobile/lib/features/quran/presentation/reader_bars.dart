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
import 'package:daily_muslim/features/quran/presentation/surah_nav_bar.dart';
import 'package:daily_muslim/features/quran/presentation/surah_pages_sheet.dart';
import 'package:daily_muslim/features/schedule/presentation/schedule_providers.dart';
import 'package:daily_muslim/features/settings/domain/app_settings.dart';
import 'package:daily_muslim/features/settings/domain/setting_values.dart';
import 'package:daily_muslim/features/settings/presentation/settings_providers.dart';
import 'package:daily_muslim/features/shell/domain/app_route.dart';
import 'package:daily_muslim/l10n/app_localizations.dart';
import 'package:dm_ui/dm_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// The reader's header above the page, after the owner's reference
/// (§15 D121, D122), in Horizon's deep Madinah green whatever the mode: the
/// app's name, *The Noble Quran*, search, the menu and the light/dark
/// switch on the first row; the surah large (tap for the surah index at
/// it) with the edition, juz (tap for the juz index) and page (tap for the
/// surah's pages) under it, and the surah's Arabic name in the KFGQPC font
/// under an arch. It draws under the status bar.
final class ReaderTopBar extends ConsumerWidget {
  /// The header for [page]; [dense] keeps it to one row for short windows.
  const new({required this.page, this.dense = false, super.key});

  /// The current page.
  final int page;

  /// One row: the surah and its line, then the buttons.
  final bool dense;

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
    final font = ref.watch(quranFontProvider).value ?? false;
    // Ivory, sage and gold on green: Horizon's night tokens, which are
    // made for a green ground (REQ-UX-010).
    const on = RawdahScheme.night;
    final arabic = style.locale == StatusLocale.ar;
    final quranFont = font ? QuranFont.family : null;
    final caption = theme.textTheme.bodySmall?.copyWith(
      color: on.inkMuted,
      fontSize: 13,
    );
    final spaced = theme.textTheme.labelSmall?.copyWith(
      color: on.accent,
      fontSize: 11,
      letterSpacing: 2,
      fontWeight: FontWeight.w600,
    );
    final buttons = [
      _RoundButton(
        tooltip: l.quranSearch,
        icon: Icons.search,
        onPressed: () => context.push(const QuranSearchRoute().location),
      ),
      const SizedBox(width: 6),
      const _ReaderMenu(),
      const SizedBox(width: 6),
      const _AppearanceButton(),
    ];
    // The surah's line: edition, juz and page on one line; the edition
    // gives way first.
    final line = sura == null
        ? const SizedBox.shrink()
        : Row(
            children: [
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
                  onTap: () =>
                      showQuranIndexSheet(context, currentJuz: part.number),
                  child: Text(
                    l.quranJuz(QuranFormat.number(part.number, style)),
                    maxLines: 1,
                    style: caption,
                  ),
                ),
                Text(' · ', style: caption),
              ],
              _TitleTap(
                hint: l.quranGoToPage,
                onTap: () => showSurahPagesSheet(
                  context,
                  sura: sura,
                  page: page,
                  onGoToPage: () => showGoToPageDialog(context, ref),
                ),
                child: Text(
                  l.quranPage(QuranFormat.number(page, style)),
                  maxLines: 1,
                  style: caption,
                ),
              ),
            ],
          );
    final title = sura == null
        ? const SizedBox.shrink()
        : _TitleTap(
            hint: l.quranIndex,
            onTap: () => showQuranIndexSheet(context, currentSura: sura.number),
            child: Text(
              arabic ? sura.header : QuranFormat.surahName(sura, style),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleLarge?.copyWith(
                color: on.ink,
                fontSize: dense ? 19 : 24,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
    final green = RawdahScheme.of(context).navBar;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [green, Color.lerp(green, on.wash, 0.6) ?? green],
          ),
          border: Border(bottom: BorderSide(color: on.accent, width: 0.6)),
        ),
        child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(
            20,
            MediaQuery.paddingOf(context).top + 6,
            12,
            dense ? 8 : 12,
          ),
          child: dense
              ? Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [title, line],
                      ),
                    ),
                    ...buttons,
                  ],
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        // The app's name, smaller rather than cut when the
                        // row is narrow.
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: AlignmentDirectional.centerStart,
                            child: Text(
                              arabic ? l.appTitle : l.appTitle.toUpperCase(),
                              maxLines: 1,
                              style: spaced,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Column(
                            children: [
                              Text(
                                l.quranNobleQuran,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: spaced,
                              ),
                              Text(
                                'القرآن الكريم',
                                textDirection: TextDirection.rtl,
                                maxLines: 1,
                                style: TextStyle(
                                  fontFamily: quranFont,
                                  fontSize: 20,
                                  height: 1.3,
                                  color: on.ink,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ...buttons,
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (sura != null)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                title,
                                const SizedBox(height: 2),
                                line,
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          _Arch(
                            name: QuranFormat.arabicName(sura),
                            fontFamily: quranFont,
                            onTap: () => showQuranIndexSheet(
                              context,
                              currentSura: sura.number,
                            ),
                            hint: l.quranIndex,
                          ),
                        ],
                      ),
                  ],
                ),
        ),
      ),
    );
  }
}

/// The surah's Arabic name under a gold arch, as in the reference.
final class _Arch extends StatelessWidget {
  const new({
    required this.name,
    required this.fontFamily,
    required this.onTap,
    required this.hint,
  });

  final String name;
  final String? fontFamily;
  final VoidCallback onTap;
  final String hint;

  @override
  Widget build(BuildContext context) {
    const on = RawdahScheme.night;
    const shape = RoundedRectangleBorder(
      side: BorderSide(color: Color(0x99D2B373)),
      borderRadius: BorderRadius.only(
        topLeft: Radius.elliptical(60, 34),
        topRight: Radius.elliptical(60, 34),
        bottomLeft: Radius.circular(22),
        bottomRight: Radius.circular(22),
      ),
    );
    return Semantics(
      button: true,
      onTapHint: hint,
      child: Material(
        color: Colors.transparent,
        shape: shape,
        child: InkWell(
          customBorder: shape,
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 104, minHeight: 54),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
              child: Center(
                widthFactor: 1,
                child: Text(
                  name,
                  textDirection: TextDirection.rtl,
                  maxLines: 1,
                  style: TextStyle(
                    fontFamily: fontFamily,
                    fontSize: 21,
                    color: on.ink,
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

/// A round, outlined icon button on the green header.
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
    const on = RawdahScheme.night;
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      color: on.ink,
      style: IconButton.styleFrom(
        side: const BorderSide(color: Color(0x80D2B373)),
        minimumSize: const Size(40, 40),
        fixedSize: const Size(40, 40),
      ),
      icon: Icon(icon, size: 19),
    );
  }
}

/// The moon of the reference: switches the app between its light and dark
/// appearance (the *Appearance* setting).
final class _AppearanceButton extends ConsumerWidget {
  const new();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final dark = Theme.of(context).brightness == Brightness.dark;
    return _RoundButton(
      tooltip: dark ? l.quranToLight : l.quranToDark,
      icon: dark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
      onPressed: () => ref
          .read(writeSettingProvider)
          .write(
            AppSettings.themeMode,
            dark ? ThemeModeSetting.light : ThemeModeSetting.dark,
          ),
    );
  }
}

/// The line between the header and the page: the reading mode (calm, the
/// Mushaf as printed) with *Tajweed colours* one tap away, and the
/// bookmark of the page (§15 D122).
final class ReadingStrip extends ConsumerWidget {
  /// The strip for [page].
  const new({required this.page, super.key});

  /// The current page.
  final int page;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = RawdahScheme.of(context);
    final marked =
        ref.watch(bookmarksProvider).value?.any((b) => b.page == page) ?? false;
    final text = theme.textTheme.bodyMedium?.copyWith(
      color: scheme.primary,
      fontSize: 14,
    );
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(20, 4, 12, 0),
      child: Row(
        children: [
          for (var i = 0; i < 3; i++)
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 3),
              child: SizedBox(
                width: 4,
                height: 14,
                child: ColoredBox(color: scheme.primary),
              ),
            ),
          const SizedBox(width: 8),
          Expanded(
            child: InkWell(
              onTap: () => showReadingModeSheet(context),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 40),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  widthFactor: 1,
                  child: Text(
                    '${l.quranCalmShort} · ${l.quranTajweed}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: text,
                  ),
                ),
              ),
            ),
          ),
          IconButton(
            tooltip: marked ? l.quranBookmarkRemove : l.quranBookmarkAdd,
            isSelected: marked,
            style: IconButton.styleFrom(
              backgroundColor: scheme.wash,
              fixedSize: const Size(40, 40),
              minimumSize: const Size(40, 40),
            ),
            color: scheme.accent,
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
        ],
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
  surahStart,
  goToAyah,
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
  const new();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final state = ref.watch(readerProvider);
    final scope = ref.watch(readerScopeProvider);
    final controller = ref.read(readerProvider.notifier);
    final prefs = state.preferences;
    const on = RawdahScheme.night;
    return PopupMenuButton<_MenuItem>(
      tooltip: l.quranMore,
      iconColor: on.ink,
      style: IconButton.styleFrom(
        side: const BorderSide(color: Color(0x80D2B373)),
        minimumSize: const Size(40, 40),
        fixedSize: const Size(40, 40),
      ),
      icon: const Icon(Icons.more_vert, size: 19),
      onSelected: (item) => switch (item) {
        _MenuItem.surahStart =>
          scope == null ? null : openSurah(ref, scope.sura),
        _MenuItem.goToAyah =>
          scope == null ? null : showGoToAyahDialog(context, ref, scope.sura),
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
        if (scope != null) ...[
          PopupMenuItem(
            value: _MenuItem.surahStart,
            child: Text(l.quranSurahStart),
          ),
          PopupMenuItem(
            value: _MenuItem.goToAyah,
            child: Text(l.quranGoToAyah),
          ),
        ],
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
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 6),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Row(
          children: [
            Expanded(
              child: Tooltip(
                message: next,
                excludeFromSemantics: true,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(0, 48),
                    shape: _buttonShape,
                    textStyle: _buttonText(context),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  onPressed:
                      onContinue ?? () => viewport.send(ViewportCommand.next),
                  icon: const Icon(Icons.chevron_left),
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
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 48),
                    shape: _buttonShape,
                    textStyle: _buttonText(context),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  onPressed: () => viewport.send(ViewportCommand.previous),
                  iconAlignment: IconAlignment.end,
                  icon: const Icon(Icons.chevron_right),
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

/// The reference's rounded rectangle for the reader's buttons.
const _buttonShape = RoundedRectangleBorder(
  borderRadius: BorderRadius.all(Radius.circular(14)),
);

/// The reference's button text: medium, one line on a phone.
TextStyle? _buttonText(BuildContext context) => Theme.of(
  context,
).textTheme.titleSmall?.copyWith(fontSize: 15, fontWeight: FontWeight.w600);

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
