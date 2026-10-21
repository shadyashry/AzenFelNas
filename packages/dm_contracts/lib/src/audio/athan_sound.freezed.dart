// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'athan_sound.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AthanSound {

/// Sound id.
 String get soundId;/// Path under `assets/`.
 String get file;/// Duration.
 int get durationMs;/// Licence reference.
 String get licenceRef;/// Lowercase hex SHA-256.
 String get sha256;/// Regular sound this Fajr recording belongs to.
 String? get fajrVariantOf;
/// Create a copy of AthanSound
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AthanSoundCopyWith<AthanSound> get copyWith => _$AthanSoundCopyWithImpl<AthanSound>(this as AthanSound, _$identity);

  /// Serializes this AthanSound to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AthanSound;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AthanSound&&(identical(other.soundId, _this.soundId) || other.soundId == _this.soundId)&&(identical(other.file, _this.file) || other.file == _this.file)&&(identical(other.durationMs, _this.durationMs) || other.durationMs == _this.durationMs)&&(identical(other.licenceRef, _this.licenceRef) || other.licenceRef == _this.licenceRef)&&(identical(other.sha256, _this.sha256) || other.sha256 == _this.sha256)&&(identical(other.fajrVariantOf, _this.fajrVariantOf) || other.fajrVariantOf == _this.fajrVariantOf));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AthanSound;
  return Object.hash(runtimeType,_this.soundId,_this.file,_this.durationMs,_this.licenceRef,_this.sha256,_this.fajrVariantOf);
}

@override
String toString() {
  final _this = this as AthanSound;
  return 'AthanSound(soundId: ${_this.soundId}, file: ${_this.file}, durationMs: ${_this.durationMs}, licenceRef: ${_this.licenceRef}, sha256: ${_this.sha256}, fajrVariantOf: ${_this.fajrVariantOf})';
}


}

