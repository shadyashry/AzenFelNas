import 'dart:async';

import 'package:daily_muslim/features/contexts/application/context_use_cases.dart';
import 'package:daily_muslim/features/contexts/domain/gazetteer_hit.dart';
import 'package:daily_muslim/features/contexts/domain/place_choice.dart';
import 'package:daily_muslim/features/contexts/domain/resolved_context.dart';
import 'package:daily_muslim/features/contexts/presentation/manual_place_state.dart';
import 'package:daily_muslim/features/schedule/presentation/schedule_providers.dart';
import 'package:dm_civil_time/dm_civil_time.dart';
import 'package:dm_core_types/dm_core_types.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Drives [ManualPlaceState]: offline search (`SearchGazetteer`) and
/// pinning a hit or typed coordinates as a manual context (`PinPlace`,
/// REQ-PRIV-002).
final class ManualPlaceController extends Notifier<ManualPlaceState> {
  /// The pause after a keystroke before the query is searched (§15 D96).
  static const typingPause = Duration(milliseconds: 300);

  Timer? _typing;

  /// The query whose results may be shown; an older search's results are
  /// dropped.
  String _latest = '';

  /// The places of the phone's time zone, once loaded (§15 D100).
  List<GazetteerHit> _suggestions = const [];

  @override
  ManualPlaceState build() {
    ref.onDispose(() => _typing?.cancel());
    unawaited(_suggest());
    return const ManualPlaceIdle();
  }

  /// Loads the suggestions; a failure only leaves the list empty.
  Future<void> _suggest() async {
    final useCases = switch (await ref.read(contextUseCasesProvider.future)) {
      Ok(:final value) => value,
      Err() => null,
    };
    if (useCases == null || !ref.mounted) return;
    _suggestions = await useCases.suggest();
    if (ref.mounted && state is ManualPlaceIdle) {
      state = ManualPlaceIdle(suggestions: _suggestions);
    }
  }

  /// The search field changed: searches [query] once typing pauses.
  void queryChanged(String query) {
    _typing?.cancel();
    _typing = Timer(typingPause, () => unawaited(search(query)));
  }

  /// Searches for [query] now; a blank query returns to idle.
  Future<void> search(String query) async {
    _typing?.cancel();
    _latest = query;
    if (query.trim().isEmpty) {
      state = ManualPlaceIdle(suggestions: _suggestions);
      return;
    }
    state = const ManualPlaceSearching();
    final useCases = await _useCases();
    if (useCases == null) return;
    final found = await useCases.search(query);
    if (query != _latest) return;
    state = switch (found) {
      Ok(value: []) => const ManualPlaceEmpty(),
      Ok(:final value) => ManualPlaceResults(value),
      Err(:final failure) => ManualPlaceError(failure),
    };
  }

  /// The device's approximate location as the place (§15 D98): the one
  /// tap for users who do not want to search; a failure stays on screen
  /// with its fix.
  Future<ResolvedContext?> locateMe() async {
    _typing?.cancel();
    _latest = '';
    state = const ManualPlaceSearching();
    final useCases = await _useCases();
    if (useCases == null) return null;
    switch (await useCases.locate()) {
      case Ok(:final value):
        ref.invalidate(scheduleProvider);
        state = ManualPlaceIdle(suggestions: _suggestions);
        return value;
      case Err(:final failure):
        state = ManualPlaceError(failure);
        return null;
    }
  }

  /// Switches to coordinate entry.
  void enterCoordinates() => state = const ManualPlaceCoordinateEntry();

  /// Pins [hit]; the new context, or `null` after a failure (in [state]).
  Future<ResolvedContext?> pickHit(GazetteerHit hit) async =>
      await _pin(GazetteerChoice(hit));

  /// Pins typed coordinates; out-of-range numbers keep the entry open.
  Future<ResolvedContext?> pickCoordinates({
    required double? latitudeDeg,
    required double? longitudeDeg,
    required String label,
  }) async {
    if (latitudeDeg == null ||
        longitudeDeg == null ||
        latitudeDeg.abs() > 90 ||
        longitudeDeg.abs() > 180) {
      state = const ManualPlaceCoordinateEntry(invalid: true);
      return null;
    }
    return await _pin(
      TypedCoordinates(
        GeoPointE6.fromDegrees(latitudeDeg, longitudeDeg),
        label: label.trim(),
      ),
    );
  }

  Future<ResolvedContext?> _pin(PlaceChoice choice) async {
    final useCases = await _useCases();
    if (useCases == null) return null;
    switch (await useCases.pin(choice)) {
      case Ok(:final value):
        ref.invalidate(scheduleProvider);
        return value;
      case Err(:final failure):
        state = ManualPlaceError(failure);
        return null;
    }
  }

  Future<ContextUseCases?> _useCases() async {
    switch (await ref.read(contextUseCasesProvider.future)) {
      case Ok(:final value):
        return value;
      case Err(:final failure):
        state = ManualPlaceError(failure);
        return null;
    }
  }
}

/// The manual place screen's state.
final NotifierProvider<ManualPlaceController, ManualPlaceState>
manualPlaceProvider =
    NotifierProvider.autoDispose<ManualPlaceController, ManualPlaceState>(
      ManualPlaceController.new,
    );
