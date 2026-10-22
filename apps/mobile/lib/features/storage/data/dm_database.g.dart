// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dm_database.dart';

// ignore_for_file: type=lint
class $ActivePackagesTable extends ActivePackages
    with TableInfo<$ActivePackagesTable, ActivePackageRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ActivePackagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<String> version = GeneratedColumn<String>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sequenceMeta = const VerificationMeta(
    'sequence',
  );
  @override
  late final GeneratedColumn<int> sequence = GeneratedColumn<int>(
    'sequence',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sha256Meta = const VerificationMeta('sha256');
  @override
  late final GeneratedColumn<String> sha256 = GeneratedColumn<String>(
    'sha256',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _activatedUtcMeta = const VerificationMeta(
    'activatedUtc',
  );
  @override
  late final GeneratedColumn<int> activatedUtc = GeneratedColumn<int>(
    'activated_utc',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _previousVersionMeta = const VerificationMeta(
    'previousVersion',
  );
  @override
  late final GeneratedColumn<String> previousVersion = GeneratedColumn<String>(
    'previous_version',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    type,
    version,
    sequence,
    sha256,
    source,
    activatedUtc,
    previousVersion,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'active_packages';
  @override
  VerificationContext validateIntegrity(
    Insertable<ActivePackageRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    } else if (isInserting) {
      context.missing(_versionMeta);
    }
    if (data.containsKey('sequence')) {
      context.handle(
        _sequenceMeta,
        sequence.isAcceptableOrUnknown(data['sequence']!, _sequenceMeta),
      );
    } else if (isInserting) {
      context.missing(_sequenceMeta);
    }
    if (data.containsKey('sha256')) {
      context.handle(
        _sha256Meta,
        sha256.isAcceptableOrUnknown(data['sha256']!, _sha256Meta),
      );
    } else if (isInserting) {
      context.missing(_sha256Meta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('activated_utc')) {
      context.handle(
        _activatedUtcMeta,
        activatedUtc.isAcceptableOrUnknown(
          data['activated_utc']!,
          _activatedUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_activatedUtcMeta);
    }
    if (data.containsKey('previous_version')) {
      context.handle(
        _previousVersionMeta,
        previousVersion.isAcceptableOrUnknown(
          data['previous_version']!,
          _previousVersionMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {type};
  @override
  ActivePackageRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ActivePackageRow(
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}version'],
      )!,
      sequence: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sequence'],
      )!,
      sha256: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sha256'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      activatedUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}activated_utc'],
      )!,
      previousVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}previous_version'],
      ),
    );
  }

  @override
  $ActivePackagesTable createAlias(String alias) {
    return $ActivePackagesTable(attachedDatabase, alias);
  }
}

