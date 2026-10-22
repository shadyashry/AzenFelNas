import 'package:daily_muslim/features/contexts/domain/context_kind.dart';
import 'package:daily_muslim/features/contexts/domain/context_place.dart';
import 'package:daily_muslim/features/contexts/domain/context_source.dart';
import 'package:daily_muslim/features/contexts/domain/location_context.dart';
import 'package:daily_muslim/features/contexts/domain/location_failure.dart';
import 'package:daily_muslim/features/contexts/domain/location_ports.dart';
import 'package:dm_core_types/dm_core_types.dart';

/// In-memory location contexts with the same contract as
/// `DriftLocationContextStore` (REQ-TEST-004).
final class FakeLocationContextStore
    implements ReadLocationContexts, WriteLocationContexts {
  final Map<int, LocationContext> _rows = {};
  int _nextId = 1;

  /// Every stored context, by id.
  List<LocationContext> get rows =>
      _rows.values.toList()..sort((a, b) => a.id.compareTo(b.id));

  @override
  Future<Result<LocationContext?, LocationFailure>> active() async {
    LocationContext? best;
    for (final row in _rows.values) {
      if (best == null ||
          row.lastUsedUtcMs > best.lastUsedUtcMs ||
          (row.lastUsedUtcMs == best.lastUsedUtcMs && row.id > best.id)) {
        best = row;
      }
    }
    return Ok(best);
  }

  @override
  Future<Result<LocationContext?, LocationFailure>> current() async =>
      Ok(_current());

  @override
  Future<Result<LocationContext, LocationFailure>> saveCurrent(
    ContextPlace place,
    ContextSource source, {
    required int utcMs,
  }) async {
    final existing = _current();
    return Ok(
      _put(
        id: existing?.id ?? _nextId++,
        kind: ContextKind.current,
        place: place,
        source: source,
        createdUtcMs: existing?.createdUtcMs ?? utcMs,
        lastUsedUtcMs: utcMs,
      ),
    );
  }

  @override
  Future<Result<LocationContext, LocationFailure>> addChosen(
    ChosenKind kind,
    ContextPlace place,
    ContextSource source, {
    required int utcMs,
  }) async => Ok(
    _put(
      id: _nextId++,
      kind: kind.kind,
      place: place,
      source: source,
      createdUtcMs: utcMs,
      lastUsedUtcMs: utcMs,
    ),
  );

  @override
  Future<Result<LocationContext, LocationFailure>> markUsed(
    int id, {
    required int utcMs,
  }) async {
    final row = _rows[id];
    if (row == null) {
      return const Err(LocationFailure.unavailable('no such context'));
    }
    return Ok(
      _put(
        id: id,
        kind: row.kind,
        place: row.place,
        source: row.source,
        createdUtcMs: row.createdUtcMs,
        lastUsedUtcMs: utcMs,
      ),
    );
  }

  LocationContext? _current() {
    for (final row in _rows.values) {
      if (row.kind == ContextKind.current) return row;
    }
    return null;
  }

  LocationContext _put({
    required int id,
    required ContextKind kind,
    required ContextPlace place,
    required ContextSource source,
    required int createdUtcMs,
    required int lastUsedUtcMs,
  }) => _rows[id] = LocationContext(
    id: id,
    kind: kind,
    place: place,
    source: source,
    createdUtcMs: createdUtcMs,
    lastUsedUtcMs: lastUsedUtcMs,
  );
}
