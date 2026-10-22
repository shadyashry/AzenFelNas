import 'package:drift/drift.dart';

/// The `gazetteer` table of §7.3: one row per place, filled at package
/// activation.
@DataClassName('GazetteerRow')
class Gazetteer extends Table {
  /// GeoNames id.
  IntColumn get id => integer()();

  /// Name in the source's local spelling.
  TextColumn get name => text()();

  /// Name without diacritics.
  TextColumn get asciiName => text()();

  /// `{"ar": [...], "en": [...]}` as in the payload.
  TextColumn get altNamesJson => text()();

  /// ISO 3166-1 alpha-2 code.
  TextColumn get country => text()();

  /// GeoNames admin1 code; empty when unknown.
  TextColumn get admin1 => text()();

  /// Latitude in degrees (micro-degree precision).
  RealColumn get lat => real()();

  /// Longitude in degrees (micro-degree precision).
  RealColumn get lon => real()();

  /// Population; 0 when unknown.
  IntColumn get population => integer()();

  /// IANA zone id.
  TextColumn get zoneId => text()();

  /// Search key of [name].
  TextColumn get nameNorm => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// One row per distinct search key of a place: the index that serves prefix
/// search (§15 D72). Without a rowid the primary key is the table's b-tree, so
/// `search_key BETWEEN prefix AND prefix + U+10FFFF` is one range scan.
@DataClassName('GazetteerNameRow')
class GazetteerNames extends Table {
  /// A `SearchKey` value.
  TextColumn get searchKey => text()();

  /// The place the key belongs to.
  IntColumn get placeId => integer().references(Gazetteer, #id)();

  /// The name the key was made from.
  TextColumn get name => text()();

  @override
  Set<Column<Object>> get primaryKey => {searchKey, placeId};

  @override
  bool get withoutRowId => true;
}

/// The gazetteer tables on their own database until the app shell (S16)
