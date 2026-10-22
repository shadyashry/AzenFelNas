import 'package:daily_muslim/features/contexts/application/resolve_place.dart';
import 'package:daily_muslim/features/contexts/domain/location_failure.dart';
import 'package:daily_muslim/features/contexts/domain/location_ports.dart';
import 'package:daily_muslim/features/contexts/domain/resolved_context.dart';
import 'package:dm_core_types/dm_core_types.dart';

/// The user picks a stored context (a pinned or manual place, or the last
/// current one) as the active context.
final class SelectContext {
  /// Selects through [_clock], [_write] and [_resolvePlace].
  const new(this._clock, this._write, this._resolvePlace);

  final Clock _clock;
  final WriteLocationContexts _write;
  final ResolvePlace _resolvePlace;

  /// Context [id], now active; its place is unchanged.
  Future<Result<ResolvedContext, LocationFailure>> call(int id) async {
    final used = await _write.markUsed(id, utcMs: _clock.nowUtcMs());
    return used.map(
      (context) => ResolvedContext(
        context: context,
        flags: _resolvePlace.flagsAt(context.place.point),
        stale: false,
      ),
    );
  }
}
