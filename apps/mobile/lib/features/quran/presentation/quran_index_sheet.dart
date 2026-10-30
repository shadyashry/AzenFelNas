import 'dart:async';

import 'package:daily_muslim/features/home/presentation/display_style.dart';
import 'package:daily_muslim/features/quran/domain/arabic_search_text.dart';
import 'package:daily_muslim/features/quran/domain/juz_contents.dart';
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
/// scrolled to that surah and marks it; with [currentJuz] the juz list
/// opens instead, scrolled to that juz (§15 D114).
Future<void> showQuranIndexSheet(
  BuildContext context, {
  int? currentSura,
  int? currentJuz,
}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  showDragHandle: true,
  builder: (context) => FractionallySizedBox(
    heightFactor: 0.85,
    child: DefaultTabController(
      length: 2,
      initialIndex: currentJuz == null ? 0 : 1,
      child: _IndexSheet(currentSura: currentSura, currentJuz: currentJuz),
    ),
  ),
);

final class _IndexSheet extends StatelessWidget {
  const new({required this.currentSura, required this.currentJuz});

  final int? currentSura;
  final int? currentJuz;

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
              _Juz(current: currentJuz),
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

/// The 30 juz, each with the surahs inside it (§15 D114); opened from the
/// juz in the reader's title it is scrolled to that juz and marks it.
final class _Juz extends ConsumerStatefulWidget {
  const new({required this.current});

  /// The juz being read, scrolled to and marked; `null` for none.
  final int? current;

  @override
  ConsumerState<_Juz> createState() => _JuzState();
}

final class _JuzState extends ConsumerState<_Juz> {
  final GlobalKey _currentKey = GlobalKey();
  bool _scrolled = false;

  void _scrollToCurrent() {
    if (_scrolled || widget.current == null) return;
    _scrolled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final target = _currentKey.currentContext;
      if (target != null && target.mounted) {
        Scrollable.ensureVisible(target);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final style = DisplayStyle.of(context, ref);
    final font = ref.watch(quranFontProvider).value ?? false;
    final juz = ref.watch(juzProvider).value ?? const <JuzEntry>[];
    final suras = ref.watch(surasProvider).value ?? const <SuraEntry>[];
    final contents = juzContents(juz, suras);
    if (contents.isNotEmpty) _scrollToCurrent();
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (j, inside) in contents) ...[
            ListTile(
              key: j.number == widget.current ? _currentKey : null,
              selected: j.number == widget.current,
              title: Text(l.quranJuz(QuranFormat.number(j.number, style))),
              subtitle: Text(
                l.quranJuzLine(QuranFormat.number(j.page, style)),
              ),
              onTap: () => _open(context, ref, j.sura, j.aya, j.page),
            ),
            for (final s in inside)
              ListTile(
                dense: true,
                contentPadding: const EdgeInsetsDirectional.only(
                  start: 40,
                  end: 16,
                ),
                title: Text(
                  s.sura.header,
                  textDirection: TextDirection.rtl,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: font ? QuranFont.family : null,
                    fontSize: 18,
                  ),
                ),
                subtitle: Text(
                  l.quranJuzSurahLine(
                    QuranFormat.number(s.aya, style),
                    QuranFormat.number(s.page, style),
                  ),
                ),
                onTap: () => _open(context, ref, s.sura.number, s.aya, s.page),
              ),
            const Divider(height: 1),
          ],
        ],
      ),
    );
  }
}

/// Opens the first verse of a surah or juz with its lines outlined
/// (§15 D114), or [page] when the package cannot place it.
void _open(BuildContext context, WidgetRef ref, int sura, int aya, int page) {
  unawaited(
    ref
        .read(readerProvider.notifier)
        .showVerseAt(sura, aya, fallbackPage: page),
  );
  Navigator.of(context).pop();
}
