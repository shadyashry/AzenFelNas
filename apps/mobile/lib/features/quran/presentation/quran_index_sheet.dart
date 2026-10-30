import 'package:daily_muslim/features/home/presentation/display_style.dart';
import 'package:daily_muslim/features/quran/domain/arabic_search_text.dart';
import 'package:daily_muslim/features/quran/domain/mushaf_index_entries.dart';
import 'package:daily_muslim/features/quran/presentation/quran_format.dart';
import 'package:daily_muslim/features/quran/presentation/quran_providers.dart';
import 'package:daily_muslim/features/quran/presentation/reader_controller.dart';
import 'package:daily_muslim/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The surah and juz index (REQ-QRN-023): the 114 surah headers as printed
/// (KFGQPC text and font), filterable by name or number, and the 30 juz;
/// a tap opens the first page.
Future<void> showQuranIndexSheet(BuildContext context) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => const FractionallySizedBox(
        heightFactor: 0.85,
        child: DefaultTabController(length: 2, child: _IndexSheet()),
      ),
    );

final class _IndexSheet extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Column(
      children: [
        TabBar(
          tabs: [
            Tab(text: l.quranSurahsTab),
            Tab(text: l.quranJuzTab),
          ],
        ),
        const Expanded(child: TabBarView(children: [_Suras(), _Juz()])),
      ],
    );
  }
}

/// The filter text of the surah list.
final NotifierProvider<_Filter, String> _filterProvider =
    NotifierProvider.autoDispose<_Filter, String>(_Filter.new);

final class _Filter extends Notifier<String> {
  @override
  String build() => '';

  void set(String value) => state = value;
}

final class _Suras extends ConsumerWidget {
  const new();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final style = DisplayStyle.of(context, ref);
    final font = ref.watch(quranFontProvider).value ?? false;
    final filter = ref.watch(_filterProvider);
    final all = ref.watch(surasProvider).value ?? const <SuraEntry>[];
    final shown = _matching(all, filter);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: TextField(
            onChanged: ref.read(_filterProvider.notifier).set,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: l.quranFilterSurahs,
            ),
          ),
        ),
        Expanded(
          child: shown.isEmpty
              ? Center(child: Text(l.quranNoSurah))
              : ListView.builder(
                  itemCount: shown.length,
                  itemBuilder: (context, i) {
                    final s = shown[i];
                    return ListTile(
                      title: Text(
                        s.header,
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                          fontFamily: font ? QuranFont.family : null,
                          fontSize: 22,
                        ),
                      ),
                      subtitle: Text(
                        l.quranSurahLine(
                          QuranFormat.number(s.number, style),
                          QuranFormat.number(s.verseCount, style),
                          QuranFormat.number(s.startPage, style),
                        ),
                      ),
                      onTap: () => _open(context, ref, s.startPage),
                    );
                  },
                ),
        ),
      ],
    );
  }

  static List<SuraEntry> _matching(List<SuraEntry> all, String filter) {
    final number = int.tryParse(filter.trim());
    if (number != null) return [...all.where((s) => s.number == number)];
    final folded = ArabicSearchText.normalize(filter);
    if (folded.isEmpty) return all;
    return [
      ...all.where(
        (s) => ArabicSearchText.normalize(s.header).contains(folded),
      ),
    ];
  }
}

final class _Juz extends ConsumerWidget {
  const new();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final style = DisplayStyle.of(context, ref);
    final all = ref.watch(juzProvider).value ?? const <JuzEntry>[];
    return ListView.builder(
      itemCount: all.length,
      itemBuilder: (context, i) {
        final j = all[i];
        return ListTile(
          title: Text(l.quranJuz(QuranFormat.number(j.number, style))),
          subtitle: Text(l.quranJuzLine(QuranFormat.number(j.page, style))),
          onTap: () => _open(context, ref, j.page),
        );
      },
    );
  }
}

void _open(BuildContext context, WidgetRef ref, int page) {
  ref.read(readerProvider.notifier).goTo(page);
  Navigator.of(context).pop();
}
