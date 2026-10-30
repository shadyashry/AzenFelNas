// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quran_notes_database.dart';

// ignore_for_file: type=lint
class $QuranBookmarksTable extends QuranBookmarks
    with TableInfo<$QuranBookmarksTable, QuranBookmarkRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QuranBookmarksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _layoutIdMeta = const VerificationMeta(
    'layoutId',
  );
  @override
  late final GeneratedColumn<String> layoutId = GeneratedColumn<String>(
    'layout_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pageMeta = const VerificationMeta('page');
  @override
  late final GeneratedColumn<int> page = GeneratedColumn<int>(
    'page',
    aliasedName,
    false,
    type: DriftSqlType.int,
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
  @override
  List<GeneratedColumn> get $columns => [layoutId, page, createdUtc];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'quran_bookmarks';
  @override
  VerificationContext validateIntegrity(
    Insertable<QuranBookmarkRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('layout_id')) {
      context.handle(
        _layoutIdMeta,
        layoutId.isAcceptableOrUnknown(data['layout_id']!, _layoutIdMeta),
      );
    } else if (isInserting) {
      context.missing(_layoutIdMeta);
    }
    if (data.containsKey('page')) {
      context.handle(
        _pageMeta,
        page.isAcceptableOrUnknown(data['page']!, _pageMeta),
      );
    } else if (isInserting) {
      context.missing(_pageMeta);
    }
    if (data.containsKey('created_utc')) {
      context.handle(
        _createdUtcMeta,
        createdUtc.isAcceptableOrUnknown(data['created_utc']!, _createdUtcMeta),
      );
    } else if (isInserting) {
      context.missing(_createdUtcMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {layoutId, page};
  @override
  QuranBookmarkRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return QuranBookmarkRow(
      layoutId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}layout_id'],
      )!,
      page: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}page'],
      )!,
      createdUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_utc'],
      )!,
    );
  }

  @override
  $QuranBookmarksTable createAlias(String alias) {
    return $QuranBookmarksTable(attachedDatabase, alias);
  }
}

