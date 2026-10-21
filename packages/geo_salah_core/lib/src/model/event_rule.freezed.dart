// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'event_rule.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$EventRule {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is EventRule);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'EventRule()';
}


}

/// @nodoc
class $EventRuleCopyWith<$Res>  {
$EventRuleCopyWith(EventRule _, $Res Function(EventRule) __);
}


/// Adds pattern-matching-related methods to [EventRule].
extension EventRulePatterns on EventRule {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( SolarAltitudeRule value)?  solarAltitude,TResult Function( TransitRule value)?  transit,TResult Function( ShadowFactorRule value)?  shadowFactor,TResult Function( HorizonRule value)?  horizon,TResult Function( IntervalAfterRule value)?  intervalAfter,TResult Function( IntervalBeforeRule value)?  intervalBefore,required TResult orElse(),}){
final _that = this;
switch (_that) {
case SolarAltitudeRule() when solarAltitude != null:
return solarAltitude(_that);case TransitRule() when transit != null:
return transit(_that);case ShadowFactorRule() when shadowFactor != null:
return shadowFactor(_that);case HorizonRule() when horizon != null:
return horizon(_that);case IntervalAfterRule() when intervalAfter != null:
return intervalAfter(_that);case IntervalBeforeRule() when intervalBefore != null:
return intervalBefore(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( SolarAltitudeRule value)  solarAltitude,required TResult Function( TransitRule value)  transit,required TResult Function( ShadowFactorRule value)  shadowFactor,required TResult Function( HorizonRule value)  horizon,required TResult Function( IntervalAfterRule value)  intervalAfter,required TResult Function( IntervalBeforeRule value)  intervalBefore,}){
final _that = this;
switch (_that) {
case SolarAltitudeRule():
return solarAltitude(_that);case TransitRule():
return transit(_that);case ShadowFactorRule():
return shadowFactor(_that);case HorizonRule():
return horizon(_that);case IntervalAfterRule():
return intervalAfter(_that);case IntervalBeforeRule():
return intervalBefore(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( SolarAltitudeRule value)?  solarAltitude,TResult? Function( TransitRule value)?  transit,TResult? Function( ShadowFactorRule value)?  shadowFactor,TResult? Function( HorizonRule value)?  horizon,TResult? Function( IntervalAfterRule value)?  intervalAfter,TResult? Function( IntervalBeforeRule value)?  intervalBefore,}){
final _that = this;
switch (_that) {
case SolarAltitudeRule() when solarAltitude != null:
return solarAltitude(_that);case TransitRule() when transit != null:
return transit(_that);case ShadowFactorRule() when shadowFactor != null:
return shadowFactor(_that);case HorizonRule() when horizon != null:
return horizon(_that);case IntervalAfterRule() when intervalAfter != null:
return intervalAfter(_that);case IntervalBeforeRule() when intervalBefore != null:
return intervalBefore(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( double degrees)?  solarAltitude,TResult Function( Duration offset)?  transit,TResult Function( int k)?  shadowFactor,TResult Function( double refractionArcmin,  double semidiameterArcmin)?  horizon,TResult Function( PrayerEvent base,  Duration duration)?  intervalAfter,TResult Function( PrayerEvent base,  Duration duration)?  intervalBefore,required TResult orElse(),}) {final _that = this;
switch (_that) {
case SolarAltitudeRule() when solarAltitude != null:
return solarAltitude(_that.degrees);case TransitRule() when transit != null:
return transit(_that.offset);case ShadowFactorRule() when shadowFactor != null:
return shadowFactor(_that.k);case HorizonRule() when horizon != null:
return horizon(_that.refractionArcmin,_that.semidiameterArcmin);case IntervalAfterRule() when intervalAfter != null:
return intervalAfter(_that.base,_that.duration);case IntervalBeforeRule() when intervalBefore != null:
return intervalBefore(_that.base,_that.duration);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( double degrees)  solarAltitude,required TResult Function( Duration offset)  transit,required TResult Function( int k)  shadowFactor,required TResult Function( double refractionArcmin,  double semidiameterArcmin)  horizon,required TResult Function( PrayerEvent base,  Duration duration)  intervalAfter,required TResult Function( PrayerEvent base,  Duration duration)  intervalBefore,}) {final _that = this;
switch (_that) {
case SolarAltitudeRule():
return solarAltitude(_that.degrees);case TransitRule():
return transit(_that.offset);case ShadowFactorRule():
return shadowFactor(_that.k);case HorizonRule():
return horizon(_that.refractionArcmin,_that.semidiameterArcmin);case IntervalAfterRule():
return intervalAfter(_that.base,_that.duration);case IntervalBeforeRule():
return intervalBefore(_that.base,_that.duration);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( double degrees)?  solarAltitude,TResult? Function( Duration offset)?  transit,TResult? Function( int k)?  shadowFactor,TResult? Function( double refractionArcmin,  double semidiameterArcmin)?  horizon,TResult? Function( PrayerEvent base,  Duration duration)?  intervalAfter,TResult? Function( PrayerEvent base,  Duration duration)?  intervalBefore,}) {final _that = this;
switch (_that) {
case SolarAltitudeRule() when solarAltitude != null:
return solarAltitude(_that.degrees);case TransitRule() when transit != null:
return transit(_that.offset);case ShadowFactorRule() when shadowFactor != null:
return shadowFactor(_that.k);case HorizonRule() when horizon != null:
return horizon(_that.refractionArcmin,_that.semidiameterArcmin);case IntervalAfterRule() when intervalAfter != null:
return intervalAfter(_that.base,_that.duration);case IntervalBeforeRule() when intervalBefore != null:
return intervalBefore(_that.base,_that.duration);case _:
  return null;

}
}

}

/// @nodoc


class SolarAltitudeRule implements EventRule {
  const SolarAltitudeRule({required this.degrees});
  

 final  double degrees;

/// Create a copy of EventRule
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SolarAltitudeRuleCopyWith<SolarAltitudeRule> get copyWith => _$SolarAltitudeRuleCopyWithImpl<SolarAltitudeRule>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is SolarAltitudeRule&&(identical(other.degrees, degrees) || other.degrees == degrees));
}


@override
int get hashCode {
    return Object.hash(runtimeType,degrees);
}

@override
String toString() {
    return 'EventRule.solarAltitude(degrees: $degrees)';
}


}