/// @nodoc
abstract mixin class $AthanSoundCopyWith<$Res>  {
  factory $AthanSoundCopyWith(AthanSound value, $Res Function(AthanSound) _then) = _$AthanSoundCopyWithImpl;
@useResult
$Res call({
 String soundId, String file, int durationMs, String licenceRef, String sha256, String? fajrVariantOf
});




}
/// @nodoc
class _$AthanSoundCopyWithImpl<$Res>
    implements $AthanSoundCopyWith<$Res> {
  _$AthanSoundCopyWithImpl(this._self, this._then);

  final AthanSound _self;
  final $Res Function(AthanSound) _then;

/// Create a copy of AthanSound
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? soundId = null,Object? file = null,Object? durationMs = null,Object? licenceRef = null,Object? sha256 = null,Object? fajrVariantOf = freezed,}) {
  return _then(AthanSound(
soundId: null == soundId ? _self.soundId : soundId // ignore: cast_nullable_to_non_nullable
as String,file: null == file ? _self.file : file // ignore: cast_nullable_to_non_nullable
as String,durationMs: null == durationMs ? _self.durationMs : durationMs // ignore: cast_nullable_to_non_nullable
as int,licenceRef: null == licenceRef ? _self.licenceRef : licenceRef // ignore: cast_nullable_to_non_nullable
as String,sha256: null == sha256 ? _self.sha256 : sha256 // ignore: cast_nullable_to_non_nullable
as String,fajrVariantOf: freezed == fajrVariantOf ? _self.fajrVariantOf : fajrVariantOf // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AthanSound].
extension AthanSoundPatterns on AthanSound {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AthanSound value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AthanSound() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AthanSound value)  $default,){
final _that = this;
switch (_that) {
case _AthanSound():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AthanSound value)?  $default,){
final _that = this;
switch (_that) {
case _AthanSound() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String soundId,  String file,  int durationMs,  String licenceRef,  String sha256,  String? fajrVariantOf)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AthanSound() when $default != null:
return $default(_that.soundId,_that.file,_that.durationMs,_that.licenceRef,_that.sha256,_that.fajrVariantOf);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String soundId,  String file,  int durationMs,  String licenceRef,  String sha256,  String? fajrVariantOf)  $default,) {final _that = this;
switch (_that) {
case _AthanSound():
return $default(_that.soundId,_that.file,_that.durationMs,_that.licenceRef,_that.sha256,_that.fajrVariantOf);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String soundId,  String file,  int durationMs,  String licenceRef,  String sha256,  String? fajrVariantOf)?  $default,) {final _that = this;
switch (_that) {
case _AthanSound() when $default != null:
return $default(_that.soundId,_that.file,_that.durationMs,_that.licenceRef,_that.sha256,_that.fajrVariantOf);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AthanSound implements AthanSound {
  const _AthanSound({required this.soundId, required this.file, required this.durationMs, required this.licenceRef, required this.sha256, this.fajrVariantOf});
  factory _AthanSound.fromJson(Map<String, dynamic> json) => _$AthanSoundFromJson(json);

/// Sound id.
@override final  String soundId;
/// Path under `assets/`.
@override final  String file;
/// Duration.
@override final  int durationMs;
/// Licence reference.
@override final  String licenceRef;
/// Lowercase hex SHA-256.
@override final  String sha256;
/// Regular sound this Fajr recording belongs to.
@override final  String? fajrVariantOf;

/// Create a copy of AthanSound
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AthanSoundCopyWith<_AthanSound> get copyWith => __$AthanSoundCopyWithImpl<_AthanSound>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AthanSoundToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AthanSound&&(identical(other.soundId, soundId) || other.soundId == soundId)&&(identical(other.file, file) || other.file == file)&&(identical(other.durationMs, durationMs) || other.durationMs == durationMs)&&(identical(other.licenceRef, licenceRef) || other.licenceRef == licenceRef)&&(identical(other.sha256, sha256) || other.sha256 == sha256)&&(identical(other.fajrVariantOf, fajrVariantOf) || other.fajrVariantOf == fajrVariantOf));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,soundId,file,durationMs,licenceRef,sha256,fajrVariantOf);
}

@override
String toString() {
    return 'AthanSound(soundId: $soundId, file: $file, durationMs: $durationMs, licenceRef: $licenceRef, sha256: $sha256, fajrVariantOf: $fajrVariantOf)';
}


}

/// @nodoc
abstract mixin class _$AthanSoundCopyWith<$Res> implements $AthanSoundCopyWith<$Res> {
  factory _$AthanSoundCopyWith(_AthanSound value, $Res Function(_AthanSound) _then) = __$AthanSoundCopyWithImpl;
@override @useResult
$Res call({
 String soundId, String file, int durationMs, String licenceRef, String sha256, String? fajrVariantOf
});




}
/// @nodoc
class __$AthanSoundCopyWithImpl<$Res>
    implements _$AthanSoundCopyWith<$Res> {
  __$AthanSoundCopyWithImpl(this._self, this._then);

  final _AthanSound _self;
  final $Res Function(_AthanSound) _then;

/// Create a copy of AthanSound
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? soundId = null,Object? file = null,Object? durationMs = null,Object? licenceRef = null,Object? sha256 = null,Object? fajrVariantOf = freezed,}) {
  return _then(_AthanSound(
soundId: null == soundId ? _self.soundId : soundId // ignore: cast_nullable_to_non_nullable
as String,file: null == file ? _self.file : file // ignore: cast_nullable_to_non_nullable
as String,durationMs: null == durationMs ? _self.durationMs : durationMs // ignore: cast_nullable_to_non_nullable
as int,licenceRef: null == licenceRef ? _self.licenceRef : licenceRef // ignore: cast_nullable_to_non_nullable
as String,sha256: null == sha256 ? _self.sha256 : sha256 // ignore: cast_nullable_to_non_nullable
as String,fajrVariantOf: freezed == fajrVariantOf ? _self.fajrVariantOf : fajrVariantOf // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
