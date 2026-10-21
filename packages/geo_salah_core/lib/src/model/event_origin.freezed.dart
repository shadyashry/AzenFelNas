// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'event_origin.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$EventOrigin {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is EventOrigin);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'EventOrigin()';
}


}

/// @nodoc
class $EventOriginCopyWith<$Res>  {
$EventOriginCopyWith(EventOrigin _, $Res Function(EventOrigin) __);
}


/// Adds pattern-matching-related methods to [EventOrigin].
extension EventOriginPatterns on EventOrigin {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( Primary value)?  primary,TResult Function( Fallback value)?  fallback,TResult Function( NoEvent value)?  noEvent,required TResult orElse(),}){
final _that = this;
switch (_that) {
case Primary() when primary != null:
return primary(_that);case Fallback() when fallback != null:
return fallback(_that);case NoEvent() when noEvent != null:
return noEvent(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( Primary value)  primary,required TResult Function( Fallback value)  fallback,required TResult Function( NoEvent value)  noEvent,}){
final _that = this;
switch (_that) {
case Primary():
return primary(_that);case Fallback():
return fallback(_that);case NoEvent():
return noEvent(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( Primary value)?  primary,TResult? Function( Fallback value)?  fallback,TResult? Function( NoEvent value)?  noEvent,}){
final _that = this;
switch (_that) {
case Primary() when primary != null:
return primary(_that);case Fallback() when fallback != null:
return fallback(_that);case NoEvent() when noEvent != null:
return noEvent(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  primary,TResult Function( HighLatitudeMethod method)?  fallback,TResult Function( NoEventReason reason)?  noEvent,required TResult orElse(),}) {final _that = this;
switch (_that) {
case Primary() when primary != null:
return primary();case Fallback() when fallback != null:
return fallback(_that.method);case NoEvent() when noEvent != null:
return noEvent(_that.reason);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  primary,required TResult Function( HighLatitudeMethod method)  fallback,required TResult Function( NoEventReason reason)  noEvent,}) {final _that = this;
switch (_that) {
case Primary():
return primary();case Fallback():
return fallback(_that.method);case NoEvent():
return noEvent(_that.reason);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  primary,TResult? Function( HighLatitudeMethod method)?  fallback,TResult? Function( NoEventReason reason)?  noEvent,}) {final _that = this;
switch (_that) {
case Primary() when primary != null:
return primary();case Fallback() when fallback != null:
return fallback(_that.method);case NoEvent() when noEvent != null:
return noEvent(_that.reason);case _:
  return null;

}
}

}

/// @nodoc


class Primary implements EventOrigin {
  const Primary();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is Primary);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'EventOrigin.primary()';
}


}




/// @nodoc


class Fallback implements EventOrigin {
  const Fallback(this.method);
  

 final  HighLatitudeMethod method;

/// Create a copy of EventOrigin
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FallbackCopyWith<Fallback> get copyWith => _$FallbackCopyWithImpl<Fallback>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is Fallback&&(identical(other.method, method) || other.method == method));
}


@override
int get hashCode {
    return Object.hash(runtimeType,method);
}

@override
String toString() {
    return 'EventOrigin.fallback(method: $method)';
}


}

/// @nodoc
abstract mixin class $FallbackCopyWith<$Res> implements $EventOriginCopyWith<$Res> {
  factory $FallbackCopyWith(Fallback value, $Res Function(Fallback) _then) = _$FallbackCopyWithImpl;
@useResult
$Res call({
 HighLatitudeMethod method
});


$HighLatitudeMethodCopyWith<$Res> get method;

}
/// @nodoc
class _$FallbackCopyWithImpl<$Res>
    implements $FallbackCopyWith<$Res> {
  _$FallbackCopyWithImpl(this._self, this._then);

  final Fallback _self;
  final $Res Function(Fallback) _then;

/// Create a copy of EventOrigin
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? method = null,}) {
  return _then(Fallback(
null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as HighLatitudeMethod,
  ));
}

/// Create a copy of EventOrigin
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HighLatitudeMethodCopyWith<$Res> get method {
  
  return $HighLatitudeMethodCopyWith<$Res>(_self.method, (value) {
    return _then(_self.copyWith(method: value));
  });
}
}

/// @nodoc


class NoEvent implements EventOrigin {
  const NoEvent(this.reason);
  

 final  NoEventReason reason;

/// Create a copy of EventOrigin
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NoEventCopyWith<NoEvent> get copyWith => _$NoEventCopyWithImpl<NoEvent>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is NoEvent&&(identical(other.reason, reason) || other.reason == reason));
}


@override
int get hashCode {
    return Object.hash(runtimeType,reason);
}

@override
String toString() {
    return 'EventOrigin.noEvent(reason: $reason)';
}


}

/// @nodoc
abstract mixin class $NoEventCopyWith<$Res> implements $EventOriginCopyWith<$Res> {
  factory $NoEventCopyWith(NoEvent value, $Res Function(NoEvent) _then) = _$NoEventCopyWithImpl;
@useResult
$Res call({
 NoEventReason reason
});




}
/// @nodoc
class _$NoEventCopyWithImpl<$Res>
    implements $NoEventCopyWith<$Res> {
  _$NoEventCopyWithImpl(this._self, this._then);

  final NoEvent _self;
  final $Res Function(NoEvent) _then;

/// Create a copy of EventOrigin
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? reason = null,}) {
  return _then(NoEvent(
null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as NoEventReason,
  ));
}


}

// dart format on