/// @nodoc
abstract mixin class $SolarAltitudeRuleCopyWith<$Res> implements $EventRuleCopyWith<$Res> {
  factory $SolarAltitudeRuleCopyWith(SolarAltitudeRule value, $Res Function(SolarAltitudeRule) _then) = _$SolarAltitudeRuleCopyWithImpl;
@useResult
$Res call({
 double degrees
});




}
/// @nodoc
class _$SolarAltitudeRuleCopyWithImpl<$Res>
    implements $SolarAltitudeRuleCopyWith<$Res> {
  _$SolarAltitudeRuleCopyWithImpl(this._self, this._then);

  final SolarAltitudeRule _self;
  final $Res Function(SolarAltitudeRule) _then;

/// Create a copy of EventRule
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? degrees = null,}) {
  return _then(SolarAltitudeRule(
degrees: null == degrees ? _self.degrees : degrees // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

/// @nodoc


class TransitRule implements EventRule {
  const TransitRule({this.offset = Duration.zero});
  

@JsonKey() final  Duration offset;

/// Create a copy of EventRule
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TransitRuleCopyWith<TransitRule> get copyWith => _$TransitRuleCopyWithImpl<TransitRule>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is TransitRule&&(identical(other.offset, offset) || other.offset == offset));
}


@override
int get hashCode {
    return Object.hash(runtimeType,offset);
}

@override
String toString() {
    return 'EventRule.transit(offset: $offset)';
}


}

/// @nodoc
abstract mixin class $TransitRuleCopyWith<$Res> implements $EventRuleCopyWith<$Res> {
  factory $TransitRuleCopyWith(TransitRule value, $Res Function(TransitRule) _then) = _$TransitRuleCopyWithImpl;
@useResult
$Res call({
 Duration offset
});




}
/// @nodoc
class _$TransitRuleCopyWithImpl<$Res>
    implements $TransitRuleCopyWith<$Res> {
  _$TransitRuleCopyWithImpl(this._self, this._then);

  final TransitRule _self;
  final $Res Function(TransitRule) _then;

/// Create a copy of EventRule
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? offset = null,}) {
  return _then(TransitRule(
offset: null == offset ? _self.offset : offset // ignore: cast_nullable_to_non_nullable
as Duration,
  ));
}


}

