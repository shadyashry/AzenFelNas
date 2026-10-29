import 'package:daily_muslim/features/home/presentation/display_style.dart';
import 'package:daily_muslim/features/qibla/domain/shadow_times.dart';
import 'package:daily_muslim/features/qibla/presentation/qibla_providers.dart';
import 'package:daily_muslim/l10n/app_localizations.dart';
import 'package:dm_ui/dm_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geo_salah_core/geo_salah_core.dart';

/// The sensor-free Qibla on the Qibla screen (§6.6, REQ-DOM-031, §15 D91):
/// the times when a stick's shadow lies on the Qibla line, which end of the
/// shadow points to the Qibla, and how long each lasts. Nothing near the
/// Kaaba, while loading, or without a place.
final class ShadowTimesSection extends ConsumerWidget {
  /// Creates the section.
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final digits = DisplayStyle.of(context, ref).digits;
    final rows = switch (ref.watch(shadowTimesProvider)) {
      AsyncData(
        value: ShadowTimesFound(:final date, :final isToday, :final times),
      ) =>
        [
          if (!isToday)
            _Note(
              l.qiblaShadowNextDay(
                digits.apply(
                  MaterialLocalizations.of(
                    context,
                  ).formatFullDate(
                    DateTime.utc(date.year, date.month, date.day),
                  ),
                ),
              ),
            ),
          for (final time in times) _ShadowRow(time: time, digits: digits),
        ],
      AsyncData(value: ShadowTimesNone()) => [_Note(l.qiblaShadowNone)],
      AsyncData(value: ShadowTimesNearKaaba() || null) ||
      AsyncError() ||
      AsyncLoading() => const <Widget>[],
    };
    if (rows.isEmpty) return const SizedBox.shrink();
    return RawdahSection(
      title: l.qiblaShadowTitle,
      footnote: l.qiblaShadowFootnote,
      padding: const EdgeInsets.only(top: 24),
      children: rows,
    );
  }
}

final class _Note extends StatelessWidget {
  const new(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
  );
}

final class _ShadowRow extends StatelessWidget {
  const new({required this.time, required this.digits});

  final ShadowTime time;
  final DigitStyle digits;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = RawdahScheme.of(context);
    final muted = theme.textTheme.bodySmall?.copyWith(color: scheme.inkMuted);
    final difficulty = switch (time.hardToUse) {
      ShadowDifficulty.highSun => l.qiblaShadowHighSun,
      ShadowDifficulty.briefWindow => l.qiblaShadowBriefWindow,
      null => null,
    };
    return MergeSemantics(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Icon(
                switch (time.kind) {
                  QiblaSunAlignmentKind.sunTowardQibla =>
                    Icons.wb_sunny_outlined,
                  QiblaSunAlignmentKind.sunAwayFromQibla =>
                    Icons.flare_outlined,
                },
                color: time.passed ? scheme.inkMuted : scheme.accent,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 10,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        digits.apply(time.localTime),
                        style: DmTheme.naskh(
                          size: 26,
                          color: time.passed ? scheme.inkMuted : scheme.primary,
                          bold: true,
                        ),
                      ),
                      if (time.passed) Text(l.qiblaShadowPassed, style: muted),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    switch (time.kind) {
                      QiblaSunAlignmentKind.sunTowardQibla =>
                        l.qiblaShadowToward,
                      QiblaSunAlignmentKind.sunAwayFromQibla =>
                        l.qiblaShadowAway,
                    },
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l.qiblaShadowWindow(
                      digits.apply(time.windowStart),
                      digits.apply(time.windowEnd),
                    ),
                    style: muted,
                  ),
                  if (difficulty != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        difficulty,
                        style: muted?.copyWith(fontWeight: FontWeight.w600),
                      ),
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
