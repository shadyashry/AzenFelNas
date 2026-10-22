import 'package:daily_muslim/features/settings/domain/setting_codec.dart';

/// One Appendix K key with its JSON [codec] and the value used while the
/// user has not chosen one.
final class SettingKey<T> {
  /// The key stored as [wire].
  const new(this.wire, this.codec, this.defaultValue);

  /// The Appendix K name; the `settings.key` column.
  final String wire;

  /// How the value is stored.
  final SettingCodec<T> codec;

  /// The value when no row exists or the row is unreadable.
  final T defaultValue;

  @override
  String toString() => 'SettingKey($wire)';
}
