// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'high_latitude_method.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$HighLatitudeMethod {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is HighLatitudeMethod);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'HighLatitudeMethod()';
}


}

/// @nodoc
class $HighLatitudeMethodCopyWith<$Res>  {
$HighLatitudeMethodCopyWith(HighLatitudeMethod _, $Res Function(HighLatitudeMethod) __);
}


/// Adds pattern-matching-related methods to [HighLatitudeMethod].
extension HighLatitudeMethodPatterns on HighLatitudeMethod {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( AnglePortion value)?  anglePortion,TResult Function( MiddleOfNight value)?  middleOfNight,TResult Function( SeventhOfNight value)?  seventhOfNight,TResult Function( NearestLatitude value)?  nearestLatitude,TResult Function( NearestValidDay value)?  nearestValidDay,required TResult orElse(),}){
final _that = this;
switch (_that) {
case AnglePortion() when anglePortion != null:
return anglePortion(_that);case MiddleOfNight() when middleOfNight != null:
return middleOfNight(_that);case SeventhOfNight() when seventhOfNight != null:
return seventhOfNight(_that);case NearestLatitude() when nearestLatitude != null:
return nearestLatitude(_that);case NearestValidDay() when nearestValidDay != null:
return nearestValidDay(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( AnglePortion value)  anglePortion,required TResult Function( MiddleOfNight value)  middleOfNight,required TResult Function( SeventhOfNight value)  seventhOfNight,required TResult Function( NearestLatitude value)  nearestLatitude,required TResult Function( NearestValidDay value)  nearestValidDay,}){
final _that = this;
switch (_that) {
case AnglePortion():
return anglePortion(_that);case MiddleOfNight():
return middleOfNight(_that);case SeventhOfNight():
return seventhOfNight(_that);case NearestLatitude():
return nearestLatitude(_that);case NearestValidDay():
return nearestValidDay(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( AnglePortion value)?  anglePortion,TResult? Function( MiddleOfNight value)?  middleOfNight,TResult? Function( SeventhOfNight value)?  seventhOfNight,TResult? Function( NearestLatitude value)?  nearestLatitude,TResult? Function( NearestValidDay value)?  nearestValidDay,}){
final _that = this;
switch (_that) {
case AnglePortion() when anglePortion != null:
return anglePortion(_that);case MiddleOfNight() when middleOfNight != null:
return middleOfNight(_that);case SeventhOfNight() when seventhOfNight != null:
return seventhOfNight(_that);case NearestLatitude() when nearestLatitude != null:
return nearestLatitude(_that);case NearestValidDay() when nearestValidDay != null:
return nearestValidDay(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  anglePortion,TResult Function()?  middleOfNight,TResult Function()?  seventhOfNight,TResult Function( double latDeg)?  nearestLatitude,TResult Function( int maxDays)?  nearestValidDay,required TResult orElse(),}) {final _that = this;
switch (_that) {
case AnglePortion() when anglePortion != null:
return anglePortion();case MiddleOfNight() when middleOfNight != null:
return middleOfNight();case SeventhOfNight() when seventhOfNight != null:
return seventhOfNight();case NearestLatitude() when nearestLatitude != null:
return nearestLatitude(_that.latDeg);case NearestValidDay() when nearestValidDay != null:
return nearestValidDay(_that.maxDays);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  anglePortion,required TResult Function()  middleOfNight,required TResult Function()  seventhOfNight,required TResult Function( double latDeg)  nearestLatitude,required TResult Function( int maxDays)  nearestValidDay,}) {final _that = this;
switch (_that) {
case AnglePortion():
return anglePortion();case MiddleOfNight():
return middleOfNight();case SeventhOfNight():
return seventhOfNight();case NearestLatitude():
return nearestLatitude(_that.latDeg);case NearestValidDay():
return nearestValidDay(_that.maxDays);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  anglePortion,TResult? Function()?  middleOfNight,TResult? Function()?  seventhOfNight,TResult? Function( double latDeg)?  nearestLatitude,TResult? Function( int maxDays)?  nearestValidDay,}) {final _that = this;
switch (_that) {
case AnglePortion() when anglePortion != null:
return anglePortion();case MiddleOfNight() when middleOfNight != null:
return middleOfNight();case SeventhOfNight() when seventhOfNight != null:
return seventhOfNight();case NearestLatitude() when nearestLatitude != null:
return nearestLatitude(_that.latDeg);case NearestValidDay() when nearestValidDay != null:
return nearestValidDay(_that.maxDays);case _:
  return null;

}
}

}

/// @nodoc


class AnglePortion implements HighLatitudeMethod {
  const AnglePortion();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AnglePortion);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'HighLatitudeMethod.anglePortion()';
}


}




