import 'dart:async';

import 'package:daily_muslim/features/home/presentation/display_style.dart';
import 'package:daily_muslim/features/quran/domain/highlight.dart';
import 'package:daily_muslim/features/quran/domain/mushaf_index_entries.dart';
import 'package:daily_muslim/features/quran/domain/surah_scope.dart';
import 'package:daily_muslim/features/quran/presentation/go_to_page_dialog.dart';
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
  /// The reference's navigator whole: heading, place, *All pages*, slider,
  /// the nearby pages, the page buttons and the footer.
  full,

  /// The place on one line, the slider, the page buttons and the footer.
  compact,

  /// The place on one line and the page buttons only.
  minimal;

  /// The density for a window [height] logical pixels tall.
  static ReaderDensity forHeight(double height) => height >= 880
      ? ReaderDensity.full
      : height >= 720
      ? ReaderDensity.compact
      : ReaderDensity.minimal;
}

/// The surah navigator under the page, outside it, after the owner's
/// reference (§15 D120–D122, REQ-QRN-024): *Within this surah*, *Page n* and
/// its place among the chosen surah's pages, *All pages*, a slider over the
/// surah's own pages that previews a page while dragging and opens it on
/// release, and the nearby pages of the surah as buttons. The page buttons
/// and the footer follow it. Nothing while the scope is not known.
final class SurahNavBar extends ConsumerWidget {
  /// The navigator at [density].
  const new({this.density = ReaderDensity.full, super.key});

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
    final full = density == ReaderDensity.full;
    final place = full
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
    final allPages = scope.single
        ? null
        : full
        ? OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(0, 40),
              textStyle: theme.textTheme.titleSmall?.copyWith(fontSize: 14),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(14)),
              ),
            ),
            onPressed: pages,
            icon: const Icon(Icons.grid_view, size: 18),
            label: Text(l.quranAllPages),
          )
        : IconButton(
            tooltip: l.quranAllPages,
            onPressed: pages,
            icon: const Icon(Icons.grid_view),
          );
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              // A narrow column (a side panel, a split window) puts *All
              // pages* under the place rather than squeezing it.
              if (full && allPages != null && constraints.maxWidth < 340) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [place, const SizedBox(height: 8), allPages],
                );
              }
              return Row(
                children: [
                  Expanded(child: place),
                  ?allPages,
                ],
              );
            },
          ),
          if (!scope.single && density != ReaderDensity.minimal)
            _SurahSlider(scope: scope),
          if (!scope.single && full) _NearbyPages(scope: scope),
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
            fontSize: 11,
            letterSpacing: 1.6,
          ),
        ),
        const SizedBox(height: 2),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.end,
          spacing: 10,
          children: [
            Text(
              l.quranPage(n(scope.page)),
              style: theme.textTheme.titleLarge?.copyWith(
                color: scheme.primary,
                fontSize: 24,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Text(
                scope.single
                    ? l.quranSurahWholePage
                    : l.quranSurahPageOf(n(scope.position), n(scope.count)),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.inkMuted,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// A slider over the surah's own pages, first page on the right as in the
/// Mushaf, with a gold thumb on a quiet track. Dragging previews the page
/// number; the page opens on release, so the pages in between are never
/// loaded.
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
    final scheme = RawdahScheme.of(context);
    final scope = widget.scope;
    String label(double v) => l.quranPage(QuranFormat.number(v.round(), style));
    final value = (_drag ?? scope.page.toDouble())
        .clamp(scope.first, scope.last)
        .toDouble();
    return Directionality(
      textDirection: TextDirection.rtl,
      child: SliderTheme(
        data: SliderTheme.of(context).copyWith(
          trackHeight: 6,
          activeTrackColor: scheme.hairline,
          inactiveTrackColor: scheme.hairline,
          thumbColor: scheme.accent,
          overlayColor: scheme.accent.withValues(alpha: 0.12),
          tickMarkShape: SliderTickMarkShape.noTickMark,
          showValueIndicator: ShowValueIndicator.onDrag,
          valueIndicatorColor: scheme.primary,
          thumbShape: const RoundSliderThumbShape(),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
        ),
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
      ),
    );
  }
}

/// The surah's pages around the current one as buttons, right to left as
/// in the Mushaf, as many as the width holds: the current one filled green
/// with a gold dot, a bookmarked one with a bookmark mark (never colour
/// alone).
final class _NearbyPages extends ConsumerWidget {
  const new({required this.scope});

  final SurahScope scope;

  static const double _width = 44;
  static const double _gap = 8;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final style = DisplayStyle.of(context, ref);
    final theme = Theme.of(context);
    final scheme = RawdahScheme.of(context);
    final bookmarked = {
      for (final b in ref.watch(bookmarksProvider).value ?? const <Bookmark>[])
        b.page,
    };
    return LayoutBuilder(
      builder: (context, constraints) {
        final fits = ((constraints.maxWidth + _gap) / (_width + _gap))
            .floor()
            .clamp(1, scope.count);
        // A window of [fits] pages around the current one, kept inside the
        // surah.
        final start = (scope.page - fits ~/ 2).clamp(
          scope.first,
          scope.last - fits + 1,
        );
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Row(
            mainAxisAlignment: fits < 4
                ? MainAxisAlignment.start
                : MainAxisAlignment.spaceBetween,
            children: [
              for (var p = start; p < start + fits; p++)
                _PageButton(
                  label: QuranFormat.number(p, style),
                  semantics: [
                    l.quranPage(QuranFormat.number(p, style)),
                    if (bookmarked.contains(p)) l.quranBookmarked,
                  ].join(', '),
                  current: p == scope.page,
                  bookmarked: bookmarked.contains(p),
                  width: _width,
                  scheme: scheme,
                  textStyle: theme.textTheme.titleSmall?.copyWith(
                    fontSize: 15,
                  ),
                  onTap: () => ref.read(readerProvider.notifier).goTo(p),
                ),
            ],
          ),
        );
      },
    );
  }
}

