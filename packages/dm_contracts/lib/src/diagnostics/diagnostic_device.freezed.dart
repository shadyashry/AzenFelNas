// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'diagnostic_device.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DiagnosticDevice {

/// Device model; null until a source exists (§15 D84).
@JsonKey(includeIfNull: true) String? get model;/// OS family.
 DiagnosticOs get os;/// App version.
 String get appVersion;
/// Create a copy of DiagnosticDevice
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DiagnosticDeviceCopyWith<DiagnosticDevice> get copyWith => _$DiagnosticDeviceCopyWithImpl<DiagnosticDevice>(this as DiagnosticDevice, _$identity);

  /// Serializes this DiagnosticDevice to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as DiagnosticDevice;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DiagnosticDevice&&(identical(other.model, _this.model) || other.model == _this.model)&&(identical(other.os, _this.os) || other.os == _this.os)&&(identical(other.appVersion, _this.appVersion) || other.appVersion == _this.appVersion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as DiagnosticDevice;
  return Object.hash(runtimeType,_this.model,_this.os,_this.appVersion);
}

@override
String toString() {
  final _this = this as DiagnosticDevice;
  return 'DiagnosticDevice(model: ${_this.model}, os: ${_this.os}, appVersion: ${_this.appVersion})';
}


}

/// @nodoc
abstract mixin class $DiagnosticDeviceCopyWith<$Res>  {
  factory $DiagnosticDeviceCopyWith(DiagnosticDevice value, $Res Function(DiagnosticDevice) _then) = _$DiagnosticDeviceCopyWithImpl;
@useResult
$Res call({
@JsonKey(includeIfNull: true) String? model, DiagnosticOs os, String appVersion
});




}
/// @nodoc
class _$DiagnosticDeviceCopyWithImpl<$Res>
    implements $DiagnosticDeviceCopyWith<$Res> {
  _$DiagnosticDeviceCopyWithImpl(this._self, this._then);

  final DiagnosticDevice _self;
  final $Res Function(DiagnosticDevice) _then;

/// Create a copy of DiagnosticDevice
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? model = freezed,Object? os = null,Object? appVersion = null,}) {
  return _then(DiagnosticDevice(
model: freezed == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String?,os: null == os ? _self.os : os // ignore: cast_nullable_to_non_nullable
as DiagnosticOs,appVersion: null == appVersion ? _self.appVersion : appVersion // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [DiagnosticDevice].
extension DiagnosticDevicePatterns on DiagnosticDevice {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DiagnosticDevice value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DiagnosticDevice() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DiagnosticDevice value)  $default,){
final _that = this;
switch (_that) {
case _DiagnosticDevice():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DiagnosticDevice value)?  $default,){
final _that = this;
switch (_that) {
case _DiagnosticDevice() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(includeIfNull: true)  String? model,  DiagnosticOs os,  String appVersion)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DiagnosticDevice() when $default != null:
return $default(_that.model,_that.os,_that.appVersion);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(includeIfNull: true)  String? model,  DiagnosticOs os,  String appVersion)  $default,) {final _that = this;
switch (_that) {
case _DiagnosticDevice():
return $default(_that.model,_that.os,_that.appVersion);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(includeIfNull: true)  String? model,  DiagnosticOs os,  String appVersion)?  $default,) {final _that = this;
switch (_that) {
case _DiagnosticDevice() when $default != null:
return $default(_that.model,_that.os,_that.appVersion);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DiagnosticDevice implements DiagnosticDevice {
  const _DiagnosticDevice({@JsonKey(includeIfNull: true) required this.model, required this.os, required this.appVersion});
  factory _DiagnosticDevice.fromJson(Map<String, dynamic> json) => _$DiagnosticDeviceFromJson(json);

/// Device model; null until a source exists (§15 D84).
@override@JsonKey(includeIfNull: true) final  String? model;
/// OS family.
@override final  DiagnosticOs os;
/// App version.
@override final  String appVersion;

/// Create a copy of DiagnosticDevice
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DiagnosticDeviceCopyWith<_DiagnosticDevice> get copyWith => __$DiagnosticDeviceCopyWithImpl<_DiagnosticDevice>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DiagnosticDeviceToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DiagnosticDevice&&(identical(other.model, model) || other.model == model)&&(identical(other.os, os) || other.os == os)&&(identical(other.appVersion, appVersion) || other.appVersion == appVersion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,model,os,appVersion);
}

@override
String toString() {
    return 'DiagnosticDevice(model: $model, os: $os, appVersion: $appVersion)';
}


}

/// @nodoc
abstract mixin class _$DiagnosticDeviceCopyWith<$Res> implements $DiagnosticDeviceCopyWith<$Res> {
  factory _$DiagnosticDeviceCopyWith(_DiagnosticDevice value, $Res Function(_DiagnosticDevice) _then) = __$DiagnosticDeviceCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(includeIfNull: true) String? model, DiagnosticOs os, String appVersion
});




}
/// @nodoc
class __$DiagnosticDeviceCopyWithImpl<$Res>
    implements _$DiagnosticDeviceCopyWith<$Res> {
  __$DiagnosticDeviceCopyWithImpl(this._self, this._then);

  final _DiagnosticDevice _self;
  final $Res Function(_DiagnosticDevice) _then;

/// Create a copy of DiagnosticDevice
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? model = freezed,Object? os = null,Object? appVersion = null,}) {
  return _then(_DiagnosticDevice(
model: freezed == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String?,os: null == os ? _self.os : os // ignore: cast_nullable_to_non_nullable
as DiagnosticOs,appVersion: null == appVersion ? _self.appVersion : appVersion // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
