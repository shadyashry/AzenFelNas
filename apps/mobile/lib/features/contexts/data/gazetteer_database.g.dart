// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gazetteer_database.dart';

// ignore_for_file: type=lint
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

abstract class _$GazetteerDatabase extends GeneratedDatabase {
  _$GazetteerDatabase(QueryExecutor e) : super(e);
  $GazetteerDatabaseManager get managers => $GazetteerDatabaseManager(this);
  late final $GazetteerTable gazetteer = $GazetteerTable(this);
  late final $GazetteerNamesTable gazetteerNames = $GazetteerNamesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    gazetteer,
    gazetteerNames,
  ];
}

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
    extends BaseReferences<_$GazetteerDatabase, $GazetteerTable, GazetteerRow> {
  $$GazetteerTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$GazetteerNamesTable, List<GazetteerNameRow>>
  _gazetteerNamesRefsTable(_$GazetteerDatabase db) =>
      MultiTypedResultKey.fromTable(
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
    extends Composer<_$GazetteerDatabase, $GazetteerTable> {
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
    extends Composer<_$GazetteerDatabase, $GazetteerTable> {
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
    extends Composer<_$GazetteerDatabase, $GazetteerTable> {
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
          _$GazetteerDatabase,
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
  $$GazetteerTableTableManager(_$GazetteerDatabase db, $GazetteerTable table)
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
      _$GazetteerDatabase,
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
        BaseReferences<
          _$GazetteerDatabase,
          $GazetteerNamesTable,
          GazetteerNameRow
        > {
  $$GazetteerNamesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $GazetteerTable _placeIdTable(_$GazetteerDatabase db) =>
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
    extends Composer<_$GazetteerDatabase, $GazetteerNamesTable> {
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
    extends Composer<_$GazetteerDatabase, $GazetteerNamesTable> {
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
    extends Composer<_$GazetteerDatabase, $GazetteerNamesTable> {
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
          _$GazetteerDatabase,
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
  $$GazetteerNamesTableTableManager(
    _$GazetteerDatabase db,
    $GazetteerNamesTable table,
  ) : super(
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
      _$GazetteerDatabase,
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

class $GazetteerDatabaseManager {
  final _$GazetteerDatabase _db;
  $GazetteerDatabaseManager(this._db);
  $$GazetteerTableTableManager get gazetteer =>
      $$GazetteerTableTableManager(_db, _db.gazetteer);
  $$GazetteerNamesTableTableManager get gazetteerNames =>
      $$GazetteerNamesTableTableManager(_db, _db.gazetteerNames);
}
