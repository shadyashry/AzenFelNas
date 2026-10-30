import 'package:daily_muslim/features/contexts/domain/gazetteer_hit.dart';
import 'package:daily_muslim/features/schedule/presentation/schedule_providers.dart';
import 'package:daily_muslim/features/travel/domain/travel_check.dart';
import 'package:daily_muslim/features/travel/presentation/travel_providers.dart';
import 'package:daily_muslim/l10n/app_localizations.dart';
import 'package:dm_core_types/dm_core_types.dart';
import 'package:dm_ui/dm_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';

/// "You seem to be in Oslo. Switch schedule?" (US-22, REQ-TRV-001): shown on
/// Home only when the check suggests it; switching follows the device
/// location, "Not now" keeps the chosen place (REQ-PRIV-002).
final class TravelBanner extends ConsumerWidget {
  /// The banner.
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dismissed = ref.watch(dismissedTravelProvider);
    return switch (ref.watch(travelCheckProvider)) {
      AsyncData(value: TravelSuggested(:final suggestion))
          when !dismissed.contains(suggestion) =>
        _Prompt(suggestion: suggestion),
      AsyncData() || AsyncError() || AsyncLoading() => const SizedBox.shrink(),
    };
  }
}

/// The city a zone is known by (§15 D101), or `null` while loading or when
/// the gazetteer has none.
final FutureProviderFamily<GazetteerHit?, String> _zoneCityProvider =
    FutureProvider.family<GazetteerHit?, String>((
      ref,
      zoneId,
    ) async {
      return switch (await ref.watch(contextUseCasesProvider.future)) {
        Ok(value: final useCases) => await useCases.nameZone(zoneId),
        Err() => null,
      };
    });

final class _Prompt extends ConsumerWidget {
  const new({required this.suggestion});

  final TravelSuggestion suggestion;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    // The zone's city in the reader's language, else the zone id's.
    final city =
        ref
            .watch(_zoneCityProvider(suggestion.toZoneId))
            .value
            ?.nameIn(Localizations.localeOf(context).languageCode) ??
        suggestion.toCity;
    // A rounded card like the other Home sections (§15 D102).
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: DmScales.gutter,
        vertical: 6,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(DmScales.radiusCard),
        child: MaterialBanner(
          content: Text(l.travelPrompt(city)),
          actions: [
            TextButton(
              onPressed: () => ref
                  .read(dismissedTravelProvider.notifier)
                  .dismiss(suggestion),
              child: Text(l.travelNotNow),
            ),
            TextButton(
              onPressed: () async {
                if (await ref.read(contextUseCasesProvider.future) case Ok(
                  value: final useCases,
                )) {
                  await useCases.follow();
                }
                ref
                  ..invalidate(scheduleProvider)
                  ..invalidate(travelCheckProvider);
              },
              child: Text(l.travelSwitch),
            ),
          ],
        ),
      ),
    );
  }
}
