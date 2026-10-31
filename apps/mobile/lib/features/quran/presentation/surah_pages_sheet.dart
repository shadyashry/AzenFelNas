import 'dart:io';

import 'package:daily_muslim/features/home/presentation/display_style.dart';
import 'package:daily_muslim/features/quran/domain/highlight.dart';
import 'package:daily_muslim/features/quran/domain/installed_quran.dart';
import 'package:daily_muslim/features/quran/domain/mushaf_index_entries.dart';
import 'package:daily_muslim/features/quran/domain/quran_package_status.dart';
import 'package:daily_muslim/features/quran/presentation/quran_format.dart';
import 'package:daily_muslim/features/quran/presentation/quran_providers.dart';
import 'package:daily_muslim/features/quran/presentation/reader_controller.dart';
import 'package:daily_muslim/l10n/app_localizations.dart';
import 'package:dm_ui/dm_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// *All pages* of the surah being read (§15 D114, D120, D121): only the
/// pages it is on, as small images of the official pages in Mushaf order
/// (right to left) in a grid as wide as the window allows, each with its
/// number, the surah's verses on it and a bookmark mark (an icon, not a
/// colour). It opens scrolled to [page], which is marked; a tap opens a
/// page. It scrolls, so it works on short landscape windows too.
/// [onGoToPage] offers typing any page number instead.
Future<void> showSurahPagesSheet(
  BuildContext context, {
  required SuraEntry sura,
  required int page,
  required VoidCallback onGoToPage,
}) => showModalBottomSheet<void>(
  context: context,
  showDragHandle: true,
  isScrollControlled: true,
  useSafeArea: true,
  builder: (context) =>
      _SurahPages(sura: sura, page: page, onGoToPage: onGoToPage),
);

final class _SurahPages extends ConsumerStatefulWidget {
  const new({
    required this.sura,
    required this.page,
    required this.onGoToPage,
  });

  final SuraEntry sura;
  final int page;
  final VoidCallback onGoToPage;

  @override
  ConsumerState<_SurahPages> createState() => _SurahPagesState();
}

final class _SurahPagesState extends ConsumerState<_SurahPages> {
  /// The widest a page in the grid may be.
  static const double _maxThumb = 112;
  static const double _gap = 12;

  ScrollController? _grid;

  @override
  void dispose() {
    _grid?.dispose();
    super.dispose();
  }

  void _open(int page) {
    ref.read(readerProvider.notifier).goTo(page);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final style = DisplayStyle.of(context, ref);
    final theme = Theme.of(context);
    final range = ref.watch(surahPagesProvider(widget.sura.number)).value;
    final installed = readablePackage(ref.watch(quranStatusProvider));
    if (range == null || installed == null) {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    final ayahs =
        ref.watch(surahPageAyahsProvider(widget.sura.number)).value ??
        const <int, ({int first, int last, bool continued})>{};
    final bookmarked = {
      for (final b in ref.watch(bookmarksProvider).value ?? const <Bookmark>[])
        b.page,
    };
    final (:first, :last) = range;
    final count = last - first + 1;
    final image = installed.manifest.pageImage;
    final scale = MediaQuery.textScalerOf(context);
    String n(int v) => QuranFormat.number(v, style);
    String? ayahLine(int page) => switch (ayahs[page]) {
      null => null,
      (:final first, continued: true, last: _) => l.quranPageContinuedAyah(
        n(first),
      ),
      (:final first, :final last, continued: false) when first == last =>
        l.quranPageFirstAyah(n(first)),
      (:final first, :final last, continued: false) => l.quranAyahRange(
        n(first),
        n(last),
      ),
    };
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              l.quranSurahPages(
                QuranFormat.surahName(widget.sura, style),
                n(first),
                n(last),
              ),
              style: theme.textTheme.titleMedium,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
            child: Text(
              l.quranSurahPagesHint,
              style: theme.textTheme.bodySmall,
            ),
          ),
          Flexible(
            // The Mushaf runs right to left in either interface language.
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth - 2 * _gap;
                  final columns = ((width + _gap) / (_maxThumb + _gap))
                      .ceil()
                      .clamp(3, 12);
                  final thumbWidth = (width - (columns - 1) * _gap) / columns;
                  final thumbHeight = thumbWidth * image.height / image.width;
                  final rowHeight = thumbHeight + 12 + scale.scale(36);
                  final grid = _grid ??= ScrollController(
                    initialScrollOffset:
                        ((widget.page - first) ~/ columns) *
                            (rowHeight + _gap) -
                        rowHeight / 2,
                  );
                  return GridView.builder(
                    controller: grid,
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(_gap),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      mainAxisSpacing: _gap,
                      crossAxisSpacing: _gap,
                      mainAxisExtent: rowHeight,
                    ),
                    itemCount: count,
                    itemBuilder: (context, i) => _Thumb(
                      installed: installed,
                      page: first + i,
                      label: n(first + i),
                      ayah: ayahLine(first + i),
                      bookmarked: bookmarked.contains(first + i),
                      current: first + i == widget.page,
                      width: thumbWidth,
                      height: thumbHeight,
                      onTap: () => _open(first + i),
                    ),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  widget.onGoToPage();
                },
                icon: const Icon(Icons.dialpad),
                label: Text(l.quranGoToPage),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// One page of the grid: the official page image, small, its number, the
/// surah's verses on it and, when bookmarked, a bookmark icon.
final class _Thumb extends StatelessWidget {
  const new({
    required this.installed,
    required this.page,
    required this.label,
    required this.ayah,
    required this.bookmarked,
    required this.current,
    required this.width,
    required this.height,
    required this.onTap,
  });

  final InstalledQuran installed;
  final int page;
  final String label;
  final String? ayah;
  final bool bookmarked;
  final bool current;
  final double width;
  final double height;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = RawdahScheme.of(context);
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context);
    final dpr = MediaQuery.devicePixelRatioOf(context);
    return Semantics(
      button: true,
      selected: current,
      label: [
        l.quranPage(label),
        ?ayah,
        if (bookmarked) l.quranBookmarked,
      ].join(', '),
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Column(
          children: [
            Stack(
              children: [
                DecoratedBox(
                  position: DecorationPosition.foreground,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: current ? scheme.accent : scheme.hairline,
                      width: current ? 3 : 1,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: SizedBox(
                    width: width,
                    height: height,
                    child: Image(
                      image: ResizeImage(
                        FileImage(File(installed.pagePath(page))),
                        width: (width * dpr).round(),
                      ),
                      fit: BoxFit.contain,
                      gaplessPlayback: true,
                      errorBuilder: (context, error, stack) =>
                          ColoredBox(color: scheme.wash),
                    ),
                  ),
                ),
                if (bookmarked)
                  PositionedDirectional(
                    top: 0,
                    start: 4,
                    child: Icon(Icons.bookmark, size: 18, color: scheme.accent),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: current ? scheme.accent : null,
                fontWeight: current ? FontWeight.w700 : null,
                decoration: current ? TextDecoration.underline : null,
              ),
            ),
            if (ayah case final ayah?)
              Text(
                ayah,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall,
              ),
          ],
        ),
      ),
    );
  }
}
