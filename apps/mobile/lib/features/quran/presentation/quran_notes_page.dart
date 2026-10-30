import 'dart:async';

import 'package:daily_muslim/features/home/presentation/display_style.dart';
import 'package:daily_muslim/features/quran/domain/ayah_highlight.dart';
import 'package:daily_muslim/features/quran/domain/highlight.dart';
import 'package:daily_muslim/features/quran/domain/mushaf_index_entries.dart';
import 'package:daily_muslim/features/quran/domain/quran_edition_pin.dart';
import 'package:daily_muslim/features/quran/presentation/highlight_sheet.dart';
import 'package:daily_muslim/features/quran/presentation/mushaf_page_image.dart';
import 'package:daily_muslim/features/quran/presentation/quran_format.dart';
import 'package:daily_muslim/features/quran/presentation/quran_providers.dart';
import 'package:daily_muslim/features/quran/presentation/reader_controller.dart';
import 'package:daily_muslim/features/schedule/presentation/schedule_providers.dart';
import 'package:daily_muslim/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Bookmarks and "My highlights" (§15 D107, REQ-QRN-050, REQ-QRN-060):
/// stored on the device apart from the download, they open their page,
/// and a highlight can be recoloured or deleted.
final class QuranNotesPage extends ConsumerWidget {
  /// The page.
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l.quranNotes),
          bottom: TabBar(
            tabs: [
              Tab(text: l.quranBookmarksTab),
              Tab(text: l.quranHighlightsTab),
            ],
          ),
        ),
        body: const TabBarView(children: [_Bookmarks(), _Highlights()]),
      ),
    );
  }
}

String _suraOf(List<SuraEntry> suras, int page) {
  var name = '';
  for (final s in suras) {
    if (s.startPage <= page) name = s.header;
  }
  return name;
}

void _open(BuildContext context, WidgetRef ref, int page) {
  ref.read(readerProvider.notifier).goTo(page);
  Navigator.of(context).pop();
}

final class _Bookmarks extends ConsumerWidget {
  const new();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final style = DisplayStyle.of(context, ref);
    final suras = ref.watch(surasProvider).value ?? const <SuraEntry>[];
    final font = ref.watch(quranFontProvider).value ?? false;
    final all = ref.watch(bookmarksProvider).value ?? const <Bookmark>[];
    if (all.isEmpty) return _Empty(l.quranNoBookmarks);
    return ListView.builder(
      itemCount: all.length,
      itemBuilder: (context, i) {
        final b = all[i];
        return ListTile(
          leading: const Icon(Icons.bookmark),
          title: Text(l.quranPage(QuranFormat.number(b.page, style))),
          subtitle: Text(
            _suraOf(suras, b.page),
            style: TextStyle(fontFamily: font ? QuranFont.family : null),
          ),
          trailing: IconButton(
            tooltip: l.quranBookmarkRemove,
            icon: const Icon(Icons.delete_outline),
            onPressed: () => ref
                .read(bookmarkStoreProvider)
                .toggleBookmark(
                  QuranEditionPin.layoutId,
                  b.page,
                  nowUtcMs: ref.read(clockProvider).nowUtcMs(),
                ),
          ),
          onTap: () => _open(context, ref, b.page),
        );
      },
    );
  }
}

final class _Highlights extends ConsumerWidget {
  const new();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final style = DisplayStyle.of(context, ref);
    final suras = ref.watch(surasProvider).value ?? const <SuraEntry>[];
    final font = ref.watch(quranFontProvider).value ?? false;
    final all = ref.watch(highlightsProvider).value ?? const <Highlight>[];
    final ayahs =
        ref.watch(ayahHighlightsProvider).value ?? const <AyahHighlight>[];
    if (all.isEmpty && ayahs.isEmpty) return _Empty(l.quranNoHighlights);
    final ayahRows = ayahs.isEmpty ? 0 : ayahs.length + 1;
    return ListView.builder(
      itemCount: ayahRows + all.length,
      itemBuilder: (context, i) {
        if (i < ayahRows) {
          if (i == 0) {
            return Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 4),
              child: Text(
                l.quranAyahHighlights,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            );
          }
          return _AyahRow(ayahs[i - 1], suras: suras);
        }
        final h = all[i - ayahRows];
        return ListTile(
          leading: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: HighlightPainter.colorOf(h.color).withValues(alpha: 1),
              shape: BoxShape.circle,
            ),
          ),
          title: Text(highlightPages(l, h, style)),
          subtitle: Text(
            '${_suraOf(suras, h.firstPage)} · '
            '${highlightColorName(l, h.color)}',
            style: TextStyle(fontFamily: font ? QuranFont.family : null),
          ),
          trailing: IconButton(
            tooltip: l.quranHighlightColor,
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => showHighlightSheet(context, h),
          ),
          onTap: () => _open(context, ref, h.firstPage),
        );
      },
    );
  }
}

/// A verse highlight (§15 D113): its colour, its reference; tap to open
/// it with its lines outlined, or remove it.
final class _AyahRow extends ConsumerWidget {
  const new(this.highlight, {required this.suras});

  final AyahHighlight highlight;
  final List<SuraEntry> suras;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final style = DisplayStyle.of(context, ref);
    final h = highlight;
    final sura = suras.where((s) => s.number == h.sura).firstOrNull;
    return ListTile(
      leading: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: HighlightPainter.colorOf(h.color).withValues(alpha: 1),
          shape: BoxShape.circle,
        ),
      ),
      title: Text(
        sura == null
            ? l.quranAyahRef(
                QuranFormat.number(h.sura, style),
                QuranFormat.number(h.sura, style),
                QuranFormat.number(h.aya, style),
              )
            : QuranFormat.verseRef(l, sura, h.aya, style),
      ),
      subtitle: Text(highlightColorName(l, h.color)),
      trailing: IconButton(
        tooltip: l.quranAyahRemoveHighlight,
        icon: const Icon(Icons.format_color_reset_outlined),
        onPressed: () => ref
            .read(ayahHighlightStoreProvider)
            .removeAyahHighlight(h.layoutId, h.sura, h.aya),
      ),
      onTap: () {
        final reader = ref.read(readerProvider.notifier);
        unawaited(
          reader.showVerseAt(
            h.sura,
            h.aya,
            fallbackPage: sura?.startPage ?? ref.read(readerProvider).page,
          ),
        );
        Navigator.of(context).pop();
      },
    );
  }
}

final class _Empty extends StatelessWidget {
  const new(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Text(text, textAlign: TextAlign.center),
    ),
  );
}
