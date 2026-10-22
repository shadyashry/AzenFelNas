// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'places_database.dart';

// ignore_for_file: type=lint
class $LocationContextsTable extends LocationContexts
    with TableInfo<$LocationContextsTable, LocationContextRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocationContextsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
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
  static const VerificationMeta _hAccMMeta = const VerificationMeta('hAccM');
  @override
  late final GeneratedColumn<double> hAccM = GeneratedColumn<double>(
    'h_acc_m',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
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
  static const VerificationMeta _countryMeta = const VerificationMeta(
    'country',
  );
  @override
  late final GeneratedColumn<String> country = GeneratedColumn<String>(
    'country',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _pinnedMeta = const VerificationMeta('pinned');
  @override
  late final GeneratedColumn<bool> pinned = GeneratedColumn<bool>(
    'pinned',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("pinned" IN (0, 1))',
    ),
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdUtcMeta = const VerificationMeta(
    'createdUtc',
  );
  @override
  late final GeneratedColumn<int> createdUtc = GeneratedColumn<int>(
    'created_utc',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastUsedUtcMeta = const VerificationMeta(
    'lastUsedUtc',
  );
  @override
  late final GeneratedColumn<int> lastUsedUtc = GeneratedColumn<int>(
    'last_used_utc',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    kind,
    lat,
    lon,
    hAccM,
    zoneId,
    country,
    source,
    pinned,
    label,
    createdUtc,
    lastUsedUtc,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'location_contexts';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocationContextRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
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
    if (data.containsKey('h_acc_m')) {
      context.handle(
        _hAccMMeta,
        hAccM.isAcceptableOrUnknown(data['h_acc_m']!, _hAccMMeta),
      );
    }
    if (data.containsKey('zone_id')) {
      context.handle(
        _zoneIdMeta,
        zoneId.isAcceptableOrUnknown(data['zone_id']!, _zoneIdMeta),
      );
    } else if (isInserting) {
      context.missing(_zoneIdMeta);
    }
    if (data.containsKey('country')) {
      context.handle(
        _countryMeta,
        country.isAcceptableOrUnknown(data['country']!, _countryMeta),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('pinned')) {
      context.handle(
        _pinnedMeta,
        pinned.isAcceptableOrUnknown(data['pinned']!, _pinnedMeta),
      );
    } else if (isInserting) {
      context.missing(_pinnedMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('created_utc')) {
      context.handle(
        _createdUtcMeta,
        createdUtc.isAcceptableOrUnknown(data['created_utc']!, _createdUtcMeta),
      );
    } else if (isInserting) {
      context.missing(_createdUtcMeta);
    }
    if (data.containsKey('last_used_utc')) {
      context.handle(
        _lastUsedUtcMeta,
        lastUsedUtc.isAcceptableOrUnknown(
          data['last_used_utc']!,
          _lastUsedUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastUsedUtcMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocationContextRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocationContextRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      lat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lat'],
      )!,
      lon: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lon'],
      )!,
      hAccM: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}h_acc_m'],
      ),
      zoneId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}zone_id'],
      )!,
      country: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}country'],
      ),
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      pinned: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}pinned'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      createdUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_utc'],
      )!,
      lastUsedUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_used_utc'],
      )!,
    );
  }

  @override
  $LocationContextsTable createAlias(String alias) {
    return $LocationContextsTable(attachedDatabase, alias);
  }
}

