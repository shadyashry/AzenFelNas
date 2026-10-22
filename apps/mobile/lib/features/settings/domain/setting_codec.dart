/// How one Appendix K value is stored as JSON in `settings.value_json`.
///
/// [decode] returns `null` for a stored value it cannot read; the caller then
/// uses the key's default (a corrupt row never crashes the app).
sealed class SettingCodec<T> {
  const new();

  /// The JSON form of [value].
  Object? encode(T value);

  /// The value of [json], or `null` when [json] is not a valid value.
  ({T value})? decode(Object? json);
}

/// A `bool`.
final class BoolCodec extends SettingCodec<bool> {
  /// The codec.
  const new();

  @override
  Object? encode(bool value) => value;

  @override
  ({bool value})? decode(Object? json) => json is bool ? (value: json) : null;
}

/// An `int`, or `null` for "not set".
final class OptionalIntCodec extends SettingCodec<int?> {
  /// The codec.
  const new();

  @override
  Object? encode(int? value) => value;

  @override
  ({int? value})? decode(Object? json) => switch (json) {
    null => (value: null),
    final int v => (value: v),
    _ => null,
  };
}

/// An `int` from a closed set of [allowed] values.
final class ChoiceIntCodec extends SettingCodec<int> {
  /// The codec accepting [allowed].
  const new(this.allowed);

  /// The valid values.
  final Set<int> allowed;

  @override
  Object? encode(int value) => value;

  @override
  ({int value})? decode(Object? json) =>
      json is int && allowed.contains(json) ? (value: json) : null;
}

/// A non-negative `int`.
final class CountCodec extends SettingCodec<int> {
  /// The codec.
  const new();

  @override
  Object? encode(int value) => value;

  @override
  ({int value})? decode(Object? json) =>
      json is int && json >= 0 ? (value: json) : null;
}

/// A `String`, or `null` for "not set".
final class OptionalStringCodec extends SettingCodec<String?> {
  /// The codec.
  const new();

  @override
  Object? encode(String? value) => value;

  @override
  ({String? value})? decode(Object? json) => switch (json) {
    null => (value: null),
    final String v => (value: v),
    _ => null,
  };
}

/// An enum stored by its `name` (the Appendix K spelling).
final class EnumCodec<E extends Enum> extends SettingCodec<E> {
  /// The codec over [values].
  const new(this.values);

  /// Every value of the enum.
  final List<E> values;

  @override
  Object? encode(E value) => value.name;

  @override
  ({E value})? decode(Object? json) {
    for (final v in values) {
      if (v.name == json) return (value: v);
    }
    return null;
  }
}

/// A map from a name to a `bool` (`athanEnabled{event: bool}`).
final class BoolMapCodec extends SettingCodec<Map<String, bool>> {
  /// The codec.
  const new();

  @override
  Object? encode(Map<String, bool> value) => {
    for (final name in value.keys.toList()..sort()) name: value[name],
  };

  @override
  ({Map<String, bool> value})? decode(Object? json) {
    if (json is! Map<String, Object?>) return null;
    final out = <String, bool>{};
    for (final MapEntry(:key, :value) in json.entries) {
      if (value is! bool) return null;
      out[key] = value;
    }
    return (value: Map.unmodifiable(out));
  }
}