/// @nodoc


class ShadowFactorRule implements EventRule {
  const ShadowFactorRule({required this.k});
  

 final  int k;

/// Create a copy of EventRule
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ShadowFactorRuleCopyWith<ShadowFactorRule> get copyWith => _$ShadowFactorRuleCopyWithImpl<ShadowFactorRule>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ShadowFactorRule&&(identical(other.k, k) || other.k == k));
}


@override
int get hashCode {
    return Object.hash(runtimeType,k);
}

@override
String toString() {
    return 'EventRule.shadowFactor(k: $k)';
}


}

/// @nodoc
abstract mixin class $ShadowFactorRuleCopyWith<$Res> implements $EventRuleCopyWith<$Res> {
  factory $ShadowFactorRuleCopyWith(ShadowFactorRule value, $Res Function(ShadowFactorRule) _then) = _$ShadowFactorRuleCopyWithImpl;
@useResult
$Res call({
 int k
});




}
/// @nodoc
class _$ShadowFactorRuleCopyWithImpl<$Res>
    implements $ShadowFactorRuleCopyWith<$Res> {
  _$ShadowFactorRuleCopyWithImpl(this._self, this._then);

  final ShadowFactorRule _self;
  final $Res Function(ShadowFactorRule) _then;

/// Create a copy of EventRule
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? k = null,}) {
  return _then(ShadowFactorRule(
k: null == k ? _self.k : k // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class HorizonRule implements EventRule {
  const HorizonRule({this.refractionArcmin = 34, this.semidiameterArcmin = 16});
  

@JsonKey() final  double refractionArcmin;
@JsonKey() final  double semidiameterArcmin;

/// Create a copy of EventRule
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HorizonRuleCopyWith<HorizonRule> get copyWith => _$HorizonRuleCopyWithImpl<HorizonRule>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is HorizonRule&&(identical(other.refractionArcmin, refractionArcmin) || other.refractionArcmin == refractionArcmin)&&(identical(other.semidiameterArcmin, semidiameterArcmin) || other.semidiameterArcmin == semidiameterArcmin));
}


@override
int get hashCode {
    return Object.hash(runtimeType,refractionArcmin,semidiameterArcmin);
}

@override
String toString() {
    return 'EventRule.horizon(refractionArcmin: $refractionArcmin, semidiameterArcmin: $semidiameterArcmin)';
}


}

