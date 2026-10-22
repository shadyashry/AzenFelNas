import 'package:daily_muslim/features/contexts/application/resolve_place.dart';
import 'package:daily_muslim/features/contexts/domain/context_kind.dart';
import 'package:daily_muslim/features/contexts/domain/context_place.dart';
import 'package:daily_muslim/features/contexts/domain/context_source.dart';
import 'package:daily_muslim/features/contexts/domain/location_failure.dart';
import 'package:daily_muslim/features/contexts/domain/location_ports.dart';
import 'package:daily_muslim/features/contexts/domain/place_choice.dart';
import 'package:daily_muslim/features/contexts/domain/resolved_context.dart';
import 'package:dm_core_types/dm_core_types.dart';

/// Keeps a place the user chose as a new active pinned or manual context
/// (§7.2 `PinPlace`); the resolver never replaces it (REQ-PRIV-002).
final class PinPlace {
  /// Pins through the given ports.
  const new({
    required this._clock,
    required this._read,
    required this._write,
    required this._resolvePlace,
  });

  final Clock _clock;
  final ReadLocationContexts _read;
  final WriteLocationContexts _write;
  final ResolvePlace _resolvePlace;

  /// The new context for [choice]. Pinning the current location fails with
  /// `LOC_UNAVAILABLE` while there is no current context.
  Future<Result<ResolvedContext, LocationFailure>> call(
    PlaceChoice choice,
  ) async {
    final now = _clock.nowUtcMs();
    switch (await _chosen(choice)) {
      case Err(:final failure):
        return Err(failure);
      case Ok(value: (final kind, final place, final source)):
        final added = await _write.addChosen(kind, place, source, utcMs: now);
        return added.map(
          (context) => ResolvedContext(
            context: context,
            flags: _resolvePlace.flagsAt(context.place.point),
            stale: false,
          ),
        );
    }
  }

  Future<Result<_Chosen, LocationFailure>> _chosen(PlaceChoice choice) async =>
      switch (choice) {
        GazetteerChoice(:final hit) => Ok((
          ChosenKind.manual,
          ContextPlace(
            point: hit.point,
            horizontalAccuracyM: null,
            zoneId: hit.zoneId,
            country: hit.country,
            label: hit.matchedName,
          ),
          ContextSource.gazetteer,
        )),
        TypedCoordinates(:final point, :final label) => Ok((
          ChosenKind.manual,
          _resolvePlace(point, horizontalAccuracyM: null, label: label).$1,
          ContextSource.typedCoordinates,
        )),
        PinCurrentLocation(:final label) => await _current(label),
      };

  Future<Result<_Chosen, LocationFailure>> _current(String label) async =>
      switch (await _read.current()) {
        Err(:final failure) => Err(failure),
        Ok(value: null) => const Err(
          LocationFailure.unavailable('no current context to pin'),
        ),
        Ok(value: final current?) => Ok((
          ChosenKind.pinned,
          ContextPlace(
            point: current.place.point,
            horizontalAccuracyM: current.place.horizontalAccuracyM,
            zoneId: current.place.zoneId,
            country: current.place.country,
            label: label,
          ),
          current.source,
        )),
      };
}

/// What `PinPlace` stores for a choice.
typedef _Chosen = (ChosenKind, ContextPlace, ContextSource);
