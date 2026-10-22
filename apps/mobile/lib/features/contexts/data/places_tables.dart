import 'package:drift/drift.dart';

/// The `location_contexts` table of §7.3 (`places.sqlite`, excluded from
/// backup — REQ-PRIV-003).
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

/// The `elevation_samples` table of §7.3: provenance of an elevation used for
/// a context; never read by a calculation.
@DataClassName('ElevationSampleRow')
class ElevationSamples extends Table {
  /// Row id.
  IntColumn get id => integer().autoIncrement()();

  /// The context the sample belongs to.
  IntColumn get contextId => integer().references(
    LocationContexts,
    #id,
    onDelete: KeyAction.cascade,
  )();

  /// Elevation in metres.
  RealColumn get valueM => real().named('value_m')();

  /// Vertical datum, e.g. `EGM2008`.
  TextColumn get datum => text()();

  /// Where the value came from (a dataset or the device).
  TextColumn get source => text()();

  /// Vertical accuracy in metres; null when unknown.
  RealColumn get vAccM => real().named('v_acc_m').nullable()();

  /// Version of the dataset; null for a device reading.
  TextColumn get datasetVersion => text().nullable()();

  /// When the value was observed (UTC epoch ms).
  IntColumn get observedUtc => integer()();
}
