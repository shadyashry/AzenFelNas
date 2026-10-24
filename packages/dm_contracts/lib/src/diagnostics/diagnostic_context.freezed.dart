// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'diagnostic_context.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DiagnosticContext {

/// Kind.
 DiagnosticContextKind get kind;/// Source wire name.
 String get source;/// Latitude in units of 0.01°.
 int get latE2;/// Longitude in units of 0.01°.
 int get lonE2;/// IANA zone.
 String get zoneId;/// ISO 3166-1 alpha-2, or null when unresolved.
@JsonKey(includeIfNull: true) String? get countryCode;
/// Create a copy of DiagnosticContext
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DiagnosticContextCopyWith<DiagnosticContext> get copyWith => _$DiagnosticContextCopyWithImpl<DiagnosticContext>(this as DiagnosticContext, _$identity);

  /// Serializes this DiagnosticContext to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as DiagnosticContext;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DiagnosticContext&&(identical(other.kind, _this.kind) || other.kind == _this.kind)&&(identical(other.source, _this.source) || other.source == _this.source)&&(identical(other.latE2, _this.latE2) || other.latE2 == _this.latE2)&&(identical(other.lonE2, _this.lonE2) || other.lonE2 == _this.lonE2)&&(identical(other.zoneId, _this.zoneId) || other.zoneId == _this.zoneId)&&(identical(other.countryCode, _this.countryCode) || other.countryCode == _this.countryCode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as DiagnosticContext;
  return Object.hash(runtimeType,_this.kind,_this.source,_this.latE2,_this.lonE2,_this.zoneId,_this.countryCode);
}

@override
String toString() {
  final _this = this as DiagnosticContext;
  return 'DiagnosticContext(kind: ${_this.kind}, source: ${_this.source}, latE2: ${_this.latE2}, lonE2: ${_this.lonE2}, zoneId: ${_this.zoneId}, countryCode: ${_this.countryCode})';
}


}

