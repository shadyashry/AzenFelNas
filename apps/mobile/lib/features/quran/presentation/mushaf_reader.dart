import 'dart:async';
import 'dart:io';

import 'package:daily_muslim/features/home/presentation/display_style.dart';
import 'package:daily_muslim/features/quran/domain/ayah_highlight.dart';
import 'package:daily_muslim/features/quran/domain/highlight.dart';
import 'package:daily_muslim/features/quran/domain/highlight_color.dart';
import 'package:daily_muslim/features/quran/domain/installed_quran.dart';
import 'package:daily_muslim/features/quran/domain/mushaf_index_entries.dart';
import 'package:daily_muslim/features/quran/domain/mushaf_layout.dart';
import 'package:daily_muslim/features/quran/domain/mushaf_lines.dart';
import 'package:daily_muslim/features/quran/domain/quran_edition_pin.dart';
import 'package:daily_muslim/features/quran/domain/reader_preferences.dart';
import 'package:daily_muslim/features/quran/domain/verse_place.dart';
import 'package:daily_muslim/features/quran/presentation/ayah_sheet.dart';
import 'package:daily_muslim/features/quran/presentation/highlight_sheet.dart';
import 'package:daily_muslim/features/quran/presentation/mushaf_page_image.dart';
import 'package:daily_muslim/features/quran/presentation/mushaf_viewport.dart';
import 'package:daily_muslim/features/quran/presentation/mushaf_viewport_controller.dart';
import 'package:daily_muslim/features/quran/presentation/quran_format.dart';
import 'package:daily_muslim/features/quran/presentation/quran_providers.dart';
import 'package:daily_muslim/features/quran/presentation/reader_bars.dart';
import 'package:daily_muslim/features/quran/presentation/reader_controller.dart';
import 'package:daily_muslim/features/quran/presentation/surah_nav_bar.dart';
import 'package:daily_muslim/l10n/app_localizations.dart';
import 'package:dm_ui/dm_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The Mushaf reader (§15 D107, D121): the page surface between the
/// reader's header and controls, which sit above and below the page, or
/// beside it in a wide, short window, never over it; hiding them gives the
/// page the whole screen.
final class MushafReader extends ConsumerStatefulWidget {
  /// The reader of [installed].
  const new({required this.installed, super.key});

  /// The active package.
  final InstalledQuran installed;

  /// Whether the controls go beside the page instead of under it
  /// (§15 D121): in a landscape window where a whole page, fitted to the
  /// height left, still leaves at least [panelMin] of width beside it.
  /// Content-driven, not tied to a device: a page is about 0.7 as wide as
  /// it is tall.
  static bool sideBySide(Size size, EdgeInsets insets, double aspect) {
    if (size.width <= size.height) return false;
    final pageWidth = (size.height - insets.vertical) * aspect;
    return size.width - insets.horizontal - pageWidth >= panelMin;
  }

  /// The narrowest side panel.
  static const double panelMin = 280;

  @override
  ConsumerState<MushafReader> createState() => _MushafReaderState();
}

final class _MushafReaderState extends ConsumerState<MushafReader> {
  final _viewport = MushafViewportController();
  final GlobalKey _surfaceKey = GlobalKey();

