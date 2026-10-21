// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'athan_audio_manifest.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AthanAudioManifest {

/// Sounds.
 List<AthanSound> get sounds;
/// Create a copy of AthanAudioManifest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AthanAudioManifestCopyWith<AthanAudioManifest> get copyWith => _$AthanAudioManifestCopyWithImpl<AthanAudioManifest>(this as AthanAudioManifest, _$identity);

  /// Serializes this AthanAudioManifest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AthanAudioManifest;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AthanAudioManifest&&const DeepCollectionEquality().equals(other.sounds, _this.sounds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AthanAudioManifest;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.sounds));
}

@override
String toString() {
  final _this = this as AthanAudioManifest;
  return 'AthanAudioManifest(sounds: ${_this.sounds})';
}


}

/// @nodoc
abstract mixin class $AthanAudioManifestCopyWith<$Res>  {
  factory $AthanAudioManifestCopyWith(AthanAudioManifest value, $Res Function(AthanAudioManifest) _then) = _$AthanAudioManifestCopyWithImpl;
@useResult
$Res call({
 List<AthanSound> sounds
});




}
/// @nodoc
class _$AthanAudioManifestCopyWithImpl<$Res>
    implements $AthanAudioManifestCopyWith<$Res> {
  _$AthanAudioManifestCopyWithImpl(this._self, this._then);

  final AthanAudioManifest _self;
  final $Res Function(AthanAudioManifest) _then;

/// Create a copy of AthanAudioManifest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? sounds = null,}) {
  return _then(AthanAudioManifest(
sounds: null == sounds ? _self.sounds : sounds // ignore: cast_nullable_to_non_nullable
as List<AthanSound>,
  ));
}

}


/// Adds pattern-matching-related methods to [AthanAudioManifest].
extension AthanAudioManifestPatterns on AthanAudioManifest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AthanAudioManifest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AthanAudioManifest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AthanAudioManifest value)  $default,){
final _that = this;
switch (_that) {
case _AthanAudioManifest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AthanAudioManifest value)?  $default,){
final _that = this;
switch (_that) {
case _AthanAudioManifest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<AthanSound> sounds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AthanAudioManifest() when $default != null:
return $default(_that.sounds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<AthanSound> sounds)  $default,) {final _that = this;
switch (_that) {
case _AthanAudioManifest():
return $default(_that.sounds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<AthanSound> sounds)?  $default,) {final _that = this;
switch (_that) {
case _AthanAudioManifest() when $default != null:
return $default(_that.sounds);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AthanAudioManifest implements AthanAudioManifest {
  const _AthanAudioManifest({required  List<AthanSound> sounds}): _sounds = sounds;
  factory _AthanAudioManifest.fromJson(Map<String, dynamic> json) => _$AthanAudioManifestFromJson(json);

/// Sounds.
 final  List<AthanSound> _sounds;
/// Sounds.
@override List<AthanSound> get sounds {
  if (_sounds is EqualUnmodifiableListView) return _sounds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sounds);
}


/// Create a copy of AthanAudioManifest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AthanAudioManifestCopyWith<_AthanAudioManifest> get copyWith => __$AthanAudioManifestCopyWithImpl<_AthanAudioManifest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AthanAudioManifestToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AthanAudioManifest&&const DeepCollectionEquality().equals(other.sounds, _sounds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_sounds));
}

@override
String toString() {
    return 'AthanAudioManifest(sounds: $sounds)';
}


}

/// @nodoc
abstract mixin class _$AthanAudioManifestCopyWith<$Res> implements $AthanAudioManifestCopyWith<$Res> {
  factory _$AthanAudioManifestCopyWith(_AthanAudioManifest value, $Res Function(_AthanAudioManifest) _then) = __$AthanAudioManifestCopyWithImpl;
@override @useResult
$Res call({
 List<AthanSound> sounds
});




}
/// @nodoc
class __$AthanAudioManifestCopyWithImpl<$Res>
    implements _$AthanAudioManifestCopyWith<$Res> {
  __$AthanAudioManifestCopyWithImpl(this._self, this._then);

  final _AthanAudioManifest _self;
  final $Res Function(_AthanAudioManifest) _then;

/// Create a copy of AthanAudioManifest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sounds = null,}) {
  return _then(_AthanAudioManifest(
sounds: null == sounds ? _self._sounds : sounds // ignore: cast_nullable_to_non_nullable
as List<AthanSound>,
  ));
}


}

// dart format on
