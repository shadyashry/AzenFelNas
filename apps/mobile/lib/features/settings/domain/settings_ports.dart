import 'package:daily_muslim/features/settings/domain/setting_key.dart';

/// Reads one setting. Contract: never fails; a missing or unreadable row is
/// the key's default.
abstract interface class ReadSetting {
  /// The current value of [key].
  Future<T> read<T>(SettingKey<T> key);
}

/// Observes one setting. Contract: emits the current value first, then each
/// change; never errors.
abstract interface class WatchSetting {
  /// The values of [key].
  Stream<T> watch<T>(SettingKey<T> key);
}

/// Writes one setting. Contract: writing the default removes the row, so
/// a later default change reaches users who never chose.
abstract interface class WriteSetting {
  /// Stores [value] for [key].
  Future<void> write<T>(SettingKey<T> key, T value);
}
