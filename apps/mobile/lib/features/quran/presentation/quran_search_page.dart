import 'package:daily_muslim/features/home/presentation/display_style.dart';
import 'package:daily_muslim/features/quran/domain/mushaf_index_entries.dart';
import 'package:daily_muslim/features/quran/presentation/quran_format.dart';
import 'package:daily_muslim/features/quran/presentation/quran_providers.dart';
import 'package:daily_muslim/features/quran/presentation/reader_controller.dart';
import 'package:daily_muslim/l10n/app_localizations.dart';
import 'package:dm_core_types/dm_core_types.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Offline search in the Quran text (§15 D106, REQ-QRN-040): the query is
/// folded like the index and matched as a substring of each verse; a
/// result shows the whole verse as published, the match in bold, the surah,
/// verse and page, and opens that page.
final class QuranSearchPage extends ConsumerWidget {
  /// The page.
  const new({super.key});

  /// Hits shown at most; the total is always given.
  static const limit = 200;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final query = ref.watch(_queryProvider);
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          autofocus: true,
          textInputAction: TextInputAction.search,
          onChanged: (v) => ref.read(_queryProvider.notifier).value = v,
          decoration: InputDecoration(
            hintText: l.quranSearchHint,
            border: InputBorder.none,
          ),
        ),
      ),
      body: query.trim().isEmpty
          ? Padding(
              padding: const EdgeInsets.all(24),
              child: Text(l.quranSearchIdle),
            )
          : const _Results(),
    );
  }
}

final NotifierProvider<_Query, String> _queryProvider =
    NotifierProvider.autoDispose<_Query, String>(_Query.new);

final class _Query extends Notifier<String> {
  @override
  String build() => '';

  String get value => state;

  set value(String value) => state = value;
}

final FutureProvider<SearchResults?> _resultsProvider =
    FutureProvider.autoDispose((ref) async {
      final query = ref.watch(_queryProvider);
      final index = ref.watch(mushafIndexProvider);
      if (index == null) return null;
      // Wait for the typing to settle.
      await Future<void>.delayed(const Duration(milliseconds: 250));
      if (!ref.mounted) return null;
      return switch (await index.search(query, limit: QuranSearchPage.limit)) {
        Ok(:final value) => value,
        Err() => null,
      };
    });

final class _Results extends ConsumerWidget {
  const new();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final style = DisplayStyle.of(context, ref);
    final suras = ref.watch(surasProvider).value ?? const <SuraEntry>[];
    final font = ref.watch(quranFontProvider).value ?? false;
    return switch (ref.watch(_resultsProvider)) {
      AsyncData(value: final SearchResults results) when results.total == 0 =>
        Center(child: Text(l.quranSearchEmpty)),
      AsyncData(value: final SearchResults results) => ListView.builder(
        itemCount: results.hits.length + 1,
        itemBuilder: (context, i) {
          if (i == 0) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Semantics(
                liveRegion: true,
                child: Text(
                  results.total > results.hits.length
                      ? l.quranSearchMore(
                          QuranFormat.number(results.hits.length, style),
                          QuranFormat.number(results.total, style),
                        )
                      : l.quranSearchCount(
                          results.total,
                          QuranFormat.number(results.total, style),
                        ),
                ),
              ),
            );
          }
          final hit = results.hits[i - 1];
          return _Hit(
            hit: hit,
            sura: hit.sura <= suras.length ? suras[hit.sura - 1].header : '',
            font: font,
            reference: l.quranVerseRef(
              QuranFormat.number(hit.aya, style),
              QuranFormat.number(hit.page, style),
            ),
            onTap: () {
              ref.read(readerProvider.notifier).goTo(hit.page);
              Navigator.of(context).pop();
            },
          );
        },
      ),
      AsyncData() => Center(child: Text(l.quranFailSearch)),
      AsyncError() => Center(child: Text(l.quranFailSearch)),
      AsyncLoading() => const LinearProgressIndicator(),
    };
  }
}

final class _Hit extends StatelessWidget {
  const new({
    required this.hit,
    required this.sura,
    required this.font,
    required this.reference,
    required this.onTap,
  });

  final VerseHit hit;
  final String sura;
  final bool font;
  final String reference;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final verse = TextStyle(
      fontFamily: font ? QuranFont.family : null,
      fontSize: 22,
      height: 1.9,
      color: theme.colorScheme.onSurface,
    );
    final text = hit.text;
    return ListTile(
      onTap: onTap,
      title: Text.rich(
        TextSpan(
          style: verse,
          children: [
            TextSpan(text: text.substring(0, hit.matchStart)),
            TextSpan(
              text: text.substring(hit.matchStart, hit.matchEnd),
              style: TextStyle(
                backgroundColor: theme.colorScheme.secondaryContainer,
              ),
            ),
            TextSpan(text: text.substring(hit.matchEnd)),
          ],
        ),
        textDirection: TextDirection.rtl,
      ),
      subtitle: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: sura,
              style: TextStyle(fontFamily: font ? QuranFont.family : null),
            ),
            TextSpan(text: ' · $reference'),
          ],
        ),
      ),
    );
  }
}
