import 'dart:convert';

import 'package:daily_muslim/features/settings/domain/setting_key.dart';
import 'package:daily_muslim/features/settings/domain/settings_ports.dart';
import 'package:daily_muslim/features/storage/data/dm_database.dart';
import 'package:drift/drift.dart';

/// Appendix K settings in the `settings` table of `dm.sqlite`.
final class DriftSettingsStore
    implements ReadSetting, WatchSetting, WriteSetting {
  /// The store in [_db].
  const new(this._db);

  final DmDatabase _db;

  @override
  Future<T> read<T>(SettingKey<T> key) =>
      _query(key).getSingleOrNull().then((row) => _valueOf(key, row));

  @override
  Stream<T> watch<T>(SettingKey<T> key) =>
      _query(key)
          .watchSingleOrNull()
          .map((row) => _valueOf(key, row))
          .distinct();

  @override
  Future<void> write<T>(SettingKey<T> key, T value) async {
    final json = jsonEncode(key.codec.encode(value));
    if (json == jsonEncode(key.codec.encode(key.defaultValue))) {
      await (_db.delete(
        _db.settings,
      )..where((r) => r.key.equals(key.wire))).go();
      return;
    }
    await _db
        .into(_db.settings)
        .insertOnConflictUpdate(
          SettingsCompanion.insert(key: key.wire, valueJson: json),
        );
  }

  Selectable<SettingRow> _query<T>(SettingKey<T> key) =>
      _db.select(_db.settings)..where((r) => r.key.equals(key.wire));

  static T _valueOf<T>(SettingKey<T> key, SettingRow? row) {
    if (row == null) return key.defaultValue;
    final Object? json;
    try {
      json = jsonDecode(row.valueJson);
    } on FormatException {
      return key.defaultValue;
    }
    return key.codec.decode(json)?.value ?? key.defaultValue;
  }
}
