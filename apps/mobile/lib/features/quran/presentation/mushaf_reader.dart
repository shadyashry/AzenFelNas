import 'dart:async';
import 'dart:io';

import 'package:daily_muslim/features/quran/domain/highlight.dart';
import 'package:daily_muslim/features/quran/domain/highlight_color.dart';
import 'package:daily_muslim/features/quran/domain/installed_quran.dart';
import 'package:daily_muslim/features/quran/domain/quran_edition_pin.dart';
import 'package:daily_muslim/features/quran/presentation/highlight_sheet.dart';
import 'package:daily_muslim/features/quran/presentation/mushaf_page_image.dart';
import 'package:daily_muslim/features/quran/presentation/mushaf_viewport.dart';
import 'package:daily_muslim/features/quran/presentation/mushaf_viewport_controller.dart';
import 'package:daily_muslim/features/quran/presentation/quran_providers.dart';
import 'package:daily_muslim/features/quran/presentation/reader_bars.dart';
import 'package:daily_muslim/features/quran/presentation/reader_controller.dart';
import 'package:daily_muslim/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The Mushaf reader (§15 D107): the page surface between the reader's
/// bars. The bars sit above and below the page, never over it; hiding them
/// gives the page the whole screen.
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
    return SafeArea(
      bottom: !chrome,
      child: Column(
        children: [
          if (chrome) ReaderTopBar(page: state.page),
          Expanded(
            child: _Surface(installed: widget.installed, viewport: _viewport),
          ),
          if (chrome && state.draft == null)
            ReaderBottomBar(viewport: _viewport),
          if (chrome && state.draft != null) DrawBar(viewport: _viewport),
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
    final regions = _regionsByPage(
      state.showHighlights
          ? ref.watch(highlightsProvider).value ?? const <Highlight>[]
          : const <Highlight>[],
      state.draft,
    );
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
          onTap: (item, point) {
            final (page, p) = _pageAt(spreads, item, point);
            final tapped = state.draft == null && state.showHighlights
                ? _highlightAt(ref.read(highlightsProvider).value, page, p)
                : null;
            if (tapped != null) {
              unawaited(showHighlightSheet(context, tapped));
            } else if (state.draft == null) {
              controller.toggleChrome();
            }
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

  static Map<int, List<(HighlightRegion, HighlightColor)>> _regionsByPage(
    List<Highlight> saved,
    HighlightDraft? draft,
  ) {
    final map = <int, List<(HighlightRegion, HighlightColor)>>{};
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