/// @nodoc
abstract mixin class $DiagnosticContextCopyWith<$Res>  {
  factory $DiagnosticContextCopyWith(DiagnosticContext value, $Res Function(DiagnosticContext) _then) = _$DiagnosticContextCopyWithImpl;
@useResult
$Res call({
 DiagnosticContextKind kind, String source, int latE2, int lonE2, String zoneId,@JsonKey(includeIfNull: true) String? countryCode
});




}
/// @nodoc
class _$DiagnosticContextCopyWithImpl<$Res>
    implements $DiagnosticContextCopyWith<$Res> {
  _$DiagnosticContextCopyWithImpl(this._self, this._then);

  final DiagnosticContext _self;
  final $Res Function(DiagnosticContext) _then;

/// Create a copy of DiagnosticContext
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? kind = null,Object? source = null,Object? latE2 = null,Object? lonE2 = null,Object? zoneId = null,Object? countryCode = freezed,}) {
  return _then(DiagnosticContext(
kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as DiagnosticContextKind,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,latE2: null == latE2 ? _self.latE2 : latE2 // ignore: cast_nullable_to_non_nullable
as int,lonE2: null == lonE2 ? _self.lonE2 : lonE2 // ignore: cast_nullable_to_non_nullable
as int,zoneId: null == zoneId ? _self.zoneId : zoneId // ignore: cast_nullable_to_non_nullable
as String,countryCode: freezed == countryCode ? _self.countryCode : countryCode // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [DiagnosticContext].
extension DiagnosticContextPatterns on DiagnosticContext {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DiagnosticContext value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DiagnosticContext() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DiagnosticContext value)  $default,){
final _that = this;
switch (_that) {
case _DiagnosticContext():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DiagnosticContext value)?  $default,){
final _that = this;
switch (_that) {
case _DiagnosticContext() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DiagnosticContextKind kind,  String source,  int latE2,  int lonE2,  String zoneId, @JsonKey(includeIfNull: true)  String? countryCode)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DiagnosticContext() when $default != null:
return $default(_that.kind,_that.source,_that.latE2,_that.lonE2,_that.zoneId,_that.countryCode);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DiagnosticContextKind kind,  String source,  int latE2,  int lonE2,  String zoneId, @JsonKey(includeIfNull: true)  String? countryCode)  $default,) {final _that = this;
switch (_that) {
case _DiagnosticContext():
return $default(_that.kind,_that.source,_that.latE2,_that.lonE2,_that.zoneId,_that.countryCode);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DiagnosticContextKind kind,  String source,  int latE2,  int lonE2,  String zoneId, @JsonKey(includeIfNull: true)  String? countryCode)?  $default,) {final _that = this;
switch (_that) {
case _DiagnosticContext() when $default != null:
return $default(_that.kind,_that.source,_that.latE2,_that.lonE2,_that.zoneId,_that.countryCode);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DiagnosticContext implements DiagnosticContext {
  const _DiagnosticContext({required this.kind, required this.source, required this.latE2, required this.lonE2, required this.zoneId, @JsonKey(includeIfNull: true) required this.countryCode});
  factory _DiagnosticContext.fromJson(Map<String, dynamic> json) => _$DiagnosticContextFromJson(json);

/// Kind.
@override final  DiagnosticContextKind kind;
/// Source wire name.
@override final  String source;
/// Latitude in units of 0.01°.
@override final  int latE2;
/// Longitude in units of 0.01°.
@override final  int lonE2;
/// IANA zone.
@override final  String zoneId;
/// ISO 3166-1 alpha-2, or null when unresolved.
@override@JsonKey(includeIfNull: true) final  String? countryCode;

/// Create a copy of DiagnosticContext
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DiagnosticContextCopyWith<_DiagnosticContext> get copyWith => __$DiagnosticContextCopyWithImpl<_DiagnosticContext>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DiagnosticContextToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DiagnosticContext&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.source, source) || other.source == source)&&(identical(other.latE2, latE2) || other.latE2 == latE2)&&(identical(other.lonE2, lonE2) || other.lonE2 == lonE2)&&(identical(other.zoneId, zoneId) || other.zoneId == zoneId)&&(identical(other.countryCode, countryCode) || other.countryCode == countryCode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,kind,source,latE2,lonE2,zoneId,countryCode);
}

@override
String toString() {
    return 'DiagnosticContext(kind: $kind, source: $source, latE2: $latE2, lonE2: $lonE2, zoneId: $zoneId, countryCode: $countryCode)';
}


}

/// @nodoc
abstract mixin class _$DiagnosticContextCopyWith<$Res> implements $DiagnosticContextCopyWith<$Res> {
  factory _$DiagnosticContextCopyWith(_DiagnosticContext value, $Res Function(_DiagnosticContext) _then) = __$DiagnosticContextCopyWithImpl;
@override @useResult
$Res call({
 DiagnosticContextKind kind, String source, int latE2, int lonE2, String zoneId,@JsonKey(includeIfNull: true) String? countryCode
});




}
/// @nodoc
class __$DiagnosticContextCopyWithImpl<$Res>
    implements _$DiagnosticContextCopyWith<$Res> {
  __$DiagnosticContextCopyWithImpl(this._self, this._then);

  final _DiagnosticContext _self;
  final $Res Function(_DiagnosticContext) _then;

/// Create a copy of DiagnosticContext
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? kind = null,Object? source = null,Object? latE2 = null,Object? lonE2 = null,Object? zoneId = null,Object? countryCode = freezed,}) {
  return _then(_DiagnosticContext(
kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as DiagnosticContextKind,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,latE2: null == latE2 ? _self.latE2 : latE2 // ignore: cast_nullable_to_non_nullable
as int,lonE2: null == lonE2 ? _self.lonE2 : lonE2 // ignore: cast_nullable_to_non_nullable
as int,zoneId: null == zoneId ? _self.zoneId : zoneId // ignore: cast_nullable_to_non_nullable
as String,countryCode: freezed == countryCode ? _self.countryCode : countryCode // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