class ActivePackageRow extends DataClass
    implements Insertable<ActivePackageRow> {
  /// `PackageType.wire`.
  final String type;

  /// The active version.
  final String version;

  /// The `targets.json` sequence it was activated under; 0 for a seed.
  final int sequence;

  /// SHA-256 of the active file.
  final String sha256;

  /// `PackageSource.wire`.
  final String source;

  /// Activation time (UTC epoch ms).
  final int activatedUtc;

  /// The version it replaced; null when none.
  final String? previousVersion;
  const ActivePackageRow({
    required this.type,
    required this.version,
    required this.sequence,
    required this.sha256,
    required this.source,
    required this.activatedUtc,
    this.previousVersion,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['type'] = Variable<String>(type);
    map['version'] = Variable<String>(version);
    map['sequence'] = Variable<int>(sequence);
    map['sha256'] = Variable<String>(sha256);
    map['source'] = Variable<String>(source);
    map['activated_utc'] = Variable<int>(activatedUtc);
    if (!nullToAbsent || previousVersion != null) {
      map['previous_version'] = Variable<String>(previousVersion);
    }
    return map;
  }

  ActivePackagesCompanion toCompanion(bool nullToAbsent) {
    return ActivePackagesCompanion(
      type: Value(type),
      version: Value(version),
      sequence: Value(sequence),
      sha256: Value(sha256),
      source: Value(source),
      activatedUtc: Value(activatedUtc),
      previousVersion: previousVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(previousVersion),
    );
  }

  factory ActivePackageRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ActivePackageRow(
      type: serializer.fromJson<String>(json['type']),
      version: serializer.fromJson<String>(json['version']),
      sequence: serializer.fromJson<int>(json['sequence']),
      sha256: serializer.fromJson<String>(json['sha256']),
      source: serializer.fromJson<String>(json['source']),
      activatedUtc: serializer.fromJson<int>(json['activatedUtc']),
      previousVersion: serializer.fromJson<String?>(json['previousVersion']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'type': serializer.toJson<String>(type),
      'version': serializer.toJson<String>(version),
      'sequence': serializer.toJson<int>(sequence),
      'sha256': serializer.toJson<String>(sha256),
      'source': serializer.toJson<String>(source),
      'activatedUtc': serializer.toJson<int>(activatedUtc),
      'previousVersion': serializer.toJson<String?>(previousVersion),
    };
  }

  ActivePackageRow copyWith({
    String? type,
    String? version,
    int? sequence,
    String? sha256,
    String? source,
    int? activatedUtc,
    Value<String?> previousVersion = const Value.absent(),
  }) => ActivePackageRow(
    type: type ?? this.type,
    version: version ?? this.version,
    sequence: sequence ?? this.sequence,
    sha256: sha256 ?? this.sha256,
    source: source ?? this.source,
    activatedUtc: activatedUtc ?? this.activatedUtc,
    previousVersion: previousVersion.present
        ? previousVersion.value
        : this.previousVersion,
  );
  ActivePackageRow copyWithCompanion(ActivePackagesCompanion data) {
    return ActivePackageRow(
      type: data.type.present ? data.type.value : this.type,
      version: data.version.present ? data.version.value : this.version,
      sequence: data.sequence.present ? data.sequence.value : this.sequence,
      sha256: data.sha256.present ? data.sha256.value : this.sha256,
      source: data.source.present ? data.source.value : this.source,
      activatedUtc: data.activatedUtc.present
          ? data.activatedUtc.value
          : this.activatedUtc,
      previousVersion: data.previousVersion.present
          ? data.previousVersion.value
          : this.previousVersion,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ActivePackageRow(')
          ..write('type: $type, ')
          ..write('version: $version, ')
          ..write('sequence: $sequence, ')
          ..write('sha256: $sha256, ')
          ..write('source: $source, ')
          ..write('activatedUtc: $activatedUtc, ')
          ..write('previousVersion: $previousVersion')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    type,
    version,
    sequence,
    sha256,
    source,
    activatedUtc,
    previousVersion,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ActivePackageRow &&
          other.type == this.type &&
          other.version == this.version &&
          other.sequence == this.sequence &&
          other.sha256 == this.sha256 &&
          other.source == this.source &&
          other.activatedUtc == this.activatedUtc &&
          other.previousVersion == this.previousVersion);
}

class ActivePackagesCompanion extends UpdateCompanion<ActivePackageRow> {
  final Value<String> type;
  final Value<String> version;
  final Value<int> sequence;
  final Value<String> sha256;
  final Value<String> source;
  final Value<int> activatedUtc;
  final Value<String?> previousVersion;
  final Value<int> rowid;
  const ActivePackagesCompanion({
    this.type = const Value.absent(),
    this.version = const Value.absent(),
    this.sequence = const Value.absent(),
    this.sha256 = const Value.absent(),
    this.source = const Value.absent(),
    this.activatedUtc = const Value.absent(),
    this.previousVersion = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ActivePackagesCompanion.insert({
    required String type,
    required String version,
    required int sequence,
    required String sha256,
    required String source,
    required int activatedUtc,
    this.previousVersion = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : type = Value(type),
       version = Value(version),
       sequence = Value(sequence),
       sha256 = Value(sha256),
       source = Value(source),
       activatedUtc = Value(activatedUtc);
  static Insertable<ActivePackageRow> custom({
    Expression<String>? type,
    Expression<String>? version,
    Expression<int>? sequence,
    Expression<String>? sha256,
    Expression<String>? source,
    Expression<int>? activatedUtc,
    Expression<String>? previousVersion,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (type != null) 'type': type,
      if (version != null) 'version': version,
      if (sequence != null) 'sequence': sequence,
      if (sha256 != null) 'sha256': sha256,
      if (source != null) 'source': source,
      if (activatedUtc != null) 'activated_utc': activatedUtc,
      if (previousVersion != null) 'previous_version': previousVersion,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ActivePackagesCompanion copyWith({
    Value<String>? type,
    Value<String>? version,
    Value<int>? sequence,
    Value<String>? sha256,
    Value<String>? source,
    Value<int>? activatedUtc,
    Value<String?>? previousVersion,
    Value<int>? rowid,
  }) {
    return ActivePackagesCompanion(
      type: type ?? this.type,
      version: version ?? this.version,
      sequence: sequence ?? this.sequence,
      sha256: sha256 ?? this.sha256,
      source: source ?? this.source,
      activatedUtc: activatedUtc ?? this.activatedUtc,
      previousVersion: previousVersion ?? this.previousVersion,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (version.present) {
      map['version'] = Variable<String>(version.value);
    }
    if (sequence.present) {
      map['sequence'] = Variable<int>(sequence.value);
    }
    if (sha256.present) {
      map['sha256'] = Variable<String>(sha256.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (activatedUtc.present) {
      map['activated_utc'] = Variable<int>(activatedUtc.value);
    }
    if (previousVersion.present) {
      map['previous_version'] = Variable<String>(previousVersion.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ActivePackagesCompanion(')
          ..write('type: $type, ')
          ..write('version: $version, ')
          ..write('sequence: $sequence, ')
          ..write('sha256: $sha256, ')
          ..write('source: $source, ')
          ..write('activatedUtc: $activatedUtc, ')
          ..write('previousVersion: $previousVersion, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PackageFilesTable extends PackageFiles
    with TableInfo<$PackageFilesTable, PackageFileRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PackageFilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<String> version = GeneratedColumn<String>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pathMeta = const VerificationMeta('path');
  @override
  late final GeneratedColumn<String> path = GeneratedColumn<String>(
    'path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sha256Meta = const VerificationMeta('sha256');
  @override
  late final GeneratedColumn<String> sha256 = GeneratedColumn<String>(
    'sha256',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedUtcMeta = const VerificationMeta(
    'updatedUtc',
  );
  @override
  late final GeneratedColumn<int> updatedUtc = GeneratedColumn<int>(
    'updated_utc',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    type,
    version,
    path,
    sha256,
    source,
    state,
    updatedUtc,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'package_files';
  @override
  VerificationContext validateIntegrity(
    Insertable<PackageFileRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    } else if (isInserting) {
      context.missing(_versionMeta);
    }
    if (data.containsKey('path')) {
      context.handle(
        _pathMeta,
        path.isAcceptableOrUnknown(data['path']!, _pathMeta),
      );
    } else if (isInserting) {
      context.missing(_pathMeta);
    }
    if (data.containsKey('sha256')) {
      context.handle(
        _sha256Meta,
        sha256.isAcceptableOrUnknown(data['sha256']!, _sha256Meta),
      );
    } else if (isInserting) {
      context.missing(_sha256Meta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    } else if (isInserting) {
      context.missing(_stateMeta);
    }
    if (data.containsKey('updated_utc')) {
      context.handle(
        _updatedUtcMeta,
        updatedUtc.isAcceptableOrUnknown(data['updated_utc']!, _updatedUtcMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedUtcMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {type, version};
  @override
  PackageFileRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PackageFileRow(
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}version'],
      )!,
      path: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}path'],
      )!,
      sha256: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sha256'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      )!,
      updatedUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_utc'],
      )!,
    );
  }

  @override
  $PackageFilesTable createAlias(String alias) {
    return $PackageFilesTable(attachedDatabase, alias);
  }
}

class PackageFileRow extends DataClass implements Insertable<PackageFileRow> {
  /// `PackageType.wire`.
  final String type;

  /// The version.
  final String version;

  /// Blob-store path, or `bundled:<type>/<version>`.
  final String path;

  /// SHA-256 of the file.
  final String sha256;

  /// `PackageSource.wire`.
  final String source;

  /// `PackageFileState.wire`.
  final String state;

  /// When `state` was last set (UTC epoch ms).
  final int updatedUtc;
  const PackageFileRow({
    required this.type,
    required this.version,
    required this.path,
    required this.sha256,
    required this.source,
    required this.state,
    required this.updatedUtc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['type'] = Variable<String>(type);
    map['version'] = Variable<String>(version);
    map['path'] = Variable<String>(path);
    map['sha256'] = Variable<String>(sha256);
    map['source'] = Variable<String>(source);
    map['state'] = Variable<String>(state);
    map['updated_utc'] = Variable<int>(updatedUtc);
    return map;
  }

  PackageFilesCompanion toCompanion(bool nullToAbsent) {
    return PackageFilesCompanion(
      type: Value(type),
      version: Value(version),
      path: Value(path),
      sha256: Value(sha256),
      source: Value(source),
      state: Value(state),
      updatedUtc: Value(updatedUtc),
    );
  }

  factory PackageFileRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PackageFileRow(
      type: serializer.fromJson<String>(json['type']),
      version: serializer.fromJson<String>(json['version']),
      path: serializer.fromJson<String>(json['path']),
      sha256: serializer.fromJson<String>(json['sha256']),
      source: serializer.fromJson<String>(json['source']),
      state: serializer.fromJson<String>(json['state']),
      updatedUtc: serializer.fromJson<int>(json['updatedUtc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'type': serializer.toJson<String>(type),
      'version': serializer.toJson<String>(version),
      'path': serializer.toJson<String>(path),
      'sha256': serializer.toJson<String>(sha256),
      'source': serializer.toJson<String>(source),
      'state': serializer.toJson<String>(state),
      'updatedUtc': serializer.toJson<int>(updatedUtc),
    };
  }

  PackageFileRow copyWith({
    String? type,
    String? version,
    String? path,
    String? sha256,
    String? source,
    String? state,
    int? updatedUtc,
  }) => PackageFileRow(
    type: type ?? this.type,
    version: version ?? this.version,
    path: path ?? this.path,
    sha256: sha256 ?? this.sha256,
    source: source ?? this.source,
    state: state ?? this.state,
    updatedUtc: updatedUtc ?? this.updatedUtc,
  );
  PackageFileRow copyWithCompanion(PackageFilesCompanion data) {
    return PackageFileRow(
      type: data.type.present ? data.type.value : this.type,
      version: data.version.present ? data.version.value : this.version,
      path: data.path.present ? data.path.value : this.path,
      sha256: data.sha256.present ? data.sha256.value : this.sha256,
      source: data.source.present ? data.source.value : this.source,
      state: data.state.present ? data.state.value : this.state,
      updatedUtc: data.updatedUtc.present
          ? data.updatedUtc.value
          : this.updatedUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PackageFileRow(')
          ..write('type: $type, ')
          ..write('version: $version, ')
          ..write('path: $path, ')
          ..write('sha256: $sha256, ')
          ..write('source: $source, ')
          ..write('state: $state, ')
          ..write('updatedUtc: $updatedUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(type, version, path, sha256, source, state, updatedUtc);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PackageFileRow &&
          other.type == this.type &&
          other.version == this.version &&
          other.path == this.path &&
          other.sha256 == this.sha256 &&
          other.source == this.source &&
          other.state == this.state &&
          other.updatedUtc == this.updatedUtc);
}

class PackageFilesCompanion extends UpdateCompanion<PackageFileRow> {
  final Value<String> type;
  final Value<String> version;
  final Value<String> path;
  final Value<String> sha256;
  final Value<String> source;
  final Value<String> state;
  final Value<int> updatedUtc;
  final Value<int> rowid;
  const PackageFilesCompanion({
    this.type = const Value.absent(),
    this.version = const Value.absent(),
    this.path = const Value.absent(),
    this.sha256 = const Value.absent(),
    this.source = const Value.absent(),
    this.state = const Value.absent(),
    this.updatedUtc = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PackageFilesCompanion.insert({
    required String type,
    required String version,
    required String path,
    required String sha256,
    required String source,
    required String state,
    required int updatedUtc,
    this.rowid = const Value.absent(),
  }) : type = Value(type),
       version = Value(version),
       path = Value(path),
       sha256 = Value(sha256),
       source = Value(source),
       state = Value(state),
       updatedUtc = Value(updatedUtc);
  static Insertable<PackageFileRow> custom({
    Expression<String>? type,
    Expression<String>? version,
    Expression<String>? path,
    Expression<String>? sha256,
    Expression<String>? source,
    Expression<String>? state,
    Expression<int>? updatedUtc,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (type != null) 'type': type,
      if (version != null) 'version': version,
      if (path != null) 'path': path,
      if (sha256 != null) 'sha256': sha256,
      if (source != null) 'source': source,
      if (state != null) 'state': state,
      if (updatedUtc != null) 'updated_utc': updatedUtc,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PackageFilesCompanion copyWith({
    Value<String>? type,
    Value<String>? version,
    Value<String>? path,
    Value<String>? sha256,
    Value<String>? source,
    Value<String>? state,
    Value<int>? updatedUtc,
    Value<int>? rowid,
  }) {
    return PackageFilesCompanion(
      type: type ?? this.type,
      version: version ?? this.version,
      path: path ?? this.path,
      sha256: sha256 ?? this.sha256,
      source: source ?? this.source,
      state: state ?? this.state,
      updatedUtc: updatedUtc ?? this.updatedUtc,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (version.present) {
      map['version'] = Variable<String>(version.value);
    }
    if (path.present) {
      map['path'] = Variable<String>(path.value);
    }
    if (sha256.present) {
      map['sha256'] = Variable<String>(sha256.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (updatedUtc.present) {
      map['updated_utc'] = Variable<int>(updatedUtc.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PackageFilesCompanion(')
          ..write('type: $type, ')
          ..write('version: $version, ')
          ..write('path: $path, ')
          ..write('sha256: $sha256, ')
          ..write('source: $source, ')
          ..write('state: $state, ')
          ..write('updatedUtc: $updatedUtc, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PackageTrustTable extends PackageTrust
    with TableInfo<$PackageTrustTable, PackageTrustRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PackageTrustTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rootJsonMeta = const VerificationMeta(
    'rootJson',
  );
  @override
  late final GeneratedColumn<Uint8List> rootJson = GeneratedColumn<Uint8List>(
    'root_json',
    aliasedName,
    true,
    type: DriftSqlType.blob,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _timestampSequenceMeta = const VerificationMeta(
    'timestampSequence',
  );
  @override
  late final GeneratedColumn<int> timestampSequence = GeneratedColumn<int>(
    'timestamp_sequence',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _snapshotSequenceMeta = const VerificationMeta(
    'snapshotSequence',
  );
  @override
  late final GeneratedColumn<int> snapshotSequence = GeneratedColumn<int>(
    'snapshot_sequence',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetsSequenceMeta = const VerificationMeta(
    'targetsSequence',
  );
  @override
  late final GeneratedColumn<int> targetsSequence = GeneratedColumn<int>(
    'targets_sequence',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timestampSha256Meta = const VerificationMeta(
    'timestampSha256',
  );
  @override
  late final GeneratedColumn<String> timestampSha256 = GeneratedColumn<String>(
    'timestamp_sha256',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _snapshotSha256Meta = const VerificationMeta(
    'snapshotSha256',
  );
  @override
  late final GeneratedColumn<String> snapshotSha256 = GeneratedColumn<String>(
    'snapshot_sha256',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _targetsSha256Meta = const VerificationMeta(
    'targetsSha256',
  );
  @override
  late final GeneratedColumn<String> targetsSha256 = GeneratedColumn<String>(
    'targets_sha256',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastSyncUtcMeta = const VerificationMeta(
    'lastSyncUtc',
  );
  @override
  late final GeneratedColumn<int> lastSyncUtc = GeneratedColumn<int>(
    'last_sync_utc',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastVerifiedUtcMeta = const VerificationMeta(
    'lastVerifiedUtc',
  );
  @override
  late final GeneratedColumn<int> lastVerifiedUtc = GeneratedColumn<int>(
    'last_verified_utc',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    rootJson,
    timestampSequence,
    snapshotSequence,
    targetsSequence,
    timestampSha256,
    snapshotSha256,
    targetsSha256,
    lastSyncUtc,
    lastVerifiedUtc,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'package_trust';
  @override
  VerificationContext validateIntegrity(
    Insertable<PackageTrustRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('root_json')) {
      context.handle(
        _rootJsonMeta,
        rootJson.isAcceptableOrUnknown(data['root_json']!, _rootJsonMeta),
      );
    }
    if (data.containsKey('timestamp_sequence')) {
      context.handle(
        _timestampSequenceMeta,
        timestampSequence.isAcceptableOrUnknown(
          data['timestamp_sequence']!,
          _timestampSequenceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_timestampSequenceMeta);
    }
    if (data.containsKey('snapshot_sequence')) {
      context.handle(
        _snapshotSequenceMeta,
        snapshotSequence.isAcceptableOrUnknown(
          data['snapshot_sequence']!,
          _snapshotSequenceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_snapshotSequenceMeta);
    }
    if (data.containsKey('targets_sequence')) {
      context.handle(
        _targetsSequenceMeta,
        targetsSequence.isAcceptableOrUnknown(
          data['targets_sequence']!,
          _targetsSequenceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetsSequenceMeta);
    }
    if (data.containsKey('timestamp_sha256')) {
      context.handle(
        _timestampSha256Meta,
        timestampSha256.isAcceptableOrUnknown(
          data['timestamp_sha256']!,
          _timestampSha256Meta,
        ),
      );
    }
    if (data.containsKey('snapshot_sha256')) {
      context.handle(
        _snapshotSha256Meta,
        snapshotSha256.isAcceptableOrUnknown(
          data['snapshot_sha256']!,
          _snapshotSha256Meta,
        ),
      );
    }
    if (data.containsKey('targets_sha256')) {
      context.handle(
        _targetsSha256Meta,
        targetsSha256.isAcceptableOrUnknown(
          data['targets_sha256']!,
          _targetsSha256Meta,
        ),
      );
    }
    if (data.containsKey('last_sync_utc')) {
      context.handle(
        _lastSyncUtcMeta,
        lastSyncUtc.isAcceptableOrUnknown(
          data['last_sync_utc']!,
          _lastSyncUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastSyncUtcMeta);
    }
    if (data.containsKey('last_verified_utc')) {
      context.handle(
        _lastVerifiedUtcMeta,
        lastVerifiedUtc.isAcceptableOrUnknown(
          data['last_verified_utc']!,
          _lastVerifiedUtcMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PackageTrustRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PackageTrustRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      rootJson: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}root_json'],
      ),
      timestampSequence: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}timestamp_sequence'],
      )!,
      snapshotSequence: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}snapshot_sequence'],
      )!,
      targetsSequence: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}targets_sequence'],
      )!,
      timestampSha256: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}timestamp_sha256'],
      ),
      snapshotSha256: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}snapshot_sha256'],
      ),
      targetsSha256: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}targets_sha256'],
      ),
      lastSyncUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_sync_utc'],
      )!,
      lastVerifiedUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_verified_utc'],
      ),
    );
  }

  @override
  $PackageTrustTable createAlias(String alias) {
    return $PackageTrustTable(attachedDatabase, alias);
  }
}

class PackageTrustRow extends DataClass implements Insertable<PackageTrustRow> {
  /// Always 1.
  final int id;

  /// The last verified `root.json`; null before the first sync.
  final Uint8List? rootJson;

  /// Trusted `timestamp.json` sequence.
  final int timestampSequence;

  /// Trusted `snapshot.json` sequence.
  final int snapshotSequence;

  /// Trusted `targets.json` sequence.
  final int targetsSequence;

  /// SHA-256 of the trusted `timestamp.json`.
  final String? timestampSha256;

  /// SHA-256 of the trusted `snapshot.json`.
  final String? snapshotSha256;

  /// SHA-256 of the trusted `targets.json`.
  final String? targetsSha256;

  /// Start of the last sync attempt (UTC epoch ms); 0 for never.
  final int lastSyncUtc;

  /// Last verification without a freshness warning (UTC epoch ms).
  final int? lastVerifiedUtc;
  const PackageTrustRow({
    required this.id,
    this.rootJson,
    required this.timestampSequence,
    required this.snapshotSequence,
    required this.targetsSequence,
    this.timestampSha256,
    this.snapshotSha256,
    this.targetsSha256,
    required this.lastSyncUtc,
    this.lastVerifiedUtc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || rootJson != null) {
      map['root_json'] = Variable<Uint8List>(rootJson);
    }
    map['timestamp_sequence'] = Variable<int>(timestampSequence);
    map['snapshot_sequence'] = Variable<int>(snapshotSequence);
    map['targets_sequence'] = Variable<int>(targetsSequence);
    if (!nullToAbsent || timestampSha256 != null) {
      map['timestamp_sha256'] = Variable<String>(timestampSha256);
    }
    if (!nullToAbsent || snapshotSha256 != null) {
      map['snapshot_sha256'] = Variable<String>(snapshotSha256);
    }
    if (!nullToAbsent || targetsSha256 != null) {
      map['targets_sha256'] = Variable<String>(targetsSha256);
    }
    map['last_sync_utc'] = Variable<int>(lastSyncUtc);
    if (!nullToAbsent || lastVerifiedUtc != null) {
      map['last_verified_utc'] = Variable<int>(lastVerifiedUtc);
    }
    return map;
  }

  PackageTrustCompanion toCompanion(bool nullToAbsent) {
    return PackageTrustCompanion(
      id: Value(id),
      rootJson: rootJson == null && nullToAbsent
          ? const Value.absent()
          : Value(rootJson),
      timestampSequence: Value(timestampSequence),
      snapshotSequence: Value(snapshotSequence),
      targetsSequence: Value(targetsSequence),
      timestampSha256: timestampSha256 == null && nullToAbsent
          ? const Value.absent()
          : Value(timestampSha256),
      snapshotSha256: snapshotSha256 == null && nullToAbsent
          ? const Value.absent()
          : Value(snapshotSha256),
      targetsSha256: targetsSha256 == null && nullToAbsent
          ? const Value.absent()
          : Value(targetsSha256),
      lastSyncUtc: Value(lastSyncUtc),
      lastVerifiedUtc: lastVerifiedUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(lastVerifiedUtc),
    );
  }

  factory PackageTrustRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PackageTrustRow(
      id: serializer.fromJson<int>(json['id']),
      rootJson: serializer.fromJson<Uint8List?>(json['rootJson']),
      timestampSequence: serializer.fromJson<int>(json['timestampSequence']),
      snapshotSequence: serializer.fromJson<int>(json['snapshotSequence']),
      targetsSequence: serializer.fromJson<int>(json['targetsSequence']),
      timestampSha256: serializer.fromJson<String?>(json['timestampSha256']),
      snapshotSha256: serializer.fromJson<String?>(json['snapshotSha256']),
      targetsSha256: serializer.fromJson<String?>(json['targetsSha256']),
      lastSyncUtc: serializer.fromJson<int>(json['lastSyncUtc']),
      lastVerifiedUtc: serializer.fromJson<int?>(json['lastVerifiedUtc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'rootJson': serializer.toJson<Uint8List?>(rootJson),
      'timestampSequence': serializer.toJson<int>(timestampSequence),
      'snapshotSequence': serializer.toJson<int>(snapshotSequence),
      'targetsSequence': serializer.toJson<int>(targetsSequence),
      'timestampSha256': serializer.toJson<String?>(timestampSha256),
      'snapshotSha256': serializer.toJson<String?>(snapshotSha256),
      'targetsSha256': serializer.toJson<String?>(targetsSha256),
      'lastSyncUtc': serializer.toJson<int>(lastSyncUtc),
      'lastVerifiedUtc': serializer.toJson<int?>(lastVerifiedUtc),
    };
  }

  PackageTrustRow copyWith({
    int? id,
    Value<Uint8List?> rootJson = const Value.absent(),
    int? timestampSequence,
    int? snapshotSequence,
    int? targetsSequence,
    Value<String?> timestampSha256 = const Value.absent(),
    Value<String?> snapshotSha256 = const Value.absent(),
    Value<String?> targetsSha256 = const Value.absent(),
    int? lastSyncUtc,
    Value<int?> lastVerifiedUtc = const Value.absent(),
  }) => PackageTrustRow(
    id: id ?? this.id,
    rootJson: rootJson.present ? rootJson.value : this.rootJson,
    timestampSequence: timestampSequence ?? this.timestampSequence,
    snapshotSequence: snapshotSequence ?? this.snapshotSequence,
    targetsSequence: targetsSequence ?? this.targetsSequence,
    timestampSha256: timestampSha256.present
        ? timestampSha256.value
        : this.timestampSha256,
    snapshotSha256: snapshotSha256.present
        ? snapshotSha256.value
        : this.snapshotSha256,
    targetsSha256: targetsSha256.present
        ? targetsSha256.value
        : this.targetsSha256,
    lastSyncUtc: lastSyncUtc ?? this.lastSyncUtc,
    lastVerifiedUtc: lastVerifiedUtc.present
        ? lastVerifiedUtc.value
        : this.lastVerifiedUtc,
  );
  PackageTrustRow copyWithCompanion(PackageTrustCompanion data) {
    return PackageTrustRow(
      id: data.id.present ? data.id.value : this.id,
      rootJson: data.rootJson.present ? data.rootJson.value : this.rootJson,
      timestampSequence: data.timestampSequence.present
          ? data.timestampSequence.value
          : this.timestampSequence,
      snapshotSequence: data.snapshotSequence.present
          ? data.snapshotSequence.value
          : this.snapshotSequence,
      targetsSequence: data.targetsSequence.present
          ? data.targetsSequence.value
          : this.targetsSequence,
      timestampSha256: data.timestampSha256.present
          ? data.timestampSha256.value
          : this.timestampSha256,
      snapshotSha256: data.snapshotSha256.present
          ? data.snapshotSha256.value
          : this.snapshotSha256,
      targetsSha256: data.targetsSha256.present
          ? data.targetsSha256.value
          : this.targetsSha256,
      lastSyncUtc: data.lastSyncUtc.present
          ? data.lastSyncUtc.value
          : this.lastSyncUtc,
      lastVerifiedUtc: data.lastVerifiedUtc.present
          ? data.lastVerifiedUtc.value
          : this.lastVerifiedUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PackageTrustRow(')
          ..write('id: $id, ')
          ..write('rootJson: $rootJson, ')
          ..write('timestampSequence: $timestampSequence, ')
          ..write('snapshotSequence: $snapshotSequence, ')
          ..write('targetsSequence: $targetsSequence, ')
          ..write('timestampSha256: $timestampSha256, ')
          ..write('snapshotSha256: $snapshotSha256, ')
          ..write('targetsSha256: $targetsSha256, ')
          ..write('lastSyncUtc: $lastSyncUtc, ')
          ..write('lastVerifiedUtc: $lastVerifiedUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    $driftBlobEquality.hash(rootJson),
    timestampSequence,
    snapshotSequence,
    targetsSequence,
    timestampSha256,
    snapshotSha256,
    targetsSha256,
    lastSyncUtc,
    lastVerifiedUtc,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PackageTrustRow &&
          other.id == this.id &&
          $driftBlobEquality.equals(other.rootJson, this.rootJson) &&
          other.timestampSequence == this.timestampSequence &&
          other.snapshotSequence == this.snapshotSequence &&
          other.targetsSequence == this.targetsSequence &&
          other.timestampSha256 == this.timestampSha256 &&
          other.snapshotSha256 == this.snapshotSha256 &&
          other.targetsSha256 == this.targetsSha256 &&
          other.lastSyncUtc == this.lastSyncUtc &&
          other.lastVerifiedUtc == this.lastVerifiedUtc);
}

class PackageTrustCompanion extends UpdateCompanion<PackageTrustRow> {
  final Value<int> id;
  final Value<Uint8List?> rootJson;
  final Value<int> timestampSequence;
  final Value<int> snapshotSequence;
  final Value<int> targetsSequence;
  final Value<String?> timestampSha256;
  final Value<String?> snapshotSha256;
  final Value<String?> targetsSha256;
  final Value<int> lastSyncUtc;
  final Value<int?> lastVerifiedUtc;
  const PackageTrustCompanion({
    this.id = const Value.absent(),
    this.rootJson = const Value.absent(),
    this.timestampSequence = const Value.absent(),
    this.snapshotSequence = const Value.absent(),
    this.targetsSequence = const Value.absent(),
    this.timestampSha256 = const Value.absent(),
    this.snapshotSha256 = const Value.absent(),
    this.targetsSha256 = const Value.absent(),
    this.lastSyncUtc = const Value.absent(),
    this.lastVerifiedUtc = const Value.absent(),
  });
  PackageTrustCompanion.insert({
    this.id = const Value.absent(),
    this.rootJson = const Value.absent(),
    required int timestampSequence,
    required int snapshotSequence,
    required int targetsSequence,
    this.timestampSha256 = const Value.absent(),
    this.snapshotSha256 = const Value.absent(),
    this.targetsSha256 = const Value.absent(),
    required int lastSyncUtc,
    this.lastVerifiedUtc = const Value.absent(),
  }) : timestampSequence = Value(timestampSequence),
       snapshotSequence = Value(snapshotSequence),
       targetsSequence = Value(targetsSequence),
       lastSyncUtc = Value(lastSyncUtc);
  static Insertable<PackageTrustRow> custom({
    Expression<int>? id,
    Expression<Uint8List>? rootJson,
    Expression<int>? timestampSequence,
    Expression<int>? snapshotSequence,
    Expression<int>? targetsSequence,
    Expression<String>? timestampSha256,
    Expression<String>? snapshotSha256,
    Expression<String>? targetsSha256,
    Expression<int>? lastSyncUtc,
    Expression<int>? lastVerifiedUtc,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (rootJson != null) 'root_json': rootJson,
      if (timestampSequence != null) 'timestamp_sequence': timestampSequence,
      if (snapshotSequence != null) 'snapshot_sequence': snapshotSequence,
      if (targetsSequence != null) 'targets_sequence': targetsSequence,
      if (timestampSha256 != null) 'timestamp_sha256': timestampSha256,
      if (snapshotSha256 != null) 'snapshot_sha256': snapshotSha256,
      if (targetsSha256 != null) 'targets_sha256': targetsSha256,
      if (lastSyncUtc != null) 'last_sync_utc': lastSyncUtc,
      if (lastVerifiedUtc != null) 'last_verified_utc': lastVerifiedUtc,
    });
  }

  PackageTrustCompanion copyWith({
    Value<int>? id,
    Value<Uint8List?>? rootJson,
    Value<int>? timestampSequence,
    Value<int>? snapshotSequence,
    Value<int>? targetsSequence,
    Value<String?>? timestampSha256,
    Value<String?>? snapshotSha256,
    Value<String?>? targetsSha256,
    Value<int>? lastSyncUtc,
    Value<int?>? lastVerifiedUtc,
  }) {
    return PackageTrustCompanion(
      id: id ?? this.id,
      rootJson: rootJson ?? this.rootJson,
      timestampSequence: timestampSequence ?? this.timestampSequence,
      snapshotSequence: snapshotSequence ?? this.snapshotSequence,
      targetsSequence: targetsSequence ?? this.targetsSequence,
      timestampSha256: timestampSha256 ?? this.timestampSha256,
      snapshotSha256: snapshotSha256 ?? this.snapshotSha256,
      targetsSha256: targetsSha256 ?? this.targetsSha256,
      lastSyncUtc: lastSyncUtc ?? this.lastSyncUtc,
      lastVerifiedUtc: lastVerifiedUtc ?? this.lastVerifiedUtc,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (rootJson.present) {
      map['root_json'] = Variable<Uint8List>(rootJson.value);
    }
    if (timestampSequence.present) {
      map['timestamp_sequence'] = Variable<int>(timestampSequence.value);
    }
    if (snapshotSequence.present) {
      map['snapshot_sequence'] = Variable<int>(snapshotSequence.value);
    }
    if (targetsSequence.present) {
      map['targets_sequence'] = Variable<int>(targetsSequence.value);
    }
    if (timestampSha256.present) {
      map['timestamp_sha256'] = Variable<String>(timestampSha256.value);
    }
    if (snapshotSha256.present) {
      map['snapshot_sha256'] = Variable<String>(snapshotSha256.value);
    }
    if (targetsSha256.present) {
      map['targets_sha256'] = Variable<String>(targetsSha256.value);
    }
    if (lastSyncUtc.present) {
      map['last_sync_utc'] = Variable<int>(lastSyncUtc.value);
    }
    if (lastVerifiedUtc.present) {
      map['last_verified_utc'] = Variable<int>(lastVerifiedUtc.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PackageTrustCompanion(')
          ..write('id: $id, ')
          ..write('rootJson: $rootJson, ')
          ..write('timestampSequence: $timestampSequence, ')
          ..write('snapshotSequence: $snapshotSequence, ')
          ..write('targetsSequence: $targetsSequence, ')
          ..write('timestampSha256: $timestampSha256, ')
          ..write('snapshotSha256: $snapshotSha256, ')
          ..write('targetsSha256: $targetsSha256, ')
          ..write('lastSyncUtc: $lastSyncUtc, ')
          ..write('lastVerifiedUtc: $lastVerifiedUtc')
          ..write(')'))
        .toString();
  }
}

class $GazetteerTable extends Gazetteer
    with TableInfo<$GazetteerTable, GazetteerRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GazetteerTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _asciiNameMeta = const VerificationMeta(
    'asciiName',
  );
  @override
  late final GeneratedColumn<String> asciiName = GeneratedColumn<String>(
    'ascii_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _altNamesJsonMeta = const VerificationMeta(
    'altNamesJson',
  );
  @override
  late final GeneratedColumn<String> altNamesJson = GeneratedColumn<String>(
    'alt_names_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _countryMeta = const VerificationMeta(
    'country',
  );
  @override
  late final GeneratedColumn<String> country = GeneratedColumn<String>(
    'country',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _admin1Meta = const VerificationMeta('admin1');
  @override
  late final GeneratedColumn<String> admin1 = GeneratedColumn<String>(
    'admin1',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _latMeta = const VerificationMeta('lat');
  @override
  late final GeneratedColumn<double> lat = GeneratedColumn<double>(
    'lat',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lonMeta = const VerificationMeta('lon');
  @override
  late final GeneratedColumn<double> lon = GeneratedColumn<double>(
    'lon',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _populationMeta = const VerificationMeta(
    'population',
  );
  @override
  late final GeneratedColumn<int> population = GeneratedColumn<int>(
    'population',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _zoneIdMeta = const VerificationMeta('zoneId');
  @override
  late final GeneratedColumn<String> zoneId = GeneratedColumn<String>(
    'zone_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameNormMeta = const VerificationMeta(
    'nameNorm',
  );
  @override
  late final GeneratedColumn<String> nameNorm = GeneratedColumn<String>(
    'name_norm',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    asciiName,
    altNamesJson,
    country,
    admin1,
    lat,
    lon,
    population,
    zoneId,
    nameNorm,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'gazetteer';
  @override
  VerificationContext validateIntegrity(
    Insertable<GazetteerRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('ascii_name')) {
      context.handle(
        _asciiNameMeta,
        asciiName.isAcceptableOrUnknown(data['ascii_name']!, _asciiNameMeta),
      );
    } else if (isInserting) {
      context.missing(_asciiNameMeta);
    }
    if (data.containsKey('alt_names_json')) {
      context.handle(
        _altNamesJsonMeta,
        altNamesJson.isAcceptableOrUnknown(
          data['alt_names_json']!,
          _altNamesJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_altNamesJsonMeta);
    }
    if (data.containsKey('country')) {
      context.handle(
        _countryMeta,
        country.isAcceptableOrUnknown(data['country']!, _countryMeta),
      );
    } else if (isInserting) {
      context.missing(_countryMeta);
    }
    if (data.containsKey('admin1')) {
      context.handle(
        _admin1Meta,
        admin1.isAcceptableOrUnknown(data['admin1']!, _admin1Meta),
      );
    } else if (isInserting) {
      context.missing(_admin1Meta);
    }
    if (data.containsKey('lat')) {
      context.handle(
        _latMeta,
        lat.isAcceptableOrUnknown(data['lat']!, _latMeta),
      );
    } else if (isInserting) {
      context.missing(_latMeta);
    }
    if (data.containsKey('lon')) {
      context.handle(
        _lonMeta,
        lon.isAcceptableOrUnknown(data['lon']!, _lonMeta),
      );
    } else if (isInserting) {
      context.missing(_lonMeta);
    }
    if (data.containsKey('population')) {
      context.handle(
        _populationMeta,
        population.isAcceptableOrUnknown(data['population']!, _populationMeta),
      );
    } else if (isInserting) {
      context.missing(_populationMeta);
    }
    if (data.containsKey('zone_id')) {
      context.handle(
        _zoneIdMeta,
        zoneId.isAcceptableOrUnknown(data['zone_id']!, _zoneIdMeta),
      );
    } else if (isInserting) {
      context.missing(_zoneIdMeta);
    }
    if (data.containsKey('name_norm')) {
      context.handle(
        _nameNormMeta,
        nameNorm.isAcceptableOrUnknown(data['name_norm']!, _nameNormMeta),
      );
    } else if (isInserting) {
      context.missing(_nameNormMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GazetteerRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GazetteerRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      asciiName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ascii_name'],
      )!,
      altNamesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}alt_names_json'],
      )!,
      country: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}country'],
      )!,
      admin1: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}admin1'],
      )!,
      lat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lat'],
      )!,
      lon: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lon'],
      )!,
      population: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}population'],
      )!,
      zoneId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}zone_id'],
      )!,
      nameNorm: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_norm'],
      )!,
    );
  }

  @override
  $GazetteerTable createAlias(String alias) {
    return $GazetteerTable(attachedDatabase, alias);
  }
}

class GazetteerRow extends DataClass implements Insertable<GazetteerRow> {
  /// GeoNames id.
  final int id;

  /// Name in the source's local spelling.
  final String name;

  /// Name without diacritics.
  final String asciiName;

  /// `{"ar": [...], "en": [...]}` as in the payload.
  final String altNamesJson;

  /// ISO 3166-1 alpha-2 code.
  final String country;

  /// GeoNames admin1 code; empty when unknown.
  final String admin1;

  /// Latitude in degrees (micro-degree precision).
  final double lat;

  /// Longitude in degrees (micro-degree precision).
  final double lon;

  /// Population; 0 when unknown.
  final int population;

  /// IANA zone id.
  final String zoneId;

  /// Search key of [name].
  final String nameNorm;
  const GazetteerRow({
    required this.id,
    required this.name,
    required this.asciiName,
    required this.altNamesJson,
    required this.country,
    required this.admin1,
    required this.lat,
    required this.lon,
    required this.population,
    required this.zoneId,
    required this.nameNorm,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['ascii_name'] = Variable<String>(asciiName);
    map['alt_names_json'] = Variable<String>(altNamesJson);
    map['country'] = Variable<String>(country);
    map['admin1'] = Variable<String>(admin1);
    map['lat'] = Variable<double>(lat);
    map['lon'] = Variable<double>(lon);
    map['population'] = Variable<int>(population);
    map['zone_id'] = Variable<String>(zoneId);
    map['name_norm'] = Variable<String>(nameNorm);
    return map;
  }

  GazetteerCompanion toCompanion(bool nullToAbsent) {
    return GazetteerCompanion(
      id: Value(id),
      name: Value(name),
      asciiName: Value(asciiName),
      altNamesJson: Value(altNamesJson),
      country: Value(country),
      admin1: Value(admin1),
      lat: Value(lat),
      lon: Value(lon),
      population: Value(population),
      zoneId: Value(zoneId),
      nameNorm: Value(nameNorm),
    );
  }

  factory GazetteerRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GazetteerRow(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      asciiName: serializer.fromJson<String>(json['asciiName']),
      altNamesJson: serializer.fromJson<String>(json['altNamesJson']),
      country: serializer.fromJson<String>(json['country']),
      admin1: serializer.fromJson<String>(json['admin1']),
      lat: serializer.fromJson<double>(json['lat']),
      lon: serializer.fromJson<double>(json['lon']),
      population: serializer.fromJson<int>(json['population']),
      zoneId: serializer.fromJson<String>(json['zoneId']),
      nameNorm: serializer.fromJson<String>(json['nameNorm']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'asciiName': serializer.toJson<String>(asciiName),
      'altNamesJson': serializer.toJson<String>(altNamesJson),
      'country': serializer.toJson<String>(country),
      'admin1': serializer.toJson<String>(admin1),
      'lat': serializer.toJson<double>(lat),
      'lon': serializer.toJson<double>(lon),
      'population': serializer.toJson<int>(population),
      'zoneId': serializer.toJson<String>(zoneId),
      'nameNorm': serializer.toJson<String>(nameNorm),
    };
  }

  GazetteerRow copyWith({
    int? id,
    String? name,
    String? asciiName,
    String? altNamesJson,
    String? country,
    String? admin1,
    double? lat,
    double? lon,
    int? population,
    String? zoneId,
    String? nameNorm,
  }) => GazetteerRow(
    id: id ?? this.id,
    name: name ?? this.name,
    asciiName: asciiName ?? this.asciiName,
    altNamesJson: altNamesJson ?? this.altNamesJson,
    country: country ?? this.country,
    admin1: admin1 ?? this.admin1,
    lat: lat ?? this.lat,
    lon: lon ?? this.lon,
    population: population ?? this.population,
    zoneId: zoneId ?? this.zoneId,
    nameNorm: nameNorm ?? this.nameNorm,
  );
  GazetteerRow copyWithCompanion(GazetteerCompanion data) {
    return GazetteerRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      asciiName: data.asciiName.present ? data.asciiName.value : this.asciiName,
      altNamesJson: data.altNamesJson.present
          ? data.altNamesJson.value
          : this.altNamesJson,
      country: data.country.present ? data.country.value : this.country,
      admin1: data.admin1.present ? data.admin1.value : this.admin1,
      lat: data.lat.present ? data.lat.value : this.lat,
      lon: data.lon.present ? data.lon.value : this.lon,
      population: data.population.present
          ? data.population.value
          : this.population,
      zoneId: data.zoneId.present ? data.zoneId.value : this.zoneId,
      nameNorm: data.nameNorm.present ? data.nameNorm.value : this.nameNorm,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GazetteerRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('asciiName: $asciiName, ')
          ..write('altNamesJson: $altNamesJson, ')
          ..write('country: $country, ')
          ..write('admin1: $admin1, ')
          ..write('lat: $lat, ')
          ..write('lon: $lon, ')
          ..write('population: $population, ')
          ..write('zoneId: $zoneId, ')
          ..write('nameNorm: $nameNorm')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    asciiName,
    altNamesJson,
    country,
    admin1,
    lat,
    lon,
    population,
    zoneId,
    nameNorm,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GazetteerRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.asciiName == this.asciiName &&
          other.altNamesJson == this.altNamesJson &&
          other.country == this.country &&
          other.admin1 == this.admin1 &&
          other.lat == this.lat &&
          other.lon == this.lon &&
          other.population == this.population &&
          other.zoneId == this.zoneId &&
          other.nameNorm == this.nameNorm);
}

class GazetteerCompanion extends UpdateCompanion<GazetteerRow> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> asciiName;
  final Value<String> altNamesJson;
  final Value<String> country;
  final Value<String> admin1;
  final Value<double> lat;
  final Value<double> lon;
  final Value<int> population;
  final Value<String> zoneId;
  final Value<String> nameNorm;
  const GazetteerCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.asciiName = const Value.absent(),
    this.altNamesJson = const Value.absent(),
    this.country = const Value.absent(),
    this.admin1 = const Value.absent(),
    this.lat = const Value.absent(),
    this.lon = const Value.absent(),
    this.population = const Value.absent(),
    this.zoneId = const Value.absent(),
    this.nameNorm = const Value.absent(),
  });
  GazetteerCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String asciiName,
    required String altNamesJson,
    required String country,
    required String admin1,
    required double lat,
    required double lon,
    required int population,
    required String zoneId,
    required String nameNorm,
  }) : name = Value(name),
       asciiName = Value(asciiName),
       altNamesJson = Value(altNamesJson),
       country = Value(country),
       admin1 = Value(admin1),
       lat = Value(lat),
       lon = Value(lon),
       population = Value(population),
       zoneId = Value(zoneId),
       nameNorm = Value(nameNorm);
  static Insertable<GazetteerRow> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? asciiName,
    Expression<String>? altNamesJson,
    Expression<String>? country,
    Expression<String>? admin1,
    Expression<double>? lat,
    Expression<double>? lon,
    Expression<int>? population,
    Expression<String>? zoneId,
    Expression<String>? nameNorm,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (asciiName != null) 'ascii_name': asciiName,
      if (altNamesJson != null) 'alt_names_json': altNamesJson,
      if (country != null) 'country': country,
      if (admin1 != null) 'admin1': admin1,
      if (lat != null) 'lat': lat,
      if (lon != null) 'lon': lon,
      if (population != null) 'population': population,
      if (zoneId != null) 'zone_id': zoneId,
      if (nameNorm != null) 'name_norm': nameNorm,
    });
  }

  GazetteerCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? asciiName,
    Value<String>? altNamesJson,
    Value<String>? country,
    Value<String>? admin1,
    Value<double>? lat,
    Value<double>? lon,
    Value<int>? population,
    Value<String>? zoneId,
    Value<String>? nameNorm,
  }) {
    return GazetteerCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      asciiName: asciiName ?? this.asciiName,
      altNamesJson: altNamesJson ?? this.altNamesJson,
      country: country ?? this.country,
      admin1: admin1 ?? this.admin1,
      lat: lat ?? this.lat,
      lon: lon ?? this.lon,
      population: population ?? this.population,
      zoneId: zoneId ?? this.zoneId,
      nameNorm: nameNorm ?? this.nameNorm,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (asciiName.present) {
      map['ascii_name'] = Variable<String>(asciiName.value);
    }
    if (altNamesJson.present) {
      map['alt_names_json'] = Variable<String>(altNamesJson.value);
    }
    if (country.present) {
      map['country'] = Variable<String>(country.value);
    }
    if (admin1.present) {
      map['admin1'] = Variable<String>(admin1.value);
    }
    if (lat.present) {
      map['lat'] = Variable<double>(lat.value);
    }
    if (lon.present) {
      map['lon'] = Variable<double>(lon.value);
    }
    if (population.present) {
      map['population'] = Variable<int>(population.value);
    }
    if (zoneId.present) {
      map['zone_id'] = Variable<String>(zoneId.value);
    }
    if (nameNorm.present) {
      map['name_norm'] = Variable<String>(nameNorm.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GazetteerCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('asciiName: $asciiName, ')
          ..write('altNamesJson: $altNamesJson, ')
          ..write('country: $country, ')
          ..write('admin1: $admin1, ')
          ..write('lat: $lat, ')
          ..write('lon: $lon, ')
          ..write('population: $population, ')
          ..write('zoneId: $zoneId, ')
          ..write('nameNorm: $nameNorm')
          ..write(')'))
        .toString();
  }
}

class $GazetteerNamesTable extends GazetteerNames
    with TableInfo<$GazetteerNamesTable, GazetteerNameRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GazetteerNamesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _searchKeyMeta = const VerificationMeta(
    'searchKey',
  );
  @override
  late final GeneratedColumn<String> searchKey = GeneratedColumn<String>(
    'search_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _placeIdMeta = const VerificationMeta(
    'placeId',
  );
  @override
  late final GeneratedColumn<int> placeId = GeneratedColumn<int>(
    'place_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES gazetteer (id)',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [searchKey, placeId, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'gazetteer_names';
  @override
  VerificationContext validateIntegrity(
    Insertable<GazetteerNameRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('search_key')) {
      context.handle(
        _searchKeyMeta,
        searchKey.isAcceptableOrUnknown(data['search_key']!, _searchKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_searchKeyMeta);
    }
    if (data.containsKey('place_id')) {
      context.handle(
        _placeIdMeta,
        placeId.isAcceptableOrUnknown(data['place_id']!, _placeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_placeIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {searchKey, placeId};
  @override
  GazetteerNameRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GazetteerNameRow(
      searchKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}search_key'],
      )!,
      placeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}place_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
    );
  }

  @override
  $GazetteerNamesTable createAlias(String alias) {
    return $GazetteerNamesTable(attachedDatabase, alias);
  }

  @override
  bool get withoutRowId => true;
}

class GazetteerNameRow extends DataClass
    implements Insertable<GazetteerNameRow> {
  /// A `SearchKey` value.
  final String searchKey;

  /// The place the key belongs to.
  final int placeId;

  /// The name the key was made from.
  final String name;
  const GazetteerNameRow({
    required this.searchKey,
    required this.placeId,
    required this.name,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['search_key'] = Variable<String>(searchKey);
    map['place_id'] = Variable<int>(placeId);
    map['name'] = Variable<String>(name);
    return map;
  }

  GazetteerNamesCompanion toCompanion(bool nullToAbsent) {
    return GazetteerNamesCompanion(
      searchKey: Value(searchKey),
      placeId: Value(placeId),
      name: Value(name),
    );
  }

  factory GazetteerNameRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GazetteerNameRow(
      searchKey: serializer.fromJson<String>(json['searchKey']),
      placeId: serializer.fromJson<int>(json['placeId']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'searchKey': serializer.toJson<String>(searchKey),
      'placeId': serializer.toJson<int>(placeId),
      'name': serializer.toJson<String>(name),
    };
  }

  GazetteerNameRow copyWith({String? searchKey, int? placeId, String? name}) =>
      GazetteerNameRow(
        searchKey: searchKey ?? this.searchKey,
        placeId: placeId ?? this.placeId,
        name: name ?? this.name,
      );
  GazetteerNameRow copyWithCompanion(GazetteerNamesCompanion data) {
    return GazetteerNameRow(
      searchKey: data.searchKey.present ? data.searchKey.value : this.searchKey,
      placeId: data.placeId.present ? data.placeId.value : this.placeId,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GazetteerNameRow(')
          ..write('searchKey: $searchKey, ')
          ..write('placeId: $placeId, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(searchKey, placeId, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GazetteerNameRow &&
          other.searchKey == this.searchKey &&
          other.placeId == this.placeId &&
          other.name == this.name);
}

class GazetteerNamesCompanion extends UpdateCompanion<GazetteerNameRow> {
  final Value<String> searchKey;
  final Value<int> placeId;
  final Value<String> name;
  const GazetteerNamesCompanion({
    this.searchKey = const Value.absent(),
    this.placeId = const Value.absent(),
    this.name = const Value.absent(),
  });
  GazetteerNamesCompanion.insert({
    required String searchKey,
    required int placeId,
    required String name,
  }) : searchKey = Value(searchKey),
       placeId = Value(placeId),
       name = Value(name);
  static Insertable<GazetteerNameRow> custom({
    Expression<String>? searchKey,
    Expression<int>? placeId,
    Expression<String>? name,
  }) {
    return RawValuesInsertable({
      if (searchKey != null) 'search_key': searchKey,
      if (placeId != null) 'place_id': placeId,
      if (name != null) 'name': name,
    });
  }

  GazetteerNamesCompanion copyWith({
    Value<String>? searchKey,
    Value<int>? placeId,
    Value<String>? name,
  }) {
    return GazetteerNamesCompanion(
      searchKey: searchKey ?? this.searchKey,
      placeId: placeId ?? this.placeId,
      name: name ?? this.name,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (searchKey.present) {
      map['search_key'] = Variable<String>(searchKey.value);
    }
    if (placeId.present) {
      map['place_id'] = Variable<int>(placeId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GazetteerNamesCompanion(')
          ..write('searchKey: $searchKey, ')
          ..write('placeId: $placeId, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }
}

class $SettingsTable extends Settings
    with TableInfo<$SettingsTable, SettingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueJsonMeta = const VerificationMeta(
    'valueJson',
  );
  @override
  late final GeneratedColumn<String> valueJson = GeneratedColumn<String>(
    'value_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, valueJson];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<SettingRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value_json')) {
      context.handle(
        _valueJsonMeta,
        valueJson.isAcceptableOrUnknown(data['value_json']!, _valueJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_valueJsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  SettingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SettingRow(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      valueJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value_json'],
      )!,
    );
  }

  @override
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }
}

class SettingRow extends DataClass implements Insertable<SettingRow> {
  /// `SettingKey.wire`.
  final String key;

  /// The value as JSON.
  final String valueJson;
  const SettingRow({required this.key, required this.valueJson});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value_json'] = Variable<String>(valueJson);
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(key: Value(key), valueJson: Value(valueJson));
  }

  factory SettingRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SettingRow(
      key: serializer.fromJson<String>(json['key']),
      valueJson: serializer.fromJson<String>(json['valueJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'valueJson': serializer.toJson<String>(valueJson),
    };
  }

  SettingRow copyWith({String? key, String? valueJson}) =>
      SettingRow(key: key ?? this.key, valueJson: valueJson ?? this.valueJson);
  SettingRow copyWithCompanion(SettingsCompanion data) {
    return SettingRow(
      key: data.key.present ? data.key.value : this.key,
      valueJson: data.valueJson.present ? data.valueJson.value : this.valueJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SettingRow(')
          ..write('key: $key, ')
          ..write('valueJson: $valueJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, valueJson);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SettingRow &&
          other.key == this.key &&
          other.valueJson == this.valueJson);
}

class SettingsCompanion extends UpdateCompanion<SettingRow> {
  final Value<String> key;
  final Value<String> valueJson;
  final Value<int> rowid;
  const SettingsCompanion({
    this.key = const Value.absent(),
    this.valueJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsCompanion.insert({
    required String key,
    required String valueJson,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       valueJson = Value(valueJson);
  static Insertable<SettingRow> custom({
    Expression<String>? key,
    Expression<String>? valueJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (valueJson != null) 'value_json': valueJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? valueJson,
    Value<int>? rowid,
  }) {
    return SettingsCompanion(
      key: key ?? this.key,
      valueJson: valueJson ?? this.valueJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (valueJson.present) {
      map['value_json'] = Variable<String>(valueJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsCompanion(')
          ..write('key: $key, ')
          ..write('valueJson: $valueJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EventLogTable extends EventLog
    with TableInfo<$EventLogTable, EventLogRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EventLogTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _seqMeta = const VerificationMeta('seq');
  @override
  late final GeneratedColumn<int> seq = GeneratedColumn<int>(
    'seq',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _utcMeta = const VerificationMeta('utc');
  @override
  late final GeneratedColumn<int> utc = GeneratedColumn<int>(
    'utc',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _levelMeta = const VerificationMeta('level');
  @override
  late final GeneratedColumn<String> level = GeneratedColumn<String>(
    'level',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _attrsJsonMeta = const VerificationMeta(
    'attrsJson',
  );
  @override
  late final GeneratedColumn<String> attrsJson = GeneratedColumn<String>(
    'attrs_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [seq, utc, level, code, attrsJson];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'event_log';
  @override
  VerificationContext validateIntegrity(
    Insertable<EventLogRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('seq')) {
      context.handle(
        _seqMeta,
        seq.isAcceptableOrUnknown(data['seq']!, _seqMeta),
      );
    }
    if (data.containsKey('utc')) {
      context.handle(
        _utcMeta,
        utc.isAcceptableOrUnknown(data['utc']!, _utcMeta),
      );
    } else if (isInserting) {
      context.missing(_utcMeta);
    }
    if (data.containsKey('level')) {
      context.handle(
        _levelMeta,
        level.isAcceptableOrUnknown(data['level']!, _levelMeta),
      );
    } else if (isInserting) {
      context.missing(_levelMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('attrs_json')) {
      context.handle(
        _attrsJsonMeta,
        attrsJson.isAcceptableOrUnknown(data['attrs_json']!, _attrsJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_attrsJsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {seq};
  @override
  EventLogRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EventLogRow(
      seq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}seq'],
      )!,
      utc: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}utc'],
      )!,
      level: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}level'],
      )!,
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
      attrsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}attrs_json'],
      )!,
    );
  }

  @override
  $EventLogTable createAlias(String alias) {
    return $EventLogTable(attachedDatabase, alias);
  }
}

class EventLogRow extends DataClass implements Insertable<EventLogRow> {
  /// Insertion order.
  final int seq;

  /// When it happened (UTC epoch ms).
  final int utc;

  /// `EventLogLevel` wire value.
  final String level;

  /// `EventCode.wire`.
  final String code;

  /// The encoded `EventLogAttrs`.
  final String attrsJson;
  const EventLogRow({
    required this.seq,
    required this.utc,
    required this.level,
    required this.code,
    required this.attrsJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['seq'] = Variable<int>(seq);
    map['utc'] = Variable<int>(utc);
    map['level'] = Variable<String>(level);
    map['code'] = Variable<String>(code);
    map['attrs_json'] = Variable<String>(attrsJson);
    return map;
  }

  EventLogCompanion toCompanion(bool nullToAbsent) {
    return EventLogCompanion(
      seq: Value(seq),
      utc: Value(utc),
      level: Value(level),
      code: Value(code),
      attrsJson: Value(attrsJson),
    );
  }

  factory EventLogRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EventLogRow(
      seq: serializer.fromJson<int>(json['seq']),
      utc: serializer.fromJson<int>(json['utc']),
      level: serializer.fromJson<String>(json['level']),
      code: serializer.fromJson<String>(json['code']),
      attrsJson: serializer.fromJson<String>(json['attrsJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'seq': serializer.toJson<int>(seq),
      'utc': serializer.toJson<int>(utc),
      'level': serializer.toJson<String>(level),
      'code': serializer.toJson<String>(code),
      'attrsJson': serializer.toJson<String>(attrsJson),
    };
  }

  EventLogRow copyWith({
    int? seq,
    int? utc,
    String? level,
    String? code,
    String? attrsJson,
  }) => EventLogRow(
    seq: seq ?? this.seq,
    utc: utc ?? this.utc,
    level: level ?? this.level,
    code: code ?? this.code,
    attrsJson: attrsJson ?? this.attrsJson,
  );
  EventLogRow copyWithCompanion(EventLogCompanion data) {
    return EventLogRow(
      seq: data.seq.present ? data.seq.value : this.seq,
      utc: data.utc.present ? data.utc.value : this.utc,
      level: data.level.present ? data.level.value : this.level,
      code: data.code.present ? data.code.value : this.code,
      attrsJson: data.attrsJson.present ? data.attrsJson.value : this.attrsJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EventLogRow(')
          ..write('seq: $seq, ')
          ..write('utc: $utc, ')
          ..write('level: $level, ')
          ..write('code: $code, ')
          ..write('attrsJson: $attrsJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(seq, utc, level, code, attrsJson);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EventLogRow &&
          other.seq == this.seq &&
          other.utc == this.utc &&
          other.level == this.level &&
          other.code == this.code &&
          other.attrsJson == this.attrsJson);
}

class EventLogCompanion extends UpdateCompanion<EventLogRow> {
  final Value<int> seq;
  final Value<int> utc;
  final Value<String> level;
  final Value<String> code;
  final Value<String> attrsJson;
  const EventLogCompanion({
    this.seq = const Value.absent(),
    this.utc = const Value.absent(),
    this.level = const Value.absent(),
    this.code = const Value.absent(),
    this.attrsJson = const Value.absent(),
  });
  EventLogCompanion.insert({
    this.seq = const Value.absent(),
    required int utc,
    required String level,
    required String code,
    required String attrsJson,
  }) : utc = Value(utc),
       level = Value(level),
       code = Value(code),
       attrsJson = Value(attrsJson);
  static Insertable<EventLogRow> custom({
    Expression<int>? seq,
    Expression<int>? utc,
    Expression<String>? level,
    Expression<String>? code,
    Expression<String>? attrsJson,
  }) {
    return RawValuesInsertable({
      if (seq != null) 'seq': seq,
      if (utc != null) 'utc': utc,
      if (level != null) 'level': level,
      if (code != null) 'code': code,
      if (attrsJson != null) 'attrs_json': attrsJson,
    });
  }

  EventLogCompanion copyWith({
    Value<int>? seq,
    Value<int>? utc,
    Value<String>? level,
    Value<String>? code,
    Value<String>? attrsJson,
  }) {
    return EventLogCompanion(
      seq: seq ?? this.seq,
      utc: utc ?? this.utc,
      level: level ?? this.level,
      code: code ?? this.code,
      attrsJson: attrsJson ?? this.attrsJson,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (seq.present) {
      map['seq'] = Variable<int>(seq.value);
    }
    if (utc.present) {
      map['utc'] = Variable<int>(utc.value);
    }
    if (level.present) {
      map['level'] = Variable<String>(level.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (attrsJson.present) {
      map['attrs_json'] = Variable<String>(attrsJson.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EventLogCompanion(')
          ..write('seq: $seq, ')
          ..write('utc: $utc, ')
          ..write('level: $level, ')
          ..write('code: $code, ')
          ..write('attrsJson: $attrsJson')
          ..write(')'))
        .toString();
  }
}

abstract class _$DmDatabase extends GeneratedDatabase {
  _$DmDatabase(QueryExecutor e) : super(e);
  $DmDatabaseManager get managers => $DmDatabaseManager(this);
  late final $ActivePackagesTable activePackages = $ActivePackagesTable(this);
  late final $PackageFilesTable packageFiles = $PackageFilesTable(this);
  late final $PackageTrustTable packageTrust = $PackageTrustTable(this);
  late final $GazetteerTable gazetteer = $GazetteerTable(this);
  late final $GazetteerNamesTable gazetteerNames = $GazetteerNamesTable(this);
  late final $SettingsTable settings = $SettingsTable(this);
  late final $EventLogTable eventLog = $EventLogTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    activePackages,
    packageFiles,
    packageTrust,
    gazetteer,
    gazetteerNames,
    settings,
    eventLog,
  ];
}

typedef $$ActivePackagesTableCreateCompanionBuilder =
    ActivePackagesCompanion Function({
      required String type,
      required String version,
      required int sequence,
      required String sha256,
      required String source,
      required int activatedUtc,
      Value<String?> previousVersion,
      Value<int> rowid,
    });
typedef $$ActivePackagesTableUpdateCompanionBuilder =
    ActivePackagesCompanion Function({
      Value<String> type,
      Value<String> version,
      Value<int> sequence,
      Value<String> sha256,
      Value<String> source,
      Value<int> activatedUtc,
      Value<String?> previousVersion,
      Value<int> rowid,
    });

class $$ActivePackagesTableFilterComposer
    extends Composer<_$DmDatabase, $ActivePackagesTable> {
  $$ActivePackagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sequence => $composableBuilder(
    column: $table.sequence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sha256 => $composableBuilder(
    column: $table.sha256,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get activatedUtc => $composableBuilder(
    column: $table.activatedUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get previousVersion => $composableBuilder(
    column: $table.previousVersion,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ActivePackagesTableOrderingComposer
    extends Composer<_$DmDatabase, $ActivePackagesTable> {
  $$ActivePackagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sequence => $composableBuilder(
    column: $table.sequence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sha256 => $composableBuilder(
    column: $table.sha256,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get activatedUtc => $composableBuilder(
    column: $table.activatedUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get previousVersion => $composableBuilder(
    column: $table.previousVersion,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ActivePackagesTableAnnotationComposer
    extends Composer<_$DmDatabase, $ActivePackagesTable> {
  $$ActivePackagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<int> get sequence =>
      $composableBuilder(column: $table.sequence, builder: (column) => column);

  GeneratedColumn<String> get sha256 =>
      $composableBuilder(column: $table.sha256, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<int> get activatedUtc => $composableBuilder(
    column: $table.activatedUtc,
    builder: (column) => column,
  );

  GeneratedColumn<String> get previousVersion => $composableBuilder(
    column: $table.previousVersion,
    builder: (column) => column,
  );
}

class $$ActivePackagesTableTableManager
    extends
        RootTableManager<
          _$DmDatabase,
          $ActivePackagesTable,
          ActivePackageRow,
          $$ActivePackagesTableFilterComposer,
          $$ActivePackagesTableOrderingComposer,
          $$ActivePackagesTableAnnotationComposer,
          $$ActivePackagesTableCreateCompanionBuilder,
          $$ActivePackagesTableUpdateCompanionBuilder,
          (
            ActivePackageRow,
            BaseReferences<
              _$DmDatabase,
              $ActivePackagesTable,
              ActivePackageRow
            >,
          ),
          ActivePackageRow,
          PrefetchHooks Function()
        > {
  $$ActivePackagesTableTableManager(_$DmDatabase db, $ActivePackagesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ActivePackagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ActivePackagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ActivePackagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> type = const Value.absent(),
                Value<String> version = const Value.absent(),
                Value<int> sequence = const Value.absent(),
                Value<String> sha256 = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<int> activatedUtc = const Value.absent(),
                Value<String?> previousVersion = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ActivePackagesCompanion(
                type: type,
                version: version,
                sequence: sequence,
                sha256: sha256,
                source: source,
                activatedUtc: activatedUtc,
                previousVersion: previousVersion,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String type,
                required String version,
                required int sequence,
                required String sha256,
                required String source,
                required int activatedUtc,
                Value<String?> previousVersion = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ActivePackagesCompanion.insert(
                type: type,
                version: version,
                sequence: sequence,
                sha256: sha256,
                source: source,
                activatedUtc: activatedUtc,
                previousVersion: previousVersion,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ActivePackagesTable, ActivePackageRow>(table),
                  BaseReferences<
                    _$DmDatabase,
                    $ActivePackagesTable,
                    ActivePackageRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ActivePackagesTableProcessedTableManager =
    ProcessedTableManager<
      _$DmDatabase,
      $ActivePackagesTable,
      ActivePackageRow,
      $$ActivePackagesTableFilterComposer,
      $$ActivePackagesTableOrderingComposer,
      $$ActivePackagesTableAnnotationComposer,
      $$ActivePackagesTableCreateCompanionBuilder,
      $$ActivePackagesTableUpdateCompanionBuilder,
      (
        ActivePackageRow,
        BaseReferences<_$DmDatabase, $ActivePackagesTable, ActivePackageRow>,
      ),
      ActivePackageRow,
      PrefetchHooks Function()
    >;
typedef $$PackageFilesTableCreateCompanionBuilder =
    PackageFilesCompanion Function({
      required String type,
      required String version,
      required String path,
      required String sha256,
      required String source,
      required String state,
      required int updatedUtc,
      Value<int> rowid,
    });
typedef $$PackageFilesTableUpdateCompanionBuilder =
    PackageFilesCompanion Function({
      Value<String> type,
      Value<String> version,
      Value<String> path,
      Value<String> sha256,
      Value<String> source,
      Value<String> state,
      Value<int> updatedUtc,
      Value<int> rowid,
    });

class $$PackageFilesTableFilterComposer
    extends Composer<_$DmDatabase, $PackageFilesTable> {
  $$PackageFilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sha256 => $composableBuilder(
    column: $table.sha256,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedUtc => $composableBuilder(
    column: $table.updatedUtc,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PackageFilesTableOrderingComposer
    extends Composer<_$DmDatabase, $PackageFilesTable> {
  $$PackageFilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sha256 => $composableBuilder(
    column: $table.sha256,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedUtc => $composableBuilder(
    column: $table.updatedUtc,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PackageFilesTableAnnotationComposer
    extends Composer<_$DmDatabase, $PackageFilesTable> {
  $$PackageFilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get path =>
      $composableBuilder(column: $table.path, builder: (column) => column);

  GeneratedColumn<String> get sha256 =>
      $composableBuilder(column: $table.sha256, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<int> get updatedUtc => $composableBuilder(
    column: $table.updatedUtc,
    builder: (column) => column,
  );
}

class $$PackageFilesTableTableManager
    extends
        RootTableManager<
          _$DmDatabase,
          $PackageFilesTable,
          PackageFileRow,
          $$PackageFilesTableFilterComposer,
          $$PackageFilesTableOrderingComposer,
          $$PackageFilesTableAnnotationComposer,
          $$PackageFilesTableCreateCompanionBuilder,
          $$PackageFilesTableUpdateCompanionBuilder,
          (
            PackageFileRow,
            BaseReferences<_$DmDatabase, $PackageFilesTable, PackageFileRow>,
          ),
          PackageFileRow,
          PrefetchHooks Function()
        > {
  $$PackageFilesTableTableManager(_$DmDatabase db, $PackageFilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PackageFilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PackageFilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PackageFilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> type = const Value.absent(),
                Value<String> version = const Value.absent(),
                Value<String> path = const Value.absent(),
                Value<String> sha256 = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<int> updatedUtc = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PackageFilesCompanion(
                type: type,
                version: version,
                path: path,
                sha256: sha256,
                source: source,
                state: state,
                updatedUtc: updatedUtc,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String type,
                required String version,
                required String path,
                required String sha256,
                required String source,
                required String state,
                required int updatedUtc,
                Value<int> rowid = const Value.absent(),
              }) => PackageFilesCompanion.insert(
                type: type,
                version: version,
                path: path,
                sha256: sha256,
                source: source,
                state: state,
                updatedUtc: updatedUtc,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PackageFilesTable, PackageFileRow>(table),
                  BaseReferences<
                    _$DmDatabase,
                    $PackageFilesTable,
                    PackageFileRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PackageFilesTableProcessedTableManager =
    ProcessedTableManager<
      _$DmDatabase,
      $PackageFilesTable,
      PackageFileRow,
      $$PackageFilesTableFilterComposer,
      $$PackageFilesTableOrderingComposer,
      $$PackageFilesTableAnnotationComposer,
      $$PackageFilesTableCreateCompanionBuilder,
      $$PackageFilesTableUpdateCompanionBuilder,
      (
        PackageFileRow,
        BaseReferences<_$DmDatabase, $PackageFilesTable, PackageFileRow>,
      ),
      PackageFileRow,
      PrefetchHooks Function()
    >;
typedef $$PackageTrustTableCreateCompanionBuilder =
    PackageTrustCompanion Function({
      Value<int> id,
      Value<Uint8List?> rootJson,
      required int timestampSequence,
      required int snapshotSequence,
      required int targetsSequence,
      Value<String?> timestampSha256,
      Value<String?> snapshotSha256,
      Value<String?> targetsSha256,
      required int lastSyncUtc,
      Value<int?> lastVerifiedUtc,
    });
typedef $$PackageTrustTableUpdateCompanionBuilder =
    PackageTrustCompanion Function({
      Value<int> id,
      Value<Uint8List?> rootJson,
      Value<int> timestampSequence,
      Value<int> snapshotSequence,
      Value<int> targetsSequence,
      Value<String?> timestampSha256,
      Value<String?> snapshotSha256,
      Value<String?> targetsSha256,
      Value<int> lastSyncUtc,
      Value<int?> lastVerifiedUtc,
    });

class $$PackageTrustTableFilterComposer
    extends Composer<_$DmDatabase, $PackageTrustTable> {
  $$PackageTrustTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get rootJson => $composableBuilder(
    column: $table.rootJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timestampSequence => $composableBuilder(
    column: $table.timestampSequence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get snapshotSequence => $composableBuilder(
    column: $table.snapshotSequence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetsSequence => $composableBuilder(
    column: $table.targetsSequence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get timestampSha256 => $composableBuilder(
    column: $table.timestampSha256,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get snapshotSha256 => $composableBuilder(
    column: $table.snapshotSha256,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetsSha256 => $composableBuilder(
    column: $table.targetsSha256,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastSyncUtc => $composableBuilder(
    column: $table.lastSyncUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastVerifiedUtc => $composableBuilder(
    column: $table.lastVerifiedUtc,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PackageTrustTableOrderingComposer
    extends Composer<_$DmDatabase, $PackageTrustTable> {
  $$PackageTrustTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get rootJson => $composableBuilder(
    column: $table.rootJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timestampSequence => $composableBuilder(
    column: $table.timestampSequence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get snapshotSequence => $composableBuilder(
    column: $table.snapshotSequence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetsSequence => $composableBuilder(
    column: $table.targetsSequence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get timestampSha256 => $composableBuilder(
    column: $table.timestampSha256,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get snapshotSha256 => $composableBuilder(
    column: $table.snapshotSha256,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetsSha256 => $composableBuilder(
    column: $table.targetsSha256,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastSyncUtc => $composableBuilder(
    column: $table.lastSyncUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastVerifiedUtc => $composableBuilder(
    column: $table.lastVerifiedUtc,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PackageTrustTableAnnotationComposer
    extends Composer<_$DmDatabase, $PackageTrustTable> {
  $$PackageTrustTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<Uint8List> get rootJson =>
      $composableBuilder(column: $table.rootJson, builder: (column) => column);

  GeneratedColumn<int> get timestampSequence => $composableBuilder(
    column: $table.timestampSequence,
    builder: (column) => column,
  );

  GeneratedColumn<int> get snapshotSequence => $composableBuilder(
    column: $table.snapshotSequence,
    builder: (column) => column,
  );

  GeneratedColumn<int> get targetsSequence => $composableBuilder(
    column: $table.targetsSequence,
    builder: (column) => column,
  );

  GeneratedColumn<String> get timestampSha256 => $composableBuilder(
    column: $table.timestampSha256,
    builder: (column) => column,
  );

  GeneratedColumn<String> get snapshotSha256 => $composableBuilder(
    column: $table.snapshotSha256,
    builder: (column) => column,
  );

  GeneratedColumn<String> get targetsSha256 => $composableBuilder(
    column: $table.targetsSha256,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastSyncUtc => $composableBuilder(
    column: $table.lastSyncUtc,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastVerifiedUtc => $composableBuilder(
    column: $table.lastVerifiedUtc,
    builder: (column) => column,
  );
}

class $$PackageTrustTableTableManager
    extends
        RootTableManager<
          _$DmDatabase,
          $PackageTrustTable,
          PackageTrustRow,
          $$PackageTrustTableFilterComposer,
          $$PackageTrustTableOrderingComposer,
          $$PackageTrustTableAnnotationComposer,
          $$PackageTrustTableCreateCompanionBuilder,
          $$PackageTrustTableUpdateCompanionBuilder,
          (
            PackageTrustRow,
            BaseReferences<_$DmDatabase, $PackageTrustTable, PackageTrustRow>,
          ),
          PackageTrustRow,
          PrefetchHooks Function()
        > {
  $$PackageTrustTableTableManager(_$DmDatabase db, $PackageTrustTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PackageTrustTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PackageTrustTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PackageTrustTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<Uint8List?> rootJson = const Value.absent(),
                Value<int> timestampSequence = const Value.absent(),
                Value<int> snapshotSequence = const Value.absent(),
                Value<int> targetsSequence = const Value.absent(),
                Value<String?> timestampSha256 = const Value.absent(),
                Value<String?> snapshotSha256 = const Value.absent(),
                Value<String?> targetsSha256 = const Value.absent(),
                Value<int> lastSyncUtc = const Value.absent(),
                Value<int?> lastVerifiedUtc = const Value.absent(),
              }) => PackageTrustCompanion(
                id: id,
                rootJson: rootJson,
                timestampSequence: timestampSequence,
                snapshotSequence: snapshotSequence,
                targetsSequence: targetsSequence,
                timestampSha256: timestampSha256,
                snapshotSha256: snapshotSha256,
                targetsSha256: targetsSha256,
                lastSyncUtc: lastSyncUtc,
                lastVerifiedUtc: lastVerifiedUtc,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<Uint8List?> rootJson = const Value.absent(),
                required int timestampSequence,
                required int snapshotSequence,
                required int targetsSequence,
                Value<String?> timestampSha256 = const Value.absent(),
                Value<String?> snapshotSha256 = const Value.absent(),
                Value<String?> targetsSha256 = const Value.absent(),
                required int lastSyncUtc,
                Value<int?> lastVerifiedUtc = const Value.absent(),
              }) => PackageTrustCompanion.insert(
                id: id,
                rootJson: rootJson,
                timestampSequence: timestampSequence,
                snapshotSequence: snapshotSequence,
                targetsSequence: targetsSequence,
                timestampSha256: timestampSha256,
                snapshotSha256: snapshotSha256,
                targetsSha256: targetsSha256,
                lastSyncUtc: lastSyncUtc,
                lastVerifiedUtc: lastVerifiedUtc,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PackageTrustTable, PackageTrustRow>(table),
                  BaseReferences<
                    _$DmDatabase,
                    $PackageTrustTable,
                    PackageTrustRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PackageTrustTableProcessedTableManager =
    ProcessedTableManager<
      _$DmDatabase,
      $PackageTrustTable,
      PackageTrustRow,
      $$PackageTrustTableFilterComposer,
      $$PackageTrustTableOrderingComposer,
      $$PackageTrustTableAnnotationComposer,
      $$PackageTrustTableCreateCompanionBuilder,
      $$PackageTrustTableUpdateCompanionBuilder,
      (
        PackageTrustRow,
        BaseReferences<_$DmDatabase, $PackageTrustTable, PackageTrustRow>,
      ),
      PackageTrustRow,
      PrefetchHooks Function()
    >;
typedef $$GazetteerTableCreateCompanionBuilder = GazetteerCompanion Function({
  Value<int> id,
  required String name,
  required String asciiName,
  required String altNamesJson,
  required String country,
  required String admin1,
  required double lat,
  required double lon,
  required int population,
  required String zoneId,
  required String nameNorm,
});
typedef $$GazetteerTableUpdateCompanionBuilder = GazetteerCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String> asciiName,
  Value<String> altNamesJson,
  Value<String> country,
  Value<String> admin1,
  Value<double> lat,
  Value<double> lon,
  Value<int> population,
  Value<String> zoneId,
  Value<String> nameNorm,
});

final class $$GazetteerTableReferences
    extends BaseReferences<_$DmDatabase, $GazetteerTable, GazetteerRow> {
  $$GazetteerTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$GazetteerNamesTable, List<GazetteerNameRow>>
  _gazetteerNamesRefsTable(_$DmDatabase db) => MultiTypedResultKey.fromTable(
    db.gazetteerNames,
    aliasName: 'gazetteer__id__gazetteer_names__place_id',
  );

  $$GazetteerNamesTableProcessedTableManager get gazetteerNamesRefs {
    final manager = $$GazetteerNamesTableTableManager(
      $_db,
      $_db.gazetteerNames,
    ).filter((f) => f.placeId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_gazetteerNamesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$GazetteerTableFilterComposer
    extends Composer<_$DmDatabase, $GazetteerTable> {
  $$GazetteerTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get asciiName => $composableBuilder(
    column: $table.asciiName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get altNamesJson => $composableBuilder(
    column: $table.altNamesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get country => $composableBuilder(
    column: $table.country,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get admin1 => $composableBuilder(
    column: $table.admin1,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lon => $composableBuilder(
    column: $table.lon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get population => $composableBuilder(
    column: $table.population,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get zoneId => $composableBuilder(
    column: $table.zoneId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameNorm => $composableBuilder(
    column: $table.nameNorm,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> gazetteerNamesRefs(
    Expression<bool> Function($$GazetteerNamesTableFilterComposer f) f,
  ) {
    final $$GazetteerNamesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.gazetteerNames,
      getReferencedColumn: (t) => t.placeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GazetteerNamesTableFilterComposer(
            $db: $db,
            $table: $db.gazetteerNames,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$GazetteerTableOrderingComposer
    extends Composer<_$DmDatabase, $GazetteerTable> {
  $$GazetteerTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get asciiName => $composableBuilder(
    column: $table.asciiName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get altNamesJson => $composableBuilder(
    column: $table.altNamesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get country => $composableBuilder(
    column: $table.country,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get admin1 => $composableBuilder(
    column: $table.admin1,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lon => $composableBuilder(
    column: $table.lon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get population => $composableBuilder(
    column: $table.population,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get zoneId => $composableBuilder(
    column: $table.zoneId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameNorm => $composableBuilder(
    column: $table.nameNorm,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GazetteerTableAnnotationComposer
    extends Composer<_$DmDatabase, $GazetteerTable> {
  $$GazetteerTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get asciiName =>
      $composableBuilder(column: $table.asciiName, builder: (column) => column);

  GeneratedColumn<String> get altNamesJson => $composableBuilder(
    column: $table.altNamesJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get country =>
      $composableBuilder(column: $table.country, builder: (column) => column);

  GeneratedColumn<String> get admin1 =>
      $composableBuilder(column: $table.admin1, builder: (column) => column);

  GeneratedColumn<double> get lat =>
      $composableBuilder(column: $table.lat, builder: (column) => column);

  GeneratedColumn<double> get lon =>
      $composableBuilder(column: $table.lon, builder: (column) => column);

  GeneratedColumn<int> get population => $composableBuilder(
    column: $table.population,
    builder: (column) => column,
  );

  GeneratedColumn<String> get zoneId =>
      $composableBuilder(column: $table.zoneId, builder: (column) => column);

  GeneratedColumn<String> get nameNorm =>
      $composableBuilder(column: $table.nameNorm, builder: (column) => column);

  Expression<T> gazetteerNamesRefs<T extends Object>(
    Expression<T> Function($$GazetteerNamesTableAnnotationComposer a) f,
  ) {
    final $$GazetteerNamesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.gazetteerNames,
      getReferencedColumn: (t) => t.placeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GazetteerNamesTableAnnotationComposer(
            $db: $db,
            $table: $db.gazetteerNames,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$GazetteerTableTableManager
    extends
        RootTableManager<
          _$DmDatabase,
          $GazetteerTable,
          GazetteerRow,
          $$GazetteerTableFilterComposer,
          $$GazetteerTableOrderingComposer,
          $$GazetteerTableAnnotationComposer,
          $$GazetteerTableCreateCompanionBuilder,
          $$GazetteerTableUpdateCompanionBuilder,
          (GazetteerRow, $$GazetteerTableReferences),
          GazetteerRow,
          PrefetchHooks Function({bool gazetteerNamesRefs})
        > {
  $$GazetteerTableTableManager(_$DmDatabase db, $GazetteerTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GazetteerTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GazetteerTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GazetteerTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> asciiName = const Value.absent(),
                Value<String> altNamesJson = const Value.absent(),
                Value<String> country = const Value.absent(),
                Value<String> admin1 = const Value.absent(),
                Value<double> lat = const Value.absent(),
                Value<double> lon = const Value.absent(),
                Value<int> population = const Value.absent(),
                Value<String> zoneId = const Value.absent(),
                Value<String> nameNorm = const Value.absent(),
              }) => GazetteerCompanion(
                id: id,
                name: name,
                asciiName: asciiName,
                altNamesJson: altNamesJson,
                country: country,
                admin1: admin1,
                lat: lat,
                lon: lon,
                population: population,
                zoneId: zoneId,
                nameNorm: nameNorm,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String asciiName,
                required String altNamesJson,
                required String country,
                required String admin1,
                required double lat,
                required double lon,
                required int population,
                required String zoneId,
                required String nameNorm,
              }) => GazetteerCompanion.insert(
                id: id,
                name: name,
                asciiName: asciiName,
                altNamesJson: altNamesJson,
                country: country,
                admin1: admin1,
                lat: lat,
                lon: lon,
                population: population,
                zoneId: zoneId,
                nameNorm: nameNorm,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$GazetteerTable, GazetteerRow>(table),
                  $$GazetteerTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({gazetteerNamesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (gazetteerNamesRefs) db.gazetteerNames,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (gazetteerNamesRefs)
                    await $_getPrefetchedData<
                      GazetteerRow,
                      $GazetteerTable,
                      GazetteerNameRow
                    >(
                      currentTable: table,
                      referencedTable: $$GazetteerTableReferences
                          ._gazetteerNamesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$GazetteerTableReferences(
                            db,
                            table,
                            p0,
                          ).gazetteerNamesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.placeId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$GazetteerTableProcessedTableManager =
    ProcessedTableManager<
      _$DmDatabase,
      $GazetteerTable,
      GazetteerRow,
      $$GazetteerTableFilterComposer,
      $$GazetteerTableOrderingComposer,
      $$GazetteerTableAnnotationComposer,
      $$GazetteerTableCreateCompanionBuilder,
      $$GazetteerTableUpdateCompanionBuilder,
      (GazetteerRow, $$GazetteerTableReferences),
      GazetteerRow,
      PrefetchHooks Function({bool gazetteerNamesRefs})
    >;
typedef $$GazetteerNamesTableCreateCompanionBuilder =
    GazetteerNamesCompanion Function({
      required String searchKey,
      required int placeId,
      required String name,
    });
typedef $$GazetteerNamesTableUpdateCompanionBuilder =
    GazetteerNamesCompanion Function({
      Value<String> searchKey,
      Value<int> placeId,
      Value<String> name,
    });

final class $$GazetteerNamesTableReferences
    extends
        BaseReferences<_$DmDatabase, $GazetteerNamesTable, GazetteerNameRow> {
  $$GazetteerNamesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $GazetteerTable _placeIdTable(_$DmDatabase db) =>
      db.gazetteer.createAlias('gazetteer_names__place_id__gazetteer__id');

  $$GazetteerTableProcessedTableManager get placeId {
    final $_column = $_itemColumn<int>('place_id')!;

    final manager = $$GazetteerTableTableManager(
      $_db,
      $_db.gazetteer,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_placeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$GazetteerNamesTableFilterComposer
    extends Composer<_$DmDatabase, $GazetteerNamesTable> {
  $$GazetteerNamesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get searchKey => $composableBuilder(
    column: $table.searchKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  $$GazetteerTableFilterComposer get placeId {
    final $$GazetteerTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.placeId,
      referencedTable: $db.gazetteer,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GazetteerTableFilterComposer(
            $db: $db,
            $table: $db.gazetteer,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GazetteerNamesTableOrderingComposer
    extends Composer<_$DmDatabase, $GazetteerNamesTable> {
  $$GazetteerNamesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get searchKey => $composableBuilder(
    column: $table.searchKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  $$GazetteerTableOrderingComposer get placeId {
    final $$GazetteerTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.placeId,
      referencedTable: $db.gazetteer,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GazetteerTableOrderingComposer(
            $db: $db,
            $table: $db.gazetteer,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GazetteerNamesTableAnnotationComposer
    extends Composer<_$DmDatabase, $GazetteerNamesTable> {
  $$GazetteerNamesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get searchKey =>
      $composableBuilder(column: $table.searchKey, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  $$GazetteerTableAnnotationComposer get placeId {
    final $$GazetteerTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.placeId,
      referencedTable: $db.gazetteer,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GazetteerTableAnnotationComposer(
            $db: $db,
            $table: $db.gazetteer,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GazetteerNamesTableTableManager
    extends
        RootTableManager<
          _$DmDatabase,
          $GazetteerNamesTable,
          GazetteerNameRow,
          $$GazetteerNamesTableFilterComposer,
          $$GazetteerNamesTableOrderingComposer,
          $$GazetteerNamesTableAnnotationComposer,
          $$GazetteerNamesTableCreateCompanionBuilder,
          $$GazetteerNamesTableUpdateCompanionBuilder,
          (GazetteerNameRow, $$GazetteerNamesTableReferences),
          GazetteerNameRow,
          PrefetchHooks Function({bool placeId})
        > {
  $$GazetteerNamesTableTableManager(_$DmDatabase db, $GazetteerNamesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GazetteerNamesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GazetteerNamesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GazetteerNamesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> searchKey = const Value.absent(),
                Value<int> placeId = const Value.absent(),
                Value<String> name = const Value.absent(),
              }) => GazetteerNamesCompanion(
                searchKey: searchKey,
                placeId: placeId,
                name: name,
              ),
          createCompanionCallback:
              ({
                required String searchKey,
                required int placeId,
                required String name,
              }) => GazetteerNamesCompanion.insert(
                searchKey: searchKey,
                placeId: placeId,
                name: name,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$GazetteerNamesTable, GazetteerNameRow>(table),
                  $$GazetteerNamesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({placeId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (placeId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.placeId,
                        referencedTable: $$GazetteerNamesTableReferences
                            ._placeIdTable(db),
                        referencedColumn: $$GazetteerNamesTableReferences
                            ._placeIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$GazetteerNamesTableProcessedTableManager =
    ProcessedTableManager<
      _$DmDatabase,
      $GazetteerNamesTable,
      GazetteerNameRow,
      $$GazetteerNamesTableFilterComposer,
      $$GazetteerNamesTableOrderingComposer,
      $$GazetteerNamesTableAnnotationComposer,
      $$GazetteerNamesTableCreateCompanionBuilder,
      $$GazetteerNamesTableUpdateCompanionBuilder,
      (GazetteerNameRow, $$GazetteerNamesTableReferences),
      GazetteerNameRow,
      PrefetchHooks Function({bool placeId})
    >;
typedef $$SettingsTableCreateCompanionBuilder = SettingsCompanion Function({
  required String key,
  required String valueJson,
  Value<int> rowid,
});
typedef $$SettingsTableUpdateCompanionBuilder = SettingsCompanion Function({
  Value<String> key,
  Value<String> valueJson,
  Value<int> rowid,
});

class $$SettingsTableFilterComposer
    extends Composer<_$DmDatabase, $SettingsTable> {
  $$SettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get valueJson => $composableBuilder(
    column: $table.valueJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SettingsTableOrderingComposer
    extends Composer<_$DmDatabase, $SettingsTable> {
  $$SettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get valueJson => $composableBuilder(
    column: $table.valueJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SettingsTableAnnotationComposer
    extends Composer<_$DmDatabase, $SettingsTable> {
  $$SettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get valueJson =>
      $composableBuilder(column: $table.valueJson, builder: (column) => column);
}

class $$SettingsTableTableManager
    extends
        RootTableManager<
          _$DmDatabase,
          $SettingsTable,
          SettingRow,
          $$SettingsTableFilterComposer,
          $$SettingsTableOrderingComposer,
          $$SettingsTableAnnotationComposer,
          $$SettingsTableCreateCompanionBuilder,
          $$SettingsTableUpdateCompanionBuilder,
          (
            SettingRow,
            BaseReferences<_$DmDatabase, $SettingsTable, SettingRow>,
          ),
          SettingRow,
          PrefetchHooks Function()
        > {
  $$SettingsTableTableManager(_$DmDatabase db, $SettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> valueJson = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => SettingsCompanion(key: key, valueJson: valueJson, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String valueJson,
                Value<int> rowid = const Value.absent(),
              }) => SettingsCompanion.insert(
                key: key,
                valueJson: valueJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SettingsTable, SettingRow>(table),
                  BaseReferences<_$DmDatabase, $SettingsTable, SettingRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$DmDatabase,
      $SettingsTable,
      SettingRow,
      $$SettingsTableFilterComposer,
      $$SettingsTableOrderingComposer,
      $$SettingsTableAnnotationComposer,
      $$SettingsTableCreateCompanionBuilder,
      $$SettingsTableUpdateCompanionBuilder,
      (SettingRow, BaseReferences<_$DmDatabase, $SettingsTable, SettingRow>),
      SettingRow,
      PrefetchHooks Function()
    >;
typedef $$EventLogTableCreateCompanionBuilder = EventLogCompanion Function({
  Value<int> seq,
  required int utc,
  required String level,
  required String code,
  required String attrsJson,
});
typedef $$EventLogTableUpdateCompanionBuilder = EventLogCompanion Function({
  Value<int> seq,
  Value<int> utc,
  Value<String> level,
  Value<String> code,
  Value<String> attrsJson,
});

class $$EventLogTableFilterComposer
    extends Composer<_$DmDatabase, $EventLogTable> {
  $$EventLogTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get seq => $composableBuilder(
    column: $table.seq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get utc => $composableBuilder(
    column: $table.utc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get attrsJson => $composableBuilder(
    column: $table.attrsJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$EventLogTableOrderingComposer
    extends Composer<_$DmDatabase, $EventLogTable> {
  $$EventLogTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get seq => $composableBuilder(
    column: $table.seq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get utc => $composableBuilder(
    column: $table.utc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get attrsJson => $composableBuilder(
    column: $table.attrsJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EventLogTableAnnotationComposer
    extends Composer<_$DmDatabase, $EventLogTable> {
  $$EventLogTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get seq =>
      $composableBuilder(column: $table.seq, builder: (column) => column);

  GeneratedColumn<int> get utc =>
      $composableBuilder(column: $table.utc, builder: (column) => column);

  GeneratedColumn<String> get level =>
      $composableBuilder(column: $table.level, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get attrsJson =>
      $composableBuilder(column: $table.attrsJson, builder: (column) => column);
}

class $$EventLogTableTableManager
    extends
        RootTableManager<
          _$DmDatabase,
          $EventLogTable,
          EventLogRow,
          $$EventLogTableFilterComposer,
          $$EventLogTableOrderingComposer,
          $$EventLogTableAnnotationComposer,
          $$EventLogTableCreateCompanionBuilder,
          $$EventLogTableUpdateCompanionBuilder,
          (
            EventLogRow,
            BaseReferences<_$DmDatabase, $EventLogTable, EventLogRow>,
          ),
          EventLogRow,
          PrefetchHooks Function()
        > {
  $$EventLogTableTableManager(_$DmDatabase db, $EventLogTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EventLogTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EventLogTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EventLogTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> seq = const Value.absent(),
                Value<int> utc = const Value.absent(),
                Value<String> level = const Value.absent(),
                Value<String> code = const Value.absent(),
                Value<String> attrsJson = const Value.absent(),
              }) => EventLogCompanion(
                seq: seq,
                utc: utc,
                level: level,
                code: code,
                attrsJson: attrsJson,
              ),
          createCompanionCallback:
              ({
                Value<int> seq = const Value.absent(),
                required int utc,
                required String level,
                required String code,
                required String attrsJson,
              }) => EventLogCompanion.insert(
                seq: seq,
                utc: utc,
                level: level,
                code: code,
                attrsJson: attrsJson,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$EventLogTable, EventLogRow>(table),
                  BaseReferences<_$DmDatabase, $EventLogTable, EventLogRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EventLogTableProcessedTableManager =
    ProcessedTableManager<
      _$DmDatabase,
      $EventLogTable,
      EventLogRow,
      $$EventLogTableFilterComposer,
      $$EventLogTableOrderingComposer,
      $$EventLogTableAnnotationComposer,
      $$EventLogTableCreateCompanionBuilder,
      $$EventLogTableUpdateCompanionBuilder,
      (EventLogRow, BaseReferences<_$DmDatabase, $EventLogTable, EventLogRow>),
      EventLogRow,
      PrefetchHooks Function()
    >;

class $DmDatabaseManager {
  final _$DmDatabase _db;
  $DmDatabaseManager(this._db);
  $$ActivePackagesTableTableManager get activePackages =>
      $$ActivePackagesTableTableManager(_db, _db.activePackages);
  $$PackageFilesTableTableManager get packageFiles =>
      $$PackageFilesTableTableManager(_db, _db.packageFiles);
  $$PackageTrustTableTableManager get packageTrust =>
      $$PackageTrustTableTableManager(_db, _db.packageTrust);
  $$GazetteerTableTableManager get gazetteer =>
      $$GazetteerTableTableManager(_db, _db.gazetteer);
  $$GazetteerNamesTableTableManager get gazetteerNames =>
      $$GazetteerNamesTableTableManager(_db, _db.gazetteerNames);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
  $$EventLogTableTableManager get eventLog =>
      $$EventLogTableTableManager(_db, _db.eventLog);
}
