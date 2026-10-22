// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'packages_database.dart';

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

abstract class _$PackagesDatabase extends GeneratedDatabase {
  _$PackagesDatabase(QueryExecutor e) : super(e);
  $PackagesDatabaseManager get managers => $PackagesDatabaseManager(this);
  late final $ActivePackagesTable activePackages = $ActivePackagesTable(this);
  late final $PackageFilesTable packageFiles = $PackageFilesTable(this);
  late final $PackageTrustTable packageTrust = $PackageTrustTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    activePackages,
    packageFiles,
    packageTrust,
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
    extends Composer<_$PackagesDatabase, $ActivePackagesTable> {
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
    extends Composer<_$PackagesDatabase, $ActivePackagesTable> {
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
    extends Composer<_$PackagesDatabase, $ActivePackagesTable> {
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
          _$PackagesDatabase,
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
              _$PackagesDatabase,
              $ActivePackagesTable,
              ActivePackageRow
            >,
          ),
          ActivePackageRow,
          PrefetchHooks Function()
        > {
  $$ActivePackagesTableTableManager(
    _$PackagesDatabase db,
    $ActivePackagesTable table,
  ) : super(
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
                    _$PackagesDatabase,
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
      _$PackagesDatabase,
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
          _$PackagesDatabase,
          $ActivePackagesTable,
          ActivePackageRow
        >,
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
    extends Composer<_$PackagesDatabase, $PackageFilesTable> {
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
    extends Composer<_$PackagesDatabase, $PackageFilesTable> {
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
    extends Composer<_$PackagesDatabase, $PackageFilesTable> {
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
          _$PackagesDatabase,
          $PackageFilesTable,
          PackageFileRow,
          $$PackageFilesTableFilterComposer,
          $$PackageFilesTableOrderingComposer,
          $$PackageFilesTableAnnotationComposer,
          $$PackageFilesTableCreateCompanionBuilder,
          $$PackageFilesTableUpdateCompanionBuilder,
          (
            PackageFileRow,
            BaseReferences<
              _$PackagesDatabase,
              $PackageFilesTable,
              PackageFileRow
            >,
          ),
          PackageFileRow,
          PrefetchHooks Function()
        > {
  $$PackageFilesTableTableManager(
    _$PackagesDatabase db,
    $PackageFilesTable table,
  ) : super(
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
                    _$PackagesDatabase,
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
      _$PackagesDatabase,
      $PackageFilesTable,
      PackageFileRow,
      $$PackageFilesTableFilterComposer,
      $$PackageFilesTableOrderingComposer,
      $$PackageFilesTableAnnotationComposer,
      $$PackageFilesTableCreateCompanionBuilder,
      $$PackageFilesTableUpdateCompanionBuilder,
      (
        PackageFileRow,
        BaseReferences<_$PackagesDatabase, $PackageFilesTable, PackageFileRow>,
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
    extends Composer<_$PackagesDatabase, $PackageTrustTable> {
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
    extends Composer<_$PackagesDatabase, $PackageTrustTable> {
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
    extends Composer<_$PackagesDatabase, $PackageTrustTable> {
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
          _$PackagesDatabase,
          $PackageTrustTable,
          PackageTrustRow,
          $$PackageTrustTableFilterComposer,
          $$PackageTrustTableOrderingComposer,
          $$PackageTrustTableAnnotationComposer,
          $$PackageTrustTableCreateCompanionBuilder,
          $$PackageTrustTableUpdateCompanionBuilder,
          (
            PackageTrustRow,
            BaseReferences<
              _$PackagesDatabase,
              $PackageTrustTable,
              PackageTrustRow
            >,
          ),
          PackageTrustRow,
          PrefetchHooks Function()
        > {
  $$PackageTrustTableTableManager(
    _$PackagesDatabase db,
    $PackageTrustTable table,
  ) : super(
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
                    _$PackagesDatabase,
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
      _$PackagesDatabase,
      $PackageTrustTable,
      PackageTrustRow,
      $$PackageTrustTableFilterComposer,
      $$PackageTrustTableOrderingComposer,
      $$PackageTrustTableAnnotationComposer,
      $$PackageTrustTableCreateCompanionBuilder,
      $$PackageTrustTableUpdateCompanionBuilder,
      (
        PackageTrustRow,
        BaseReferences<_$PackagesDatabase, $PackageTrustTable, PackageTrustRow>,
      ),
      PackageTrustRow,
      PrefetchHooks Function()
    >;

class $PackagesDatabaseManager {
  final _$PackagesDatabase _db;
  $PackagesDatabaseManager(this._db);
  $$ActivePackagesTableTableManager get activePackages =>
      $$ActivePackagesTableTableManager(_db, _db.activePackages);
  $$PackageFilesTableTableManager get packageFiles =>
      $$PackageFilesTableTableManager(_db, _db.packageFiles);
  $$PackageTrustTableTableManager get packageTrust =>
      $$PackageTrustTableTableManager(_db, _db.packageTrust);
}
