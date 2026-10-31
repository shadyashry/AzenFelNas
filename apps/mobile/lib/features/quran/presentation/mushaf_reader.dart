import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:daily_muslim/features/quran/domain/ayah_highlight.dart';
import 'package:daily_muslim/features/quran/domain/highlight.dart';
import 'package:daily_muslim/features/quran/domain/highlight_color.dart';
import 'package:daily_muslim/features/quran/domain/installed_quran.dart';
import 'package:daily_muslim/features/quran/domain/mushaf_layout.dart';
import 'package:daily_muslim/features/quran/domain/mushaf_lines.dart';
import 'package:daily_muslim/features/quran/domain/page_box.dart';
import 'package:daily_muslim/features/quran/domain/quran_edition_pin.dart';
import 'package:daily_muslim/features/quran/domain/verse_place.dart';
import 'package:daily_muslim/features/quran/presentation/ayah_sheet.dart';
import 'package:daily_muslim/features/quran/presentation/highlight_sheet.dart';
import 'package:daily_muslim/features/quran/presentation/mushaf_page_image.dart';
import 'package:daily_muslim/features/quran/presentation/mushaf_viewport.dart';
import 'package:daily_muslim/features/quran/presentation/mushaf_viewport_controller.dart';
import 'package:daily_muslim/features/quran/presentation/quran_providers.dart';
import 'package:daily_muslim/features/quran/presentation/reader_bars.dart';
import 'package:daily_muslim/features/quran/presentation/reader_controller.dart';
import 'package:daily_muslim/features/quran/presentation/reader_overlay.dart';
import 'package:daily_muslim/l10n/app_localizations.dart';
import 'package:dm_ui/dm_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Where the reading surface sits in a window, and where the controls
/// float over it (§15 D123). Pure layout, so it is tested without a
/// device.
///
/// The surface never changes when the controls appear or hide: its insets
/// depend only on the window. A landscape window gives the page everything
/// inside the system insets (status bar, cutouts, navigation) but a thin
/// lower reading margin, where the *…* handle sits without covering a word;
/// the controls float over the page while they are shown. A portrait window
/// keeps the toolbar's and the navigator's room above and below the page,
/// so a whole page is never covered; there the controls (and the handle)
/// appear over that room only.
@immutable
final class ReaderLayout {
  /// The layout of a window of [size] with system [insets].
  const new({required this.size, required this.insets});

  /// The window.
  final Size size;

  /// The system insets.
  final EdgeInsets insets;

  /// Whether the window is wider than tall.
  bool get landscape => size.width > size.height;

  /// The lower reading margin that holds the *…* handle in landscape.
  static const double handleRoom = 28;

  /// The reading surface's insets.
  EdgeInsets get surface => landscape
      ? insets.copyWith(bottom: insets.bottom + handleRoom)
      : EdgeInsets.fromLTRB(
          insets.left,
          insets.top + ReaderToolbar.height,
          insets.right,
          insets.bottom + panelHeight + ReaderNavPanel.margin * 2,
        );

  /// The navigator's height in this window (one row or two).
  double get panelHeight => ReaderNavPanel.heightAt(
    math.min(
      maxPanelWidth,
      size.width - insets.horizontal - ReaderNavPanel.margin * 2,
    ),
  );

  /// The widest the navigator gets.
  static const double maxPanelWidth = 960;
}

/// The Mushaf reader (§15 D107, D123): the frameless page on the reading
/// surface; the toolbar and the page navigator float over it after a short
/// tap and hide after another, without moving or resizing the page.
final class MushafReader extends ConsumerStatefulWidget {
  /// The reader of [installed].
  const new({required this.installed, super.key});

  /// The active package.
  final InstalledQuran installed;

  @override
  ConsumerState<MushafReader> createState() => _MushafReaderState();
}

final class _MushafReaderState extends ConsumerState<MushafReader> {
  final _viewport = MushafViewportController();
  bool? _landscape;

  @override
  void dispose() {
    _viewport.dispose();
    super.dispose();
  }

