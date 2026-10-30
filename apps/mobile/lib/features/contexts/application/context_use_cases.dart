import 'package:daily_muslim/features/contexts/application/follow_device_location.dart';
import 'package:daily_muslim/features/contexts/application/locate_with_permission.dart';
import 'package:daily_muslim/features/contexts/application/name_nearest_place.dart';
import 'package:daily_muslim/features/contexts/application/name_zone.dart';
import 'package:daily_muslim/features/contexts/application/pin_place.dart';
import 'package:daily_muslim/features/contexts/application/resolve_observer_context.dart';
import 'package:daily_muslim/features/contexts/application/search_gazetteer.dart';
import 'package:daily_muslim/features/contexts/application/suggest_places.dart';
import 'package:daily_muslim/features/travel/application/handle_zone_change.dart';
import 'package:meta/meta.dart';

/// The location use cases the screens call once the runtime data that
/// `ResolvePlace` needs is loaded. Built in `app/di.dart` only.
@immutable
final class ContextUseCases {
  /// The use cases.
  const new({
    required this.locate,
    required this.resolve,
    required this.pin,
    required this.search,
    required this.travel,
    required this.follow,
    required this.suggest,
    required this.nameNearest,
    required this.nameZone,
  });

  /// First-run approximate location (asks for access).
  final LocateWithPermission locate;

  /// The active context for the next calculation.
  final ResolveObserverContext resolve;

  /// Keeps a chosen place.
  final PinPlace pin;

  /// Offline place search.
  final SearchGazetteer search;

  /// Travel Mode's on-open check (REQ-TRV-001).
  final HandleZoneChange travel;

  /// Leaves a pinned or manual place for the device location, after the
  /// user confirmed (REQ-PRIV-002).
  final FollowDeviceLocation follow;

  /// Places to tap before anything is typed (§15 D100).
  final SuggestPlaces suggest;

  /// The name of the place a fix is in, for the screen (§15 D100).
  final NameNearestPlace nameNearest;

  /// The city a zone is known by, for the screen (§15 D101).
  final NameZone nameZone;
}
