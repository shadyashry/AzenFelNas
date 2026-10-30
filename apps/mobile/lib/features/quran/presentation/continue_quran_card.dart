import 'package:daily_muslim/features/home/presentation/display_style.dart';
import 'package:daily_muslim/features/quran/domain/mushaf_index_entries.dart';
import 'package:daily_muslim/features/quran/domain/quran_package_status.dart';
import 'package:daily_muslim/features/quran/presentation/quran_format.dart';
import 'package:daily_muslim/features/quran/presentation/quran_providers.dart';
import 'package:daily_muslim/features/shell/domain/app_route.dart';
import 'package:daily_muslim/l10n/app_localizations.dart';
import 'package:dm_ui/dm_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Home's "Continue Quran" (§15 D108): the surah, as printed in the
/// Mushaf's header and in the package's own KFGQPC font, and the page the
/// reader was last left on, with a gold resume button that opens the
/// reader there (it restores its last page). Shown only when there is a
/// saved page and the downloaded Quran is readable; "Ready offline" only
/// when the package checked complete (`QuranReady`). Nothing of the Mushaf
/// page itself is drawn here.
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
    final r = RawdahScheme.of(context);
    final suras = ref.watch(surasProvider).value ?? const <SuraEntry>[];
    SuraEntry? sura;
    for (final s in suras) {
      if (s.startPage <= page) sura = s;
    }
    final font = ref.watch(quranFontProvider).value ?? false;
    final pageText = l.quranPage(QuranFormat.number(page, style));
    final offline = status is QuranReady;
    void open() => context.go(const QuranRoute().location);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DmScales.gutter),
      child: Semantics(
        button: true,
        label: [
          l.homeContinueQuran,
          ?sura?.header,
          pageText,
          if (offline) l.quranReadyOffline,
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
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const _Book(),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l.homeContinueQuran,
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(color: r.inkMuted, fontSize: 14),
                        ),
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 8,
                          children: [
                            if (sura != null)
                              Text(
                                sura.header,
                                textDirection: TextDirection.rtl,
                                style: TextStyle(
                                  fontFamily: font ? QuranFont.family : null,
                                  fontSize: 21,
                                  color: r.ink,
                                ),
                              ),
                            if (sura != null)
                              Text(
                                '·',
                                style: DmTheme.naskh(size: 20, color: r.ink),
                              ),
                            Text(
                              pageText,
                              style: DmTheme.naskh(size: 20, color: r.ink),
                            ),
                          ],
                        ),
                        if (offline)
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 6,
                            children: [
                              Icon(
                                Icons.check_circle,
                                size: DmScales.iconSmall,
                                color: r.primary,
                              ),
                              Text(
                                l.quranReadyOffline,
                                style: Theme.of(context).textTheme.labelMedium,
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _Resume(label: l.homeQuranResume, onTap: open),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A closed Mushaf: a forest-green tile with a gold bookmark.
final class _Book extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) => Container(
    width: 46,
    height: 56,
    decoration: BoxDecoration(
      color: RawdahPalette.forest,
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: RawdahPalette.gold.withValues(alpha: 0.6)),
    ),
    alignment: Alignment.topCenter,
    padding: const EdgeInsets.only(top: 6),
    child: const Icon(
      Icons.bookmark,
      size: DmScales.iconMedium,
      color: RawdahPalette.goldLight,
    ),
  );
}

/// The gold resume button; the chevron mirrors with the text direction.
final class _Resume extends StatelessWidget {
  const new({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => IconButton(
    onPressed: onTap,
    tooltip: label,
    style: IconButton.styleFrom(
      backgroundColor: RawdahPalette.gold,
      foregroundColor: RawdahPalette.emeraldDeep,
      minimumSize: const Size(52, 52),
    ),
    icon: const Icon(Icons.chevron_right, size: 30),
  );
}
