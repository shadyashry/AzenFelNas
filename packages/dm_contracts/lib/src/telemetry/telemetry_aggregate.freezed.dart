// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'telemetry_aggregate.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TelemetryAggregate {

/// Schema version; 1.
 int get schemaVersion;/// Day, `YYYY-MM-DD`.
 String get day;/// App version.
 String get appVersion;/// Platform.
 TelemetryPlatform get platform;/// OS major version.
 int get osMajor;/// Counters.
 TelemetryCounters get counters;/// Country, when consented.
 String? get countryCode;
/// Create a copy of TelemetryAggregate
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TelemetryAggregateCopyWith<TelemetryAggregate> get copyWith => _$TelemetryAggregateCopyWithImpl<TelemetryAggregate>(this as TelemetryAggregate, _$identity);

  /// Serializes this TelemetryAggregate to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as TelemetryAggregate;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TelemetryAggregate&&(identical(other.schemaVersion, _this.schemaVersion) || other.schemaVersion == _this.schemaVersion)&&(identical(other.day, _this.day) || other.day == _this.day)&&(identical(other.appVersion, _this.appVersion) || other.appVersion == _this.appVersion)&&(identical(other.platform, _this.platform) || other.platform == _this.platform)&&(identical(other.osMajor, _this.osMajor) || other.osMajor == _this.osMajor)&&(identical(other.counters, _this.counters) || other.counters == _this.counters)&&(identical(other.countryCode, _this.countryCode) || other.countryCode == _this.countryCode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as TelemetryAggregate;
  return Object.hash(runtimeType,_this.schemaVersion,_this.day,_this.appVersion,_this.platform,_this.osMajor,_this.counters,_this.countryCode);
}

@override
String toString() {
  final _this = this as TelemetryAggregate;
  return 'TelemetryAggregate(schemaVersion: ${_this.schemaVersion}, day: ${_this.day}, appVersion: ${_this.appVersion}, platform: ${_this.platform}, osMajor: ${_this.osMajor}, counters: ${_this.counters}, countryCode: ${_this.countryCode})';
}


}

/// @nodoc
abstract mixin class $TelemetryAggregateCopyWith<$Res>  {
  factory $TelemetryAggregateCopyWith(TelemetryAggregate value, $Res Function(TelemetryAggregate) _then) = _$TelemetryAggregateCopyWithImpl;
@useResult
$Res call({
 int schemaVersion, String day, String appVersion, TelemetryPlatform platform, int osMajor, TelemetryCounters counters, String? countryCode
});


$TelemetryCountersCopyWith<$Res> get counters;

}
/// @nodoc
class _$TelemetryAggregateCopyWithImpl<$Res>
    implements $TelemetryAggregateCopyWith<$Res> {
  _$TelemetryAggregateCopyWithImpl(this._self, this._then);

  final TelemetryAggregate _self;
  final $Res Function(TelemetryAggregate) _then;

/// Create a copy of TelemetryAggregate
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? schemaVersion = null,Object? day = null,Object? appVersion = null,Object? platform = null,Object? osMajor = null,Object? counters = null,Object? countryCode = freezed,}) {
  return _then(TelemetryAggregate(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,day: null == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as String,appVersion: null == appVersion ? _self.appVersion : appVersion // ignore: cast_nullable_to_non_nullable
as String,platform: null == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as TelemetryPlatform,osMajor: null == osMajor ? _self.osMajor : osMajor // ignore: cast_nullable_to_non_nullable
as int,counters: null == counters ? _self.counters : counters // ignore: cast_nullable_to_non_nullable
as TelemetryCounters,countryCode: freezed == countryCode ? _self.countryCode : countryCode // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of TelemetryAggregate
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TelemetryCountersCopyWith<$Res> get counters {
  
  return $TelemetryCountersCopyWith<$Res>(_self.counters, (value) {
    return _then(_self.copyWith(counters: value));
  });
}
}


/// Adds pattern-matching-related methods to [TelemetryAggregate].
extension TelemetryAggregatePatterns on TelemetryAggregate {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TelemetryAggregate value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TelemetryAggregate() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TelemetryAggregate value)  $default,){
final _that = this;
switch (_that) {
case _TelemetryAggregate():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TelemetryAggregate value)?  $default,){
final _that = this;
switch (_that) {
case _TelemetryAggregate() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int schemaVersion,  String day,  String appVersion,  TelemetryPlatform platform,  int osMajor,  TelemetryCounters counters,  String? countryCode)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TelemetryAggregate() when $default != null:
return $default(_that.schemaVersion,_that.day,_that.appVersion,_that.platform,_that.osMajor,_that.counters,_that.countryCode);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int schemaVersion,  String day,  String appVersion,  TelemetryPlatform platform,  int osMajor,  TelemetryCounters counters,  String? countryCode)  $default,) {final _that = this;
switch (_that) {
case _TelemetryAggregate():
return $default(_that.schemaVersion,_that.day,_that.appVersion,_that.platform,_that.osMajor,_that.counters,_that.countryCode);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int schemaVersion,  String day,  String appVersion,  TelemetryPlatform platform,  int osMajor,  TelemetryCounters counters,  String? countryCode)?  $default,) {final _that = this;
switch (_that) {
case _TelemetryAggregate() when $default != null:
return $default(_that.schemaVersion,_that.day,_that.appVersion,_that.platform,_that.osMajor,_that.counters,_that.countryCode);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TelemetryAggregate implements TelemetryAggregate {
  const _TelemetryAggregate({required this.schemaVersion, required this.day, required this.appVersion, required this.platform, required this.osMajor, required this.counters, this.countryCode});
  factory _TelemetryAggregate.fromJson(Map<String, dynamic> json) => _$TelemetryAggregateFromJson(json);

/// Schema version; 1.
@override final  int schemaVersion;
/// Day, `YYYY-MM-DD`.
@override final  String day;
/// App version.
@override final  String appVersion;
/// Platform.
@override final  TelemetryPlatform platform;
/// OS major version.
@override final  int osMajor;
/// Counters.
@override final  TelemetryCounters counters;
/// Country, when consented.
@override final  String? countryCode;

/// Create a copy of TelemetryAggregate
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TelemetryAggregateCopyWith<_TelemetryAggregate> get copyWith => __$TelemetryAggregateCopyWithImpl<_TelemetryAggregate>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TelemetryAggregateToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TelemetryAggregate&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.day, day) || other.day == day)&&(identical(other.appVersion, appVersion) || other.appVersion == appVersion)&&(identical(other.platform, platform) || other.platform == platform)&&(identical(other.osMajor, osMajor) || other.osMajor == osMajor)&&(identical(other.counters, counters) || other.counters == counters)&&(identical(other.countryCode, countryCode) || other.countryCode == countryCode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,schemaVersion,day,appVersion,platform,osMajor,counters,countryCode);
}

