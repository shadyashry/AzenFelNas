import 'package:daily_muslim/features/contexts/application/locate_observer.dart';
import 'package:daily_muslim/features/contexts/application/resolve_place.dart';
import 'package:daily_muslim/features/contexts/domain/location_failure.dart';
import 'package:daily_muslim/features/contexts/domain/location_ports.dart';
import 'package:daily_muslim/features/contexts/domain/resolved_context.dart';
import 'package:dm_core_types/dm_core_types.dart';

/// The observer context for the next calculation (§7.2, §7.5): a pinned or
/// manual active context as it is, otherwise the refreshed device location.
final class ResolveObserverContext {
  /// Resolves through [_read], [_locate] and [_resolvePlace].
  const new(this._read, this._locate, this._resolvePlace);

  final ReadLocationContexts _read;
  final LocateObserver _locate;
  final ResolvePlace _resolvePlace;

  /// The active context. A pinned or manual one is never replaced and its
  /// zone and country are never re-resolved (ADR-014, REQ-PRIV-002); a
  /// failure means "ask for a manual place".
  Future<Result<ResolvedContext, LocationFailure>> call() async {
    switch (await _read.active()) {
      case Err(:final failure):
        return Err(failure);
      case Ok(value: final context?) when context.kind.isUserChosen:
        return Ok(
          ResolvedContext(
            context: context,
            flags: _resolvePlace.flagsAt(context.place.point),
            stale: false,
          ),
        );
      case Ok():
        return await _locate();
    }
  }
}
