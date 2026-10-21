// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'gazetteer_alt_names.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GazetteerAltNames {

/// Arabic names.
 List<String> get ar;/// English names.
 List<String> get en;
/// Create a copy of GazetteerAltNames
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GazetteerAltNamesCopyWith<GazetteerAltNames> get copyWith => _$GazetteerAltNamesCopyWithImpl<GazetteerAltNames>(this as GazetteerAltNames, _$identity);

  /// Serializes this GazetteerAltNames to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as GazetteerAltNames;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GazetteerAltNames&&const DeepCollectionEquality().equals(other.ar, _this.ar)&&const DeepCollectionEquality().equals(other.en, _this.en));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as GazetteerAltNames;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.ar),const DeepCollectionEquality().hash(_this.en));
}

@override
String toString() {
  final _this = this as GazetteerAltNames;
  return 'GazetteerAltNames(ar: ${_this.ar}, en: ${_this.en})';
}


}

/// @nodoc
abstract mixin class $GazetteerAltNamesCopyWith<$Res>  {
  factory $GazetteerAltNamesCopyWith(GazetteerAltNames value, $Res Function(GazetteerAltNames) _then) = _$GazetteerAltNamesCopyWithImpl;
@useResult
$Res call({
 List<String> ar, List<String> en
});




}
/// @nodoc
class _$GazetteerAltNamesCopyWithImpl<$Res>
    implements $GazetteerAltNamesCopyWith<$Res> {
  _$GazetteerAltNamesCopyWithImpl(this._self, this._then);

  final GazetteerAltNames _self;
  final $Res Function(GazetteerAltNames) _then;

/// Create a copy of GazetteerAltNames
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? ar = null,Object? en = null,}) {
  return _then(GazetteerAltNames(
ar: null == ar ? _self.ar : ar // ignore: cast_nullable_to_non_nullable
as List<String>,en: null == en ? _self.en : en // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [GazetteerAltNames].
extension GazetteerAltNamesPatterns on GazetteerAltNames {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GazetteerAltNames value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GazetteerAltNames() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GazetteerAltNames value)  $default,){
final _that = this;
switch (_that) {
case _GazetteerAltNames():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GazetteerAltNames value)?  $default,){
final _that = this;
switch (_that) {
case _GazetteerAltNames() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<String> ar,  List<String> en)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GazetteerAltNames() when $default != null:
return $default(_that.ar,_that.en);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<String> ar,  List<String> en)  $default,) {final _that = this;
switch (_that) {
case _GazetteerAltNames():
return $default(_that.ar,_that.en);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<String> ar,  List<String> en)?  $default,) {final _that = this;
switch (_that) {
case _GazetteerAltNames() when $default != null:
return $default(_that.ar,_that.en);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GazetteerAltNames implements GazetteerAltNames {
  const _GazetteerAltNames({required  List<String> ar, required  List<String> en}): _ar = ar,_en = en;
  factory _GazetteerAltNames.fromJson(Map<String, dynamic> json) => _$GazetteerAltNamesFromJson(json);

/// Arabic names.
 final  List<String> _ar;
/// Arabic names.
@override List<String> get ar {
  if (_ar is EqualUnmodifiableListView) return _ar;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_ar);
}

/// English names.
 final  List<String> _en;
/// English names.
@override List<String> get en {
  if (_en is EqualUnmodifiableListView) return _en;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_en);
}


/// Create a copy of GazetteerAltNames
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GazetteerAltNamesCopyWith<_GazetteerAltNames> get copyWith => __$GazetteerAltNamesCopyWithImpl<_GazetteerAltNames>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GazetteerAltNamesToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _GazetteerAltNames&&const DeepCollectionEquality().equals(other.ar, _ar)&&const DeepCollectionEquality().equals(other.en, _en));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_ar),const DeepCollectionEquality().hash(_en));
}

@override
String toString() {
    return 'GazetteerAltNames(ar: $ar, en: $en)';
}


}

/// @nodoc
abstract mixin class _$GazetteerAltNamesCopyWith<$Res> implements $GazetteerAltNamesCopyWith<$Res> {
  factory _$GazetteerAltNamesCopyWith(_GazetteerAltNames value, $Res Function(_GazetteerAltNames) _then) = __$GazetteerAltNamesCopyWithImpl;
@override @useResult
$Res call({
 List<String> ar, List<String> en
});




}
/// @nodoc
class __$GazetteerAltNamesCopyWithImpl<$Res>
    implements _$GazetteerAltNamesCopyWith<$Res> {
  __$GazetteerAltNamesCopyWithImpl(this._self, this._then);

  final _GazetteerAltNames _self;
  final $Res Function(_GazetteerAltNames) _then;

/// Create a copy of GazetteerAltNames
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? ar = null,Object? en = null,}) {
  return _then(_GazetteerAltNames(
ar: null == ar ? _self._ar : ar // ignore: cast_nullable_to_non_nullable
as List<String>,en: null == en ? _self._en : en // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
