// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tuf_timestamp_meta.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TufTimestampMeta {

/// `snapshot.json`.
@JsonKey(name: 'snapshot.json') TufMetaRef get snapshotJson;
/// Create a copy of TufTimestampMeta
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TufTimestampMetaCopyWith<TufTimestampMeta> get copyWith => _$TufTimestampMetaCopyWithImpl<TufTimestampMeta>(this as TufTimestampMeta, _$identity);

  /// Serializes this TufTimestampMeta to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as TufTimestampMeta;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TufTimestampMeta&&(identical(other.snapshotJson, _this.snapshotJson) || other.snapshotJson == _this.snapshotJson));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as TufTimestampMeta;
  return Object.hash(runtimeType,_this.snapshotJson);
}

@override
String toString() {
  final _this = this as TufTimestampMeta;
  return 'TufTimestampMeta(snapshotJson: ${_this.snapshotJson})';
}


}

/// @nodoc
abstract mixin class $TufTimestampMetaCopyWith<$Res>  {
  factory $TufTimestampMetaCopyWith(TufTimestampMeta value, $Res Function(TufTimestampMeta) _then) = _$TufTimestampMetaCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'snapshot.json') TufMetaRef snapshotJson
});


$TufMetaRefCopyWith<$Res> get snapshotJson;

}
/// @nodoc
class _$TufTimestampMetaCopyWithImpl<$Res>
    implements $TufTimestampMetaCopyWith<$Res> {
  _$TufTimestampMetaCopyWithImpl(this._self, this._then);

  final TufTimestampMeta _self;
  final $Res Function(TufTimestampMeta) _then;

/// Create a copy of TufTimestampMeta
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? snapshotJson = null,}) {
  return _then(TufTimestampMeta(
snapshotJson: null == snapshotJson ? _self.snapshotJson : snapshotJson // ignore: cast_nullable_to_non_nullable
as TufMetaRef,
  ));
}
/// Create a copy of TufTimestampMeta
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TufMetaRefCopyWith<$Res> get snapshotJson {
  
  return $TufMetaRefCopyWith<$Res>(_self.snapshotJson, (value) {
    return _then(_self.copyWith(snapshotJson: value));
  });
}
}


/// Adds pattern-matching-related methods to [TufTimestampMeta].
extension TufTimestampMetaPatterns on TufTimestampMeta {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TufTimestampMeta value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TufTimestampMeta() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TufTimestampMeta value)  $default,){
final _that = this;
switch (_that) {
case _TufTimestampMeta():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TufTimestampMeta value)?  $default,){
final _that = this;
switch (_that) {
case _TufTimestampMeta() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'snapshot.json')  TufMetaRef snapshotJson)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TufTimestampMeta() when $default != null:
return $default(_that.snapshotJson);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'snapshot.json')  TufMetaRef snapshotJson)  $default,) {final _that = this;
switch (_that) {
case _TufTimestampMeta():
return $default(_that.snapshotJson);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'snapshot.json')  TufMetaRef snapshotJson)?  $default,) {final _that = this;
switch (_that) {
case _TufTimestampMeta() when $default != null:
return $default(_that.snapshotJson);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TufTimestampMeta implements TufTimestampMeta {
  const _TufTimestampMeta({@JsonKey(name: 'snapshot.json') required this.snapshotJson});
  factory _TufTimestampMeta.fromJson(Map<String, dynamic> json) => _$TufTimestampMetaFromJson(json);

/// `snapshot.json`.
@override@JsonKey(name: 'snapshot.json') final  TufMetaRef snapshotJson;

/// Create a copy of TufTimestampMeta
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TufTimestampMetaCopyWith<_TufTimestampMeta> get copyWith => __$TufTimestampMetaCopyWithImpl<_TufTimestampMeta>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TufTimestampMetaToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TufTimestampMeta&&(identical(other.snapshotJson, snapshotJson) || other.snapshotJson == snapshotJson));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,snapshotJson);
}

@override
String toString() {
    return 'TufTimestampMeta(snapshotJson: $snapshotJson)';
}


}

/// @nodoc
abstract mixin class _$TufTimestampMetaCopyWith<$Res> implements $TufTimestampMetaCopyWith<$Res> {
  factory _$TufTimestampMetaCopyWith(_TufTimestampMeta value, $Res Function(_TufTimestampMeta) _then) = __$TufTimestampMetaCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'snapshot.json') TufMetaRef snapshotJson
});


@override $TufMetaRefCopyWith<$Res> get snapshotJson;

}
/// @nodoc
class __$TufTimestampMetaCopyWithImpl<$Res>
    implements _$TufTimestampMetaCopyWith<$Res> {
  __$TufTimestampMetaCopyWithImpl(this._self, this._then);

  final _TufTimestampMeta _self;
  final $Res Function(_TufTimestampMeta) _then;

/// Create a copy of TufTimestampMeta
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? snapshotJson = null,}) {
  return _then(_TufTimestampMeta(
snapshotJson: null == snapshotJson ? _self.snapshotJson : snapshotJson // ignore: cast_nullable_to_non_nullable
as TufMetaRef,
  ));
}

/// Create a copy of TufTimestampMeta
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TufMetaRefCopyWith<$Res> get snapshotJson {
  
  return $TufMetaRefCopyWith<$Res>(_self.snapshotJson, (value) {
    return _then(_self.copyWith(snapshotJson: value));
  });
}
}

// dart format on
