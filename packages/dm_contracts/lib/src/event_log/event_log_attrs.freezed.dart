// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'event_log_attrs.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$EventLogAttrs {

/// Failure code.
@FailureCodeConverter() FailureCode? get code;/// Plan generation.
 int? get generation;/// Plan entry id.
 String? get entryId;/// Package type.
 String? get packageType;/// Version.
 String? get version;/// State name.
 String? get state;/// Reason code.
 String? get reason;/// Duration in ms.
 int? get durationMs;/// Count.
 int? get count;/// IANA zone.
 String? get zoneId;/// ISO 3166-1 alpha-2.
 String? get countryCode;
/// Create a copy of EventLogAttrs
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EventLogAttrsCopyWith<EventLogAttrs> get copyWith => _$EventLogAttrsCopyWithImpl<EventLogAttrs>(this as EventLogAttrs, _$identity);

  /// Serializes this EventLogAttrs to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as EventLogAttrs;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EventLogAttrs&&(identical(other.code, _this.code) || other.code == _this.code)&&(identical(other.generation, _this.generation) || other.generation == _this.generation)&&(identical(other.entryId, _this.entryId) || other.entryId == _this.entryId)&&(identical(other.packageType, _this.packageType) || other.packageType == _this.packageType)&&(identical(other.version, _this.version) || other.version == _this.version)&&(identical(other.state, _this.state) || other.state == _this.state)&&(identical(other.reason, _this.reason) || other.reason == _this.reason)&&(identical(other.durationMs, _this.durationMs) || other.durationMs == _this.durationMs)&&(identical(other.count, _this.count) || other.count == _this.count)&&(identical(other.zoneId, _this.zoneId) || other.zoneId == _this.zoneId)&&(identical(other.countryCode, _this.countryCode) || other.countryCode == _this.countryCode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as EventLogAttrs;
  return Object.hash(runtimeType,_this.code,_this.generation,_this.entryId,_this.packageType,_this.version,_this.state,_this.reason,_this.durationMs,_this.count,_this.zoneId,_this.countryCode);
}

@override
String toString() {
  final _this = this as EventLogAttrs;
  return 'EventLogAttrs(code: ${_this.code}, generation: ${_this.generation}, entryId: ${_this.entryId}, packageType: ${_this.packageType}, version: ${_this.version}, state: ${_this.state}, reason: ${_this.reason}, durationMs: ${_this.durationMs}, count: ${_this.count}, zoneId: ${_this.zoneId}, countryCode: ${_this.countryCode})';
}


}

