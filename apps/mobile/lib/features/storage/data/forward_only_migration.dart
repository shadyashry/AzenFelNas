import 'package:drift/drift.dart';

/// One schema step: brings a database from version `v - 1` to `v`.
typedef MigrationStep = Future<void> Function(Migrator m);

/// The migration rules of §7.3 for every database file: forward only, one
/// step per version, and a refusal instead of a guess.
///
/// [steps] maps a target version to the step that reaches it. Opening a file
/// written by a newer app (a downgrade) or one that needs a missing step
/// throws [MigrationRefused]; drift then fails the open and the caller maps
/// that to `DB_MIGRATION_FAILED` (Appendix J). The file is left as it was.
final class ForwardOnlyMigration {
  /// The rules with [steps].
  const new(this.steps);

  /// The step for each version above 1.
  final Map<int, MigrationStep> steps;

  /// The drift strategy for [db]: create everything or run each step in
  /// order, then enforce foreign keys on every connection.
  MigrationStrategy strategy(GeneratedDatabase db) => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: upgrade,
    beforeOpen: (_) => db.customStatement('PRAGMA foreign_keys = ON'),
  );

  /// Runs the steps from [from] (exclusive) to [to] (inclusive).
  Future<void> upgrade(Migrator m, int from, int to) async {
    if (from > to) throw MigrationRefused(from: from, to: to);
    for (var version = from + 1; version <= to; version++) {
      final step = steps[version];
      if (step == null) throw MigrationRefused(from: from, to: to);
      await step(m);
    }
  }
}

/// A migration the app cannot run: a downgrade or a missing step.
final class MigrationRefused implements Exception {
  /// The refusal from [from] to [to].
  const new({required this.from, required this.to});

  /// The version found in the file.
  final int from;

  /// The version this app writes.
  final int to;

  @override
  String toString() => 'MigrationRefused(from: $from, to: $to)';
}
