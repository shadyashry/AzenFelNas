import 'dart:async';

import 'package:daily_muslim/features/home/presentation/display_style.dart';
import 'package:daily_muslim/features/quran/domain/mushaf_index_entries.dart';
import 'package:daily_muslim/features/quran/domain/surah_scope.dart';
import 'package:daily_muslim/features/quran/presentation/quran_format.dart';
import 'package:daily_muslim/features/quran/presentation/reader_controller.dart';
import 'package:daily_muslim/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A slider over the chosen surah's own pages (§15 D120, D121, D123,
/// REQ-QRN-024), first page on the right as in the Mushaf in both
/// interface languages, so the gold part grows from the right as the
/// reader advances. Dragging previews the page number; the page opens on
/// release, so the pages in between are never loaded.
final class SurahSlider extends ConsumerStatefulWidget {
  /// The slider over [scope]'s pages, in [active] and [inactive].
  const new({
    required this.scope,
    required this.active,
    required this.inactive,
    super.key,
  });

  /// The surah and the current page's place in it.
  final SurahScope scope;

  /// The track the reader has read through, and the handle.
  final Color active;

  /// The rest of the track.
  final Color inactive;

  @override
  ConsumerState<SurahSlider> createState() => _SurahSliderState();
}

final class _SurahSliderState extends ConsumerState<SurahSlider> {
  double? _drag;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final style = DisplayStyle.of(context, ref);
    final scope = widget.scope;
    String label(double v) => l.quranPage(QuranFormat.number(v.round(), style));
    final value = (_drag ?? scope.page.toDouble())
        .clamp(scope.first, scope.last)
        .toDouble();
    return Directionality(
      textDirection: TextDirection.rtl,
      child: SliderTheme(
        data: SliderTheme.of(context).copyWith(
          trackHeight: 6,
          activeTrackColor: widget.active,
          inactiveTrackColor: widget.inactive,
          thumbColor: widget.active,
          overlayColor: widget.active.withValues(alpha: 0.16),
          valueIndicatorColor: widget.active,
          inactiveTickMarkColor: Colors.transparent,
          activeTickMarkColor: Colors.transparent,
        ),
        child: Slider(
          value: value,
          min: scope.first.toDouble(),
          max: scope.last.toDouble(),
          divisions: scope.count - 1,
          label: label(value),
          semanticFormatterCallback: label,
          onChanged: (v) => setState(() => _drag = v),
          onChangeEnd: (v) {
            setState(() => _drag = null);
            ref.read(readerProvider.notifier).goTo(v.round());
          },
        ),
      ),
    );
  }
}

/// The surah after the scope's when the current page is its last, so the
/// reader's *Next page* becomes *Continue to* it; `null` otherwise.
SuraEntry? continueAfter(SurahScope? scope, List<SuraEntry> suras) {
  if (scope == null || !scope.atEnd) return null;
  for (final s in suras) {
    if (s.number == scope.sura.number + 1) return s;
  }
  return null;
}

/// Opens the first verse of [sura] with its lines outlined; it becomes the
/// navigator's surah even when it starts on the page already shown.
void openSurah(WidgetRef ref, SuraEntry sura) => unawaited(
  ref
      .read(readerProvider.notifier)
      .showVerseAt(sura.number, 1, fallbackPage: sura.startPage),
);
