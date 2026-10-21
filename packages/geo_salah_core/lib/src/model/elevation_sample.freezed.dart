// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'elevation_sample.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ElevationSample {

/// Height in metres above [datum].
 double get valueM;/// Vertical datum of [valueM].
 ElevationDatum get datum;/// How the value was obtained.
 ElevationSource get source;/// When the value was observed, UTC epoch milliseconds.
 int get observedUtcMs;/// One-sigma vertical accuracy in metres, when known.
 double? get verticalAccuracyM;/// Version of the dataset the value came from, when any.
 String? get datasetVersion;
/// Create a copy of ElevationSample
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ElevationSampleCopyWith<ElevationSample> get copyWith => _$ElevationSampleCopyWithImpl<ElevationSample>(this as ElevationSample, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ElevationSample;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ElevationSample&&(identical(other.valueM, _this.valueM) || other.valueM == _this.valueM)&&(identical(other.datum, _this.datum) || other.datum == _this.datum)&&(identical(other.source, _this.source) || other.source == _this.source)&&(identical(other.observedUtcMs, _this.observedUtcMs) || other.observedUtcMs == _this.observedUtcMs)&&(identical(other.verticalAccuracyM, _this.verticalAccuracyM) || other.verticalAccuracyM == _this.verticalAccuracyM)&&(identical(other.datasetVersion, _this.datasetVersion) || other.datasetVersion == _this.datasetVersion));
}


@override
int get hashCode {
  final _this = this as ElevationSample;
  return Object.hash(runtimeType,_this.valueM,_this.datum,_this.source,_this.observedUtcMs,_this.verticalAccuracyM,_this.datasetVersion);
}

@override
String toString() {
  final _this = this as ElevationSample;
  return 'ElevationSample(valueM: ${_this.valueM}, datum: ${_this.datum}, source: ${_this.source}, observedUtcMs: ${_this.observedUtcMs}, verticalAccuracyM: ${_this.verticalAccuracyM}, datasetVersion: ${_this.datasetVersion})';
}


}

/// @nodoc
abstract mixin class $ElevationSampleCopyWith<$Res>  {
  factory $ElevationSampleCopyWith(ElevationSample value, $Res Function(ElevationSample) _then) = _$ElevationSampleCopyWithImpl;
@useResult
$Res call({
 double valueM, ElevationDatum datum, ElevationSource source, int observedUtcMs, double? verticalAccuracyM, String? datasetVersion
});




}
/// @nodoc
class _$ElevationSampleCopyWithImpl<$Res>
    implements $ElevationSampleCopyWith<$Res> {
  _$ElevationSampleCopyWithImpl(this._self, this._then);

  final ElevationSample _self;
  final $Res Function(ElevationSample) _then;

/// Create a copy of ElevationSample
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? valueM = null,Object? datum = null,Object? source = null,Object? observedUtcMs = null,Object? verticalAccuracyM = freezed,Object? datasetVersion = freezed,}) {
  return _then(ElevationSample(
valueM: null == valueM ? _self.valueM : valueM // ignore: cast_nullable_to_non_nullable
as double,datum: null == datum ? _self.datum : datum // ignore: cast_nullable_to_non_nullable
as ElevationDatum,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as ElevationSource,observedUtcMs: null == observedUtcMs ? _self.observedUtcMs : observedUtcMs // ignore: cast_nullable_to_non_nullable
as int,verticalAccuracyM: freezed == verticalAccuracyM ? _self.verticalAccuracyM : verticalAccuracyM // ignore: cast_nullable_to_non_nullable
as double?,datasetVersion: freezed == datasetVersion ? _self.datasetVersion : datasetVersion // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ElevationSample].
extension ElevationSamplePatterns on ElevationSample {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ElevationSample value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ElevationSample() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ElevationSample value)  $default,){
final _that = this;
switch (_that) {
case _ElevationSample():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ElevationSample value)?  $default,){
final _that = this;
switch (_that) {
case _ElevationSample() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double valueM,  ElevationDatum datum,  ElevationSource source,  int observedUtcMs,  double? verticalAccuracyM,  String? datasetVersion)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ElevationSample() when $default != null:
return $default(_that.valueM,_that.datum,_that.source,_that.observedUtcMs,_that.verticalAccuracyM,_that.datasetVersion);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double valueM,  ElevationDatum datum,  ElevationSource source,  int observedUtcMs,  double? verticalAccuracyM,  String? datasetVersion)  $default,) {final _that = this;
switch (_that) {
case _ElevationSample():
return $default(_that.valueM,_that.datum,_that.source,_that.observedUtcMs,_that.verticalAccuracyM,_that.datasetVersion);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double valueM,  ElevationDatum datum,  ElevationSource source,  int observedUtcMs,  double? verticalAccuracyM,  String? datasetVersion)?  $default,) {final _that = this;
switch (_that) {
case _ElevationSample() when $default != null:
return $default(_that.valueM,_that.datum,_that.source,_that.observedUtcMs,_that.verticalAccuracyM,_that.datasetVersion);case _:
  return null;

}
}

}