class LocationContextRow extends DataClass
    implements Insertable<LocationContextRow> {
  /// Row id.
  final int id;

  /// `ContextKind.wire`.
  final String kind;

  /// Latitude in degrees (micro-degree precision).
  final double lat;

  /// Longitude in degrees (micro-degree precision).
  final double lon;

  /// Horizontal accuracy in metres; null for a gazetteer or typed place.
  final double? hAccM;

  /// IANA zone id.
  final String zoneId;

  /// ISO 3166-1 alpha-2 code; null when no country resolves.
  final String? country;

  /// `ContextSource.wire`.
  final String source;

  /// Whether the user chose the context (kind pinned or manual).
  final bool pinned;

  /// User-facing name.
  final String label;

  /// First write (UTC epoch ms).
  final int createdUtc;

  /// Last selection or refresh (UTC epoch ms); the largest is active.
  final int lastUsedUtc;
  const LocationContextRow({
    required this.id,
    required this.kind,
    required this.lat,
    required this.lon,
    this.hAccM,
    required this.zoneId,
    this.country,
    required this.source,
    required this.pinned,
    required this.label,
    required this.createdUtc,
    required this.lastUsedUtc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['kind'] = Variable<String>(kind);
    map['lat'] = Variable<double>(lat);
    map['lon'] = Variable<double>(lon);
    if (!nullToAbsent || hAccM != null) {
      map['h_acc_m'] = Variable<double>(hAccM);
    }
    map['zone_id'] = Variable<String>(zoneId);
    if (!nullToAbsent || country != null) {
      map['country'] = Variable<String>(country);
    }
    map['source'] = Variable<String>(source);
    map['pinned'] = Variable<bool>(pinned);
    map['label'] = Variable<String>(label);
    map['created_utc'] = Variable<int>(createdUtc);
    map['last_used_utc'] = Variable<int>(lastUsedUtc);
    return map;
  }

  LocationContextsCompanion toCompanion(bool nullToAbsent) {
    return LocationContextsCompanion(
      id: Value(id),
      kind: Value(kind),
      lat: Value(lat),
      lon: Value(lon),
      hAccM: hAccM == null && nullToAbsent
          ? const Value.absent()
          : Value(hAccM),
      zoneId: Value(zoneId),
      country: country == null && nullToAbsent
          ? const Value.absent()
          : Value(country),
      source: Value(source),
      pinned: Value(pinned),
      label: Value(label),
      createdUtc: Value(createdUtc),
      lastUsedUtc: Value(lastUsedUtc),
    );
  }

  factory LocationContextRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocationContextRow(
      id: serializer.fromJson<int>(json['id']),
      kind: serializer.fromJson<String>(json['kind']),
      lat: serializer.fromJson<double>(json['lat']),
      lon: serializer.fromJson<double>(json['lon']),
      hAccM: serializer.fromJson<double?>(json['hAccM']),
      zoneId: serializer.fromJson<String>(json['zoneId']),
      country: serializer.fromJson<String?>(json['country']),
      source: serializer.fromJson<String>(json['source']),
      pinned: serializer.fromJson<bool>(json['pinned']),
      label: serializer.fromJson<String>(json['label']),
      createdUtc: serializer.fromJson<int>(json['createdUtc']),
      lastUsedUtc: serializer.fromJson<int>(json['lastUsedUtc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'kind': serializer.toJson<String>(kind),
      'lat': serializer.toJson<double>(lat),
      'lon': serializer.toJson<double>(lon),
      'hAccM': serializer.toJson<double?>(hAccM),
      'zoneId': serializer.toJson<String>(zoneId),
      'country': serializer.toJson<String?>(country),
      'source': serializer.toJson<String>(source),
      'pinned': serializer.toJson<bool>(pinned),
      'label': serializer.toJson<String>(label),
      'createdUtc': serializer.toJson<int>(createdUtc),
      'lastUsedUtc': serializer.toJson<int>(lastUsedUtc),
    };
  }

  LocationContextRow copyWith({
    int? id,
    String? kind,
    double? lat,
    double? lon,
    Value<double?> hAccM = const Value.absent(),
    String? zoneId,
    Value<String?> country = const Value.absent(),
    String? source,
    bool? pinned,
    String? label,
    int? createdUtc,
    int? lastUsedUtc,
  }) => LocationContextRow(
    id: id ?? this.id,
    kind: kind ?? this.kind,
    lat: lat ?? this.lat,
    lon: lon ?? this.lon,
    hAccM: hAccM.present ? hAccM.value : this.hAccM,
    zoneId: zoneId ?? this.zoneId,
    country: country.present ? country.value : this.country,
    source: source ?? this.source,
    pinned: pinned ?? this.pinned,
    label: label ?? this.label,
    createdUtc: createdUtc ?? this.createdUtc,
    lastUsedUtc: lastUsedUtc ?? this.lastUsedUtc,
  );
  LocationContextRow copyWithCompanion(LocationContextsCompanion data) {
    return LocationContextRow(
      id: data.id.present ? data.id.value : this.id,
      kind: data.kind.present ? data.kind.value : this.kind,
      lat: data.lat.present ? data.lat.value : this.lat,
      lon: data.lon.present ? data.lon.value : this.lon,
      hAccM: data.hAccM.present ? data.hAccM.value : this.hAccM,
      zoneId: data.zoneId.present ? data.zoneId.value : this.zoneId,
      country: data.country.present ? data.country.value : this.country,
      source: data.source.present ? data.source.value : this.source,
      pinned: data.pinned.present ? data.pinned.value : this.pinned,
      label: data.label.present ? data.label.value : this.label,
      createdUtc: data.createdUtc.present
          ? data.createdUtc.value
          : this.createdUtc,
      lastUsedUtc: data.lastUsedUtc.present
          ? data.lastUsedUtc.value
          : this.lastUsedUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocationContextRow(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('lat: $lat, ')
          ..write('lon: $lon, ')
          ..write('hAccM: $hAccM, ')
          ..write('zoneId: $zoneId, ')
          ..write('country: $country, ')
          ..write('source: $source, ')
          ..write('pinned: $pinned, ')
          ..write('label: $label, ')
          ..write('createdUtc: $createdUtc, ')
          ..write('lastUsedUtc: $lastUsedUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    kind,
    lat,
    lon,
    hAccM,
    zoneId,
    country,
    source,
    pinned,
    label,
    createdUtc,
    lastUsedUtc,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocationContextRow &&
          other.id == this.id &&
          other.kind == this.kind &&
          other.lat == this.lat &&
          other.lon == this.lon &&
          other.hAccM == this.hAccM &&
          other.zoneId == this.zoneId &&
          other.country == this.country &&
          other.source == this.source &&
          other.pinned == this.pinned &&
          other.label == this.label &&
          other.createdUtc == this.createdUtc &&
          other.lastUsedUtc == this.lastUsedUtc);
}

class LocationContextsCompanion extends UpdateCompanion<LocationContextRow> {
  final Value<int> id;
  final Value<String> kind;
  final Value<double> lat;
  final Value<double> lon;
  final Value<double?> hAccM;
  final Value<String> zoneId;
  final Value<String?> country;
  final Value<String> source;
  final Value<bool> pinned;
  final Value<String> label;
  final Value<int> createdUtc;
  final Value<int> lastUsedUtc;
  const LocationContextsCompanion({
    this.id = const Value.absent(),
    this.kind = const Value.absent(),
    this.lat = const Value.absent(),
    this.lon = const Value.absent(),
    this.hAccM = const Value.absent(),
    this.zoneId = const Value.absent(),
    this.country = const Value.absent(),
    this.source = const Value.absent(),
    this.pinned = const Value.absent(),
    this.label = const Value.absent(),
    this.createdUtc = const Value.absent(),
    this.lastUsedUtc = const Value.absent(),
  });
  LocationContextsCompanion.insert({
    this.id = const Value.absent(),
    required String kind,
    required double lat,
    required double lon,
    this.hAccM = const Value.absent(),
    required String zoneId,
    this.country = const Value.absent(),
    required String source,
    required bool pinned,
    required String label,
    required int createdUtc,
    required int lastUsedUtc,
  }) : kind = Value(kind),
       lat = Value(lat),
       lon = Value(lon),
       zoneId = Value(zoneId),
       source = Value(source),
       pinned = Value(pinned),
       label = Value(label),
       createdUtc = Value(createdUtc),
       lastUsedUtc = Value(lastUsedUtc);
  static Insertable<LocationContextRow> custom({
    Expression<int>? id,
    Expression<String>? kind,
    Expression<double>? lat,
    Expression<double>? lon,
    Expression<double>? hAccM,
    Expression<String>? zoneId,
    Expression<String>? country,
    Expression<String>? source,
    Expression<bool>? pinned,
    Expression<String>? label,
    Expression<int>? createdUtc,
    Expression<int>? lastUsedUtc,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (kind != null) 'kind': kind,
      if (lat != null) 'lat': lat,
      if (lon != null) 'lon': lon,
      if (hAccM != null) 'h_acc_m': hAccM,
      if (zoneId != null) 'zone_id': zoneId,
      if (country != null) 'country': country,
      if (source != null) 'source': source,
      if (pinned != null) 'pinned': pinned,
      if (label != null) 'label': label,
      if (createdUtc != null) 'created_utc': createdUtc,
      if (lastUsedUtc != null) 'last_used_utc': lastUsedUtc,
    });
  }

  LocationContextsCompanion copyWith({
    Value<int>? id,
    Value<String>? kind,
    Value<double>? lat,
    Value<double>? lon,
    Value<double?>? hAccM,
    Value<String>? zoneId,
    Value<String?>? country,
    Value<String>? source,
    Value<bool>? pinned,
    Value<String>? label,
    Value<int>? createdUtc,
    Value<int>? lastUsedUtc,
  }) {
    return LocationContextsCompanion(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      lat: lat ?? this.lat,
      lon: lon ?? this.lon,
      hAccM: hAccM ?? this.hAccM,
      zoneId: zoneId ?? this.zoneId,
      country: country ?? this.country,
      source: source ?? this.source,
      pinned: pinned ?? this.pinned,
      label: label ?? this.label,
      createdUtc: createdUtc ?? this.createdUtc,
      lastUsedUtc: lastUsedUtc ?? this.lastUsedUtc,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (lat.present) {
      map['lat'] = Variable<double>(lat.value);
    }
    if (lon.present) {
      map['lon'] = Variable<double>(lon.value);
    }
    if (hAccM.present) {
      map['h_acc_m'] = Variable<double>(hAccM.value);
    }
    if (zoneId.present) {
      map['zone_id'] = Variable<String>(zoneId.value);
    }
    if (country.present) {
      map['country'] = Variable<String>(country.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (pinned.present) {
      map['pinned'] = Variable<bool>(pinned.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (createdUtc.present) {
      map['created_utc'] = Variable<int>(createdUtc.value);
    }
    if (lastUsedUtc.present) {
      map['last_used_utc'] = Variable<int>(lastUsedUtc.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocationContextsCompanion(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('lat: $lat, ')
          ..write('lon: $lon, ')
          ..write('hAccM: $hAccM, ')
          ..write('zoneId: $zoneId, ')
          ..write('country: $country, ')
          ..write('source: $source, ')
          ..write('pinned: $pinned, ')
          ..write('label: $label, ')
          ..write('createdUtc: $createdUtc, ')
          ..write('lastUsedUtc: $lastUsedUtc')
          ..write(')'))
        .toString();
  }
}

abstract class _$PlacesDatabase extends GeneratedDatabase {
  _$PlacesDatabase(QueryExecutor e) : super(e);
  $PlacesDatabaseManager get managers => $PlacesDatabaseManager(this);
  late final $LocationContextsTable locationContexts = $LocationContextsTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [locationContexts];
}

typedef $$LocationContextsTableCreateCompanionBuilder =
    LocationContextsCompanion Function({
      Value<int> id,
      required String kind,
      required double lat,
      required double lon,
      Value<double?> hAccM,
      required String zoneId,
      Value<String?> country,
      required String source,
      required bool pinned,
      required String label,
      required int createdUtc,
      required int lastUsedUtc,
    });
typedef $$LocationContextsTableUpdateCompanionBuilder =
    LocationContextsCompanion Function({
      Value<int> id,
      Value<String> kind,
      Value<double> lat,
      Value<double> lon,
      Value<double?> hAccM,
      Value<String> zoneId,
      Value<String?> country,
      Value<String> source,
      Value<bool> pinned,
      Value<String> label,
      Value<int> createdUtc,
      Value<int> lastUsedUtc,
    });

class $$LocationContextsTableFilterComposer
    extends Composer<_$PlacesDatabase, $LocationContextsTable> {
  $$LocationContextsTableFilterComposer({
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

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
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

  ColumnFilters<double> get hAccM => $composableBuilder(
    column: $table.hAccM,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get zoneId => $composableBuilder(
    column: $table.zoneId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get country => $composableBuilder(
    column: $table.country,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get pinned => $composableBuilder(
    column: $table.pinned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdUtc => $composableBuilder(
    column: $table.createdUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastUsedUtc => $composableBuilder(
    column: $table.lastUsedUtc,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocationContextsTableOrderingComposer
    extends Composer<_$PlacesDatabase, $LocationContextsTable> {
  $$LocationContextsTableOrderingComposer({
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

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
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

  ColumnOrderings<double> get hAccM => $composableBuilder(
    column: $table.hAccM,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get zoneId => $composableBuilder(
    column: $table.zoneId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get country => $composableBuilder(
    column: $table.country,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get pinned => $composableBuilder(
    column: $table.pinned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdUtc => $composableBuilder(
    column: $table.createdUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastUsedUtc => $composableBuilder(
    column: $table.lastUsedUtc,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocationContextsTableAnnotationComposer
    extends Composer<_$PlacesDatabase, $LocationContextsTable> {
  $$LocationContextsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<double> get lat =>
      $composableBuilder(column: $table.lat, builder: (column) => column);

  GeneratedColumn<double> get lon =>
      $composableBuilder(column: $table.lon, builder: (column) => column);

  GeneratedColumn<double> get hAccM =>
      $composableBuilder(column: $table.hAccM, builder: (column) => column);

  GeneratedColumn<String> get zoneId =>
      $composableBuilder(column: $table.zoneId, builder: (column) => column);

  GeneratedColumn<String> get country =>
      $composableBuilder(column: $table.country, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<bool> get pinned =>
      $composableBuilder(column: $table.pinned, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<int> get createdUtc => $composableBuilder(
    column: $table.createdUtc,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastUsedUtc => $composableBuilder(
    column: $table.lastUsedUtc,
    builder: (column) => column,
  );
}

class $$LocationContextsTableTableManager
    extends
        RootTableManager<
          _$PlacesDatabase,
          $LocationContextsTable,
          LocationContextRow,
          $$LocationContextsTableFilterComposer,
          $$LocationContextsTableOrderingComposer,
          $$LocationContextsTableAnnotationComposer,
          $$LocationContextsTableCreateCompanionBuilder,
          $$LocationContextsTableUpdateCompanionBuilder,
          (
            LocationContextRow,
            BaseReferences<
              _$PlacesDatabase,
              $LocationContextsTable,
              LocationContextRow
            >,
          ),
          LocationContextRow,
          PrefetchHooks Function()
        > {
  $$LocationContextsTableTableManager(
    _$PlacesDatabase db,
    $LocationContextsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocationContextsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocationContextsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocationContextsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<double> lat = const Value.absent(),
                Value<double> lon = const Value.absent(),
                Value<double?> hAccM = const Value.absent(),
                Value<String> zoneId = const Value.absent(),
                Value<String?> country = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<bool> pinned = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<int> createdUtc = const Value.absent(),
                Value<int> lastUsedUtc = const Value.absent(),
              }) => LocationContextsCompanion(
                id: id,
                kind: kind,
                lat: lat,
                lon: lon,
                hAccM: hAccM,
                zoneId: zoneId,
                country: country,
                source: source,
                pinned: pinned,
                label: label,
                createdUtc: createdUtc,
                lastUsedUtc: lastUsedUtc,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String kind,
                required double lat,
                required double lon,
                Value<double?> hAccM = const Value.absent(),
                required String zoneId,
                Value<String?> country = const Value.absent(),
                required String source,
                required bool pinned,
                required String label,
                required int createdUtc,
                required int lastUsedUtc,
              }) => LocationContextsCompanion.insert(
                id: id,
                kind: kind,
                lat: lat,
                lon: lon,
                hAccM: hAccM,
                zoneId: zoneId,
                country: country,
                source: source,
                pinned: pinned,
                label: label,
                createdUtc: createdUtc,
                lastUsedUtc: lastUsedUtc,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LocationContextsTable, LocationContextRow>(
                    table,
                  ),
                  BaseReferences<
                    _$PlacesDatabase,
                    $LocationContextsTable,
                    LocationContextRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocationContextsTableProcessedTableManager =
    ProcessedTableManager<
      _$PlacesDatabase,
      $LocationContextsTable,
      LocationContextRow,
      $$LocationContextsTableFilterComposer,
      $$LocationContextsTableOrderingComposer,
      $$LocationContextsTableAnnotationComposer,
      $$LocationContextsTableCreateCompanionBuilder,
      $$LocationContextsTableUpdateCompanionBuilder,
      (
        LocationContextRow,
        BaseReferences<
          _$PlacesDatabase,
          $LocationContextsTable,
          LocationContextRow
        >,
      ),
      LocationContextRow,
      PrefetchHooks Function()
    >;

class $PlacesDatabaseManager {
  final _$PlacesDatabase _db;
  $PlacesDatabaseManager(this._db);
  $$LocationContextsTableTableManager get locationContexts =>
      $$LocationContextsTableTableManager(_db, _db.locationContexts);
}
