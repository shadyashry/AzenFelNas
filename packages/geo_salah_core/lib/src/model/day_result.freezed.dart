// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'day_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DayResult {

/// The prayer day, a civil date in the observer's zone.
 CivilDate get day;/// `GS-` + 16 base32 characters (§6.4 ¶11).
 String get calculationId;/// The day's events.
 List<PrayerTime> get times;/// How the day was calculated.
 Provenance get provenance;
/// Create a copy of DayResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DayResultCopyWith<DayResult> get copyWith => _$DayResultCopyWithImpl<DayResult>(this as DayResult, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as DayResult;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DayResult&&(identical(other.day, _this.day) || other.day == _this.day)&&(identical(other.calculationId, _this.calculationId) || other.calculationId == _this.calculationId)&&const DeepCollectionEquality().equals(other.times, _this.times)&&(identical(other.provenance, _this.provenance) || other.provenance == _this.provenance));
}


@override
int get hashCode {
  final _this = this as DayResult;
  return Object.hash(runtimeType,_this.day,_this.calculationId,const DeepCollectionEquality().hash(_this.times),_this.provenance);
}

@override
String toString() {
  final _this = this as DayResult;
  return 'DayResult(day: ${_this.day}, calculationId: ${_this.calculationId}, times: ${_this.times}, provenance: ${_this.provenance})';
}


}

/// @nodoc
abstract mixin class $DayResultCopyWith<$Res>  {
  factory $DayResultCopyWith(DayResult value, $Res Function(DayResult) _then) = _$DayResultCopyWithImpl;
@useResult
$Res call({
 CivilDate day, String calculationId, List<PrayerTime> times, Provenance provenance
});


$ProvenanceCopyWith<$Res> get provenance;

}
/// @nodoc
class _$DayResultCopyWithImpl<$Res>
    implements $DayResultCopyWith<$Res> {
  _$DayResultCopyWithImpl(this._self, this._then);

  final DayResult _self;
  final $Res Function(DayResult) _then;

/// Create a copy of DayResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? day = null,Object? calculationId = null,Object? times = null,Object? provenance = null,}) {
  return _then(DayResult(
day: null == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as CivilDate,calculationId: null == calculationId ? _self.calculationId : calculationId // ignore: cast_nullable_to_non_nullable
as String,times: null == times ? _self.times : times // ignore: cast_nullable_to_non_nullable
as List<PrayerTime>,provenance: null == provenance ? _self.provenance : provenance // ignore: cast_nullable_to_non_nullable
as Provenance,
  ));
}
/// Create a copy of DayResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProvenanceCopyWith<$Res> get provenance {
  
  return $ProvenanceCopyWith<$Res>(_self.provenance, (value) {
    return _then(_self.copyWith(provenance: value));
  });
}
}


/// Adds pattern-matching-related methods to [DayResult].
extension DayResultPatterns on DayResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DayResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DayResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DayResult value)  $default,){
final _that = this;
switch (_that) {
case _DayResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DayResult value)?  $default,){
final _that = this;
switch (_that) {
case _DayResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( CivilDate day,  String calculationId,  List<PrayerTime> times,  Provenance provenance)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DayResult() when $default != null:
return $default(_that.day,_that.calculationId,_that.times,_that.provenance);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( CivilDate day,  String calculationId,  List<PrayerTime> times,  Provenance provenance)  $default,) {final _that = this;
switch (_that) {
case _DayResult():
return $default(_that.day,_that.calculationId,_that.times,_that.provenance);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( CivilDate day,  String calculationId,  List<PrayerTime> times,  Provenance provenance)?  $default,) {final _that = this;
switch (_that) {
case _DayResult() when $default != null:
return $default(_that.day,_that.calculationId,_that.times,_that.provenance);case _:
  return null;

}
}

}

/// @nodoc


class _DayResult implements DayResult {
  const _DayResult({required this.day, required this.calculationId, required  List<PrayerTime> times, required this.provenance}): _times = times;
  

/// The prayer day, a civil date in the observer's zone.
@override final  CivilDate day;
/// `GS-` + 16 base32 characters (§6.4 ¶11).
@override final  String calculationId;
/// The day's events.
 final  List<PrayerTime> _times;
/// The day's events.
@override List<PrayerTime> get times {
  if (_times is EqualUnmodifiableListView) return _times;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_times);
}

/// How the day was calculated.
@override final  Provenance provenance;

/// Create a copy of DayResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DayResultCopyWith<_DayResult> get copyWith => __$DayResultCopyWithImpl<_DayResult>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DayResult&&(identical(other.day, day) || other.day == day)&&(identical(other.calculationId, calculationId) || other.calculationId == calculationId)&&const DeepCollectionEquality().equals(other.times, _times)&&(identical(other.provenance, provenance) || other.provenance == provenance));
}


@override
int get hashCode {
    return Object.hash(runtimeType,day,calculationId,const DeepCollectionEquality().hash(_times),provenance);
}

@override
String toString() {
    return 'DayResult(day: $day, calculationId: $calculationId, times: $times, provenance: $provenance)';
}


}

/// @nodoc
abstract mixin class _$DayResultCopyWith<$Res> implements $DayResultCopyWith<$Res> {
  factory _$DayResultCopyWith(_DayResult value, $Res Function(_DayResult) _then) = __$DayResultCopyWithImpl;
@override @useResult
$Res call({
 CivilDate day, String calculationId, List<PrayerTime> times, Provenance provenance
});


@override $ProvenanceCopyWith<$Res> get provenance;

}
/// @nodoc
class __$DayResultCopyWithImpl<$Res>
    implements _$DayResultCopyWith<$Res> {
  __$DayResultCopyWithImpl(this._self, this._then);

  final _DayResult _self;
  final $Res Function(_DayResult) _then;

/// Create a copy of DayResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? day = null,Object? calculationId = null,Object? times = null,Object? provenance = null,}) {
  return _then(_DayResult(
day: null == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as CivilDate,calculationId: null == calculationId ? _self.calculationId : calculationId // ignore: cast_nullable_to_non_nullable
as String,times: null == times ? _self._times : times // ignore: cast_nullable_to_non_nullable
as List<PrayerTime>,provenance: null == provenance ? _self.provenance : provenance // ignore: cast_nullable_to_non_nullable
as Provenance,
  ));
}

/// Create a copy of DayResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProvenanceCopyWith<$Res> get provenance {
  
  return $ProvenanceCopyWith<$Res>(_self.provenance, (value) {
    return _then(_self.copyWith(provenance: value));
  });
}
}

// dart format on
