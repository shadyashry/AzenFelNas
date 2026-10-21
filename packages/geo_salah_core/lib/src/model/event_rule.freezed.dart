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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( TransitRule value)?  transit,TResult Function( HorizonRule value)?  horizon,required TResult orElse(),}){
final _that = this;
switch (_that) {
case TransitRule() when transit != null:
return transit(_that);case HorizonRule() when horizon != null:
return horizon(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( TransitRule value)  transit,required TResult Function( HorizonRule value)  horizon,}){
final _that = this;
switch (_that) {
case TransitRule():
return transit(_that);case HorizonRule():
return horizon(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( TransitRule value)?  transit,TResult? Function( HorizonRule value)?  horizon,}){
final _that = this;
switch (_that) {
case TransitRule() when transit != null:
return transit(_that);case HorizonRule() when horizon != null:
return horizon(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( Duration offset)?  transit,TResult Function( double refractionArcmin,  double semidiameterArcmin)?  horizon,required TResult orElse(),}) {final _that = this;
switch (_that) {
case TransitRule() when transit != null:
return transit(_that.offset);case HorizonRule() when horizon != null:
return horizon(_that.refractionArcmin,_that.semidiameterArcmin);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( Duration offset)  transit,required TResult Function( double refractionArcmin,  double semidiameterArcmin)  horizon,}) {final _that = this;
switch (_that) {
case TransitRule():
return transit(_that.offset);case HorizonRule():
return horizon(_that.refractionArcmin,_that.semidiameterArcmin);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( Duration offset)?  transit,TResult? Function( double refractionArcmin,  double semidiameterArcmin)?  horizon,}) {final _that = this;
switch (_that) {
case TransitRule() when transit != null:
return transit(_that.offset);case HorizonRule() when horizon != null:
return horizon(_that.refractionArcmin,_that.semidiameterArcmin);case _:
  return null;

}
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

// dart format on
