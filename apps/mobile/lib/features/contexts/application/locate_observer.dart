import 'package:daily_muslim/features/contexts/application/resolve_place.dart';
import 'package:daily_muslim/features/contexts/domain/context_changed.dart';
import 'package:daily_muslim/features/contexts/domain/context_source.dart';
import 'package:daily_muslim/features/contexts/domain/location_context.dart';
import 'package:daily_muslim/features/contexts/domain/location_failure.dart';
import 'package:daily_muslim/features/contexts/domain/location_fix.dart';
import 'package:daily_muslim/features/contexts/domain/location_ports.dart';
import 'package:daily_muslim/features/contexts/domain/resolved_context.dart';
import 'package:dm_core_types/dm_core_types.dart';

/// The device-location chain of §7.5 that refreshes the `current` context:
/// fresh fix → last known fix (stale) → failure (manual-place prompt).
final class LocateObserver {
  /// Locates through the given ports.
  const new({
    required this._clock,
    required this._locator,
    required this._read,
    required this._write,
    required this._resolvePlace,
    required this._events,
  });

  final Clock _clock;
  final LocateDevice _locator;
  final ReadLocationContexts _read;
  final WriteLocationContexts _write;
  final ResolvePlace _resolvePlace;
  final RecordContextEvent _events;

  /// Coarsest accepted fix (ADR-014).
  static const maxAccuracyM = 5000.0;

  /// Oldest accepted fresh fix (ADR-014).
  static const freshAge = Duration(minutes: 15);

  /// Oldest accepted last known fix (§7.5).
  static const lastKnownAge = Duration(hours: 24);

  /// Stores the device location as the active `current` context. Pinned and
  /// manual contexts are never read or written here (REQ-PRIV-002).
  Future<Result<ResolvedContext, LocationFailure>> call() async {
    final now = _clock.nowUtcMs();
    final fresh = await _locator.currentFix();
    if (fresh case Ok(:final value) when _accepts(value, now, freshAge)) {
      return await _store(value, ContextSource.freshFix, now);
    }
    final lastKnown = await _locator.lastKnownFix();
    if (lastKnown case Ok(value: final fix?)
        when _accepts(fix, now, lastKnownAge)) {
      return await _store(fix, ContextSource.lastKnownFix, now);
    }
    return Err(switch (fresh) {
      Err(:final failure) => failure,
      Ok() => const LocationFailure.unavailable('no fix within limits'),
    });
  }

  static bool _accepts(LocationFix fix, int nowUtcMs, Duration maxAge) =>
      fix.horizontalAccuracyM <= maxAccuracyM &&
      nowUtcMs - fix.fixUtcMs <= maxAge.inMilliseconds;

  Future<Result<ResolvedContext, LocationFailure>> _store(
    LocationFix fix,
    ContextSource source,
    int now,
  ) async {
    final previous = switch (await _read.current()) {
      Ok(:final value) => value,
      Err() => null,
    };
    final (place, flags) = _resolvePlace(
      fix.point,
      horizontalAccuracyM: fix.horizontalAccuracyM,
      label: '',
    );
    final saved = await _write.saveCurrent(place, source, utcMs: now);
    if (saved case Ok(value: final context)) {
      await _record(fix, context, previous, now);
    }
    return saved.map(
      (context) => ResolvedContext(
        context: context,
        flags: flags,
        stale: source == ContextSource.lastKnownFix,
      ),
    );
  }

  /// Diagnostics only: a mock fix changes nothing else (§7.5). No coordinate
  /// reaches the event (REQ-PRIV-001).
  Future<void> _record(
    LocationFix fix,
    LocationContext context,
    LocationContext? previous,
    int now,
  ) async {
    ContextChanged event(ContextChangeReason reason) => ContextChanged(
      utcMs: now,
      reason: reason,
      zoneId: context.place.zoneId,
      country: context.place.country,
    );
    if (fix.isMock) {
      await _events.record(event(ContextChangeReason.mockLocation));
    }
    if (previous?.place.zoneId != context.place.zoneId ||
        previous?.place.country != context.place.country) {
      await _events.record(event(ContextChangeReason.resolver));
    }
  }
}
