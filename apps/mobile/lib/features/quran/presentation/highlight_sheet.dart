import 'package:daily_muslim/features/home/presentation/display_style.dart';
import 'package:daily_muslim/features/quran/domain/highlight.dart';
import 'package:daily_muslim/features/quran/domain/highlight_color.dart';
import 'package:daily_muslim/features/quran/presentation/mushaf_page_image.dart';
import 'package:daily_muslim/features/quran/presentation/quran_format.dart';
import 'package:daily_muslim/features/quran/presentation/quran_providers.dart';
import 'package:daily_muslim/features/schedule/presentation/schedule_providers.dart';
import 'package:daily_muslim/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The localised name of [color].
String highlightColorName(AppLocalizations l, HighlightColor color) =>
    switch (color) {
      HighlightColor.yellow => l.quranColorYellow,
      HighlightColor.green => l.quranColorGreen,
      HighlightColor.blue => l.quranColorBlue,
      HighlightColor.pink => l.quranColorPink,
      HighlightColor.orange => l.quranColorOrange,
    };

/// The pages a highlight covers, in words.
String highlightPages(
  AppLocalizations l,
  Highlight h,
  DisplayStyle style,
) => h.firstPage == h.lastPage
    ? l.quranPage(QuranFormat.number(h.firstPage, style))
    : l.quranHighlightPages(
        QuranFormat.number(h.firstPage, style),
        QuranFormat.number(h.lastPage, style),
      );

/// Edits [highlight]: another colour, or delete.
Future<void> showHighlightSheet(BuildContext context, Highlight highlight) =>
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => _HighlightSheet(highlight),
    );

final class _HighlightSheet extends ConsumerWidget {
  const new(this.highlight);

  final Highlight highlight;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final style = DisplayStyle.of(context, ref);
    final store = ref.read(highlightStoreProvider);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              highlightPages(l, highlight, style),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Text(l.quranHighlightColor),
            HighlightColorRow(
              selected: highlight.color,
              onSelected: (color) async {
                await store.recolorHighlight(
                  highlight.id,
                  color,
                  nowUtcMs: ref.read(clockProvider).nowUtcMs(),
                );
                if (context.mounted) Navigator.of(context).pop();
              },
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              icon: const Icon(Icons.delete_outline),
              label: Text(l.quranHighlightDelete),
              onPressed: () async {
                await store.deleteHighlight(highlight.id);
                if (context.mounted) Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// The five highlight colours as 48 dp swatches with names for screen
/// readers; the chosen one is ringed and checked, not marked by colour
/// alone.
final class HighlightColorRow extends StatelessWidget {
  /// The row with [selected] chosen.
  const new({required this.selected, required this.onSelected, super.key});

  /// The chosen colour.
  final HighlightColor selected;

  /// Called with the tapped colour.
  final ValueChanged<HighlightColor> onSelected;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final ink = Theme.of(context).colorScheme.onSurface;
    return Wrap(
      spacing: 4,
      children: [
        for (final color in HighlightColor.values)
          Semantics(
            button: true,
            selected: color == selected,
            label: highlightColorName(l, color),
            child: InkResponse(
              onTap: () => onSelected(color),
              radius: 26,
              child: SizedBox.square(
                dimension: 48,
                child: Center(
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: HighlightPainter.colorOf(color)
                          .withValues(alpha: 1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: color == selected
                            ? ink
                            : ink.withValues(alpha: 0.25),
                        width: color == selected ? 3 : 1,
                      ),
                    ),
                    child: color == selected
                        ? Icon(Icons.check, size: 18, color: ink)
                        : null,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