/// @nodoc
abstract mixin class $EventLogAttrsCopyWith<$Res>  {
  factory $EventLogAttrsCopyWith(EventLogAttrs value, $Res Function(EventLogAttrs) _then) = _$EventLogAttrsCopyWithImpl;
@useResult
$Res call({
@FailureCodeConverter() FailureCode? code, int? generation, String? entryId, String? packageType, String? version, String? state, String? reason, int? durationMs, int? count, String? zoneId, String? countryCode
});




}
/// @nodoc
class _$EventLogAttrsCopyWithImpl<$Res>
    implements $EventLogAttrsCopyWith<$Res> {
  _$EventLogAttrsCopyWithImpl(this._self, this._then);

  final EventLogAttrs _self;
  final $Res Function(EventLogAttrs) _then;

/// Create a copy of EventLogAttrs
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? code = freezed,Object? generation = freezed,Object? entryId = freezed,Object? packageType = freezed,Object? version = freezed,Object? state = freezed,Object? reason = freezed,Object? durationMs = freezed,Object? count = freezed,Object? zoneId = freezed,Object? countryCode = freezed,}) {
  return _then(EventLogAttrs(
code: freezed == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as FailureCode?,generation: freezed == generation ? _self.generation : generation // ignore: cast_nullable_to_non_nullable
as int?,entryId: freezed == entryId ? _self.entryId : entryId // ignore: cast_nullable_to_non_nullable
as String?,packageType: freezed == packageType ? _self.packageType : packageType // ignore: cast_nullable_to_non_nullable
as String?,version: freezed == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String?,state: freezed == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String?,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,durationMs: freezed == durationMs ? _self.durationMs : durationMs // ignore: cast_nullable_to_non_nullable
as int?,count: freezed == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int?,zoneId: freezed == zoneId ? _self.zoneId : zoneId // ignore: cast_nullable_to_non_nullable
as String?,countryCode: freezed == countryCode ? _self.countryCode : countryCode // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [EventLogAttrs].
extension EventLogAttrsPatterns on EventLogAttrs {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EventLogAttrs value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EventLogAttrs() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EventLogAttrs value)  $default,){
final _that = this;
switch (_that) {
case _EventLogAttrs():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EventLogAttrs value)?  $default,){
final _that = this;
switch (_that) {
case _EventLogAttrs() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@FailureCodeConverter()  FailureCode? code,  int? generation,  String? entryId,  String? packageType,  String? version,  String? state,  String? reason,  int? durationMs,  int? count,  String? zoneId,  String? countryCode)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EventLogAttrs() when $default != null:
return $default(_that.code,_that.generation,_that.entryId,_that.packageType,_that.version,_that.state,_that.reason,_that.durationMs,_that.count,_that.zoneId,_that.countryCode);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@FailureCodeConverter()  FailureCode? code,  int? generation,  String? entryId,  String? packageType,  String? version,  String? state,  String? reason,  int? durationMs,  int? count,  String? zoneId,  String? countryCode)  $default,) {final _that = this;
switch (_that) {
case _EventLogAttrs():
return $default(_that.code,_that.generation,_that.entryId,_that.packageType,_that.version,_that.state,_that.reason,_that.durationMs,_that.count,_that.zoneId,_that.countryCode);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@FailureCodeConverter()  FailureCode? code,  int? generation,  String? entryId,  String? packageType,  String? version,  String? state,  String? reason,  int? durationMs,  int? count,  String? zoneId,  String? countryCode)?  $default,) {final _that = this;
switch (_that) {
case _EventLogAttrs() when $default != null:
return $default(_that.code,_that.generation,_that.entryId,_that.packageType,_that.version,_that.state,_that.reason,_that.durationMs,_that.count,_that.zoneId,_that.countryCode);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EventLogAttrs implements EventLogAttrs {
  const _EventLogAttrs({@FailureCodeConverter() this.code, this.generation, this.entryId, this.packageType, this.version, this.state, this.reason, this.durationMs, this.count, this.zoneId, this.countryCode});
  factory _EventLogAttrs.fromJson(Map<String, dynamic> json) => _$EventLogAttrsFromJson(json);

/// Failure code.
@override@FailureCodeConverter() final  FailureCode? code;
/// Plan generation.
@override final  int? generation;
/// Plan entry id.
@override final  String? entryId;
/// Package type.
@override final  String? packageType;
/// Version.
@override final  String? version;
/// State name.
@override final  String? state;
/// Reason code.
@override final  String? reason;
/// Duration in ms.
@override final  int? durationMs;
/// Count.
@override final  int? count;
/// IANA zone.
@override final  String? zoneId;
/// ISO 3166-1 alpha-2.
@override final  String? countryCode;

/// Create a copy of EventLogAttrs
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EventLogAttrsCopyWith<_EventLogAttrs> get copyWith => __$EventLogAttrsCopyWithImpl<_EventLogAttrs>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EventLogAttrsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _EventLogAttrs&&(identical(other.code, code) || other.code == code)&&(identical(other.generation, generation) || other.generation == generation)&&(identical(other.entryId, entryId) || other.entryId == entryId)&&(identical(other.packageType, packageType) || other.packageType == packageType)&&(identical(other.version, version) || other.version == version)&&(identical(other.state, state) || other.state == state)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.durationMs, durationMs) || other.durationMs == durationMs)&&(identical(other.count, count) || other.count == count)&&(identical(other.zoneId, zoneId) || other.zoneId == zoneId)&&(identical(other.countryCode, countryCode) || other.countryCode == countryCode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,code,generation,entryId,packageType,version,state,reason,durationMs,count,zoneId,countryCode);
}

@override
String toString() {
    return 'EventLogAttrs(code: $code, generation: $generation, entryId: $entryId, packageType: $packageType, version: $version, state: $state, reason: $reason, durationMs: $durationMs, count: $count, zoneId: $zoneId, countryCode: $countryCode)';
}


}

/// @nodoc
abstract mixin class _$EventLogAttrsCopyWith<$Res> implements $EventLogAttrsCopyWith<$Res> {
  factory _$EventLogAttrsCopyWith(_EventLogAttrs value, $Res Function(_EventLogAttrs) _then) = __$EventLogAttrsCopyWithImpl;
@override @useResult
$Res call({
@FailureCodeConverter() FailureCode? code, int? generation, String? entryId, String? packageType, String? version, String? state, String? reason, int? durationMs, int? count, String? zoneId, String? countryCode
});




}
/// @nodoc
class __$EventLogAttrsCopyWithImpl<$Res>
    implements _$EventLogAttrsCopyWith<$Res> {
  __$EventLogAttrsCopyWithImpl(this._self, this._then);

  final _EventLogAttrs _self;
  final $Res Function(_EventLogAttrs) _then;

/// Create a copy of EventLogAttrs
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? code = freezed,Object? generation = freezed,Object? entryId = freezed,Object? packageType = freezed,Object? version = freezed,Object? state = freezed,Object? reason = freezed,Object? durationMs = freezed,Object? count = freezed,Object? zoneId = freezed,Object? countryCode = freezed,}) {
  return _then(_EventLogAttrs(
code: freezed == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as FailureCode?,generation: freezed == generation ? _self.generation : generation // ignore: cast_nullable_to_non_nullable
as int?,entryId: freezed == entryId ? _self.entryId : entryId // ignore: cast_nullable_to_non_nullable
as String?,packageType: freezed == packageType ? _self.packageType : packageType // ignore: cast_nullable_to_non_nullable
as String?,version: freezed == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String?,state: freezed == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String?,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,durationMs: freezed == durationMs ? _self.durationMs : durationMs // ignore: cast_nullable_to_non_nullable
as int?,count: freezed == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int?,zoneId: freezed == zoneId ? _self.zoneId : zoneId // ignore: cast_nullable_to_non_nullable
as String?,countryCode: freezed == countryCode ? _self.countryCode : countryCode // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
