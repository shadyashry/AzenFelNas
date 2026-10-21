// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tuf_snapshot_meta.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TufSnapshotMeta {

/// `targets.json`.
@JsonKey(name: 'targets.json') TufMetaRef get targetsJson;
/// Create a copy of TufSnapshotMeta
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TufSnapshotMetaCopyWith<TufSnapshotMeta> get copyWith => _$TufSnapshotMetaCopyWithImpl<TufSnapshotMeta>(this as TufSnapshotMeta, _$identity);

  /// Serializes this TufSnapshotMeta to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as TufSnapshotMeta;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TufSnapshotMeta&&(identical(other.targetsJson, _this.targetsJson) || other.targetsJson == _this.targetsJson));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as TufSnapshotMeta;
  return Object.hash(runtimeType,_this.targetsJson);
}

@override
String toString() {
  final _this = this as TufSnapshotMeta;
  return 'TufSnapshotMeta(targetsJson: ${_this.targetsJson})';
}


}

/// @nodoc
abstract mixin class $TufSnapshotMetaCopyWith<$Res>  {
  factory $TufSnapshotMetaCopyWith(TufSnapshotMeta value, $Res Function(TufSnapshotMeta) _then) = _$TufSnapshotMetaCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'targets.json') TufMetaRef targetsJson
});


$TufMetaRefCopyWith<$Res> get targetsJson;

}
/// @nodoc
class _$TufSnapshotMetaCopyWithImpl<$Res>
    implements $TufSnapshotMetaCopyWith<$Res> {
  _$TufSnapshotMetaCopyWithImpl(this._self, this._then);

  final TufSnapshotMeta _self;
  final $Res Function(TufSnapshotMeta) _then;

/// Create a copy of TufSnapshotMeta
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? targetsJson = null,}) {
  return _then(TufSnapshotMeta(
targetsJson: null == targetsJson ? _self.targetsJson : targetsJson // ignore: cast_nullable_to_non_nullable
as TufMetaRef,
  ));
}
/// Create a copy of TufSnapshotMeta
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TufMetaRefCopyWith<$Res> get targetsJson {
  
  return $TufMetaRefCopyWith<$Res>(_self.targetsJson, (value) {
    return _then(_self.copyWith(targetsJson: value));
  });
}
}


/// Adds pattern-matching-related methods to [TufSnapshotMeta].
extension TufSnapshotMetaPatterns on TufSnapshotMeta {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TufSnapshotMeta value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TufSnapshotMeta() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TufSnapshotMeta value)  $default,){
final _that = this;
switch (_that) {
case _TufSnapshotMeta():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TufSnapshotMeta value)?  $default,){
final _that = this;
switch (_that) {
case _TufSnapshotMeta() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'targets.json')  TufMetaRef targetsJson)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TufSnapshotMeta() when $default != null:
return $default(_that.targetsJson);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'targets.json')  TufMetaRef targetsJson)  $default,) {final _that = this;
switch (_that) {
case _TufSnapshotMeta():
return $default(_that.targetsJson);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'targets.json')  TufMetaRef targetsJson)?  $default,) {final _that = this;
switch (_that) {
case _TufSnapshotMeta() when $default != null:
return $default(_that.targetsJson);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TufSnapshotMeta implements TufSnapshotMeta {
  const _TufSnapshotMeta({@JsonKey(name: 'targets.json') required this.targetsJson});
  factory _TufSnapshotMeta.fromJson(Map<String, dynamic> json) => _$TufSnapshotMetaFromJson(json);

/// `targets.json`.
@override@JsonKey(name: 'targets.json') final  TufMetaRef targetsJson;

/// Create a copy of TufSnapshotMeta
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TufSnapshotMetaCopyWith<_TufSnapshotMeta> get copyWith => __$TufSnapshotMetaCopyWithImpl<_TufSnapshotMeta>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TufSnapshotMetaToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TufSnapshotMeta&&(identical(other.targetsJson, targetsJson) || other.targetsJson == targetsJson));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,targetsJson);
}

@override
String toString() {
    return 'TufSnapshotMeta(targetsJson: $targetsJson)';
}


}

/// @nodoc
abstract mixin class _$TufSnapshotMetaCopyWith<$Res> implements $TufSnapshotMetaCopyWith<$Res> {
  factory _$TufSnapshotMetaCopyWith(_TufSnapshotMeta value, $Res Function(_TufSnapshotMeta) _then) = __$TufSnapshotMetaCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'targets.json') TufMetaRef targetsJson
});


@override $TufMetaRefCopyWith<$Res> get targetsJson;

}
/// @nodoc
class __$TufSnapshotMetaCopyWithImpl<$Res>
    implements _$TufSnapshotMetaCopyWith<$Res> {
  __$TufSnapshotMetaCopyWithImpl(this._self, this._then);

  final _TufSnapshotMeta _self;
  final $Res Function(_TufSnapshotMeta) _then;

/// Create a copy of TufSnapshotMeta
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? targetsJson = null,}) {
  return _then(_TufSnapshotMeta(
targetsJson: null == targetsJson ? _self.targetsJson : targetsJson // ignore: cast_nullable_to_non_nullable
as TufMetaRef,
  ));
}

/// Create a copy of TufSnapshotMeta
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TufMetaRefCopyWith<$Res> get targetsJson {
  
  return $TufMetaRefCopyWith<$Res>(_self.targetsJson, (value) {
    return _then(_self.copyWith(targetsJson: value));
  });
}
}

// dart format on