  /// Opens a landscape window on the page alone and a portrait one with
  /// the controls, once per orientation (§15 D123).
  void _follow(bool landscape) {
    if (_landscape == landscape) return;
    _landscape = landscape;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(readerProvider.notifier).followOrientation(landscape: landscape);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final state = ref.watch(readerProvider);
    final palette = MushafPalette.of(context);
    if (!state.restored) {
      return ColoredBox(
        color: palette.surface,
        child: Center(child: Text(l.quranOpening)),
      );
    }
    // A screen reader keeps the controls: nothing then depends on a tap
    // that is hard to find.
    final chrome =
        state.chromeVisible || MediaQuery.accessibleNavigationOf(context);
    final night = Theme.of(context).brightness == Brightness.dark;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: chrome || night
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      child: ColoredBox(
        color: palette.surface,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final layout = ReaderLayout(
              size: constraints.biggest,
              insets: MediaQuery.paddingOf(context),
            );
            _follow(layout.landscape);
            final insets = layout.insets;
            final drawing = state.draft != null;
            final duration = MediaQuery.disableAnimationsOf(context)
                ? Duration.zero
                : const Duration(milliseconds: 180);
            Widget reveal(Widget child) => IgnorePointer(
              ignoring: !chrome,
              child: ExcludeSemantics(
                excluding: !chrome,
                child: AnimatedOpacity(
                  opacity: chrome ? 1 : 0,
                  duration: duration,
                  child: child,
                ),
              ),
            );
            return Stack(
              children: [
                Positioned.fill(
                  child: Padding(
                    padding: layout.surface,
                    child: _Surface(
                      installed: widget.installed,
                      viewport: _viewport,
                      landscape: layout.landscape,
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  top: 0,
                  right: 0,
                  child: reveal(
                    ReaderToolbar(
                      page: state.page,
                      viewport: _viewport,
                      landscape: layout.landscape,
                    ),
                  ),
                ),
                Positioned(
                  left: insets.left + ReaderNavPanel.margin,
                  right: insets.right + ReaderNavPanel.margin,
                  bottom: insets.bottom + ReaderNavPanel.margin,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: ReaderLayout.maxPanelWidth,
                      ),
                      child: drawing
                          ? DrawBar(viewport: _viewport)
                          : reveal(
                              ReaderNavPanel(
                                page: state.page,
                                viewport: _viewport,
                              ),
                            ),
                    ),
                  ),
                ),
                if (!chrome && !drawing)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: insets.bottom,
                    child: Center(
                      child: ReaderHandle(
                        onPressed: ref.read(readerProvider.notifier).showChrome,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// The pages, one or two at a time, each cut to its own content and drawn
/// in the theme's ink.
final class _Surface extends ConsumerWidget {
  const new({
    required this.installed,
    required this.viewport,
    required this.landscape,
  });

  final InstalledQuran installed;
  final MushafViewportController viewport;
  final bool landscape;

  /// Two facing pages need a landscape window tall enough to read them.
  static bool spreadsFit(Size size) =>
      size.width > size.height * 1.15 && size.height >= 480;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final boxesAsync = ref.watch(pageBoxesProvider);
    if (boxesAsync.isLoading && !boxesAsync.hasValue) {
      return const SizedBox.expand();
    }
    final boxes = boxesAsync.value;
    final state = ref.watch(readerProvider);
    final controller = ref.read(readerProvider.notifier);
    final palette = MushafPalette.of(context);
    const layout = QuranEditionPin.layout;
    final whole = installed.manifest.pageImage;
    PageBox boxOf(int page) =>
        boxes?.of(page) ??
        PageBox.whole(pixelWidth: whole.width, pixelHeight: whole.height);
    final view = _PageView(boxOf);
    final ayahRegions = state.showHighlights
        ? ref.watch(ayahRegionsProvider).value ??
              const <int, List<(HighlightRegion, HighlightColor)>>{}
        : const <int, List<(HighlightRegion, HighlightColor)>>{};
    final regions = _regionsByPage(
      state.showHighlights
          ? ref.watch(highlightsProvider).value ?? const <Highlight>[]
          : const <Highlight>[],
      state.draft,
      ayahRegions,
    );
    final marks = _marksByPage(state.mark);
    return LayoutBuilder(
      builder: (context, constraints) {
        final spreads =
            state.preferences.facingPages && spreadsFit(constraints.biggest);
        Widget page(int number, Size size) => MushafPageImage(
          key: ValueKey(number),
          page: number,
          path: installed.pagePath(number),
          size: size,
          box: boxOf(number),
          ink: boxes == null ? null : palette.ink,
          night: Theme.of(context).brightness == Brightness.dark,
          regions: regions[number] ?? const [],
          marks: marks[number] ?? const [],
          errorLabel: l.quranPageError,
        );
        _precache(context, layout.pageCount, state.page, constraints, boxOf);
        return MushafViewport(
          itemCount: spreads ? layout.spreadCount : layout.pageCount,
          item: spreads ? layout.spreadOf(state.page) : state.page - 1,
          aspectOf: (item) =>
              spreads ? view.spreadAspect(item) : boxOf(item + 1).aspect,
          fit: state.preferences.fitFor(landscape: landscape),
          controller: viewport,
          drawing: state.draft != null,
          semanticLabel: l.quranReaderLabel(state.page.toString()),
          semanticHint: l.quranControlsHint,
          reveal: _reveal(state.mark, spreads, layout, boxOf),
          onItemChanged: (item) => controller.goTo(
            spreads ? layout.pagesOf(item).right : item + 1,
          ),
          itemBuilder: (context, item, size) {
            if (!spreads) return page(item + 1, size);
            final pages = layout.pagesOf(item);
            final right = view.rightShare(item) * size.width;
            final left = pages.left;
            return Row(
              // The right page first, as in the printed Mushaf.
              textDirection: TextDirection.rtl,
              children: [
                SizedBox(
                  width: right,
                  height: size.height,
                  child: page(pages.right, Size(right, size.height)),
                ),
                SizedBox(
                  width: size.width - right,
                  height: size.height,
                  child: left == null
                      ? null
                      : page(left, Size(size.width - right, size.height)),
                ),
              ],
            );
          },
          onDraw: (item, a, b) {
            final hit = view.region(item, a, b, spreads: spreads);
            if (hit != null) controller.addRegion(hit);
          },
          onTap: (item, point) async {
            final (page, p) = view.pageAt(item, point, spreads: spreads);
            final reading = state.draft == null && state.showHighlights;
            final tapped = reading
                ? _highlightAt(ref.read(highlightsProvider).value, page, p)
                : null;
            if (tapped != null) {
              unawaited(showHighlightSheet(context, tapped));
              return;
            }
            // A tap on a highlighted verse opens it (§15 D114).
            final verses = reading && _onAyahHighlight(ayahRegions, page, p)
                ? await _versesAt(ref, page, p, highlightedOnly: true)
                : const <VersePlace>[];
            if (verses.isNotEmpty && context.mounted) {
              unawaited(
                showAyahSheet(
                  context,
                  title: l.quranAyahsOnLine,
                  places: verses,
                ),
              );
            } else if (state.draft == null) {
              controller.toggleChrome();
            }
          },
          onLongPress: (item, point) async {
            final (page, p) = view.pageAt(item, point, spreads: spreads);
            final verses = await _versesAt(ref, page, p);
            if (verses.isEmpty || !context.mounted) return;
            unawaited(HapticFeedback.selectionClick());
            unawaited(
              showAyahSheet(
                context,
                title: l.quranAyahsOnLine,
                places: verses,
              ),
            );
          },
        );
      },
    );
  }

  static Highlight? _highlightAt(List<Highlight>? all, int page, Offset p) {
    for (final h in all ?? const <Highlight>[]) {
      for (final r in h.regions) {
        if (r.page == page &&
            p.dx >= r.left &&
            p.dx <= r.right &&
            p.dy >= r.top &&
            p.dy <= r.bottom) {
          return h;
        }
      }
    }
    return null;
  }

  /// The verses on the line under [p] of [page]; with [highlightedOnly]
  /// only those with a verse highlight. Empty off the lines (the margins,
  /// the page title) and on a surah title line.
  static Future<List<VersePlace>> _versesAt(
    WidgetRef ref,
    int page,
    Offset p, {
    bool highlightedOnly = false,
  }) async {
    if (QuranEditionPin.layoutId != MushafLines.layoutId) return const [];
    final line = MushafLines.lineAt(page, p.dx, p.dy);
    if (line == null) return const [];
    final verses = await ref.read(versesOnPageProvider(page).future);
    final marked = highlightedOnly
        ? {
            for (final h
                in ref.read(ayahHighlightsProvider).value ??
                    const <AyahHighlight>[])
              (h.sura, h.aya),
          }
        : null;
    return [
      for (final v in verses)
        if (v.covers(page, line) &&
            (marked == null || marked.contains((v.sura, v.aya))))
          v,
    ];
  }

  static bool _onAyahHighlight(
    Map<int, List<(HighlightRegion, HighlightColor)>> ayahRegions,
    int page,
    Offset p,
  ) => (ayahRegions[page] ?? const []).any(
    (r) =>
        p.dx >= r.$1.left &&
        p.dx <= r.$1.right &&
        p.dy >= r.$1.top &&
        p.dy <= r.$1.bottom,
  );

  /// Where the opened verse's first line is, as a height on its item, to
  /// bring it into view (§15 D120); `null` without a mark or line
  /// geometry.
  static ({int item, double y})? _reveal(
    VersePlace? mark,
    bool spreads,
    MushafLayout layout,
    PageBox Function(int page) boxOf,
  ) {
    if (mark == null || QuranEditionPin.layoutId != MushafLines.layoutId) {
      return null;
    }
    final band = MushafLines.band(mark.page, mark.lineStart);
    if (band == null) return null;
    return (
      item: spreads ? layout.spreadOf(mark.page) : mark.page - 1,
      y: boxOf(mark.page).fromPage(band.left, band.top).y.clamp(0.0, 1.0),
    );
  }

  static Map<int, List<HighlightRegion>> _marksByPage(VersePlace? mark) {
    final map = <int, List<HighlightRegion>>{};
    if (mark == null || QuranEditionPin.layoutId != MushafLines.layoutId) {
      return map;
    }
    for (final (:page, :line) in mark.lines(MushafLines.linesOn)) {
      final band = MushafLines.band(page, line);
      if (band != null) (map[page] ??= []).add(band);
    }
    return map;
  }

  static Map<int, List<(HighlightRegion, HighlightColor)>> _regionsByPage(
    List<Highlight> saved,
    HighlightDraft? draft,
    Map<int, List<(HighlightRegion, HighlightColor)>> ayahs,
  ) {
    final map = <int, List<(HighlightRegion, HighlightColor)>>{
      for (final MapEntry(:key, :value) in ayahs.entries) key: [...value],
    };
    for (final h in saved) {
      for (final r in h.regions) {
        (map[r.page] ??= []).add((r, h.color));
      }
    }
    if (draft != null) {
      for (final r in draft.regions) {
        (map[r.page] ??= []).add((r, draft.color));
      }
    }
    return map;
  }

  /// Decodes the neighbouring pages ahead of a turn, at the fit size only;
  /// the image cache is bounded, so only a few pages are ever held.
  void _precache(
    BuildContext context,
    int pageCount,
    int page,
    BoxConstraints constraints,
    PageBox Function(int page) boxOf,
  ) {
    final ratio = MediaQuery.devicePixelRatioOf(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      for (final n in [page + 1, page - 1, page + 2]) {
        if (n < 1 || n > pageCount) continue;
        final width = MushafPageImage.decodeWidth(
          constraints.maxWidth,
          ratio,
          boxOf(n).pixelWidth,
        );
        unawaited(
          precacheImage(
            ResizeImage(FileImage(File(installed.pagePath(n))), width: width),
            context,
            onError: (_, _) {},
          ),
        );
      }
    });
  }
}

/// How viewport points map to pages through their boxes (§15 D123): the
/// viewport reports a point on an item (0..1 of what is drawn); bookmarks,
/// highlights and lines are in whole-page fractions.
@immutable
final class _PageView {
  const new(this.boxOf);

  final PageBox Function(int page) boxOf;

  static const MushafLayout _layout = QuranEditionPin.layout;

  /// Width / height of spread [item]: its pages side by side at one height.
  double spreadAspect(int item) {
    final pages = _layout.pagesOf(item);
    final left = pages.left;
    return boxOf(pages.right).aspect +
        (left == null ? boxOf(pages.right).aspect : boxOf(left).aspect);
  }

  /// The share of spread [item]'s width its right page takes.
  double rightShare(int item) =>
      boxOf(_layout.pagesOf(item).right).aspect / spreadAspect(item);

  /// Page and page point of [point] on [item].
  (int, Offset) pageAt(int item, Offset point, {required bool spreads}) {
    var page = item + 1;
    var x = point.dx;
    if (spreads) {
      final pages = _layout.pagesOf(item);
      final share = rightShare(item);
      // The right part is the right (odd) page.
      if (point.dx >= 1 - share) {
        page = pages.right;
        x = (point.dx - (1 - share)) / share;
      } else {
        page = pages.left ?? pages.right;
        x = point.dx / (1 - share);
      }
    }
    final p = boxOf(page).toPage(x, point.dy);
    return (page, Offset(p.x, p.y));
  }

  /// The highlight area between [a] and [b] on [item], on the page where
  /// it started.
  HighlightRegion? region(
    int item,
    Offset a,
    Offset b, {
    required bool spreads,
  }) {
    final (page, pa) = pageAt(item, a, spreads: spreads);
    final (other, pb) = pageAt(item, b, spreads: spreads);
    // A box crossing the spine stays on the page it started on.
    final end = other == page ? pb : Offset(page.isOdd ? 0 : 1, pb.dy);
    return HighlightRegion.between(
      page,
      (x: pa.dx, y: pa.dy),
      (x: end.dx, y: end.dy),
    );
  }
}
