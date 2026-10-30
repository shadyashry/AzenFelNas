import 'dart:async';

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
/// a tap opens the first page. With [currentSura] the surah list opens
/// scrolled to that surah and marks it (§15 D111).
Future<void> showQuranIndexSheet(BuildContext context, {int? currentSura}) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.85,
        child: DefaultTabController(
          length: 2,
          child: _IndexSheet(currentSura: currentSura),
        ),
      ),
    );

final class _IndexSheet extends StatelessWidget {
  const new({required this.currentSura});

  final int? currentSura;

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
        Expanded(
          child: TabBarView(
            children: [
              _Suras(current: currentSura),
              const _Juz(),
            ],
          ),
        ),
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

  String get value => state;

  set value(String value) => state = value;
}

final class _Suras extends ConsumerStatefulWidget {
  const new({required this.current});

  /// The surah being read, scrolled to and marked; `null` for none.
  final int? current;

  @override
  ConsumerState<_Suras> createState() => _SurasState();
}

final class _SurasState extends ConsumerState<_Suras> {
  final ScrollController _scroll = ScrollController();
  bool _scrolled = false;

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  /// Once the full list is laid out, brings the current surah to the top.
  /// Every row has the prototype's height, so its offset is its index
  /// times that height.
  void _scrollToCurrent(List<SuraEntry> shown) {
    final current = widget.current;
    if (_scrolled || current == null || shown.isEmpty) return;
    _scrolled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      final index = shown.indexWhere((s) => s.number == current);
      if (index < 0) return;
      final position = _scroll.position;
      final rowHeight =
          (position.maxScrollExtent + position.viewportDimension) /
          shown.length;
      _scroll.jumpTo(
        (index * rowHeight).clamp(0, position.maxScrollExtent).toDouble(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final style = DisplayStyle.of(context, ref);
    final font = ref.watch(quranFontProvider).value ?? false;
    final filter = ref.watch(_filterProvider);
    final all = ref.watch(surasProvider).value ?? const <SuraEntry>[];
    final shown = _matching(all, filter);
    if (filter.isEmpty) _scrollToCurrent(shown);
    Widget tile(SuraEntry s) => ListTile(
      selected: s.number == widget.current,
      title: Text(
        s.header,
        textDirection: TextDirection.rtl,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
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
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: () => _open(context, ref, s.number, 1, s.startPage),
    );
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: TextField(
            onChanged: (v) => ref.read(_filterProvider.notifier).value = v,
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
                  controller: _scroll,
                  prototypeItem: tile(shown.first),
                  itemCount: shown.length,
                  itemBuilder: (context, i) => tile(shown[i]),
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
          onTap: () => _open(context, ref, j.sura, j.aya, j.page),
        );
      },
    );
  }
}

/// Opens the first verse of a surah or juz with its lines outlined
/// (§15 D111), or [page] when the package cannot place it.
void _open(BuildContext context, WidgetRef ref, int sura, int aya, int page) {
  unawaited(
    ref
        .read(readerProvider.notifier)
        .showVerseAt(sura, aya, fallbackPage: page),
  );
  Navigator.of(context).pop();
}
