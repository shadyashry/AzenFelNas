import 'package:daily_muslim/features/contexts/application/resolve_place.dart';
import 'package:daily_muslim/features/contexts/domain/location_context.dart';
import 'package:daily_muslim/features/contexts/domain/location_fix.dart';
import 'package:daily_muslim/features/contexts/domain/location_ports.dart';
import 'package:daily_muslim/features/travel/domain/travel_check.dart';
import 'package:dm_core_types/dm_core_types.dart';

/// Travel Mode's check (§7.2 `travel`, US-22, REQ-TRV-001), run when the app
/// opens or the platform reports a zone change: compares the zone of the
/// platform's cached fix with the active pinned or manual context. It never
/// requests a new fix, never runs in the background and never changes a
/// context; switching is the user's call (`FollowDeviceLocation`).
final class HandleZoneChange {
  /// Checks through [_contexts], [_device] and [_resolvePlace] at [_clock].
  const new(this._contexts, this._device, this._resolvePlace, this._clock);

  final ReadLocationContexts _contexts;
  final LocateDevice _device;
  final ResolvePlace _resolvePlace;
  final Clock _clock;

  /// A cached fix older than this says nothing about where the device is now
  /// (§15 D88).
  static const int maxFixAgeMs = 6 * 3600000;

  /// What to ask, if anything.
  Future<TravelCheck> call() async {
    switch (await _contexts.active()) {
      case Err() || Ok(value: null):
        return const TravelUnknown();
      case Ok(value: final context?) when !context.kind.isUserChosen:
        return const TravelNoChange();
      case Ok(value: final context?):
        return _compare(context, await _device.lastKnownFix());
    }
  }

  TravelCheck _compare(
    LocationContext context,
    Result<LocationFix?, Failure> cached,
  ) {
    switch (cached) {
      case Err() || Ok(value: null):
        return const TravelUnknown();
      case Ok(value: final fix?)
          when fix.isMock || _clock.nowUtcMs() - fix.fixUtcMs > maxFixAgeMs:
        return const TravelUnknown();
      case Ok(value: final fix?):
        final (place, _) = _resolvePlace(
          fix.point,
          horizontalAccuracyM: fix.horizontalAccuracyM,
          label: '',
        );
        if (place.zoneId == context.place.zoneId) {
          return const TravelNoChange();
        }
        return TravelSuggested(
          TravelSuggestion(
            contextId: context.id,
            fromLabel: context.place.label,
            fromZoneId: context.place.zoneId,
            toZoneId: place.zoneId,
            toCountry: place.country,
          ),
        );
    }
  }
}
