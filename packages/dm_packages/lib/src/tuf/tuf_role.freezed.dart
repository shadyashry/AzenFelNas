// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tuf_role.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TufRole {

/// Key ids allowed to sign.
 List<String> get keyIds;/// Signatures required.
 int get threshold;
/// Create a copy of TufRole
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TufRoleCopyWith<TufRole> get copyWith => _$TufRoleCopyWithImpl<TufRole>(this as TufRole, _$identity);

  /// Serializes this TufRole to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as TufRole;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TufRole&&const DeepCollectionEquality().equals(other.keyIds, _this.keyIds)&&(identical(other.threshold, _this.threshold) || other.threshold == _this.threshold));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as TufRole;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.keyIds),_this.threshold);
}

@override
String toString() {
  final _this = this as TufRole;
  return 'TufRole(keyIds: ${_this.keyIds}, threshold: ${_this.threshold})';
}


}

/// @nodoc
abstract mixin class $TufRoleCopyWith<$Res>  {
  factory $TufRoleCopyWith(TufRole value, $Res Function(TufRole) _then) = _$TufRoleCopyWithImpl;
@useResult
$Res call({
 List<String> keyIds, int threshold
});




}
/// @nodoc
class _$TufRoleCopyWithImpl<$Res>
    implements $TufRoleCopyWith<$Res> {
  _$TufRoleCopyWithImpl(this._self, this._then);

  final TufRole _self;
  final $Res Function(TufRole) _then;

/// Create a copy of TufRole
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? keyIds = null,Object? threshold = null,}) {
  return _then(TufRole(
keyIds: null == keyIds ? _self.keyIds : keyIds // ignore: cast_nullable_to_non_nullable
as List<String>,threshold: null == threshold ? _self.threshold : threshold // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [TufRole].
extension TufRolePatterns on TufRole {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TufRole value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TufRole() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TufRole value)  $default,){
final _that = this;
switch (_that) {
case _TufRole():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TufRole value)?  $default,){
final _that = this;
switch (_that) {
case _TufRole() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<String> keyIds,  int threshold)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TufRole() when $default != null:
return $default(_that.keyIds,_that.threshold);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<String> keyIds,  int threshold)  $default,) {final _that = this;
switch (_that) {
case _TufRole():
return $default(_that.keyIds,_that.threshold);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<String> keyIds,  int threshold)?  $default,) {final _that = this;
switch (_that) {
case _TufRole() when $default != null:
return $default(_that.keyIds,_that.threshold);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TufRole implements TufRole {
  const _TufRole({required  List<String> keyIds, required this.threshold}): _keyIds = keyIds;
  factory _TufRole.fromJson(Map<String, dynamic> json) => _$TufRoleFromJson(json);

/// Key ids allowed to sign.
 final  List<String> _keyIds;
/// Key ids allowed to sign.
@override List<String> get keyIds {
  if (_keyIds is EqualUnmodifiableListView) return _keyIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_keyIds);
}

/// Signatures required.
@override final  int threshold;

/// Create a copy of TufRole
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TufRoleCopyWith<_TufRole> get copyWith => __$TufRoleCopyWithImpl<_TufRole>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TufRoleToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TufRole&&const DeepCollectionEquality().equals(other.keyIds, _keyIds)&&(identical(other.threshold, threshold) || other.threshold == threshold));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_keyIds),threshold);
}

@override
String toString() {
    return 'TufRole(keyIds: $keyIds, threshold: $threshold)';
}


}

/// @nodoc
abstract mixin class _$TufRoleCopyWith<$Res> implements $TufRoleCopyWith<$Res> {
  factory _$TufRoleCopyWith(_TufRole value, $Res Function(_TufRole) _then) = __$TufRoleCopyWithImpl;
@override @useResult
$Res call({
 List<String> keyIds, int threshold
});




}
/// @nodoc
class __$TufRoleCopyWithImpl<$Res>
    implements _$TufRoleCopyWith<$Res> {
  __$TufRoleCopyWithImpl(this._self, this._then);

  final _TufRole _self;
  final $Res Function(_TufRole) _then;

/// Create a copy of TufRole
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? keyIds = null,Object? threshold = null,}) {
  return _then(_TufRole(
keyIds: null == keyIds ? _self._keyIds : keyIds // ignore: cast_nullable_to_non_nullable
as List<String>,threshold: null == threshold ? _self.threshold : threshold // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