class QuranBookmarkRow extends DataClass
    implements Insertable<QuranBookmarkRow> {
  /// The page layout (`QuranPackageManifest.layoutId`).
  final String layoutId;

  /// Page number.
  final int page;

  /// Created (UTC epoch ms).
  final int createdUtc;
  const QuranBookmarkRow({
    required this.layoutId,
    required this.page,
    required this.createdUtc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['layout_id'] = Variable<String>(layoutId);
    map['page'] = Variable<int>(page);
    map['created_utc'] = Variable<int>(createdUtc);
    return map;
  }

  QuranBookmarksCompanion toCompanion(bool nullToAbsent) {
    return QuranBookmarksCompanion(
      layoutId: Value(layoutId),
      page: Value(page),
      createdUtc: Value(createdUtc),
    );
  }

  factory QuranBookmarkRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return QuranBookmarkRow(
      layoutId: serializer.fromJson<String>(json['layoutId']),
      page: serializer.fromJson<int>(json['page']),
      createdUtc: serializer.fromJson<int>(json['createdUtc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'layoutId': serializer.toJson<String>(layoutId),
      'page': serializer.toJson<int>(page),
      'createdUtc': serializer.toJson<int>(createdUtc),
    };
  }

  QuranBookmarkRow copyWith({String? layoutId, int? page, int? createdUtc}) =>
      QuranBookmarkRow(
        layoutId: layoutId ?? this.layoutId,
        page: page ?? this.page,
        createdUtc: createdUtc ?? this.createdUtc,
      );
  QuranBookmarkRow copyWithCompanion(QuranBookmarksCompanion data) {
    return QuranBookmarkRow(
      layoutId: data.layoutId.present ? data.layoutId.value : this.layoutId,
      page: data.page.present ? data.page.value : this.page,
      createdUtc: data.createdUtc.present
          ? data.createdUtc.value
          : this.createdUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('QuranBookmarkRow(')
          ..write('layoutId: $layoutId, ')
          ..write('page: $page, ')
          ..write('createdUtc: $createdUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(layoutId, page, createdUtc);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QuranBookmarkRow &&
          other.layoutId == this.layoutId &&
          other.page == this.page &&
          other.createdUtc == this.createdUtc);
}

class QuranBookmarksCompanion extends UpdateCompanion<QuranBookmarkRow> {
  final Value<String> layoutId;
  final Value<int> page;
  final Value<int> createdUtc;
  final Value<int> rowid;
  const QuranBookmarksCompanion({
    this.layoutId = const Value.absent(),
    this.page = const Value.absent(),
    this.createdUtc = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  QuranBookmarksCompanion.insert({
    required String layoutId,
    required int page,
    required int createdUtc,
    this.rowid = const Value.absent(),
  }) : layoutId = Value(layoutId),
       page = Value(page),
       createdUtc = Value(createdUtc);
  static Insertable<QuranBookmarkRow> custom({
    Expression<String>? layoutId,
    Expression<int>? page,
    Expression<int>? createdUtc,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (layoutId != null) 'layout_id': layoutId,
      if (page != null) 'page': page,
      if (createdUtc != null) 'created_utc': createdUtc,
      if (rowid != null) 'rowid': rowid,
    });
  }

  QuranBookmarksCompanion copyWith({
    Value<String>? layoutId,
    Value<int>? page,
    Value<int>? createdUtc,
    Value<int>? rowid,
  }) {
    return QuranBookmarksCompanion(
      layoutId: layoutId ?? this.layoutId,
      page: page ?? this.page,
      createdUtc: createdUtc ?? this.createdUtc,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (layoutId.present) {
      map['layout_id'] = Variable<String>(layoutId.value);
    }
    if (page.present) {
      map['page'] = Variable<int>(page.value);
    }
    if (createdUtc.present) {
      map['created_utc'] = Variable<int>(createdUtc.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QuranBookmarksCompanion(')
          ..write('layoutId: $layoutId, ')
          ..write('page: $page, ')
          ..write('createdUtc: $createdUtc, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $QuranHighlightsTable extends QuranHighlights
    with TableInfo<$QuranHighlightsTable, QuranHighlightRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QuranHighlightsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _layoutIdMeta = const VerificationMeta(
    'layoutId',
  );
  @override
  late final GeneratedColumn<String> layoutId = GeneratedColumn<String>(
    'layout_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
    'color',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _firstPageMeta = const VerificationMeta(
    'firstPage',
  );
  @override
  late final GeneratedColumn<int> firstPage = GeneratedColumn<int>(
    'first_page',
    aliasedName,
    false,
    type: DriftSqlType.int,
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
    id,
    layoutId,
    color,
    firstPage,
    createdUtc,
    updatedUtc,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'quran_highlights';
  @override
  VerificationContext validateIntegrity(
    Insertable<QuranHighlightRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('layout_id')) {
      context.handle(
        _layoutIdMeta,
        layoutId.isAcceptableOrUnknown(data['layout_id']!, _layoutIdMeta),
      );
    } else if (isInserting) {
      context.missing(_layoutIdMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    } else if (isInserting) {
      context.missing(_colorMeta);
    }
    if (data.containsKey('first_page')) {
      context.handle(
        _firstPageMeta,
        firstPage.isAcceptableOrUnknown(data['first_page']!, _firstPageMeta),
      );
    } else if (isInserting) {
      context.missing(_firstPageMeta);
    }
    if (data.containsKey('created_utc')) {
      context.handle(
        _createdUtcMeta,
        createdUtc.isAcceptableOrUnknown(data['created_utc']!, _createdUtcMeta),
      );
    } else if (isInserting) {
      context.missing(_createdUtcMeta);
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
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  QuranHighlightRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return QuranHighlightRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      layoutId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}layout_id'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color'],
      )!,
      firstPage: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}first_page'],
      )!,
      createdUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_utc'],
      )!,
      updatedUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_utc'],
      )!,
    );
  }

  @override
  $QuranHighlightsTable createAlias(String alias) {
    return $QuranHighlightsTable(attachedDatabase, alias);
  }
}

class QuranHighlightRow extends DataClass
    implements Insertable<QuranHighlightRow> {
  /// Row id.
  final int id;

  /// The page layout.
  final String layoutId;

  /// `HighlightColor.name`.
  final String color;

  /// First page covered, for ordering.
  final int firstPage;

  /// Created (UTC epoch ms).
  final int createdUtc;

  /// Last edited (UTC epoch ms).
  final int updatedUtc;
  const QuranHighlightRow({
    required this.id,
    required this.layoutId,
    required this.color,
    required this.firstPage,
    required this.createdUtc,
    required this.updatedUtc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['layout_id'] = Variable<String>(layoutId);
    map['color'] = Variable<String>(color);
    map['first_page'] = Variable<int>(firstPage);
    map['created_utc'] = Variable<int>(createdUtc);
    map['updated_utc'] = Variable<int>(updatedUtc);
    return map;
  }

  QuranHighlightsCompanion toCompanion(bool nullToAbsent) {
    return QuranHighlightsCompanion(
      id: Value(id),
      layoutId: Value(layoutId),
      color: Value(color),
      firstPage: Value(firstPage),
      createdUtc: Value(createdUtc),
      updatedUtc: Value(updatedUtc),
    );
  }

  factory QuranHighlightRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return QuranHighlightRow(
      id: serializer.fromJson<int>(json['id']),
      layoutId: serializer.fromJson<String>(json['layoutId']),
      color: serializer.fromJson<String>(json['color']),
      firstPage: serializer.fromJson<int>(json['firstPage']),
      createdUtc: serializer.fromJson<int>(json['createdUtc']),
      updatedUtc: serializer.fromJson<int>(json['updatedUtc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'layoutId': serializer.toJson<String>(layoutId),
      'color': serializer.toJson<String>(color),
      'firstPage': serializer.toJson<int>(firstPage),
      'createdUtc': serializer.toJson<int>(createdUtc),
      'updatedUtc': serializer.toJson<int>(updatedUtc),
    };
  }

  QuranHighlightRow copyWith({
    int? id,
    String? layoutId,
    String? color,
    int? firstPage,
    int? createdUtc,
    int? updatedUtc,
  }) => QuranHighlightRow(
    id: id ?? this.id,
    layoutId: layoutId ?? this.layoutId,
    color: color ?? this.color,
    firstPage: firstPage ?? this.firstPage,
    createdUtc: createdUtc ?? this.createdUtc,
    updatedUtc: updatedUtc ?? this.updatedUtc,
  );
  QuranHighlightRow copyWithCompanion(QuranHighlightsCompanion data) {
    return QuranHighlightRow(
      id: data.id.present ? data.id.value : this.id,
      layoutId: data.layoutId.present ? data.layoutId.value : this.layoutId,
      color: data.color.present ? data.color.value : this.color,
      firstPage: data.firstPage.present ? data.firstPage.value : this.firstPage,
      createdUtc: data.createdUtc.present
          ? data.createdUtc.value
          : this.createdUtc,
      updatedUtc: data.updatedUtc.present
          ? data.updatedUtc.value
          : this.updatedUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('QuranHighlightRow(')
          ..write('id: $id, ')
          ..write('layoutId: $layoutId, ')
          ..write('color: $color, ')
          ..write('firstPage: $firstPage, ')
          ..write('createdUtc: $createdUtc, ')
          ..write('updatedUtc: $updatedUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, layoutId, color, firstPage, createdUtc, updatedUtc);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QuranHighlightRow &&
          other.id == this.id &&
          other.layoutId == this.layoutId &&
          other.color == this.color &&
          other.firstPage == this.firstPage &&
          other.createdUtc == this.createdUtc &&
          other.updatedUtc == this.updatedUtc);
}

class QuranHighlightsCompanion extends UpdateCompanion<QuranHighlightRow> {
  final Value<int> id;
  final Value<String> layoutId;
  final Value<String> color;
  final Value<int> firstPage;
  final Value<int> createdUtc;
  final Value<int> updatedUtc;
  const QuranHighlightsCompanion({
    this.id = const Value.absent(),
    this.layoutId = const Value.absent(),
    this.color = const Value.absent(),
    this.firstPage = const Value.absent(),
    this.createdUtc = const Value.absent(),
    this.updatedUtc = const Value.absent(),
  });
  QuranHighlightsCompanion.insert({
    this.id = const Value.absent(),
    required String layoutId,
    required String color,
    required int firstPage,
    required int createdUtc,
    required int updatedUtc,
  }) : layoutId = Value(layoutId),
       color = Value(color),
       firstPage = Value(firstPage),
       createdUtc = Value(createdUtc),
       updatedUtc = Value(updatedUtc);
  static Insertable<QuranHighlightRow> custom({
    Expression<int>? id,
    Expression<String>? layoutId,
    Expression<String>? color,
    Expression<int>? firstPage,
    Expression<int>? createdUtc,
    Expression<int>? updatedUtc,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (layoutId != null) 'layout_id': layoutId,
      if (color != null) 'color': color,
      if (firstPage != null) 'first_page': firstPage,
      if (createdUtc != null) 'created_utc': createdUtc,
      if (updatedUtc != null) 'updated_utc': updatedUtc,
    });
  }

  QuranHighlightsCompanion copyWith({
    Value<int>? id,
    Value<String>? layoutId,
    Value<String>? color,
    Value<int>? firstPage,
    Value<int>? createdUtc,
    Value<int>? updatedUtc,
  }) {
    return QuranHighlightsCompanion(
      id: id ?? this.id,
      layoutId: layoutId ?? this.layoutId,
      color: color ?? this.color,
      firstPage: firstPage ?? this.firstPage,
      createdUtc: createdUtc ?? this.createdUtc,
      updatedUtc: updatedUtc ?? this.updatedUtc,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (layoutId.present) {
      map['layout_id'] = Variable<String>(layoutId.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (firstPage.present) {
      map['first_page'] = Variable<int>(firstPage.value);
    }
    if (createdUtc.present) {
      map['created_utc'] = Variable<int>(createdUtc.value);
    }
    if (updatedUtc.present) {
      map['updated_utc'] = Variable<int>(updatedUtc.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QuranHighlightsCompanion(')
          ..write('id: $id, ')
          ..write('layoutId: $layoutId, ')
          ..write('color: $color, ')
          ..write('firstPage: $firstPage, ')
          ..write('createdUtc: $createdUtc, ')
          ..write('updatedUtc: $updatedUtc')
          ..write(')'))
        .toString();
  }
}

class $QuranHighlightRegionsTable extends QuranHighlightRegions
    with TableInfo<$QuranHighlightRegionsTable, QuranHighlightRegionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QuranHighlightRegionsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _highlightIdMeta = const VerificationMeta(
    'highlightId',
  );
  @override
  late final GeneratedColumn<int> highlightId = GeneratedColumn<int>(
    'highlight_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES quran_highlights (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _pageMeta = const VerificationMeta('page');
  @override
  late final GeneratedColumn<int> page = GeneratedColumn<int>(
    'page',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _x0Meta = const VerificationMeta('x0');
  @override
  late final GeneratedColumn<double> x0 = GeneratedColumn<double>(
    'x0',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _y0Meta = const VerificationMeta('y0');
  @override
  late final GeneratedColumn<double> y0 = GeneratedColumn<double>(
    'y0',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _x1Meta = const VerificationMeta('x1');
  @override
  late final GeneratedColumn<double> x1 = GeneratedColumn<double>(
    'x1',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _y1Meta = const VerificationMeta('y1');
  @override
  late final GeneratedColumn<double> y1 = GeneratedColumn<double>(
    'y1',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, highlightId, page, x0, y0, x1, y1];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'quran_highlight_regions';
  @override
  VerificationContext validateIntegrity(
    Insertable<QuranHighlightRegionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('highlight_id')) {
      context.handle(
        _highlightIdMeta,
        highlightId.isAcceptableOrUnknown(
          data['highlight_id']!,
          _highlightIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_highlightIdMeta);
    }
    if (data.containsKey('page')) {
      context.handle(
        _pageMeta,
        page.isAcceptableOrUnknown(data['page']!, _pageMeta),
      );
    } else if (isInserting) {
      context.missing(_pageMeta);
    }
    if (data.containsKey('x0')) {
      context.handle(_x0Meta, x0.isAcceptableOrUnknown(data['x0']!, _x0Meta));
    } else if (isInserting) {
      context.missing(_x0Meta);
    }
    if (data.containsKey('y0')) {
      context.handle(_y0Meta, y0.isAcceptableOrUnknown(data['y0']!, _y0Meta));
    } else if (isInserting) {
      context.missing(_y0Meta);
    }
    if (data.containsKey('x1')) {
      context.handle(_x1Meta, x1.isAcceptableOrUnknown(data['x1']!, _x1Meta));
    } else if (isInserting) {
      context.missing(_x1Meta);
    }
    if (data.containsKey('y1')) {
      context.handle(_y1Meta, y1.isAcceptableOrUnknown(data['y1']!, _y1Meta));
    } else if (isInserting) {
      context.missing(_y1Meta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  QuranHighlightRegionRow map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return QuranHighlightRegionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      highlightId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}highlight_id'],
      )!,
      page: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}page'],
      )!,
      x0: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}x0'],
      )!,
      y0: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}y0'],
      )!,
      x1: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}x1'],
      )!,
      y1: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}y1'],
      )!,
    );
  }

  @override
  $QuranHighlightRegionsTable createAlias(String alias) {
    return $QuranHighlightRegionsTable(attachedDatabase, alias);
  }
}

class QuranHighlightRegionRow extends DataClass
    implements Insertable<QuranHighlightRegionRow> {
  /// Row id.
  final int id;

  /// The highlight.
  final int highlightId;

  /// Page number.
  final int page;

  /// Left edge.
  final double x0;

  /// Top edge.
  final double y0;

  /// Right edge.
  final double x1;

  /// Bottom edge.
  final double y1;
  const QuranHighlightRegionRow({
    required this.id,
    required this.highlightId,
    required this.page,
    required this.x0,
    required this.y0,
    required this.x1,
    required this.y1,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['highlight_id'] = Variable<int>(highlightId);
    map['page'] = Variable<int>(page);
    map['x0'] = Variable<double>(x0);
    map['y0'] = Variable<double>(y0);
    map['x1'] = Variable<double>(x1);
    map['y1'] = Variable<double>(y1);
    return map;
  }

  QuranHighlightRegionsCompanion toCompanion(bool nullToAbsent) {
    return QuranHighlightRegionsCompanion(
      id: Value(id),
      highlightId: Value(highlightId),
      page: Value(page),
      x0: Value(x0),
      y0: Value(y0),
      x1: Value(x1),
      y1: Value(y1),
    );
  }

  factory QuranHighlightRegionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return QuranHighlightRegionRow(
      id: serializer.fromJson<int>(json['id']),
      highlightId: serializer.fromJson<int>(json['highlightId']),
      page: serializer.fromJson<int>(json['page']),
      x0: serializer.fromJson<double>(json['x0']),
      y0: serializer.fromJson<double>(json['y0']),
      x1: serializer.fromJson<double>(json['x1']),
      y1: serializer.fromJson<double>(json['y1']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'highlightId': serializer.toJson<int>(highlightId),
      'page': serializer.toJson<int>(page),
      'x0': serializer.toJson<double>(x0),
      'y0': serializer.toJson<double>(y0),
      'x1': serializer.toJson<double>(x1),
      'y1': serializer.toJson<double>(y1),
    };
  }

  QuranHighlightRegionRow copyWith({
    int? id,
    int? highlightId,
    int? page,
    double? x0,
    double? y0,
    double? x1,
    double? y1,
  }) => QuranHighlightRegionRow(
    id: id ?? this.id,
    highlightId: highlightId ?? this.highlightId,
    page: page ?? this.page,
    x0: x0 ?? this.x0,
    y0: y0 ?? this.y0,
    x1: x1 ?? this.x1,
    y1: y1 ?? this.y1,
  );
  QuranHighlightRegionRow copyWithCompanion(
    QuranHighlightRegionsCompanion data,
  ) {
    return QuranHighlightRegionRow(
      id: data.id.present ? data.id.value : this.id,
      highlightId: data.highlightId.present
          ? data.highlightId.value
          : this.highlightId,
      page: data.page.present ? data.page.value : this.page,
      x0: data.x0.present ? data.x0.value : this.x0,
      y0: data.y0.present ? data.y0.value : this.y0,
      x1: data.x1.present ? data.x1.value : this.x1,
      y1: data.y1.present ? data.y1.value : this.y1,
    );
  }

  @override
  String toString() {
    return (StringBuffer('QuranHighlightRegionRow(')
          ..write('id: $id, ')
          ..write('highlightId: $highlightId, ')
          ..write('page: $page, ')
          ..write('x0: $x0, ')
          ..write('y0: $y0, ')
          ..write('x1: $x1, ')
          ..write('y1: $y1')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, highlightId, page, x0, y0, x1, y1);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QuranHighlightRegionRow &&
          other.id == this.id &&
          other.highlightId == this.highlightId &&
          other.page == this.page &&
          other.x0 == this.x0 &&
          other.y0 == this.y0 &&
          other.x1 == this.x1 &&
          other.y1 == this.y1);
}

class QuranHighlightRegionsCompanion
    extends UpdateCompanion<QuranHighlightRegionRow> {
  final Value<int> id;
  final Value<int> highlightId;
  final Value<int> page;
  final Value<double> x0;
  final Value<double> y0;
  final Value<double> x1;
  final Value<double> y1;
  const QuranHighlightRegionsCompanion({
    this.id = const Value.absent(),
    this.highlightId = const Value.absent(),
    this.page = const Value.absent(),
    this.x0 = const Value.absent(),
    this.y0 = const Value.absent(),
    this.x1 = const Value.absent(),
    this.y1 = const Value.absent(),
  });
  QuranHighlightRegionsCompanion.insert({
    this.id = const Value.absent(),
    required int highlightId,
    required int page,
    required double x0,
    required double y0,
    required double x1,
    required double y1,
  }) : highlightId = Value(highlightId),
       page = Value(page),
       x0 = Value(x0),
       y0 = Value(y0),
       x1 = Value(x1),
       y1 = Value(y1);
  static Insertable<QuranHighlightRegionRow> custom({
    Expression<int>? id,
    Expression<int>? highlightId,
    Expression<int>? page,
    Expression<double>? x0,
    Expression<double>? y0,
    Expression<double>? x1,
    Expression<double>? y1,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (highlightId != null) 'highlight_id': highlightId,
      if (page != null) 'page': page,
      if (x0 != null) 'x0': x0,
      if (y0 != null) 'y0': y0,
      if (x1 != null) 'x1': x1,
      if (y1 != null) 'y1': y1,
    });
  }

  QuranHighlightRegionsCompanion copyWith({
    Value<int>? id,
    Value<int>? highlightId,
    Value<int>? page,
    Value<double>? x0,
    Value<double>? y0,
    Value<double>? x1,
    Value<double>? y1,
  }) {
    return QuranHighlightRegionsCompanion(
      id: id ?? this.id,
      highlightId: highlightId ?? this.highlightId,
      page: page ?? this.page,
      x0: x0 ?? this.x0,
      y0: y0 ?? this.y0,
      x1: x1 ?? this.x1,
      y1: y1 ?? this.y1,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (highlightId.present) {
      map['highlight_id'] = Variable<int>(highlightId.value);
    }
    if (page.present) {
      map['page'] = Variable<int>(page.value);
    }
    if (x0.present) {
      map['x0'] = Variable<double>(x0.value);
    }
    if (y0.present) {
      map['y0'] = Variable<double>(y0.value);
    }
    if (x1.present) {
      map['x1'] = Variable<double>(x1.value);
    }
    if (y1.present) {
      map['y1'] = Variable<double>(y1.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QuranHighlightRegionsCompanion(')
          ..write('id: $id, ')
          ..write('highlightId: $highlightId, ')
          ..write('page: $page, ')
          ..write('x0: $x0, ')
          ..write('y0: $y0, ')
          ..write('x1: $x1, ')
          ..write('y1: $y1')
          ..write(')'))
        .toString();
  }
}

class $QuranReadingPositionsTable extends QuranReadingPositions
    with TableInfo<$QuranReadingPositionsTable, QuranReadingPositionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QuranReadingPositionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _layoutIdMeta = const VerificationMeta(
    'layoutId',
  );
  @override
  late final GeneratedColumn<String> layoutId = GeneratedColumn<String>(
    'layout_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pageMeta = const VerificationMeta('page');
  @override
  late final GeneratedColumn<int> page = GeneratedColumn<int>(
    'page',
    aliasedName,
    false,
    type: DriftSqlType.int,
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
  List<GeneratedColumn> get $columns => [layoutId, page, updatedUtc];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'quran_reading_positions';
  @override
  VerificationContext validateIntegrity(
    Insertable<QuranReadingPositionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('layout_id')) {
      context.handle(
        _layoutIdMeta,
        layoutId.isAcceptableOrUnknown(data['layout_id']!, _layoutIdMeta),
      );
    } else if (isInserting) {
      context.missing(_layoutIdMeta);
    }
    if (data.containsKey('page')) {
      context.handle(
        _pageMeta,
        page.isAcceptableOrUnknown(data['page']!, _pageMeta),
      );
    } else if (isInserting) {
      context.missing(_pageMeta);
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
  Set<GeneratedColumn> get $primaryKey => {layoutId};
  @override
  QuranReadingPositionRow map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return QuranReadingPositionRow(
      layoutId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}layout_id'],
      )!,
      page: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}page'],
      )!,
      updatedUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_utc'],
      )!,
    );
  }

  @override
  $QuranReadingPositionsTable createAlias(String alias) {
    return $QuranReadingPositionsTable(attachedDatabase, alias);
  }
}

class QuranReadingPositionRow extends DataClass
    implements Insertable<QuranReadingPositionRow> {
  /// The page layout.
  final String layoutId;

  /// Page number.
  final int page;

  /// Saved (UTC epoch ms).
  final int updatedUtc;
  const QuranReadingPositionRow({
    required this.layoutId,
    required this.page,
    required this.updatedUtc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['layout_id'] = Variable<String>(layoutId);
    map['page'] = Variable<int>(page);
    map['updated_utc'] = Variable<int>(updatedUtc);
    return map;
  }

  QuranReadingPositionsCompanion toCompanion(bool nullToAbsent) {
    return QuranReadingPositionsCompanion(
      layoutId: Value(layoutId),
      page: Value(page),
      updatedUtc: Value(updatedUtc),
    );
  }

  factory QuranReadingPositionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return QuranReadingPositionRow(
      layoutId: serializer.fromJson<String>(json['layoutId']),
      page: serializer.fromJson<int>(json['page']),
      updatedUtc: serializer.fromJson<int>(json['updatedUtc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'layoutId': serializer.toJson<String>(layoutId),
      'page': serializer.toJson<int>(page),
      'updatedUtc': serializer.toJson<int>(updatedUtc),
    };
  }

  QuranReadingPositionRow copyWith({
    String? layoutId,
    int? page,
    int? updatedUtc,
  }) => QuranReadingPositionRow(
    layoutId: layoutId ?? this.layoutId,
    page: page ?? this.page,
    updatedUtc: updatedUtc ?? this.updatedUtc,
  );
  QuranReadingPositionRow copyWithCompanion(
    QuranReadingPositionsCompanion data,
  ) {
    return QuranReadingPositionRow(
      layoutId: data.layoutId.present ? data.layoutId.value : this.layoutId,
      page: data.page.present ? data.page.value : this.page,
      updatedUtc: data.updatedUtc.present
          ? data.updatedUtc.value
          : this.updatedUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('QuranReadingPositionRow(')
          ..write('layoutId: $layoutId, ')
          ..write('page: $page, ')
          ..write('updatedUtc: $updatedUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(layoutId, page, updatedUtc);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QuranReadingPositionRow &&
          other.layoutId == this.layoutId &&
          other.page == this.page &&
          other.updatedUtc == this.updatedUtc);
}

class QuranReadingPositionsCompanion
    extends UpdateCompanion<QuranReadingPositionRow> {
  final Value<String> layoutId;
  final Value<int> page;
  final Value<int> updatedUtc;
  final Value<int> rowid;
  const QuranReadingPositionsCompanion({
    this.layoutId = const Value.absent(),
    this.page = const Value.absent(),
    this.updatedUtc = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  QuranReadingPositionsCompanion.insert({
    required String layoutId,
    required int page,
    required int updatedUtc,
    this.rowid = const Value.absent(),
  }) : layoutId = Value(layoutId),
       page = Value(page),
       updatedUtc = Value(updatedUtc);
  static Insertable<QuranReadingPositionRow> custom({
    Expression<String>? layoutId,
    Expression<int>? page,
    Expression<int>? updatedUtc,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (layoutId != null) 'layout_id': layoutId,
      if (page != null) 'page': page,
      if (updatedUtc != null) 'updated_utc': updatedUtc,
      if (rowid != null) 'rowid': rowid,
    });
  }

  QuranReadingPositionsCompanion copyWith({
    Value<String>? layoutId,
    Value<int>? page,
    Value<int>? updatedUtc,
    Value<int>? rowid,
  }) {
    return QuranReadingPositionsCompanion(
      layoutId: layoutId ?? this.layoutId,
      page: page ?? this.page,
      updatedUtc: updatedUtc ?? this.updatedUtc,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (layoutId.present) {
      map['layout_id'] = Variable<String>(layoutId.value);
    }
    if (page.present) {
      map['page'] = Variable<int>(page.value);
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
    return (StringBuffer('QuranReadingPositionsCompanion(')
          ..write('layoutId: $layoutId, ')
          ..write('page: $page, ')
          ..write('updatedUtc: $updatedUtc, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $QuranReaderPrefsTable extends QuranReaderPrefs
    with TableInfo<$QuranReaderPrefsTable, QuranReaderPrefsRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QuranReaderPrefsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fitMeta = const VerificationMeta('fit');
  @override
  late final GeneratedColumn<String> fit = GeneratedColumn<String>(
    'fit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _facingPagesMeta = const VerificationMeta(
    'facingPages',
  );
  @override
  late final GeneratedColumn<bool> facingPages = GeneratedColumn<bool>(
    'facing_pages',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("facing_pages" IN (0, 1))',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [id, fit, facingPages];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'quran_reader_prefs';
  @override
  VerificationContext validateIntegrity(
    Insertable<QuranReaderPrefsRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('fit')) {
      context.handle(
        _fitMeta,
        fit.isAcceptableOrUnknown(data['fit']!, _fitMeta),
      );
    } else if (isInserting) {
      context.missing(_fitMeta);
    }
    if (data.containsKey('facing_pages')) {
      context.handle(
        _facingPagesMeta,
        facingPages.isAcceptableOrUnknown(
          data['facing_pages']!,
          _facingPagesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_facingPagesMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  QuranReaderPrefsRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return QuranReaderPrefsRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      fit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fit'],
      )!,
      facingPages: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}facing_pages'],
      )!,
    );
  }

  @override
  $QuranReaderPrefsTable createAlias(String alias) {
    return $QuranReaderPrefsTable(attachedDatabase, alias);
  }
}

class QuranReaderPrefsRow extends DataClass
    implements Insertable<QuranReaderPrefsRow> {
  /// Always 1.
  final int id;

  /// `PageFit.name`.
  final String fit;

  /// Two facing pages on wide windows.
  final bool facingPages;
  const QuranReaderPrefsRow({
    required this.id,
    required this.fit,
    required this.facingPages,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['fit'] = Variable<String>(fit);
    map['facing_pages'] = Variable<bool>(facingPages);
    return map;
  }

  QuranReaderPrefsCompanion toCompanion(bool nullToAbsent) {
    return QuranReaderPrefsCompanion(
      id: Value(id),
      fit: Value(fit),
      facingPages: Value(facingPages),
    );
  }

  factory QuranReaderPrefsRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return QuranReaderPrefsRow(
      id: serializer.fromJson<int>(json['id']),
      fit: serializer.fromJson<String>(json['fit']),
      facingPages: serializer.fromJson<bool>(json['facingPages']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'fit': serializer.toJson<String>(fit),
      'facingPages': serializer.toJson<bool>(facingPages),
    };
  }

  QuranReaderPrefsRow copyWith({int? id, String? fit, bool? facingPages}) =>
      QuranReaderPrefsRow(
        id: id ?? this.id,
        fit: fit ?? this.fit,
        facingPages: facingPages ?? this.facingPages,
      );
  QuranReaderPrefsRow copyWithCompanion(QuranReaderPrefsCompanion data) {
    return QuranReaderPrefsRow(
      id: data.id.present ? data.id.value : this.id,
      fit: data.fit.present ? data.fit.value : this.fit,
      facingPages: data.facingPages.present
          ? data.facingPages.value
          : this.facingPages,
    );
  }

  @override
  String toString() {
    return (StringBuffer('QuranReaderPrefsRow(')
          ..write('id: $id, ')
          ..write('fit: $fit, ')
          ..write('facingPages: $facingPages')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, fit, facingPages);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QuranReaderPrefsRow &&
          other.id == this.id &&
          other.fit == this.fit &&
          other.facingPages == this.facingPages);
}

class QuranReaderPrefsCompanion extends UpdateCompanion<QuranReaderPrefsRow> {
  final Value<int> id;
  final Value<String> fit;
  final Value<bool> facingPages;
  const QuranReaderPrefsCompanion({
    this.id = const Value.absent(),
    this.fit = const Value.absent(),
    this.facingPages = const Value.absent(),
  });
  QuranReaderPrefsCompanion.insert({
    this.id = const Value.absent(),
    required String fit,
    required bool facingPages,
  }) : fit = Value(fit),
       facingPages = Value(facingPages);
  static Insertable<QuranReaderPrefsRow> custom({
    Expression<int>? id,
    Expression<String>? fit,
    Expression<bool>? facingPages,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (fit != null) 'fit': fit,
      if (facingPages != null) 'facing_pages': facingPages,
    });
  }

  QuranReaderPrefsCompanion copyWith({
    Value<int>? id,
    Value<String>? fit,
    Value<bool>? facingPages,
  }) {
    return QuranReaderPrefsCompanion(
      id: id ?? this.id,
      fit: fit ?? this.fit,
      facingPages: facingPages ?? this.facingPages,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (fit.present) {
      map['fit'] = Variable<String>(fit.value);
    }
    if (facingPages.present) {
      map['facing_pages'] = Variable<bool>(facingPages.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QuranReaderPrefsCompanion(')
          ..write('id: $id, ')
          ..write('fit: $fit, ')
          ..write('facingPages: $facingPages')
          ..write(')'))
        .toString();
  }
}

abstract class _$QuranNotesDatabase extends GeneratedDatabase {
  _$QuranNotesDatabase(QueryExecutor e) : super(e);
  $QuranNotesDatabaseManager get managers => $QuranNotesDatabaseManager(this);
  late final $QuranBookmarksTable quranBookmarks = $QuranBookmarksTable(this);
  late final $QuranHighlightsTable quranHighlights = $QuranHighlightsTable(
    this,
  );
  late final $QuranHighlightRegionsTable quranHighlightRegions =
      $QuranHighlightRegionsTable(this);
  late final $QuranReadingPositionsTable quranReadingPositions =
      $QuranReadingPositionsTable(this);
  late final $QuranReaderPrefsTable quranReaderPrefs = $QuranReaderPrefsTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    quranBookmarks,
    quranHighlights,
    quranHighlightRegions,
    quranReadingPositions,
    quranReaderPrefs,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'quran_highlights',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('quran_highlight_regions', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$QuranBookmarksTableCreateCompanionBuilder =
    QuranBookmarksCompanion Function({
      required String layoutId,
      required int page,
      required int createdUtc,
      Value<int> rowid,
    });
typedef $$QuranBookmarksTableUpdateCompanionBuilder =
    QuranBookmarksCompanion Function({
      Value<String> layoutId,
      Value<int> page,
      Value<int> createdUtc,
      Value<int> rowid,
    });

class $$QuranBookmarksTableFilterComposer
    extends Composer<_$QuranNotesDatabase, $QuranBookmarksTable> {
  $$QuranBookmarksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get layoutId => $composableBuilder(
    column: $table.layoutId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get page => $composableBuilder(
    column: $table.page,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdUtc => $composableBuilder(
    column: $table.createdUtc,
    builder: (column) => ColumnFilters(column),
  );
}

class $$QuranBookmarksTableOrderingComposer
    extends Composer<_$QuranNotesDatabase, $QuranBookmarksTable> {
  $$QuranBookmarksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get layoutId => $composableBuilder(
    column: $table.layoutId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get page => $composableBuilder(
    column: $table.page,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdUtc => $composableBuilder(
    column: $table.createdUtc,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$QuranBookmarksTableAnnotationComposer
    extends Composer<_$QuranNotesDatabase, $QuranBookmarksTable> {
  $$QuranBookmarksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get layoutId =>
      $composableBuilder(column: $table.layoutId, builder: (column) => column);

  GeneratedColumn<int> get page =>
      $composableBuilder(column: $table.page, builder: (column) => column);

  GeneratedColumn<int> get createdUtc => $composableBuilder(
    column: $table.createdUtc,
    builder: (column) => column,
  );
}

class $$QuranBookmarksTableTableManager
    extends
        RootTableManager<
          _$QuranNotesDatabase,
          $QuranBookmarksTable,
          QuranBookmarkRow,
          $$QuranBookmarksTableFilterComposer,
          $$QuranBookmarksTableOrderingComposer,
          $$QuranBookmarksTableAnnotationComposer,
          $$QuranBookmarksTableCreateCompanionBuilder,
          $$QuranBookmarksTableUpdateCompanionBuilder,
          (
            QuranBookmarkRow,
            BaseReferences<
              _$QuranNotesDatabase,
              $QuranBookmarksTable,
              QuranBookmarkRow
            >,
          ),
          QuranBookmarkRow,
          PrefetchHooks Function()
        > {
  $$QuranBookmarksTableTableManager(
    _$QuranNotesDatabase db,
    $QuranBookmarksTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QuranBookmarksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$QuranBookmarksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$QuranBookmarksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> layoutId = const Value.absent(),
                Value<int> page = const Value.absent(),
                Value<int> createdUtc = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => QuranBookmarksCompanion(
                layoutId: layoutId,
                page: page,
                createdUtc: createdUtc,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String layoutId,
                required int page,
                required int createdUtc,
                Value<int> rowid = const Value.absent(),
              }) => QuranBookmarksCompanion.insert(
                layoutId: layoutId,
                page: page,
                createdUtc: createdUtc,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$QuranBookmarksTable, QuranBookmarkRow>(table),
                  BaseReferences<
                    _$QuranNotesDatabase,
                    $QuranBookmarksTable,
                    QuranBookmarkRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$QuranBookmarksTableProcessedTableManager =
    ProcessedTableManager<
      _$QuranNotesDatabase,
      $QuranBookmarksTable,
      QuranBookmarkRow,
      $$QuranBookmarksTableFilterComposer,
      $$QuranBookmarksTableOrderingComposer,
      $$QuranBookmarksTableAnnotationComposer,
      $$QuranBookmarksTableCreateCompanionBuilder,
      $$QuranBookmarksTableUpdateCompanionBuilder,
      (
        QuranBookmarkRow,
        BaseReferences<
          _$QuranNotesDatabase,
          $QuranBookmarksTable,
          QuranBookmarkRow
        >,
      ),
      QuranBookmarkRow,
      PrefetchHooks Function()
    >;
typedef $$QuranHighlightsTableCreateCompanionBuilder =
    QuranHighlightsCompanion Function({
      Value<int> id,
      required String layoutId,
      required String color,
      required int firstPage,
      required int createdUtc,
      required int updatedUtc,
    });
typedef $$QuranHighlightsTableUpdateCompanionBuilder =
    QuranHighlightsCompanion Function({
      Value<int> id,
      Value<String> layoutId,
      Value<String> color,
      Value<int> firstPage,
      Value<int> createdUtc,
      Value<int> updatedUtc,
    });

final class $$QuranHighlightsTableReferences
    extends
        BaseReferences<
          _$QuranNotesDatabase,
          $QuranHighlightsTable,
          QuranHighlightRow
        > {
  $$QuranHighlightsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<
    $QuranHighlightRegionsTable,
    List<QuranHighlightRegionRow>
  >
  _quranHighlightRegionsRefsTable(_$QuranNotesDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.quranHighlightRegions,
        aliasName:
            'quran_highlights__id__quran_highlight_regions__highlight_id',
      );

  $$QuranHighlightRegionsTableProcessedTableManager
  get quranHighlightRegionsRefs {
    final manager = $$QuranHighlightRegionsTableTableManager(
      $_db,
      $_db.quranHighlightRegions,
    ).filter((f) => f.highlightId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _quranHighlightRegionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$QuranHighlightsTableFilterComposer
    extends Composer<_$QuranNotesDatabase, $QuranHighlightsTable> {
  $$QuranHighlightsTableFilterComposer({
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

  ColumnFilters<String> get layoutId => $composableBuilder(
    column: $table.layoutId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get firstPage => $composableBuilder(
    column: $table.firstPage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdUtc => $composableBuilder(
    column: $table.createdUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedUtc => $composableBuilder(
    column: $table.updatedUtc,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> quranHighlightRegionsRefs(
    Expression<bool> Function($$QuranHighlightRegionsTableFilterComposer f) f,
  ) {
    final $$QuranHighlightRegionsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.quranHighlightRegions,
          getReferencedColumn: (t) => t.highlightId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$QuranHighlightRegionsTableFilterComposer(
                $db: $db,
                $table: $db.quranHighlightRegions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$QuranHighlightsTableOrderingComposer
    extends Composer<_$QuranNotesDatabase, $QuranHighlightsTable> {
  $$QuranHighlightsTableOrderingComposer({
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

  ColumnOrderings<String> get layoutId => $composableBuilder(
    column: $table.layoutId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get firstPage => $composableBuilder(
    column: $table.firstPage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdUtc => $composableBuilder(
    column: $table.createdUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedUtc => $composableBuilder(
    column: $table.updatedUtc,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$QuranHighlightsTableAnnotationComposer
    extends Composer<_$QuranNotesDatabase, $QuranHighlightsTable> {
  $$QuranHighlightsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get layoutId =>
      $composableBuilder(column: $table.layoutId, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<int> get firstPage =>
      $composableBuilder(column: $table.firstPage, builder: (column) => column);

  GeneratedColumn<int> get createdUtc => $composableBuilder(
    column: $table.createdUtc,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedUtc => $composableBuilder(
    column: $table.updatedUtc,
    builder: (column) => column,
  );

  Expression<T> quranHighlightRegionsRefs<T extends Object>(
    Expression<T> Function($$QuranHighlightRegionsTableAnnotationComposer a) f,
  ) {
    final $$QuranHighlightRegionsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.quranHighlightRegions,
          getReferencedColumn: (t) => t.highlightId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$QuranHighlightRegionsTableAnnotationComposer(
                $db: $db,
                $table: $db.quranHighlightRegions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$QuranHighlightsTableTableManager
    extends
        RootTableManager<
          _$QuranNotesDatabase,
          $QuranHighlightsTable,
          QuranHighlightRow,
          $$QuranHighlightsTableFilterComposer,
          $$QuranHighlightsTableOrderingComposer,
          $$QuranHighlightsTableAnnotationComposer,
          $$QuranHighlightsTableCreateCompanionBuilder,
          $$QuranHighlightsTableUpdateCompanionBuilder,
          (QuranHighlightRow, $$QuranHighlightsTableReferences),
          QuranHighlightRow,
          PrefetchHooks Function({bool quranHighlightRegionsRefs})
        > {
  $$QuranHighlightsTableTableManager(
    _$QuranNotesDatabase db,
    $QuranHighlightsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QuranHighlightsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$QuranHighlightsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$QuranHighlightsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> layoutId = const Value.absent(),
                Value<String> color = const Value.absent(),
                Value<int> firstPage = const Value.absent(),
                Value<int> createdUtc = const Value.absent(),
                Value<int> updatedUtc = const Value.absent(),
              }) => QuranHighlightsCompanion(
                id: id,
                layoutId: layoutId,
                color: color,
                firstPage: firstPage,
                createdUtc: createdUtc,
                updatedUtc: updatedUtc,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String layoutId,
                required String color,
                required int firstPage,
                required int createdUtc,
                required int updatedUtc,
              }) => QuranHighlightsCompanion.insert(
                id: id,
                layoutId: layoutId,
                color: color,
                firstPage: firstPage,
                createdUtc: createdUtc,
                updatedUtc: updatedUtc,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$QuranHighlightsTable, QuranHighlightRow>(table),
                  $$QuranHighlightsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({quranHighlightRegionsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (quranHighlightRegionsRefs) db.quranHighlightRegions,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (quranHighlightRegionsRefs)
                    await $_getPrefetchedData<
                      QuranHighlightRow,
                      $QuranHighlightsTable,
                      QuranHighlightRegionRow
                    >(
                      currentTable: table,
                      referencedTable: $$QuranHighlightsTableReferences
                          ._quranHighlightRegionsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$QuranHighlightsTableReferences(
                            db,
                            table,
                            p0,
                          ).quranHighlightRegionsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.highlightId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$QuranHighlightsTableProcessedTableManager =
    ProcessedTableManager<
      _$QuranNotesDatabase,
      $QuranHighlightsTable,
      QuranHighlightRow,
      $$QuranHighlightsTableFilterComposer,
      $$QuranHighlightsTableOrderingComposer,
      $$QuranHighlightsTableAnnotationComposer,
      $$QuranHighlightsTableCreateCompanionBuilder,
      $$QuranHighlightsTableUpdateCompanionBuilder,
      (QuranHighlightRow, $$QuranHighlightsTableReferences),
      QuranHighlightRow,
      PrefetchHooks Function({bool quranHighlightRegionsRefs})
    >;
typedef $$QuranHighlightRegionsTableCreateCompanionBuilder =
    QuranHighlightRegionsCompanion Function({
      Value<int> id,
      required int highlightId,
      required int page,
      required double x0,
      required double y0,
      required double x1,
      required double y1,
    });
typedef $$QuranHighlightRegionsTableUpdateCompanionBuilder =
    QuranHighlightRegionsCompanion Function({
      Value<int> id,
      Value<int> highlightId,
      Value<int> page,
      Value<double> x0,
      Value<double> y0,
      Value<double> x1,
      Value<double> y1,
    });

final class $$QuranHighlightRegionsTableReferences
    extends
        BaseReferences<
          _$QuranNotesDatabase,
          $QuranHighlightRegionsTable,
          QuranHighlightRegionRow
        > {
  $$QuranHighlightRegionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $QuranHighlightsTable _highlightIdTable(_$QuranNotesDatabase db) =>
      db.quranHighlights.createAlias(
        'quran_highlight_regions__highlight_id__quran_highlights__id',
      );

  $$QuranHighlightsTableProcessedTableManager get highlightId {
    final $_column = $_itemColumn<int>('highlight_id')!;

    final manager = $$QuranHighlightsTableTableManager(
      $_db,
      $_db.quranHighlights,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_highlightIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$QuranHighlightRegionsTableFilterComposer
    extends Composer<_$QuranNotesDatabase, $QuranHighlightRegionsTable> {
  $$QuranHighlightRegionsTableFilterComposer({
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

  ColumnFilters<int> get page => $composableBuilder(
    column: $table.page,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get x0 => $composableBuilder(
    column: $table.x0,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get y0 => $composableBuilder(
    column: $table.y0,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get x1 => $composableBuilder(
    column: $table.x1,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get y1 => $composableBuilder(
    column: $table.y1,
    builder: (column) => ColumnFilters(column),
  );

  $$QuranHighlightsTableFilterComposer get highlightId {
    final $$QuranHighlightsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.highlightId,
      referencedTable: $db.quranHighlights,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuranHighlightsTableFilterComposer(
            $db: $db,
            $table: $db.quranHighlights,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$QuranHighlightRegionsTableOrderingComposer
    extends Composer<_$QuranNotesDatabase, $QuranHighlightRegionsTable> {
  $$QuranHighlightRegionsTableOrderingComposer({
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

  ColumnOrderings<int> get page => $composableBuilder(
    column: $table.page,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get x0 => $composableBuilder(
    column: $table.x0,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get y0 => $composableBuilder(
    column: $table.y0,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get x1 => $composableBuilder(
    column: $table.x1,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get y1 => $composableBuilder(
    column: $table.y1,
    builder: (column) => ColumnOrderings(column),
  );

  $$QuranHighlightsTableOrderingComposer get highlightId {
    final $$QuranHighlightsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.highlightId,
      referencedTable: $db.quranHighlights,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuranHighlightsTableOrderingComposer(
            $db: $db,
            $table: $db.quranHighlights,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$QuranHighlightRegionsTableAnnotationComposer
    extends Composer<_$QuranNotesDatabase, $QuranHighlightRegionsTable> {
  $$QuranHighlightRegionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get page =>
      $composableBuilder(column: $table.page, builder: (column) => column);

  GeneratedColumn<double> get x0 =>
      $composableBuilder(column: $table.x0, builder: (column) => column);

  GeneratedColumn<double> get y0 =>
      $composableBuilder(column: $table.y0, builder: (column) => column);

  GeneratedColumn<double> get x1 =>
      $composableBuilder(column: $table.x1, builder: (column) => column);

  GeneratedColumn<double> get y1 =>
      $composableBuilder(column: $table.y1, builder: (column) => column);

  $$QuranHighlightsTableAnnotationComposer get highlightId {
    final $$QuranHighlightsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.highlightId,
      referencedTable: $db.quranHighlights,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuranHighlightsTableAnnotationComposer(
            $db: $db,
            $table: $db.quranHighlights,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$QuranHighlightRegionsTableTableManager
    extends
        RootTableManager<
          _$QuranNotesDatabase,
          $QuranHighlightRegionsTable,
          QuranHighlightRegionRow,
          $$QuranHighlightRegionsTableFilterComposer,
          $$QuranHighlightRegionsTableOrderingComposer,
          $$QuranHighlightRegionsTableAnnotationComposer,
          $$QuranHighlightRegionsTableCreateCompanionBuilder,
          $$QuranHighlightRegionsTableUpdateCompanionBuilder,
          (QuranHighlightRegionRow, $$QuranHighlightRegionsTableReferences),
          QuranHighlightRegionRow,
          PrefetchHooks Function({bool highlightId})
        > {
  $$QuranHighlightRegionsTableTableManager(
    _$QuranNotesDatabase db,
    $QuranHighlightRegionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QuranHighlightRegionsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$QuranHighlightRegionsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$QuranHighlightRegionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> highlightId = const Value.absent(),
                Value<int> page = const Value.absent(),
                Value<double> x0 = const Value.absent(),
                Value<double> y0 = const Value.absent(),
                Value<double> x1 = const Value.absent(),
                Value<double> y1 = const Value.absent(),
              }) => QuranHighlightRegionsCompanion(
                id: id,
                highlightId: highlightId,
                page: page,
                x0: x0,
                y0: y0,
                x1: x1,
                y1: y1,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int highlightId,
                required int page,
                required double x0,
                required double y0,
                required double x1,
                required double y1,
              }) => QuranHighlightRegionsCompanion.insert(
                id: id,
                highlightId: highlightId,
                page: page,
                x0: x0,
                y0: y0,
                x1: x1,
                y1: y1,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $QuranHighlightRegionsTable,
                    QuranHighlightRegionRow
                  >(table),
                  $$QuranHighlightRegionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({highlightId = false}) {
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
                    if (highlightId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.highlightId,
                        referencedTable: $$QuranHighlightRegionsTableReferences
                            ._highlightIdTable(db),
                        referencedColumn: $$QuranHighlightRegionsTableReferences
                            ._highlightIdTable(db)
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

typedef $$QuranHighlightRegionsTableProcessedTableManager =
    ProcessedTableManager<
      _$QuranNotesDatabase,
      $QuranHighlightRegionsTable,
      QuranHighlightRegionRow,
      $$QuranHighlightRegionsTableFilterComposer,
      $$QuranHighlightRegionsTableOrderingComposer,
      $$QuranHighlightRegionsTableAnnotationComposer,
      $$QuranHighlightRegionsTableCreateCompanionBuilder,
      $$QuranHighlightRegionsTableUpdateCompanionBuilder,
      (QuranHighlightRegionRow, $$QuranHighlightRegionsTableReferences),
      QuranHighlightRegionRow,
      PrefetchHooks Function({bool highlightId})
    >;
typedef $$QuranReadingPositionsTableCreateCompanionBuilder =
    QuranReadingPositionsCompanion Function({
      required String layoutId,
      required int page,
      required int updatedUtc,
      Value<int> rowid,
    });
typedef $$QuranReadingPositionsTableUpdateCompanionBuilder =
    QuranReadingPositionsCompanion Function({
      Value<String> layoutId,
      Value<int> page,
      Value<int> updatedUtc,
      Value<int> rowid,
    });

class $$QuranReadingPositionsTableFilterComposer
    extends Composer<_$QuranNotesDatabase, $QuranReadingPositionsTable> {
  $$QuranReadingPositionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get layoutId => $composableBuilder(
    column: $table.layoutId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get page => $composableBuilder(
    column: $table.page,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedUtc => $composableBuilder(
    column: $table.updatedUtc,
    builder: (column) => ColumnFilters(column),
  );
}

class $$QuranReadingPositionsTableOrderingComposer
    extends Composer<_$QuranNotesDatabase, $QuranReadingPositionsTable> {
  $$QuranReadingPositionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get layoutId => $composableBuilder(
    column: $table.layoutId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get page => $composableBuilder(
    column: $table.page,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedUtc => $composableBuilder(
    column: $table.updatedUtc,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$QuranReadingPositionsTableAnnotationComposer
    extends Composer<_$QuranNotesDatabase, $QuranReadingPositionsTable> {
  $$QuranReadingPositionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get layoutId =>
      $composableBuilder(column: $table.layoutId, builder: (column) => column);

  GeneratedColumn<int> get page =>
      $composableBuilder(column: $table.page, builder: (column) => column);

  GeneratedColumn<int> get updatedUtc => $composableBuilder(
    column: $table.updatedUtc,
    builder: (column) => column,
  );
}

class $$QuranReadingPositionsTableTableManager
    extends
        RootTableManager<
          _$QuranNotesDatabase,
          $QuranReadingPositionsTable,
          QuranReadingPositionRow,
          $$QuranReadingPositionsTableFilterComposer,
          $$QuranReadingPositionsTableOrderingComposer,
          $$QuranReadingPositionsTableAnnotationComposer,
          $$QuranReadingPositionsTableCreateCompanionBuilder,
          $$QuranReadingPositionsTableUpdateCompanionBuilder,
          (
            QuranReadingPositionRow,
            BaseReferences<
              _$QuranNotesDatabase,
              $QuranReadingPositionsTable,
              QuranReadingPositionRow
            >,
          ),
          QuranReadingPositionRow,
          PrefetchHooks Function()
        > {
  $$QuranReadingPositionsTableTableManager(
    _$QuranNotesDatabase db,
    $QuranReadingPositionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QuranReadingPositionsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$QuranReadingPositionsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$QuranReadingPositionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> layoutId = const Value.absent(),
                Value<int> page = const Value.absent(),
                Value<int> updatedUtc = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => QuranReadingPositionsCompanion(
                layoutId: layoutId,
                page: page,
                updatedUtc: updatedUtc,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String layoutId,
                required int page,
                required int updatedUtc,
                Value<int> rowid = const Value.absent(),
              }) => QuranReadingPositionsCompanion.insert(
                layoutId: layoutId,
                page: page,
                updatedUtc: updatedUtc,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $QuranReadingPositionsTable,
                    QuranReadingPositionRow
                  >(table),
                  BaseReferences<
                    _$QuranNotesDatabase,
                    $QuranReadingPositionsTable,
                    QuranReadingPositionRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$QuranReadingPositionsTableProcessedTableManager =
    ProcessedTableManager<
      _$QuranNotesDatabase,
      $QuranReadingPositionsTable,
      QuranReadingPositionRow,
      $$QuranReadingPositionsTableFilterComposer,
      $$QuranReadingPositionsTableOrderingComposer,
      $$QuranReadingPositionsTableAnnotationComposer,
      $$QuranReadingPositionsTableCreateCompanionBuilder,
      $$QuranReadingPositionsTableUpdateCompanionBuilder,
      (
        QuranReadingPositionRow,
        BaseReferences<
          _$QuranNotesDatabase,
          $QuranReadingPositionsTable,
          QuranReadingPositionRow
        >,
      ),
      QuranReadingPositionRow,
      PrefetchHooks Function()
    >;
typedef $$QuranReaderPrefsTableCreateCompanionBuilder =
    QuranReaderPrefsCompanion Function({
      Value<int> id,
      required String fit,
      required bool facingPages,
    });
typedef $$QuranReaderPrefsTableUpdateCompanionBuilder =
    QuranReaderPrefsCompanion Function({
      Value<int> id,
      Value<String> fit,
      Value<bool> facingPages,
    });

class $$QuranReaderPrefsTableFilterComposer
    extends Composer<_$QuranNotesDatabase, $QuranReaderPrefsTable> {
  $$QuranReaderPrefsTableFilterComposer({
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

  ColumnFilters<String> get fit => $composableBuilder(
    column: $table.fit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get facingPages => $composableBuilder(
    column: $table.facingPages,
    builder: (column) => ColumnFilters(column),
  );
}

class $$QuranReaderPrefsTableOrderingComposer
    extends Composer<_$QuranNotesDatabase, $QuranReaderPrefsTable> {
  $$QuranReaderPrefsTableOrderingComposer({
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

  ColumnOrderings<String> get fit => $composableBuilder(
    column: $table.fit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get facingPages => $composableBuilder(
    column: $table.facingPages,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$QuranReaderPrefsTableAnnotationComposer
    extends Composer<_$QuranNotesDatabase, $QuranReaderPrefsTable> {
  $$QuranReaderPrefsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get fit =>
      $composableBuilder(column: $table.fit, builder: (column) => column);

  GeneratedColumn<bool> get facingPages => $composableBuilder(
    column: $table.facingPages,
    builder: (column) => column,
  );
}

class $$QuranReaderPrefsTableTableManager
    extends
        RootTableManager<
          _$QuranNotesDatabase,
          $QuranReaderPrefsTable,
          QuranReaderPrefsRow,
          $$QuranReaderPrefsTableFilterComposer,
          $$QuranReaderPrefsTableOrderingComposer,
          $$QuranReaderPrefsTableAnnotationComposer,
          $$QuranReaderPrefsTableCreateCompanionBuilder,
          $$QuranReaderPrefsTableUpdateCompanionBuilder,
          (
            QuranReaderPrefsRow,
            BaseReferences<
              _$QuranNotesDatabase,
              $QuranReaderPrefsTable,
              QuranReaderPrefsRow
            >,
          ),
          QuranReaderPrefsRow,
          PrefetchHooks Function()
        > {
  $$QuranReaderPrefsTableTableManager(
    _$QuranNotesDatabase db,
    $QuranReaderPrefsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QuranReaderPrefsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$QuranReaderPrefsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$QuranReaderPrefsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> fit = const Value.absent(),
                Value<bool> facingPages = const Value.absent(),
              }) => QuranReaderPrefsCompanion(
                id: id,
                fit: fit,
                facingPages: facingPages,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String fit,
                required bool facingPages,
              }) => QuranReaderPrefsCompanion.insert(
                id: id,
                fit: fit,
                facingPages: facingPages,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$QuranReaderPrefsTable, QuranReaderPrefsRow>(
                    table,
                  ),
                  BaseReferences<
                    _$QuranNotesDatabase,
                    $QuranReaderPrefsTable,
                    QuranReaderPrefsRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$QuranReaderPrefsTableProcessedTableManager =
    ProcessedTableManager<
      _$QuranNotesDatabase,
      $QuranReaderPrefsTable,
      QuranReaderPrefsRow,
      $$QuranReaderPrefsTableFilterComposer,
      $$QuranReaderPrefsTableOrderingComposer,
      $$QuranReaderPrefsTableAnnotationComposer,
      $$QuranReaderPrefsTableCreateCompanionBuilder,
      $$QuranReaderPrefsTableUpdateCompanionBuilder,
      (
        QuranReaderPrefsRow,
        BaseReferences<
          _$QuranNotesDatabase,
          $QuranReaderPrefsTable,
          QuranReaderPrefsRow
        >,
      ),
      QuranReaderPrefsRow,
      PrefetchHooks Function()
    >;

class $QuranNotesDatabaseManager {
  final _$QuranNotesDatabase _db;
  $QuranNotesDatabaseManager(this._db);
  $$QuranBookmarksTableTableManager get quranBookmarks =>
      $$QuranBookmarksTableTableManager(_db, _db.quranBookmarks);
  $$QuranHighlightsTableTableManager get quranHighlights =>
      $$QuranHighlightsTableTableManager(_db, _db.quranHighlights);
  $$QuranHighlightRegionsTableTableManager get quranHighlightRegions =>
      $$QuranHighlightRegionsTableTableManager(_db, _db.quranHighlightRegions);
  $$QuranReadingPositionsTableTableManager get quranReadingPositions =>
      $$QuranReadingPositionsTableTableManager(_db, _db.quranReadingPositions);
  $$QuranReaderPrefsTableTableManager get quranReaderPrefs =>
      $$QuranReaderPrefsTableTableManager(_db, _db.quranReaderPrefs);
}