/// @nodoc


class MiddleOfNight implements HighLatitudeMethod {
  const MiddleOfNight();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is MiddleOfNight);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'HighLatitudeMethod.middleOfNight()';
}


}




/// @nodoc


class SeventhOfNight implements HighLatitudeMethod {
  const SeventhOfNight();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is SeventhOfNight);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'HighLatitudeMethod.seventhOfNight()';
}


}




/// @nodoc


class NearestLatitude implements HighLatitudeMethod {
  const NearestLatitude({required this.latDeg});
  

 final  double latDeg;

/// Create a copy of HighLatitudeMethod
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NearestLatitudeCopyWith<NearestLatitude> get copyWith => _$NearestLatitudeCopyWithImpl<NearestLatitude>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is NearestLatitude&&(identical(other.latDeg, latDeg) || other.latDeg == latDeg));
}


@override
int get hashCode {
    return Object.hash(runtimeType,latDeg);
}

@override
String toString() {
    return 'HighLatitudeMethod.nearestLatitude(latDeg: $latDeg)';
}


}

/// @nodoc
abstract mixin class $NearestLatitudeCopyWith<$Res> implements $HighLatitudeMethodCopyWith<$Res> {
  factory $NearestLatitudeCopyWith(NearestLatitude value, $Res Function(NearestLatitude) _then) = _$NearestLatitudeCopyWithImpl;
@useResult
$Res call({
 double latDeg
});




}
/// @nodoc
class _$NearestLatitudeCopyWithImpl<$Res>
    implements $NearestLatitudeCopyWith<$Res> {
  _$NearestLatitudeCopyWithImpl(this._self, this._then);

  final NearestLatitude _self;
  final $Res Function(NearestLatitude) _then;

/// Create a copy of HighLatitudeMethod
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? latDeg = null,}) {
  return _then(NearestLatitude(
latDeg: null == latDeg ? _self.latDeg : latDeg // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

/// @nodoc


class NearestValidDay implements HighLatitudeMethod {
  const NearestValidDay({required this.maxDays});
  

 final  int maxDays;

/// Create a copy of HighLatitudeMethod
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NearestValidDayCopyWith<NearestValidDay> get copyWith => _$NearestValidDayCopyWithImpl<NearestValidDay>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is NearestValidDay&&(identical(other.maxDays, maxDays) || other.maxDays == maxDays));
}


@override
int get hashCode {
    return Object.hash(runtimeType,maxDays);
}

@override
String toString() {
    return 'HighLatitudeMethod.nearestValidDay(maxDays: $maxDays)';
}


}

/// @nodoc
abstract mixin class $NearestValidDayCopyWith<$Res> implements $HighLatitudeMethodCopyWith<$Res> {
  factory $NearestValidDayCopyWith(NearestValidDay value, $Res Function(NearestValidDay) _then) = _$NearestValidDayCopyWithImpl;
@useResult
$Res call({
 int maxDays
});




}
/// @nodoc
class _$NearestValidDayCopyWithImpl<$Res>
    implements $NearestValidDayCopyWith<$Res> {
  _$NearestValidDayCopyWithImpl(this._self, this._then);

  final NearestValidDay _self;
  final $Res Function(NearestValidDay) _then;

/// Create a copy of HighLatitudeMethod
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? maxDays = null,}) {
  return _then(NearestValidDay(
maxDays: null == maxDays ? _self.maxDays : maxDays // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
