import 'package:daily_muslim/features/home/presentation/display_style.dart';
import 'package:daily_muslim/features/quran/domain/mushaf_index_entries.dart';
import 'package:daily_muslim/features/quran/domain/quran_package_status.dart';
import 'package:daily_muslim/features/quran/domain/surah_names.dart';
import 'package:daily_muslim/features/quran/presentation/quran_format.dart';
import 'package:daily_muslim/features/quran/presentation/quran_providers.dart';
import 'package:daily_muslim/features/shell/domain/app_route.dart';
import 'package:daily_muslim/l10n/app_localizations.dart';
import 'package:dm_ui/dm_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Home's "Continue Quran" (§15 D108, D109): the surah and page the reader
/// was last left on, with a gold resume action that opens the reader there
/// (it restores its last page). Arabic names the surah as its Mushaf header
/// does, without the word «سورة» and with every mark kept; English by its
/// English name (`SurahNames`, §15 D110). Shown only when
/// there is a saved page and the downloaded Quran is readable; "Available
/// offline" only when the package checked complete (`QuranReady`). Nothing
/// of the Mushaf page itself is drawn here.
final class ContinueQuranCard extends ConsumerWidget {
  /// The card, or nothing when there is nothing to continue.
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // The saved page first: before the first read nothing else is asked.
    final page = ref.watch(lastQuranPageProvider).value;
    if (page == null) return const SizedBox.shrink();
    final status = ref.watch(quranStatusProvider);
    if (readablePackage(status) == null) return const SizedBox.shrink();
    final l = AppLocalizations.of(context);
    final style = DisplayStyle.of(context, ref);
    final type = DmType.of(style.locale);
    final r = RawdahScheme.of(context);
    final suras = ref.watch(surasProvider).value ?? const <SuraEntry>[];
    SuraEntry? sura;
    for (final s in suras) {
      if (s.startPage <= page) sura = s;
    }
    final surah = switch ((sura, style.locale)) {
      (null, _) => null,
      (final SuraEntry s, StatusLocale.ar) => _nameOf(s.header),
      (final SuraEntry s, StatusLocale.en) =>
        SurahNames.englishOf(s.number) ??
            l.homeSurahNumber(QuranFormat.number(s.number, style)),
    };
    final title = [?surah, l.quranPage(QuranFormat.number(page, style))];
    final offline = status is QuranReady;
    void open() => context.go(const QuranRoute().location);
    return Semantics(
      button: true,
      label: [
        l.homeContinueQuran,
        ...title,
        if (offline) l.homeQuranOffline,
      ].join(', '),
      excludeSemantics: true,
      onTap: open,
      child: Material(
        color: r.wash,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DmScales.radiusCard),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: open,
          child: Padding(
            padding: const EdgeInsets.all(DmScales.cardPadding),
            child: Row(
              children: [
                const _Book(),
                const SizedBox(width: DmScales.iconGap),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.homeContinueQuran,
                        style: type.quranLabel.copyWith(color: r.inkMuted),
                      ),
                      const SizedBox(height: DmScales.lineGap),
                      Text(
                        title.join(' · '),
                        style: type.quranTitle.copyWith(color: r.ink),
                      ),
                      if (offline) ...[
                        const SizedBox(height: DmScales.lineGap),
                        Row(
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              size: DmScales.iconSmall,
                              color: r.inkMuted,
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                l.homeQuranOffline,
                                style: type.offline.copyWith(
                                  color: r.inkMuted,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: DmScales.iconGap),
                _Resume(label: l.homeQuranResume, style: type.resume),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// The surah's name from its Mushaf header, e.g. «الكَهۡفِ» from
  /// «سُورَةُ الكَهۡفِ»: the first word («سورة») dropped, marks kept.
  static String _nameOf(String header) {
    final cut = header.indexOf(' ');
    return cut < 0 ? header : header.substring(cut + 1).trim();
  }
}

/// A closed Mushaf: a forest-green tile with a gold bookmark.
final class _Book extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) => Container(
    width: 52,
    height: 64,
    decoration: BoxDecoration(
      color: RawdahPalette.forest,
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: RawdahPalette.gold.withValues(alpha: 0.6)),
    ),
    alignment: Alignment.topCenter,
    padding: const EdgeInsets.only(top: 8),
    child: const Icon(
      Icons.bookmark,
      size: DmScales.iconLarge,
      color: RawdahPalette.goldLight,
    ),
  );
}

/// The gold resume disc with its label under it; the arrow follows the
/// reading direction. The whole card is the tap target; this is its mark.
final class _Resume extends StatelessWidget {
  const new({required this.label, required this.style});

  final String label;
  final TextStyle style;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 52,
        height: 52,
        decoration: const BoxDecoration(
          color: RawdahPalette.gold,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.chevron_right,
          size: 30,
          color: RawdahPalette.emeraldDeep,
        ),
      ),
      const SizedBox(height: DmScales.lineGap),
      Text(label, style: style.copyWith(color: RawdahPalette.goldInk)),
    ],
  );
}
