import 'package:daily_muslim/features/contexts/application/locate_with_permission.dart';
import 'package:daily_muslim/features/contexts/application/pin_place.dart';
import 'package:daily_muslim/features/contexts/application/resolve_observer_context.dart';
import 'package:daily_muslim/features/contexts/application/search_gazetteer.dart';
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
  });

  /// First-run approximate location (asks for access).
  final LocateWithPermission locate;

  /// The active context for the next calculation.
  final ResolveObserverContext resolve;

  /// Keeps a chosen place.
  final PinPlace pin;

  /// Offline place search.
  final SearchGazetteer search;
}
