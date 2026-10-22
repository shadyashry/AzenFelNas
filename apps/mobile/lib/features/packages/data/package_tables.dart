import 'package:drift/drift.dart';

/// §7.3 `active_packages`: one row per package type.
@DataClassName('ActivePackageRow')
class ActivePackages extends Table {
  /// `PackageType.wire`.
  TextColumn get type => text()();

  /// The active version.
  TextColumn get version => text()();

  /// The `targets.json` sequence it was activated under; 0 for a seed.
  IntColumn get sequence => integer()();

  /// SHA-256 of the active file.
  TextColumn get sha256 => text()();

  /// `PackageSource.wire`.
  TextColumn get source => text()();

  /// Activation time (UTC epoch ms).
  IntColumn get activatedUtc => integer()();

  /// The version it replaced; null when none.
  TextColumn get previousVersion => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {type};
}

/// §7.3 `package_files`, plus `source` and `updated_utc` (§15 D74).
@DataClassName('PackageFileRow')
class PackageFiles extends Table {
  /// `PackageType.wire`.
  TextColumn get type => text()();

  /// The version.
  TextColumn get version => text()();

  /// Blob-store path, or `bundled:<type>/<version>`.
  TextColumn get path => text()();

  /// SHA-256 of the file.
  TextColumn get sha256 => text()();

  /// `PackageSource.wire`.
  TextColumn get source => text()();

  /// `PackageFileState.wire`.
  TextColumn get state => text()();

  /// When `state` was last set (UTC epoch ms).
  IntColumn get updatedUtc => integer()();

  @override
  Set<Column<Object>> get primaryKey => {type, version};
}

/// The channel trust state (one row, id 1): the last verified root, the
/// trusted sequences and hashes, and the sync times (§15 D74).
@DataClassName('PackageTrustRow')
class PackageTrust extends Table {
  /// Always 1.
  IntColumn get id => integer()();

  /// The last verified `root.json`; null before the first sync.
  BlobColumn get rootJson => blob().nullable()();

  /// Trusted `timestamp.json` sequence.
  IntColumn get timestampSequence => integer()();

  /// Trusted `snapshot.json` sequence.
  IntColumn get snapshotSequence => integer()();

  /// Trusted `targets.json` sequence.
  IntColumn get targetsSequence => integer()();

  /// SHA-256 of the trusted `timestamp.json`.
  TextColumn get timestampSha256 => text().nullable()();

  /// SHA-256 of the trusted `snapshot.json`.
  TextColumn get snapshotSha256 => text().nullable()();

  /// SHA-256 of the trusted `targets.json`.
  TextColumn get targetsSha256 => text().nullable()();

  /// Start of the last sync attempt (UTC epoch ms); 0 for never.
  IntColumn get lastSyncUtc => integer()();

  /// Last verification without a freshness warning (UTC epoch ms).
  IntColumn get lastVerifiedUtc => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
