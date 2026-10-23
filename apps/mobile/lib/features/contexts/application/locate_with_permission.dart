import 'package:daily_muslim/features/contexts/application/locate_observer.dart';
import 'package:daily_muslim/features/contexts/domain/location_access.dart';
import 'package:daily_muslim/features/contexts/domain/location_failure.dart';
import 'package:daily_muslim/features/contexts/domain/location_ports.dart';
import 'package:daily_muslim/features/contexts/domain/resolved_context.dart';
import 'package:dm_core_types/dm_core_types.dart';

/// The first-run "use approximate location" action (§18.3): asks for
/// approximate access at the moment of need, then locates. A refusal is
/// `LOC_PERMISSION_DENIED`, which the caller turns into the manual-place
/// branch.
final class LocateWithPermission {
  /// Asks through [_access], then locates with [_locate].
  const new(this._access, this._locate);

  final RequestLocationAccess _access;
  final LocateObserver _locate;

  /// The device context, or why there is none.
  Future<Result<ResolvedContext, LocationFailure>> call() async =>
      switch (await _access.request()) {
        LocationAccess.granted => await _locate(),
        LocationAccess.denied ||
        LocationAccess.permanentlyDenied ||
        LocationAccess.restricted => const Err(
          LocationFailure.permissionDenied(),
        ),
      };
}
