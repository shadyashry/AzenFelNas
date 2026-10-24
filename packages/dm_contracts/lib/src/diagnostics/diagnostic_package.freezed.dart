// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'diagnostic_package.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DiagnosticPackage {

/// Package type wire name.
 String get type;/// Package version.
 String get version;/// Snapshot sequence it was activated from.
 int get sequence;
/// Create a copy of DiagnosticPackage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DiagnosticPackageCopyWith<DiagnosticPackage> get copyWith => _$DiagnosticPackageCopyWithImpl<DiagnosticPackage>(this as DiagnosticPackage, _$identity);

  /// Serializes this DiagnosticPackage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as DiagnosticPackage;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DiagnosticPackage&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.version, _this.version) || other.version == _this.version)&&(identical(other.sequence, _this.sequence) || other.sequence == _this.sequence));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as DiagnosticPackage;
  return Object.hash(runtimeType,_this.type,_this.version,_this.sequence);
}

@override
String toString() {
  final _this = this as DiagnosticPackage;
  return 'DiagnosticPackage(type: ${_this.type}, version: ${_this.version}, sequence: ${_this.sequence})';
}


}

/// @nodoc
abstract mixin class $DiagnosticPackageCopyWith<$Res>  {
  factory $DiagnosticPackageCopyWith(DiagnosticPackage value, $Res Function(DiagnosticPackage) _then) = _$DiagnosticPackageCopyWithImpl;
@useResult
$Res call({
 String type, String version, int sequence
});




}
/// @nodoc
class _$DiagnosticPackageCopyWithImpl<$Res>
    implements $DiagnosticPackageCopyWith<$Res> {
  _$DiagnosticPackageCopyWithImpl(this._self, this._then);

  final DiagnosticPackage _self;
  final $Res Function(DiagnosticPackage) _then;

/// Create a copy of DiagnosticPackage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? version = null,Object? sequence = null,}) {
  return _then(DiagnosticPackage(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,sequence: null == sequence ? _self.sequence : sequence // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [DiagnosticPackage].
extension DiagnosticPackagePatterns on DiagnosticPackage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DiagnosticPackage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DiagnosticPackage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DiagnosticPackage value)  $default,){
final _that = this;
switch (_that) {
case _DiagnosticPackage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DiagnosticPackage value)?  $default,){
final _that = this;
switch (_that) {
case _DiagnosticPackage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String type,  String version,  int sequence)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DiagnosticPackage() when $default != null:
return $default(_that.type,_that.version,_that.sequence);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String type,  String version,  int sequence)  $default,) {final _that = this;
switch (_that) {
case _DiagnosticPackage():
return $default(_that.type,_that.version,_that.sequence);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String type,  String version,  int sequence)?  $default,) {final _that = this;
switch (_that) {
case _DiagnosticPackage() when $default != null:
return $default(_that.type,_that.version,_that.sequence);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DiagnosticPackage implements DiagnosticPackage {
  const _DiagnosticPackage({required this.type, required this.version, required this.sequence});
  factory _DiagnosticPackage.fromJson(Map<String, dynamic> json) => _$DiagnosticPackageFromJson(json);

/// Package type wire name.
@override final  String type;
/// Package version.
@override final  String version;
/// Snapshot sequence it was activated from.
@override final  int sequence;

/// Create a copy of DiagnosticPackage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DiagnosticPackageCopyWith<_DiagnosticPackage> get copyWith => __$DiagnosticPackageCopyWithImpl<_DiagnosticPackage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DiagnosticPackageToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DiagnosticPackage&&(identical(other.type, type) || other.type == type)&&(identical(other.version, version) || other.version == version)&&(identical(other.sequence, sequence) || other.sequence == sequence));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,type,version,sequence);
}

@override
String toString() {
    return 'DiagnosticPackage(type: $type, version: $version, sequence: $sequence)';
}


}

/// @nodoc
abstract mixin class _$DiagnosticPackageCopyWith<$Res> implements $DiagnosticPackageCopyWith<$Res> {
  factory _$DiagnosticPackageCopyWith(_DiagnosticPackage value, $Res Function(_DiagnosticPackage) _then) = __$DiagnosticPackageCopyWithImpl;
@override @useResult
$Res call({
 String type, String version, int sequence
});




}
/// @nodoc
class __$DiagnosticPackageCopyWithImpl<$Res>
    implements _$DiagnosticPackageCopyWith<$Res> {
  __$DiagnosticPackageCopyWithImpl(this._self, this._then);

  final _DiagnosticPackage _self;
  final $Res Function(_DiagnosticPackage) _then;

/// Create a copy of DiagnosticPackage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? version = null,Object? sequence = null,}) {
  return _then(_DiagnosticPackage(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,sequence: null == sequence ? _self.sequence : sequence // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