@override
String toString() {
    return 'TelemetryAggregate(schemaVersion: $schemaVersion, day: $day, appVersion: $appVersion, platform: $platform, osMajor: $osMajor, counters: $counters, countryCode: $countryCode)';
}


}

/// @nodoc
abstract mixin class _$TelemetryAggregateCopyWith<$Res> implements $TelemetryAggregateCopyWith<$Res> {
  factory _$TelemetryAggregateCopyWith(_TelemetryAggregate value, $Res Function(_TelemetryAggregate) _then) = __$TelemetryAggregateCopyWithImpl;
@override @useResult
$Res call({
 int schemaVersion, String day, String appVersion, TelemetryPlatform platform, int osMajor, TelemetryCounters counters, String? countryCode
});


@override $TelemetryCountersCopyWith<$Res> get counters;

}
/// @nodoc
class __$TelemetryAggregateCopyWithImpl<$Res>
    implements _$TelemetryAggregateCopyWith<$Res> {
  __$TelemetryAggregateCopyWithImpl(this._self, this._then);

  final _TelemetryAggregate _self;
  final $Res Function(_TelemetryAggregate) _then;

/// Create a copy of TelemetryAggregate
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? schemaVersion = null,Object? day = null,Object? appVersion = null,Object? platform = null,Object? osMajor = null,Object? counters = null,Object? countryCode = freezed,}) {
  return _then(_TelemetryAggregate(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,day: null == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as String,appVersion: null == appVersion ? _self.appVersion : appVersion // ignore: cast_nullable_to_non_nullable
as String,platform: null == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as TelemetryPlatform,osMajor: null == osMajor ? _self.osMajor : osMajor // ignore: cast_nullable_to_non_nullable
as int,counters: null == counters ? _self.counters : counters // ignore: cast_nullable_to_non_nullable
as TelemetryCounters,countryCode: freezed == countryCode ? _self.countryCode : countryCode // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of TelemetryAggregate
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TelemetryCountersCopyWith<$Res> get counters {
  
  return $TelemetryCountersCopyWith<$Res>(_self.counters, (value) {
    return _then(_self.copyWith(counters: value));
  });
}
}

// dart format on
