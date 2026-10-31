import 'package:daily_muslim/features/contexts/domain/gazetteer_hit.dart';
import 'package:daily_muslim/features/contexts/domain/resolved_context.dart';
import 'package:daily_muslim/features/contexts/presentation/manual_place_controller.dart';
import 'package:daily_muslim/features/onboarding/presentation/city_pick.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Drives [CityPick] (§15 D126): a tap selects a city, *Use this city*
/// pins it through the manual place search (`PinPlace`, REQ-PRIV-002).
/// A second confirm while one is stored is ignored.
final class CitySelection extends Notifier<CityPick> {
  @override
  CityPick build() => const CityPick();

  /// Selects [hit].
  void choose(GazetteerHit hit) {
    if (!state.saving) state = CityPick(hit: hit);
  }

  /// Pins the selected city; the new context, or `null` when none is
  /// selected, one is being stored, or pinning failed (the search shows
  /// why).
  Future<ResolvedContext?> confirm() async {
    final hit = state.hit;
    if (hit == null || state.saving) return null;
    state = CityPick(hit: hit, saving: true);
    final pinned = await ref.read(manualPlaceProvider.notifier).pickHit(hit);
    if (ref.mounted) state = CityPick(hit: hit);
    return pinned;
  }
}

/// The picker's selection; it ends with the picker.
final NotifierProvider<CitySelection, CityPick> citySelectionProvider =
    NotifierProvider.autoDispose<CitySelection, CityPick>(CitySelection.new);
