import 'package:drift/drift.dart';

part 'places_database.g.dart';

/// The `location_contexts` table of §7.3 (`places.sqlite`, excluded from
/// backup — REQ-PRIV-003, S16).
@DataClassName('LocationContextRow')
class LocationContexts extends Table {
  /// Row id.
  IntColumn get id => integer().autoIncrement()();

  /// `ContextKind.wire`.
  TextColumn get kind => text()();

  /// Latitude in degrees (micro-degree precision).
  RealColumn get lat => real()();

  /// Longitude in degrees (micro-degree precision).
  RealColumn get lon => real()();

  /// Horizontal accuracy in metres; null for a gazetteer or typed place.
  RealColumn get hAccM => real().named('h_acc_m').nullable()();

  /// IANA zone id.
  TextColumn get zoneId => text()();

  /// ISO 3166-1 alpha-2 code; null when no country resolves.
  TextColumn get country => text().nullable()();

  /// `ContextSource.wire`.
  TextColumn get source => text()();

  /// Whether the user chose the context (kind pinned or manual).
  BoolColumn get pinned => boolean()();

  /// User-facing name.
  TextColumn get label => text()();

  /// First write (UTC epoch ms).
  IntColumn get createdUtc => integer()();

  /// Last selection or refresh (UTC epoch ms); the largest is active.
  IntColumn get lastUsedUtc => integer()();
}

/// The location tables on their own database until the app shell (S16)
/// opens `places.sqlite` with drift_flutter (§15 D73).
@DriftDatabase(tables: [LocationContexts])
final class PlacesDatabase extends _$PlacesDatabase {
  /// The database on [executor].
  new(super.e);

  @override
  int get schemaVersion => 1;
}
