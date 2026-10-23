import 'package:daily_muslim/features/contexts/domain/context_kind.dart';
import 'package:daily_muslim/features/contexts/domain/resolved_context.dart';
import 'package:geo_salah_core/geo_salah_core.dart';

/// The engine [Observer] at a resolved context's place.
abstract final class ObserverOf {
  /// The observer of [resolved]: its point, zone and kind as the source.
  static Observer context(ResolvedContext resolved) {
    final context = resolved.context;
    return Observer(
      latitudeDeg: context.place.point.latE6 / 1e6,
      longitudeDeg: context.place.point.lonE6 / 1e6,
      zoneId: context.place.zoneId,
      source: switch (context.kind) {
        ContextKind.current => ObserverSource.device,
        ContextKind.pinned => ObserverSource.pinned,
        ContextKind.manual => ObserverSource.manual,
      },
      horizontalAccuracyM: context.place.horizontalAccuracyM,
    );
  }
}