/// @nodoc
abstract mixin class $HorizonRuleCopyWith<$Res> implements $EventRuleCopyWith<$Res> {
  factory $HorizonRuleCopyWith(HorizonRule value, $Res Function(HorizonRule) _then) = _$HorizonRuleCopyWithImpl;
@useResult
$Res call({
 double refractionArcmin, double semidiameterArcmin
});




}
/// @nodoc
class _$HorizonRuleCopyWithImpl<$Res>
    implements $HorizonRuleCopyWith<$Res> {
  _$HorizonRuleCopyWithImpl(this._self, this._then);

  final HorizonRule _self;
  final $Res Function(HorizonRule) _then;

/// Create a copy of EventRule
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? refractionArcmin = null,Object? semidiameterArcmin = null,}) {
  return _then(HorizonRule(
refractionArcmin: null == refractionArcmin ? _self.refractionArcmin : refractionArcmin // ignore: cast_nullable_to_non_nullable
as double,semidiameterArcmin: null == semidiameterArcmin ? _self.semidiameterArcmin : semidiameterArcmin // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

/// @nodoc


class IntervalAfterRule implements EventRule {
  const IntervalAfterRule({required this.base, required this.duration});
  

 final  PrayerEvent base;
 final  Duration duration;

/// Create a copy of EventRule
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IntervalAfterRuleCopyWith<IntervalAfterRule> get copyWith => _$IntervalAfterRuleCopyWithImpl<IntervalAfterRule>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is IntervalAfterRule&&(identical(other.base, base) || other.base == base)&&(identical(other.duration, duration) || other.duration == duration));
}


@override
int get hashCode {
    return Object.hash(runtimeType,base,duration);
}

@override
String toString() {
    return 'EventRule.intervalAfter(base: $base, duration: $duration)';
}


}

/// @nodoc
abstract mixin class $IntervalAfterRuleCopyWith<$Res> implements $EventRuleCopyWith<$Res> {
  factory $IntervalAfterRuleCopyWith(IntervalAfterRule value, $Res Function(IntervalAfterRule) _then) = _$IntervalAfterRuleCopyWithImpl;
@useResult
$Res call({
 PrayerEvent base, Duration duration
});




}
/// @nodoc
class _$IntervalAfterRuleCopyWithImpl<$Res>
    implements $IntervalAfterRuleCopyWith<$Res> {
  _$IntervalAfterRuleCopyWithImpl(this._self, this._then);

  final IntervalAfterRule _self;
  final $Res Function(IntervalAfterRule) _then;

/// Create a copy of EventRule
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? base = null,Object? duration = null,}) {
  return _then(IntervalAfterRule(
base: null == base ? _self.base : base // ignore: cast_nullable_to_non_nullable
as PrayerEvent,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as Duration,
  ));
}


}

/// @nodoc


class IntervalBeforeRule implements EventRule {
  const IntervalBeforeRule({required this.base, required this.duration});
  

 final  PrayerEvent base;
 final  Duration duration;

/// Create a copy of EventRule
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IntervalBeforeRuleCopyWith<IntervalBeforeRule> get copyWith => _$IntervalBeforeRuleCopyWithImpl<IntervalBeforeRule>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is IntervalBeforeRule&&(identical(other.base, base) || other.base == base)&&(identical(other.duration, duration) || other.duration == duration));
}


@override
int get hashCode {
    return Object.hash(runtimeType,base,duration);
}

@override
String toString() {
    return 'EventRule.intervalBefore(base: $base, duration: $duration)';
}


}

/// @nodoc
abstract mixin class $IntervalBeforeRuleCopyWith<$Res> implements $EventRuleCopyWith<$Res> {
  factory $IntervalBeforeRuleCopyWith(IntervalBeforeRule value, $Res Function(IntervalBeforeRule) _then) = _$IntervalBeforeRuleCopyWithImpl;
@useResult
$Res call({
 PrayerEvent base, Duration duration
});




}
/// @nodoc
class _$IntervalBeforeRuleCopyWithImpl<$Res>
    implements $IntervalBeforeRuleCopyWith<$Res> {
  _$IntervalBeforeRuleCopyWithImpl(this._self, this._then);

  final IntervalBeforeRule _self;
  final $Res Function(IntervalBeforeRule) _then;

/// Create a copy of EventRule
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? base = null,Object? duration = null,}) {
  return _then(IntervalBeforeRule(
base: null == base ? _self.base : base // ignore: cast_nullable_to_non_nullable
as PrayerEvent,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as Duration,
  ));
}


}

// dart format on
