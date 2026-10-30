import 'dart:async';

import 'package:daily_muslim/features/home/presentation/display_style.dart';
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

/// The surah bar under the page, outside it (§15 D120, REQ-QRN-024): the
/// chosen surah, the page and its place among the surah's pages (tap for
/// the surah's pages), *Beginning of the surah*, *Go to ayah* and, on its
/// last page, *Continue to* the next surah. Nothing while the scope is
/// not known.
final class SurahNavBar extends ConsumerWidget {
  /// The bar.
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scope = ref.watch(readerScopeProvider);
    if (scope == null) return const SizedBox.shrink();
    final l = AppLocalizations.of(context);
    final style = DisplayStyle.of(context, ref);
    final theme = Theme.of(context);
    final scheme = RawdahScheme.of(context);
    final suras = ref.watch(surasProvider).value ?? const <SuraEntry>[];
    final next = scope.atEnd ? _after(suras, scope.sura.number) : null;
    // A short window (a phone on its side) gets one row, so the page keeps
    // most of the height.
    final compact = MediaQuery.sizeOf(context).height < 560;
    final name = QuranFormat.surahName(scope.sura, style);
    String n(int v) => QuranFormat.number(v, style);
    final where = scope.single
        ? l.quranSurahOnePage(n(scope.page))
        : l.quranSurahPosition(
            n(scope.page),
            n(scope.position),
            n(scope.count),
          );
    void pages() => showSurahPagesSheet(
      context,
      sura: scope.sura,
      page: scope.page,
      onGoToPage: () => showGoToPageDialog(context, ref),
    );
    return Material(
      color: theme.colorScheme.surface,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Divider(height: 1, color: scheme.hairline),
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(12, 2, 4, 2),
            child: Row(
              children: [
                Expanded(
                  child: Semantics(
                    button: !scope.single,
                    onTapHint: scope.single ? null : l.quranSurahPagesOpen,
                    child: InkWell(
                      onTap: scope.single ? null : pages,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: 44),
                        child: compact
                            ? Align(
                                alignment: AlignmentDirectional.centerStart,
                                child: Text(
                                  '$name · $where',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodySmall,
                                ),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.titleSmall,
                                  ),
                                  Text(
                                    where,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.bodySmall,
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ),
                if (compact && next != null)
                  Flexible(
                    child: _NextSurah(scope: scope, next: next, inline: true),
                  ),
                IconButton(
                  tooltip: l.quranSurahStart,
                  icon: const Icon(Icons.vertical_align_top),
                  onPressed: () => _open(ref, scope.sura),
                ),
                IconButton(
                  tooltip: l.quranGoToAyah,
                  icon: const Icon(Icons.format_list_numbered_rtl),
                  onPressed: () => showGoToAyahDialog(context, ref, scope.sura),
                ),
                if (!scope.single)
                  IconButton(
                    tooltip: l.quranSurahPagesOpen,
                    icon: const Icon(Icons.view_carousel_outlined),
                    onPressed: pages,
                  ),
              ],
            ),
          ),
          if (!compact && next != null) _NextSurah(scope: scope, next: next),
        ],
      ),
    );
  }
}

/// *Continue to* the surah after the one ending on this page; says when it
/// begins on this same page (several short surahs share a page).
final class _NextSurah extends ConsumerWidget {
  const new({required this.scope, required this.next, this.inline = false});

  final SurahScope scope;
  final SuraEntry next;

  /// Inside the bar's one row rather than on a row of its own.
  final bool inline;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final style = DisplayStyle.of(context, ref);
    final samePage = next.startPage == scope.page;
    return Padding(
      padding: inline
          ? const EdgeInsets.symmetric(horizontal: 4)
          : const EdgeInsets.fromLTRB(12, 0, 12, 4),
      child: FilledButton.tonalIcon(
        onPressed: () => _open(ref, next),
        icon: const Icon(Icons.skip_next),
        label: Text(
          samePage
              ? l.quranNextSurahSamePage(QuranFormat.surahName(next, style))
              : l.quranNextSurah(QuranFormat.surahName(next, style)),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

/// The surah after [number], or `null` after the last.
SuraEntry? _after(List<SuraEntry> suras, int number) {
  for (final s in suras) {
    if (s.number == number + 1) return s;
  }
  return null;
}

/// Opens the first verse of [sura] with its lines outlined; it becomes the
/// bar's surah even when it starts on the page already shown.
void _open(WidgetRef ref, SuraEntry sura) => unawaited(
  ref
      .read(readerProvider.notifier)
      .showVerseAt(sura.number, 1, fallbackPage: sura.startPage),
);