final class _PageButton extends StatelessWidget {
  const new({
    required this.label,
    required this.semantics,
    required this.current,
    required this.bookmarked,
    required this.width,
    required this.scheme,
    required this.textStyle,
    required this.onTap,
  });

  final String label;
  final String semantics;
  final bool current;
  final bool bookmarked;
  final double width;
  final RawdahScheme scheme;
  final TextStyle? textStyle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // The current page: Horizon's deep green with ivory and gold, in both
    // modes, as the reference's selected page.
    const on = RawdahScheme.night;
    final ground = current ? RawdahScheme.light.primary : scheme.wash;
    return Semantics(
      button: true,
      selected: current,
      label: semantics,
      excludeSemantics: true,
      child: Material(
        color: ground,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          side: current
              ? BorderSide(color: on.accent, width: 1.5)
              : BorderSide.none,
        ),
        child: InkWell(
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          onTap: onTap,
          child: SizedBox(
            width: width,
            height: 44,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  label,
                  style: textStyle?.copyWith(
                    color: current ? on.ink : scheme.inkMuted,
                    fontWeight: current ? FontWeight.w700 : null,
                  ),
                ),
                if (current)
                  Positioned(
                    bottom: 6,
                    child: SizedBox.square(
                      dimension: 5,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: on.accent,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                if (bookmarked)
                  PositionedDirectional(
                    top: 2,
                    end: 4,
                    child: Icon(
                      Icons.bookmark,
                      size: 12,
                      color: current ? on.accent : scheme.accent,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The footer under the page buttons: the surah's verses on the page and
/// whether the position is saved.
final class ReaderFooter extends ConsumerWidget {
  /// The footer.
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scope = ref.watch(readerScopeProvider);
    if (scope == null) return const SizedBox.shrink();
    final l = AppLocalizations.of(context);
    final style = DisplayStyle.of(context, ref);
    final theme = Theme.of(context);
    final scheme = RawdahScheme.of(context);
    final saved = ref.watch(readerProvider.select((s) => s.positionSaved));
    final ayahs = ref
        .watch(surahPageAyahsProvider(scope.sura.number))
        .value?[scope.page];
    String n(int v) => QuranFormat.number(v, style);
    final small = theme.textTheme.bodySmall?.copyWith(
      color: scheme.inkMuted,
      fontSize: 12,
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (ayahs != null)
            Flexible(
              child: Text(
                ayahs.first == ayahs.last
                    ? l.quranPageFirstAyah(n(ayahs.first))
                    : l.quranAyahRange(n(ayahs.first), n(ayahs.last)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: small,
              ),
            ),
          if (saved)
            Flexible(
              flex: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.check, size: 14, color: scheme.inkMuted),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      l.quranPositionSaved,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: small,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
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
