// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'hijri_date.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$HijriDate {

/// Hijri year, ≥ 1.
 int get year;/// Month, 1–12.
 int get month;/// Day of month, 1–30.
 int get day;
/// Create a copy of HijriDate
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HijriDateCopyWith<HijriDate> get copyWith => _$HijriDateCopyWithImpl<HijriDate>(this as HijriDate, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as HijriDate;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HijriDate&&(identical(other.year, _this.year) || other.year == _this.year)&&(identical(other.month, _this.month) || other.month == _this.month)&&(identical(other.day, _this.day) || other.day == _this.day));
}


@override
int get hashCode {
  final _this = this as HijriDate;
  return Object.hash(runtimeType,_this.year,_this.month,_this.day);
}

@override
String toString() {
  final _this = this as HijriDate;
  return 'HijriDate(year: ${_this.year}, month: ${_this.month}, day: ${_this.day})';
}


}

/// @nodoc
abstract mixin class $HijriDateCopyWith<$Res>  {
  factory $HijriDateCopyWith(HijriDate value, $Res Function(HijriDate) _then) = _$HijriDateCopyWithImpl;
@useResult
$Res call({
 int year, int month, int day
});




}
/// @nodoc
class _$HijriDateCopyWithImpl<$Res>
    implements $HijriDateCopyWith<$Res> {
  _$HijriDateCopyWithImpl(this._self, this._then);

  final HijriDate _self;
  final $Res Function(HijriDate) _then;

/// Create a copy of HijriDate
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? year = null,Object? month = null,Object? day = null,}) {
  return _then(HijriDate(
year: null == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int,month: null == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as int,day: null == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [HijriDate].
extension HijriDatePatterns on HijriDate {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HijriDate value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HijriDate() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HijriDate value)  $default,){
final _that = this;
switch (_that) {
case _HijriDate():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HijriDate value)?  $default,){
final _that = this;
switch (_that) {
case _HijriDate() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int year,  int month,  int day)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HijriDate() when $default != null:
return $default(_that.year,_that.month,_that.day);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int year,  int month,  int day)  $default,) {final _that = this;
switch (_that) {
case _HijriDate():
return $default(_that.year,_that.month,_that.day);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int year,  int month,  int day)?  $default,) {final _that = this;
switch (_that) {
case _HijriDate() when $default != null:
return $default(_that.year,_that.month,_that.day);case _:
  return null;

}
}

}

/// @nodoc


class _HijriDate implements HijriDate {
  const _HijriDate({required this.year, required this.month, required this.day});
  

/// Hijri year, ≥ 1.
@override final  int year;
/// Month, 1–12.
@override final  int month;
/// Day of month, 1–30.
@override final  int day;

/// Create a copy of HijriDate
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HijriDateCopyWith<_HijriDate> get copyWith => __$HijriDateCopyWithImpl<_HijriDate>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _HijriDate&&(identical(other.year, year) || other.year == year)&&(identical(other.month, month) || other.month == month)&&(identical(other.day, day) || other.day == day));
}


@override
int get hashCode {
    return Object.hash(runtimeType,year,month,day);
}

@override
String toString() {
    return 'HijriDate(year: $year, month: $month, day: $day)';
}


}

/// @nodoc
abstract mixin class _$HijriDateCopyWith<$Res> implements $HijriDateCopyWith<$Res> {
  factory _$HijriDateCopyWith(_HijriDate value, $Res Function(_HijriDate) _then) = __$HijriDateCopyWithImpl;
@override @useResult
$Res call({
 int year, int month, int day
});




}
/// @nodoc
class __$HijriDateCopyWithImpl<$Res>
    implements _$HijriDateCopyWith<$Res> {
  __$HijriDateCopyWithImpl(this._self, this._then);

  final _HijriDate _self;
  final $Res Function(_HijriDate) _then;

/// Create a copy of HijriDate
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? year = null,Object? month = null,Object? day = null,}) {
  return _then(_HijriDate(
year: null == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int,month: null == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as int,day: null == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
