import 'package:daily_muslim/features/radio/domain/radio_station.dart';
import 'package:daily_muslim/features/settings/domain/app_settings.dart';
import 'package:daily_muslim/features/settings/domain/settings_ports.dart';

/// Adds a station to the favorites, or takes it out (§15 D122,
/// REQ-RADIO-002): kept by its provider-qualified id only.
final class ToggleRadioFavorite {
  /// The use case over the settings store.
  const new({required this._read, required this._write});

  final ReadSetting _read;
  final WriteSetting _write;

  /// Toggles [id]; returns whether it is a favorite now.
  Future<bool> call(RadioStationId id) async {
    final current = await _read.read(AppSettings.radioFavorites);
    final next = {...current};
    final added = next.add(id.wire);
    if (!added) next.remove(id.wire);
    await _write.write(AppSettings.radioFavorites, next);
    return added;
  }
}
