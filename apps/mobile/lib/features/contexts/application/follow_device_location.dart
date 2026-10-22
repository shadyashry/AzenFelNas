import 'package:daily_muslim/features/contexts/application/locate_observer.dart';
import 'package:daily_muslim/features/contexts/domain/location_failure.dart';
import 'package:daily_muslim/features/contexts/domain/resolved_context.dart';
import 'package:dm_core_types/dm_core_types.dart';

/// The user switches from a pinned or manual place back to the device
/// location: the only way the active context stops being user-chosen.
final class FollowDeviceLocation {
  /// Follows through [_locate].
  const new(this._locate);

  final LocateObserver _locate;

  /// The refreshed `current` context, now active; pinned and manual rows stay
  /// stored unchanged for a later `SelectContext`.
  Future<Result<ResolvedContext, LocationFailure>> call() => _locate();
}
