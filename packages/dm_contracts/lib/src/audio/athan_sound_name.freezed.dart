// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'athan_sound_name.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AthanSoundName {

/// English name.
 String get en;/// Arabic name.
 String get ar;
/// Create a copy of AthanSoundName
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AthanSoundNameCopyWith<AthanSoundName> get copyWith => _$AthanSoundNameCopyWithImpl<AthanSoundName>(this as AthanSoundName, _$identity);

  /// Serializes this AthanSoundName to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AthanSoundName;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AthanSoundName&&(identical(other.en, _this.en) || other.en == _this.en)&&(identical(other.ar, _this.ar) || other.ar == _this.ar));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AthanSoundName;
  return Object.hash(runtimeType,_this.en,_this.ar);
}

@override
String toString() {
  final _this = this as AthanSoundName;
  return 'AthanSoundName(en: ${_this.en}, ar: ${_this.ar})';
}


}

/// @nodoc
abstract mixin class $AthanSoundNameCopyWith<$Res>  {
  factory $AthanSoundNameCopyWith(AthanSoundName value, $Res Function(AthanSoundName) _then) = _$AthanSoundNameCopyWithImpl;
@useResult
$Res call({
 String en, String ar
});




}
/// @nodoc
class _$AthanSoundNameCopyWithImpl<$Res>
    implements $AthanSoundNameCopyWith<$Res> {
  _$AthanSoundNameCopyWithImpl(this._self, this._then);

  final AthanSoundName _self;
  final $Res Function(AthanSoundName) _then;

/// Create a copy of AthanSoundName
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? en = null,Object? ar = null,}) {
  return _then(AthanSoundName(
en: null == en ? _self.en : en // ignore: cast_nullable_to_non_nullable
as String,ar: null == ar ? _self.ar : ar // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [AthanSoundName].
extension AthanSoundNamePatterns on AthanSoundName {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AthanSoundName value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AthanSoundName() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AthanSoundName value)  $default,){
final _that = this;
switch (_that) {
case _AthanSoundName():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AthanSoundName value)?  $default,){
final _that = this;
switch (_that) {
case _AthanSoundName() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String en,  String ar)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AthanSoundName() when $default != null:
return $default(_that.en,_that.ar);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String en,  String ar)  $default,) {final _that = this;
switch (_that) {
case _AthanSoundName():
return $default(_that.en,_that.ar);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String en,  String ar)?  $default,) {final _that = this;
switch (_that) {
case _AthanSoundName() when $default != null:
return $default(_that.en,_that.ar);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AthanSoundName implements AthanSoundName {
  const _AthanSoundName({required this.en, required this.ar});
  factory _AthanSoundName.fromJson(Map<String, dynamic> json) => _$AthanSoundNameFromJson(json);

/// English name.
@override final  String en;
/// Arabic name.
@override final  String ar;

/// Create a copy of AthanSoundName
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AthanSoundNameCopyWith<_AthanSoundName> get copyWith => __$AthanSoundNameCopyWithImpl<_AthanSoundName>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AthanSoundNameToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AthanSoundName&&(identical(other.en, en) || other.en == en)&&(identical(other.ar, ar) || other.ar == ar));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,en,ar);
}

@override
String toString() {
    return 'AthanSoundName(en: $en, ar: $ar)';
}


}

/// @nodoc
abstract mixin class _$AthanSoundNameCopyWith<$Res> implements $AthanSoundNameCopyWith<$Res> {
  factory _$AthanSoundNameCopyWith(_AthanSoundName value, $Res Function(_AthanSoundName) _then) = __$AthanSoundNameCopyWithImpl;
@override @useResult
$Res call({
 String en, String ar
});




}
/// @nodoc
class __$AthanSoundNameCopyWithImpl<$Res>
    implements _$AthanSoundNameCopyWith<$Res> {
  __$AthanSoundNameCopyWithImpl(this._self, this._then);

  final _AthanSoundName _self;
  final $Res Function(_AthanSoundName) _then;

/// Create a copy of AthanSoundName
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? en = null,Object? ar = null,}) {
  return _then(_AthanSoundName(
en: null == en ? _self.en : en // ignore: cast_nullable_to_non_nullable
as String,ar: null == ar ? _self.ar : ar // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
