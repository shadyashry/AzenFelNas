import 'package:daily_muslim/features/home/domain/fasting_day.dart';
import 'package:daily_muslim/features/home/presentation/display_style.dart';
import 'package:daily_muslim/features/home/presentation/home_providers.dart';
import 'package:daily_muslim/features/home/presentation/time_rows.dart';
import 'package:daily_muslim/features/schedule/presentation/schedule_providers.dart';
import 'package:daily_muslim/features/settings/domain/app_settings.dart';
import 'package:daily_muslim/features/settings/presentation/settings_providers.dart';
import 'package:daily_muslim/l10n/app_localizations.dart';
import 'package:dm_ui/dm_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geo_salah_core/geo_salah_core.dart';

/// Home's Ramadan card (US-07, US-23, REQ-RAM-001): the fasting window, the
/// Hijri confidence (Expected is said; Confirmed needs no badge) and the
/// one-tap ±1 day override. Outside Ramadan it takes no space.
final class FastingCard extends ConsumerWidget {
  /// The card.
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final style = DisplayStyle.of(context, ref);
    return switch (ref.watch(fastingDayProvider)) {
      NotFasting() => const SizedBox.shrink(),
      FastingUnknown(:final ramadan) => _Card(
        ramadan: ramadan,
        lines: [l.homeFastingUnknown],
      ),
      FastingWindow(:final ramadan, :final begins, :final ends, :final imsak) =>
        _Card(
          ramadan: ramadan,
          lines: [
            style.digits.apply(
              l.homeFastingWindow(
                TimeRows.timeText(l, begins),
                TimeRows.timeText(l, ends),
              ),
            ),
            if (imsak != null)
              style.digits.apply(
                l.homeFastingImsak(TimeRows.timeText(l, imsak)),
              ),
          ],
        ),
    };
  }
}

final class _Card extends ConsumerWidget {
  const new({required this.ramadan, required this.lines});

  final RamadanDate ramadan;
  final List<String> lines;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final style = DisplayStyle.of(context, ref);
    final badge = switch (ramadan.confidence) {
      HijriConfidence.confirmed => null,
      HijriConfidence.expected => StatusCopy.expectedHijri(style.locale),
      HijriConfidence.userOverride => l.homeHijriOverrideApplied,
    };
    return Card(
      margin: const EdgeInsetsDirectional.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              style.digits.apply(l.homeFastingTitle(ramadan.day)),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (badge != null) Text(badge),
            for (final line in lines) Text(line),
            const _HijriOverride(),
          ],
        ),
      ),
    );
  }
}

/// The ±1 day override (`hijriOverrideDays`, ADR-016); the schedule is
/// recalculated with it, so Ramadan rules and the card follow at once.
final class _HijriOverride extends ConsumerWidget {
  const new();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final current = switch (ref.watch(hijriOverrideSettingProvider)) {
      AsyncData(:final value) => value,
      _ => 0,
    };
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8,
      children: [
        Text(l.homeHijriOverride),
        SegmentedButton<int>(
          segments: const [
            ButtonSegment(value: -1, label: Text('−1')),
            ButtonSegment(value: 0, label: Text('0')),
            ButtonSegment(value: 1, label: Text('+1')),
          ],
          selected: {current},
          onSelectionChanged: (choice) async {
            await ref
                .read(writeSettingProvider)
                .write(AppSettings.hijriOverrideDays, choice.single);
            ref.invalidate(scheduleProvider);
          },
        ),
      ],
    );
  }
}
