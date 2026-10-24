import 'package:daily_muslim/features/schedule/presentation/schedule_providers.dart';
import 'package:daily_muslim/features/travel/domain/travel_check.dart';
import 'package:dm_core_types/dm_core_types.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Travel Mode's check, run each time Home opens (REQ-TRV-001).
final FutureProvider<TravelCheck> travelCheckProvider =
    FutureProvider.autoDispose<TravelCheck>((ref) async {
      switch (await ref.watch(contextUseCasesProvider.future)) {
        case Err():
          return const TravelUnknown();
        case Ok(value: final useCases):
          return await useCases.travel();
      }
    });

/// The suggestions the user answered "Not now" this session; asked again on
/// the next launch or for another zone (§15 D88).
final NotifierProvider<DismissedTravel, Set<TravelSuggestion>>
dismissedTravelProvider =
    NotifierProvider<DismissedTravel, Set<TravelSuggestion>>(
      DismissedTravel.new,
    );

/// See [dismissedTravelProvider].
final class DismissedTravel extends Notifier<Set<TravelSuggestion>> {
  @override
  Set<TravelSuggestion> build() => const {};

  /// Stops asking [suggestion] in this session.
  void dismiss(TravelSuggestion suggestion) => state = {...state, suggestion};
}
