import 'package:drift/drift.dart';

/// §7.3 `settings`: one row per Appendix K key that differs from its default.
@DataClassName('SettingRow')
class Settings extends Table {
  /// `SettingKey.wire`.
  TextColumn get key => text()();

  /// The value as JSON.
  TextColumn get valueJson => text()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}