  @override
  void dispose() {
    _viewport.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final state = ref.watch(readerProvider);
    if (!state.restored) {
      return Center(child: Text(l.quranOpening));
    }
    final chrome = state.chromeVisible;
    final image = widget.installed.manifest.pageImage;
    final aspect = image.width / image.height;
    // One key for every layout, so hiding the bars or turning the phone
    // keeps the pages, their zoom and the viewport's command handler
    // (§15 D116, D121).
    final surface = KeyedSubtree(
      key: _surfaceKey,
      child: _Surface(installed: widget.installed, viewport: _viewport),
    );
    return ColoredBox(
      color: RawdahScheme.of(context).ground,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = constraints.biggest;
          final insets = MediaQuery.paddingOf(context);
          if (chrome && MushafReader.sideBySide(size, insets, aspect)) {
            return Row(
              children: [
                Expanded(child: SafeArea(child: surface)),
                SizedBox(
                  // Fit page: what the fitted page leaves, so no blank band
                  // is left beside it. Fit width: narrow, the page takes
                  // the rest.
                  width: state.preferences.fit == PageFit.width
                      ? MushafReader.panelMin
                      : (size.width -
                                insets.horizontal -
                                (size.height - insets.vertical) * aspect -
                                16)
                            .clamp(MushafReader.panelMin, 420)
                            .toDouble(),
                  child: Material(
                    color: RawdahScheme.of(context).panel,
                    child: Column(
                      children: [
                        ReaderTopBar(page: state.page),
                        Expanded(
                          child: SingleChildScrollView(
                            child: SafeArea(
                              top: false,
                              bottom: false,
                              child: ReaderControls(
                                viewport: _viewport,
                                density: ReaderDensity.full,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }
          return Column(
            children: [
              if (chrome) ReaderTopBar(page: state.page),
              Expanded(
                child: SafeArea(top: !chrome, bottom: !chrome, child: surface),
              ),
              if (chrome)
                SafeArea(
                  top: false,
                  bottom: false,
                  child: ReaderControls(
                    viewport: _viewport,
                    density: ReaderDensity.forHeight(
                      MediaQuery.sizeOf(context).height,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// The controls under or beside the page: the surah navigator and the page
/// buttons, kept to a readable width on wide windows, or the drawing bar
/// while a highlight is drawn.
final class ReaderControls extends ConsumerWidget {
  /// The controls driving [viewport] at [density].
  const new({required this.viewport, required this.density, super.key});

  /// The page surface.
  final MushafViewportController viewport;

  /// How much room they may take.
  final ReaderDensity density;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final style = DisplayStyle.of(context, ref);
    final scheme = RawdahScheme.of(context);
    if (ref.watch(readerProvider.select((s) => s.draft != null))) {
      return DrawBar(viewport: viewport);
    }
    final scope = ref.watch(readerScopeProvider);
    final suras = ref.watch(surasProvider).value ?? const <SuraEntry>[];
    final next = continueAfter(scope, suras);
    final name = next == null ? null : QuranFormat.surahName(next, style);
    return Material(
      color: scheme.panel,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Divider(height: 1, color: scheme.hairline),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SurahNavBar(viewport: viewport, density: density),
                  ReaderBottomBar(
                    viewport: viewport,
                    dense: density != ReaderDensity.full,
                    continueShort: name,
                    continueLabel: name == null
                        ? null
                        : next?.startPage == scope?.page
                        ? l.quranNextSurahSamePage(name)
                        : l.quranNextSurah(name),
                    onContinue: next == null
                        ? null
                        : () => openSurah(ref, next),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The pages, one or two at a time, laid out for the space left.
final class _Surface extends ConsumerWidget {
  const new({required this.installed, required this.viewport});

  final InstalledQuran installed;
  final MushafViewportController viewport;

  /// Two facing pages need a landscape window tall enough to read them.
  static bool spreadsFit(Size size) =>
      size.width > size.height * 1.15 && size.height >= 480;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final state = ref.watch(readerProvider);
    final controller = ref.read(readerProvider.notifier);
    const layout = QuranEditionPin.layout;
    final image = installed.manifest.pageImage;
    final aspect = image.width / image.height;
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
          sourceWidth: image.width,
          regions: regions[number] ?? const [],
          marks: marks[number] ?? const [],
          errorLabel: l.quranPageError,
        );
        _precache(context, layout.pageCount, state.page, constraints.biggest);
        return MushafViewport(
          itemCount: spreads ? layout.spreadCount : layout.pageCount,
          item: spreads ? layout.spreadOf(state.page) : state.page - 1,
          aspect: spreads ? aspect * 2 : aspect,
          fit: state.preferences.fit,
          controller: viewport,
          drawing: state.draft != null,
          semanticLabel: l.quranReaderLabel(state.page.toString()),
          reveal: _reveal(state.mark, spreads, layout),
          onItemChanged: (item) => controller.goTo(
            spreads ? layout.pagesOf(item).right : item + 1,
          ),
          itemBuilder: (context, item, size) {
            if (!spreads) return page(item + 1, size);
            final pages = layout.pagesOf(item);
            final half = Size(size.width / 2, size.height);
            final left = pages.left;
            return Row(
              // The right page first, as in the printed Mushaf.
              textDirection: TextDirection.rtl,
              children: [
                SizedBox.fromSize(size: half, child: page(pages.right, half)),
                SizedBox.fromSize(
                  size: half,
                  child: left == null ? null : page(left, half),
                ),
              ],
            );
          },
          onDraw: (item, a, b) {
            final hit = _toPage(spreads, item, a, b);
            if (hit != null) controller.addRegion(hit);
          },
          onTap: (item, point) async {
            final (page, p) = _pageAt(spreads, item, point);
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
            final (page, p) = _pageAt(spreads, item, point);
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

  /// Page and page-relative point of [point] on [item].
  static (int, Offset) _pageAt(bool spreads, int item, Offset point) {
    const layout = QuranEditionPin.layout;
    if (!spreads) return (item + 1, point);
    final pages = layout.pagesOf(item);
    // The right half is the right (odd) page.
    if (point.dx >= 0.5) {
      return (pages.right, Offset((point.dx - 0.5) * 2, point.dy));
    }
    return (pages.left ?? pages.right, Offset(point.dx * 2, point.dy));
  }

  static HighlightRegion? _toPage(bool spreads, int item, Offset a, Offset b) {
    final (page, pa) = _pageAt(spreads, item, a);
    final (_, pb) = _pageAt(spreads, item, b);
    // A box crossing the spine stays on the page it started on.
    final end = spreads && (a.dx >= 0.5) != (b.dx >= 0.5)
        ? Offset(a.dx >= 0.5 ? 0 : 1, pb.dy)
        : pb;
    return HighlightRegion.between(
      page,
      (x: pa.dx, y: pa.dy),
      (x: end.dx, y: end.dy),
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
  /// the page title, the page number) and on a surah title line.
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

  /// The lines of the verse just opened, by page.
  /// Where the opened verse's first line is, to bring it into view
  /// (§15 D120); `null` without a mark or line geometry.
  static ({int item, double y})? _reveal(
    VersePlace? mark,
    bool spreads,
    MushafLayout layout,
  ) {
    if (mark == null || QuranEditionPin.layoutId != MushafLines.layoutId) {
      return null;
    }
    final band = MushafLines.band(mark.page, mark.lineStart);
    if (band == null) return null;
    return (
      item: spreads ? layout.spreadOf(mark.page) : mark.page - 1,
      y: band.top,
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
  void _precache(BuildContext context, int pageCount, int page, Size size) {
    final ratio = MediaQuery.devicePixelRatioOf(context);
    final width = MushafPageImage.decodeWidth(
      size.width,
      ratio,
      installed.manifest.pageImage.width,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      for (final n in [page + 1, page - 1, page + 2]) {
        if (n < 1 || n > pageCount) continue;
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
