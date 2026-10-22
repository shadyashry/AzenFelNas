import 'package:daily_muslim/features/contexts/domain/context_kind.dart';
import 'package:daily_muslim/features/contexts/domain/context_place.dart';
import 'package:daily_muslim/features/contexts/domain/context_source.dart';
import 'package:daily_muslim/features/contexts/domain/location_context.dart';
import 'package:daily_muslim/features/contexts/domain/location_failure.dart';
import 'package:daily_muslim/features/contexts/domain/location_ports.dart';
import 'package:daily_muslim/features/storage/data/places_database.dart';
import 'package:dm_civil_time/dm_civil_time.dart';
import 'package:dm_core_types/dm_core_types.dart';
import 'package:drift/drift.dart';

/// Location contexts on drift (§7.3 `location_contexts`). Storage errors
/// come back as `LOC_UNAVAILABLE` (§15 D73).
final class DriftLocationContextStore
    implements ReadLocationContexts, WriteLocationContexts {
  /// The store over [_db].
  const new(this._db);

  final PlacesDatabase _db;

  @override
  Future<Result<LocationContext?, LocationFailure>> active() =>
      _guard(() async {
        final query = _db.select(_db.locationContexts)
          ..orderBy([
            (t) => OrderingTerm.desc(t.lastUsedUtc),
            (t) => OrderingTerm.desc(t.id),
          ])
          ..limit(1);
        final row = await query.getSingleOrNull();
        return row == null ? null : _context(row);
      });

  @override
  Future<Result<LocationContext?, LocationFailure>> current() =>
      _guard(() async {
        final row = await _currentRow();
        return row == null ? null : _context(row);
      });

  @override
  Future<Result<LocationContext, LocationFailure>> saveCurrent(
    ContextPlace place,
    ContextSource source, {
    required int utcMs,
  }) => _guard(
    () => _db.transaction(() async {
      final existing = await _currentRow();
      final values = _values(ContextKind.current, place, source, utcMs);
      if (existing == null) {
        final id = await _db.into(_db.locationContexts).insert(values);
        return await _byId(id);
      }
      await (_db.update(_db.locationContexts)
            ..where((t) => t.id.equals(existing.id)))
          .write(values.copyWith(createdUtc: Value(existing.createdUtc)));
      return await _byId(existing.id);
    }),
  );

  @override
  Future<Result<LocationContext, LocationFailure>> addChosen(
    ChosenKind kind,
    ContextPlace place,
    ContextSource source, {
    required int utcMs,
  }) => _guard(() async {
    final id = await _db
        .into(_db.locationContexts)
        .insert(_values(kind.kind, place, source, utcMs));
    return await _byId(id);
  });

  @override
  Future<Result<LocationContext, LocationFailure>> markUsed(
    int id, {
    required int utcMs,
  }) => _guard(() async {
    final changed =
        await (_db.update(_db.locationContexts)..where((t) => t.id.equals(id)))
            .write(LocationContextsCompanion(lastUsedUtc: Value(utcMs)));
    if (changed == 0) throw const _NoSuchContext();
    return await _byId(id);
  });

  Future<LocationContextRow?> _currentRow() => (_db.select(
    _db.locationContexts,
  )..where((t) => t.kind.equals(ContextKind.current.wire))).getSingleOrNull();

  Future<LocationContext> _byId(int id) async => _context(
    await (_db.select(
      _db.locationContexts,
    )..where((t) => t.id.equals(id))).getSingle(),
  );

  static Future<Result<T, LocationFailure>> _guard<T>(
    Future<T> Function() body,
  ) async {
    try {
      return Ok(await body());
    } on _NoSuchContext {
      return const Err(LocationFailure.unavailable('no such context'));
    } on Exception catch (error) {
      return Err(LocationFailure.unavailable('context store: $error'));
    }
  }

  static LocationContextsCompanion _values(
    ContextKind kind,
    ContextPlace place,
    ContextSource source,
    int utcMs,
  ) => LocationContextsCompanion.insert(
    kind: kind.wire,
    lat: place.point.latE6 / 1e6,
    lon: place.point.lonE6 / 1e6,
    hAccM: Value(place.horizontalAccuracyM),
    zoneId: place.zoneId,
    country: Value(place.country),
    source: source.wire,
    pinned: kind.isUserChosen,
    label: place.label,
    createdUtc: utcMs,
    lastUsedUtc: utcMs,
  );

  static LocationContext _context(LocationContextRow row) => LocationContext(
    id: row.id,
    kind: ContextKind.fromWire(row.kind) ?? (throw _BadRow('kind', row.kind)),
    place: ContextPlace(
      point: GeoPointE6((row.lat * 1e6).round(), (row.lon * 1e6).round()),
      horizontalAccuracyM: row.hAccM,
      zoneId: row.zoneId,
      country: row.country,
      label: row.label,
    ),
    source:
        ContextSource.fromWire(row.source) ??
        (throw _BadRow('source', row.source)),
    createdUtcMs: row.createdUtc,
    lastUsedUtcMs: row.lastUsedUtc,
  );
}

final class _NoSuchContext implements Exception {
  const new();
}

final class _BadRow implements Exception {
  const new(this.column, this.value);

  final String column;
  final String value;

  @override
  String toString() => 'unknown $column "$value"';
}
