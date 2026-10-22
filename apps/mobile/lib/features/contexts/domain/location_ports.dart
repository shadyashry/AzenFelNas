import 'package:daily_muslim/features/contexts/domain/context_changed.dart';
import 'package:daily_muslim/features/contexts/domain/context_kind.dart';
import 'package:daily_muslim/features/contexts/domain/context_place.dart';
import 'package:daily_muslim/features/contexts/domain/context_source.dart';
import 'package:daily_muslim/features/contexts/domain/location_access.dart';
import 'package:daily_muslim/features/contexts/domain/location_context.dart';
import 'package:daily_muslim/features/contexts/domain/location_failure.dart';
import 'package:daily_muslim/features/contexts/domain/location_fix.dart';
import 'package:dm_core_types/dm_core_types.dart';

/// Device location (port of `ResolveObserverContext`; adapter:
/// `GeolocatorDeviceLocator`). Approximate accuracy only (ADR-014).
abstract interface class LocateDevice {
  /// A new fix, or why there is none: services off, permission denied, or
  /// unavailable (timeout, no provider). Never prompts for permission.
  Future<Result<LocationFix, LocationFailure>> currentFix();

  /// The platform's cached fix, `Ok(null)` when it has none. Fails like
  /// [currentFix] only when the platform refuses to answer.
  Future<Result<LocationFix?, LocationFailure>> lastKnownFix();
}

/// Location permission (adapter: `PermissionHandlerLocationAccess`).
abstract interface class RequestLocationAccess {
  /// Asks the OS for approximate location access when it may still ask, and
  /// returns the resulting state; asking again after a grant is a no-op.
  Future<LocationAccess> request();
}

/// Reads stored location contexts (adapter: `DriftLocationContextStore`).
abstract interface class ReadLocationContexts {
  /// The context used last, `Ok(null)` when there is none.
  Future<Result<LocationContext?, LocationFailure>> active();

  /// The one `current` context, `Ok(null)` when the resolver never stored one.
  Future<Result<LocationContext?, LocationFailure>> current();
}

/// Writes stored location contexts (adapter: `DriftLocationContextStore`).
/// No method changes the place of a pinned or manual row (REQ-PRIV-002).
abstract interface class WriteLocationContexts {
  /// Creates or replaces the single `current` row with [place] from [source]
  /// and makes it active at [utcMs]; other rows are untouched.
  Future<Result<LocationContext, LocationFailure>> saveCurrent(
    ContextPlace place,
    ContextSource source, {
    required int utcMs,
  });

  /// Adds a new context of [kind] at [place], active from [utcMs].
  Future<Result<LocationContext, LocationFailure>> addChosen(
    ChosenKind kind,
    ContextPlace place,
    ContextSource source, {
    required int utcMs,
  });

  /// Makes context [id] active at [utcMs]; only `lastUsedUtcMs` changes.
  /// Fails with `LOC_UNAVAILABLE` when [id] does not exist.
  Future<Result<LocationContext, LocationFailure>> markUsed(
    int id, {
    required int utcMs,
  });
}

/// The resolver's diagnostics (§9.6): `EventLogContextEvents` maps them to
/// Appendix J entries; the drift ring buffer arrives with the app shell (S16).
abstract interface class RecordContextEvent {
  /// Records [event]; never throws and never changes the caller's outcome.
  Future<void> record(ContextChanged event);
}