/// @nodoc


class _ElevationSample implements ElevationSample {
  const _ElevationSample({required this.valueM, required this.datum, required this.source, required this.observedUtcMs, this.verticalAccuracyM, this.datasetVersion});
  

/// Height in metres above [datum].
@override final  double valueM;
/// Vertical datum of [valueM].
@override final  ElevationDatum datum;
/// How the value was obtained.
@override final  ElevationSource source;
/// When the value was observed, UTC epoch milliseconds.
@override final  int observedUtcMs;
/// One-sigma vertical accuracy in metres, when known.
@override final  double? verticalAccuracyM;
/// Version of the dataset the value came from, when any.
@override final  String? datasetVersion;

/// Create a copy of ElevationSample
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ElevationSampleCopyWith<_ElevationSample> get copyWith => __$ElevationSampleCopyWithImpl<_ElevationSample>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ElevationSample&&(identical(other.valueM, valueM) || other.valueM == valueM)&&(identical(other.datum, datum) || other.datum == datum)&&(identical(other.source, source) || other.source == source)&&(identical(other.observedUtcMs, observedUtcMs) || other.observedUtcMs == observedUtcMs)&&(identical(other.verticalAccuracyM, verticalAccuracyM) || other.verticalAccuracyM == verticalAccuracyM)&&(identical(other.datasetVersion, datasetVersion) || other.datasetVersion == datasetVersion));
}


@override
int get hashCode {
    return Object.hash(runtimeType,valueM,datum,source,observedUtcMs,verticalAccuracyM,datasetVersion);
}

@override
String toString() {
    return 'ElevationSample(valueM: $valueM, datum: $datum, source: $source, observedUtcMs: $observedUtcMs, verticalAccuracyM: $verticalAccuracyM, datasetVersion: $datasetVersion)';
}


}

/// @nodoc
abstract mixin class _$ElevationSampleCopyWith<$Res> implements $ElevationSampleCopyWith<$Res> {
  factory _$ElevationSampleCopyWith(_ElevationSample value, $Res Function(_ElevationSample) _then) = __$ElevationSampleCopyWithImpl;
@override @useResult
$Res call({
 double valueM, ElevationDatum datum, ElevationSource source, int observedUtcMs, double? verticalAccuracyM, String? datasetVersion
});




}
/// @nodoc
class __$ElevationSampleCopyWithImpl<$Res>
    implements _$ElevationSampleCopyWith<$Res> {
  __$ElevationSampleCopyWithImpl(this._self, this._then);

  final _ElevationSample _self;
  final $Res Function(_ElevationSample) _then;

/// Create a copy of ElevationSample
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? valueM = null,Object? datum = null,Object? source = null,Object? observedUtcMs = null,Object? verticalAccuracyM = freezed,Object? datasetVersion = freezed,}) {
  return _then(_ElevationSample(
valueM: null == valueM ? _self.valueM : valueM // ignore: cast_nullable_to_non_nullable
as double,datum: null == datum ? _self.datum : datum // ignore: cast_nullable_to_non_nullable
as ElevationDatum,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as ElevationSource,observedUtcMs: null == observedUtcMs ? _self.observedUtcMs : observedUtcMs // ignore: cast_nullable_to_non_nullable
as int,verticalAccuracyM: freezed == verticalAccuracyM ? _self.verticalAccuracyM : verticalAccuracyM // ignore: cast_nullable_to_non_nullable
as double?,datasetVersion: freezed == datasetVersion ? _self.datasetVersion : datasetVersion // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
