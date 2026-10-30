import 'package:daily_muslim/features/home/presentation/display_style.dart';
import 'package:daily_muslim/features/quran/domain/ayah_highlight.dart';
import 'package:daily_muslim/features/quran/domain/mushaf_index_entries.dart';
import 'package:daily_muslim/features/quran/domain/quran_edition_pin.dart';
import 'package:daily_muslim/features/quran/domain/verse_place.dart';
import 'package:daily_muslim/features/quran/presentation/highlight_sheet.dart';
import 'package:daily_muslim/features/quran/presentation/quran_format.dart';
import 'package:daily_muslim/features/quran/presentation/quran_providers.dart';
import 'package:daily_muslim/features/quran/presentation/reader_controller.dart';
import 'package:daily_muslim/features/schedule/presentation/schedule_providers.dart';
import 'package:daily_muslim/l10n/app_localizations.dart';
import 'package:dm_ui/dm_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The verses of a line or a page (§15 D114), each with its reference, the
/// start of its text in the Mushaf's own font, and what can be done with
/// it: highlight it in a colour (drawn over the lines it is on), remove
/// that highlight, copy its text with the reference, or show it on the
/// page. Everything comes from the package's verse table; the page image
/// is never changed.
Future<void> showAyahSheet(
  BuildContext context, {
  required String title,
  required List<VersePlace> places,
  bool hint = false,
}) => showModalBottomSheet<void>(
  context: context,
  showDragHandle: true,
  isScrollControlled: true,
  builder: (context) => _AyahSheet(title: title, places: places, hint: hint),
);

final class _AyahSheet extends ConsumerWidget {
  const new({required this.title, required this.places, required this.hint});

  final String title;
  final List<VersePlace> places;
  final bool hint;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final muted = Theme.of(context).textTheme.labelMedium;
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.8,
        ),
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            if (hint) ...[
              const SizedBox(height: DmScales.lineGap),
              Text(l.quranAyahHint, style: muted),
            ],
            const SizedBox(height: DmScales.lineGap),
            Text(l.quranAyahLinesNote, style: muted),
            for (final place in places) ...[
              const Divider(height: 24),
              _Ayah(place),
            ],
          ],
        ),
      ),
    );
  }
}

final class _Ayah extends ConsumerWidget {
  const new(this.place);

  final VersePlace place;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final style = DisplayStyle.of(context, ref);
    final suras = ref.watch(surasProvider).value ?? const <SuraEntry>[];
    final font = ref.watch(quranFontProvider).value ?? false;
    final highlighted = [
      for (final h
          in ref.watch(ayahHighlightsProvider).value ?? const <AyahHighlight>[])
        if (h.sura == place.sura && h.aya == place.aya) h,
    ].firstOrNull;
    final sura = suras.where((s) => s.number == place.sura).firstOrNull;
    final reference = sura == null
        ? l.quranAyahRef(
            QuranFormat.number(place.sura, style),
            QuranFormat.number(place.sura, style),
            QuranFormat.number(place.aya, style),
          )
        : QuranFormat.verseRef(l, sura, place.aya, style);
    final store = ref.read(ayahHighlightStoreProvider);
    int now() => ref.read(clockProvider).nowUtcMs();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                reference,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            IconButton(
              tooltip: l.quranAyahShow,
              icon: const Icon(Icons.center_focus_strong_outlined),
              onPressed: () {
                ref.read(readerProvider.notifier).showVerse(place);
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
        // The verse as the source gives it, in the Mushaf's own font.
        Text(
          place.text,
          textDirection: TextDirection.rtl,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontFamily: font ? QuranFont.family : null,
            fontSize: 20,
            height: 1.6,
          ),
        ),
        const SizedBox(height: DmScales.lineGap * 2),
        Text(l.quranAyahHighlight),
        HighlightColorRow(
          selected: highlighted?.color,
          onSelected: (color) => store.setAyahHighlight(
            QuranEditionPin.layoutId,
            place.sura,
            place.aya,
            color,
            nowUtcMs: now(),
          ),
        ),
        Wrap(
          spacing: 8,
          children: [
            TextButton.icon(
              icon: const Icon(Icons.copy_outlined),
              label: Text(l.quranAyahCopy),
              onPressed: () async {
                await Clipboard.setData(
                  ClipboardData(text: '﴿${place.text}﴾\n$reference'),
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(l.quranAyahCopied)));
                }
              },
            ),
            if (highlighted != null)
              TextButton.icon(
                icon: const Icon(Icons.format_color_reset_outlined),
                label: Text(l.quranAyahRemoveHighlight),
                onPressed: () => store.removeAyahHighlight(
                  QuranEditionPin.layoutId,
                  place.sura,
                  place.aya,
                ),
              ),
          ],
        ),
      ],
    );
  }
}
