import 'dart:io';

import 'package:daily_muslim/features/home/presentation/display_style.dart';
import 'package:daily_muslim/features/quran/domain/installed_quran.dart';
import 'package:daily_muslim/features/quran/domain/mushaf_index_entries.dart';
import 'package:daily_muslim/features/quran/domain/quran_package_status.dart';
import 'package:daily_muslim/features/quran/presentation/quran_format.dart';
import 'package:daily_muslim/features/quran/presentation/quran_providers.dart';
import 'package:daily_muslim/features/quran/presentation/reader_controller.dart';
import 'package:daily_muslim/l10n/app_localizations.dart';
import 'package:dm_ui/dm_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The pages of the surah being read, as small images of the official
/// pages in Mushaf order (right to left), with a slider along them
/// (§15 D113). It opens on [page], marked; a tap opens a page.
/// [onGoToPage] offers typing any page number instead.
Future<void> showSurahPagesSheet(
  BuildContext context, {
  required SuraEntry sura,
  required int page,
  required VoidCallback onGoToPage,
}) => showModalBottomSheet<void>(
  context: context,
  showDragHandle: true,
  isScrollControlled: true,
  builder: (context) =>
      _SurahPages(sura: sura, page: page, onGoToPage: onGoToPage),
);

final class _SurahPages extends ConsumerStatefulWidget {
  const new({
    required this.sura,
    required this.page,
    required this.onGoToPage,
  });

  final SuraEntry sura;
  final int page;
  final VoidCallback onGoToPage;

  @override
  ConsumerState<_SurahPages> createState() => _SurahPagesState();
}

final class _SurahPagesState extends ConsumerState<_SurahPages> {
  static const double _thumbWidth = 96;
  static const double _gap = 12;
  static const double _extent = _thumbWidth + _gap;

  late int _focus = widget.page;
  ScrollController? _strip;
  double _viewport = 0;

  @override
  void dispose() {
    _strip?.dispose();
    super.dispose();
  }

  /// The strip offset that centres page [index] (0 = the surah's first).
  double _centre(int index) =>
      (index * _extent - (_viewport - _extent) / 2).clamp(0, double.infinity);

  void _open(int page) {
    ref.read(readerProvider.notifier).goTo(page);
    Navigator.of(context).pop();
  }

  void _slide(double value, int first) {
    setState(() => _focus = value.round());
    final strip = _strip;
    if (strip == null || !strip.hasClients) return;
    strip.jumpTo(
      _centre(_focus - first).clamp(0, strip.position.maxScrollExtent),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final style = DisplayStyle.of(context, ref);
    final theme = Theme.of(context);
    final range = ref.watch(surahPagesProvider(widget.sura.number)).value;
    final installed = readablePackage(ref.watch(quranStatusProvider));
    if (range == null || installed == null) {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    final (:first, :last) = range;
    final count = last - first + 1;
    final image = installed.manifest.pageImage;
    final thumbHeight = _thumbWidth * image.height / image.width;
    String n(int v) => QuranFormat.number(v, style);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                l.quranSurahPages(
                  QuranFormat.surahName(widget.sura, style),
                  n(first),
                  n(last),
                ),
                style: theme.textTheme.titleMedium,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
              child: Text(
                l.quranSurahPagesHint,
                style: theme.textTheme.bodySmall,
              ),
            ),
            // The Mushaf runs right to left in either interface language.
            Directionality(
              textDirection: TextDirection.rtl,
              child: SizedBox(
                height:
                    thumbHeight +
                    16 +
                    MediaQuery.textScalerOf(context).scale(20),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    _viewport = constraints.maxWidth;
                    final strip = _strip ??= ScrollController(
                      initialScrollOffset: _centre(widget.page - first),
                    );
                    return ListView.builder(
                      controller: strip,
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: _gap),
                      itemExtent: _extent,
                      itemCount: count,
                      itemBuilder: (context, i) => _Thumb(
                        installed: installed,
                        page: first + i,
                        label: n(first + i),
                        current: first + i == widget.page,
                        focused: first + i == _focus,
                        width: _thumbWidth,
                        height: thumbHeight,
                        onTap: () => _open(first + i),
                      ),
                    );
                  },
                ),
              ),
            ),
            if (count > 1)
              Directionality(
                textDirection: TextDirection.rtl,
                child: Slider(
                  value: _focus.clamp(first, last).toDouble(),
                  min: first.toDouble(),
                  max: last.toDouble(),
                  divisions: count - 1,
                  label: l.quranPage(n(_focus)),
                  semanticFormatterCallback: (v) => l.quranPage(n(v.round())),
                  onChanged: (v) => _slide(v, first),
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  TextButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      widget.onGoToPage();
                    },
                    icon: const Icon(Icons.dialpad),
                    label: Text(l.quranGoToPage),
                  ),
                  const Spacer(),
                  FilledButton(
                    onPressed: _focus == widget.page
                        ? null
                        : () => _open(_focus),
                    child: Text(l.quranPage(n(_focus))),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One page of the strip: the official page image, small, and its number.
final class _Thumb extends StatelessWidget {
  const new({
    required this.installed,
    required this.page,
    required this.label,
    required this.current,
    required this.focused,
    required this.width,
    required this.height,
    required this.onTap,
  });

  final InstalledQuran installed;
  final int page;
  final String label;
  final bool current;
  final bool focused;
  final double width;
  final double height;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = RawdahScheme.of(context);
    final l = AppLocalizations.of(context);
    final dpr = MediaQuery.devicePixelRatioOf(context);
    return Semantics(
      button: true,
      selected: current,
      label: l.quranPage(label),
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          child: Column(
            children: [
              DecoratedBox(
                position: DecorationPosition.foreground,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: current
                        ? scheme.accent
                        : focused
                        ? scheme.primary
                        : scheme.hairline,
                    width: current || focused ? 3 : 1,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: SizedBox(
                  width: width,
                  height: height,
                  child: Image(
                    image: ResizeImage(
                      FileImage(File(installed.pagePath(page))),
                      width: (width * dpr).round(),
                    ),
                    fit: BoxFit.contain,
                    gaplessPlayback: true,
                    errorBuilder: (context, error, stack) =>
                        ColoredBox(color: scheme.wash),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: current ? scheme.accent : null,
                  fontWeight: current ? FontWeight.w700 : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
