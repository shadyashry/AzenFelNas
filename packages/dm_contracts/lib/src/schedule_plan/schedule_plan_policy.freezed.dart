// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'schedule_plan_policy.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SchedulePlanPolicy {

/// Locale of the pre-rendered text.
 PlanLocale get locale;/// Whether Do Not Disturb silences the Athan.
 bool get respectDnd;/// Whether to vibrate.
 bool get vibrate;/// Whether Android plays the full Athan.
 bool get fullAthanAndroid;/// iOS clip length, at most 29 s (REQ-ALM-034).
 int get iosClipSeconds;/// Pre-reminder offset ∈ {0, 5, 10, 15, 30} (REQ-ALM-042).
 int get preReminderMinutes;/// Snooze length; 5 (REQ-ALM-042).
 int get snoozeMinutes;
/// Create a copy of SchedulePlanPolicy
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SchedulePlanPolicyCopyWith<SchedulePlanPolicy> get copyWith => _$SchedulePlanPolicyCopyWithImpl<SchedulePlanPolicy>(this as SchedulePlanPolicy, _$identity);

  /// Serializes this SchedulePlanPolicy to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SchedulePlanPolicy;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SchedulePlanPolicy&&(identical(other.locale, _this.locale) || other.locale == _this.locale)&&(identical(other.respectDnd, _this.respectDnd) || other.respectDnd == _this.respectDnd)&&(identical(other.vibrate, _this.vibrate) || other.vibrate == _this.vibrate)&&(identical(other.fullAthanAndroid, _this.fullAthanAndroid) || other.fullAthanAndroid == _this.fullAthanAndroid)&&(identical(other.iosClipSeconds, _this.iosClipSeconds) || other.iosClipSeconds == _this.iosClipSeconds)&&(identical(other.preReminderMinutes, _this.preReminderMinutes) || other.preReminderMinutes == _this.preReminderMinutes)&&(identical(other.snoozeMinutes, _this.snoozeMinutes) || other.snoozeMinutes == _this.snoozeMinutes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SchedulePlanPolicy;
  return Object.hash(runtimeType,_this.locale,_this.respectDnd,_this.vibrate,_this.fullAthanAndroid,_this.iosClipSeconds,_this.preReminderMinutes,_this.snoozeMinutes);
}

@override
String toString() {
  final _this = this as SchedulePlanPolicy;
  return 'SchedulePlanPolicy(locale: ${_this.locale}, respectDnd: ${_this.respectDnd}, vibrate: ${_this.vibrate}, fullAthanAndroid: ${_this.fullAthanAndroid}, iosClipSeconds: ${_this.iosClipSeconds}, preReminderMinutes: ${_this.preReminderMinutes}, snoozeMinutes: ${_this.snoozeMinutes})';
}


}

/// @nodoc
abstract mixin class $SchedulePlanPolicyCopyWith<$Res>  {
  factory $SchedulePlanPolicyCopyWith(SchedulePlanPolicy value, $Res Function(SchedulePlanPolicy) _then) = _$SchedulePlanPolicyCopyWithImpl;
@useResult
$Res call({
 PlanLocale locale, bool respectDnd, bool vibrate, bool fullAthanAndroid, int iosClipSeconds, int preReminderMinutes, int snoozeMinutes
});




}
/// @nodoc
class _$SchedulePlanPolicyCopyWithImpl<$Res>
    implements $SchedulePlanPolicyCopyWith<$Res> {
  _$SchedulePlanPolicyCopyWithImpl(this._self, this._then);

  final SchedulePlanPolicy _self;
  final $Res Function(SchedulePlanPolicy) _then;

/// Create a copy of SchedulePlanPolicy
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? locale = null,Object? respectDnd = null,Object? vibrate = null,Object? fullAthanAndroid = null,Object? iosClipSeconds = null,Object? preReminderMinutes = null,Object? snoozeMinutes = null,}) {
  return _then(SchedulePlanPolicy(
locale: null == locale ? _self.locale : locale // ignore: cast_nullable_to_non_nullable
as PlanLocale,respectDnd: null == respectDnd ? _self.respectDnd : respectDnd // ignore: cast_nullable_to_non_nullable
as bool,vibrate: null == vibrate ? _self.vibrate : vibrate // ignore: cast_nullable_to_non_nullable
as bool,fullAthanAndroid: null == fullAthanAndroid ? _self.fullAthanAndroid : fullAthanAndroid // ignore: cast_nullable_to_non_nullable
as bool,iosClipSeconds: null == iosClipSeconds ? _self.iosClipSeconds : iosClipSeconds // ignore: cast_nullable_to_non_nullable
as int,preReminderMinutes: null == preReminderMinutes ? _self.preReminderMinutes : preReminderMinutes // ignore: cast_nullable_to_non_nullable
as int,snoozeMinutes: null == snoozeMinutes ? _self.snoozeMinutes : snoozeMinutes // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [SchedulePlanPolicy].
extension SchedulePlanPolicyPatterns on SchedulePlanPolicy {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SchedulePlanPolicy value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SchedulePlanPolicy() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SchedulePlanPolicy value)  $default,){
final _that = this;
switch (_that) {
case _SchedulePlanPolicy():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SchedulePlanPolicy value)?  $default,){
final _that = this;
switch (_that) {
case _SchedulePlanPolicy() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( PlanLocale locale,  bool respectDnd,  bool vibrate,  bool fullAthanAndroid,  int iosClipSeconds,  int preReminderMinutes,  int snoozeMinutes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SchedulePlanPolicy() when $default != null:
return $default(_that.locale,_that.respectDnd,_that.vibrate,_that.fullAthanAndroid,_that.iosClipSeconds,_that.preReminderMinutes,_that.snoozeMinutes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( PlanLocale locale,  bool respectDnd,  bool vibrate,  bool fullAthanAndroid,  int iosClipSeconds,  int preReminderMinutes,  int snoozeMinutes)  $default,) {final _that = this;
switch (_that) {
case _SchedulePlanPolicy():
return $default(_that.locale,_that.respectDnd,_that.vibrate,_that.fullAthanAndroid,_that.iosClipSeconds,_that.preReminderMinutes,_that.snoozeMinutes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( PlanLocale locale,  bool respectDnd,  bool vibrate,  bool fullAthanAndroid,  int iosClipSeconds,  int preReminderMinutes,  int snoozeMinutes)?  $default,) {final _that = this;
switch (_that) {
case _SchedulePlanPolicy() when $default != null:
return $default(_that.locale,_that.respectDnd,_that.vibrate,_that.fullAthanAndroid,_that.iosClipSeconds,_that.preReminderMinutes,_that.snoozeMinutes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SchedulePlanPolicy implements SchedulePlanPolicy {
  const _SchedulePlanPolicy({required this.locale, required this.respectDnd, required this.vibrate, required this.fullAthanAndroid, required this.iosClipSeconds, required this.preReminderMinutes, required this.snoozeMinutes});
  factory _SchedulePlanPolicy.fromJson(Map<String, dynamic> json) => _$SchedulePlanPolicyFromJson(json);

/// Locale of the pre-rendered text.
@override final  PlanLocale locale;
/// Whether Do Not Disturb silences the Athan.
@override final  bool respectDnd;
/// Whether to vibrate.
@override final  bool vibrate;
/// Whether Android plays the full Athan.
@override final  bool fullAthanAndroid;
/// iOS clip length, at most 29 s (REQ-ALM-034).
@override final  int iosClipSeconds;
/// Pre-reminder offset ∈ {0, 5, 10, 15, 30} (REQ-ALM-042).
@override final  int preReminderMinutes;
/// Snooze length; 5 (REQ-ALM-042).
@override final  int snoozeMinutes;

/// Create a copy of SchedulePlanPolicy
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SchedulePlanPolicyCopyWith<_SchedulePlanPolicy> get copyWith => __$SchedulePlanPolicyCopyWithImpl<_SchedulePlanPolicy>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SchedulePlanPolicyToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SchedulePlanPolicy&&(identical(other.locale, locale) || other.locale == locale)&&(identical(other.respectDnd, respectDnd) || other.respectDnd == respectDnd)&&(identical(other.vibrate, vibrate) || other.vibrate == vibrate)&&(identical(other.fullAthanAndroid, fullAthanAndroid) || other.fullAthanAndroid == fullAthanAndroid)&&(identical(other.iosClipSeconds, iosClipSeconds) || other.iosClipSeconds == iosClipSeconds)&&(identical(other.preReminderMinutes, preReminderMinutes) || other.preReminderMinutes == preReminderMinutes)&&(identical(other.snoozeMinutes, snoozeMinutes) || other.snoozeMinutes == snoozeMinutes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,locale,respectDnd,vibrate,fullAthanAndroid,iosClipSeconds,preReminderMinutes,snoozeMinutes);
}

@override
String toString() {
    return 'SchedulePlanPolicy(locale: $locale, respectDnd: $respectDnd, vibrate: $vibrate, fullAthanAndroid: $fullAthanAndroid, iosClipSeconds: $iosClipSeconds, preReminderMinutes: $preReminderMinutes, snoozeMinutes: $snoozeMinutes)';
}


}

/// @nodoc
abstract mixin class _$SchedulePlanPolicyCopyWith<$Res> implements $SchedulePlanPolicyCopyWith<$Res> {
  factory _$SchedulePlanPolicyCopyWith(_SchedulePlanPolicy value, $Res Function(_SchedulePlanPolicy) _then) = __$SchedulePlanPolicyCopyWithImpl;
@override @useResult
$Res call({
 PlanLocale locale, bool respectDnd, bool vibrate, bool fullAthanAndroid, int iosClipSeconds, int preReminderMinutes, int snoozeMinutes
});




}
/// @nodoc
class __$SchedulePlanPolicyCopyWithImpl<$Res>
    implements _$SchedulePlanPolicyCopyWith<$Res> {
  __$SchedulePlanPolicyCopyWithImpl(this._self, this._then);

  final _SchedulePlanPolicy _self;
  final $Res Function(_SchedulePlanPolicy) _then;

/// Create a copy of SchedulePlanPolicy
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? locale = null,Object? respectDnd = null,Object? vibrate = null,Object? fullAthanAndroid = null,Object? iosClipSeconds = null,Object? preReminderMinutes = null,Object? snoozeMinutes = null,}) {
  return _then(_SchedulePlanPolicy(
locale: null == locale ? _self.locale : locale // ignore: cast_nullable_to_non_nullable
as PlanLocale,respectDnd: null == respectDnd ? _self.respectDnd : respectDnd // ignore: cast_nullable_to_non_nullable
as bool,vibrate: null == vibrate ? _self.vibrate : vibrate // ignore: cast_nullable_to_non_nullable
as bool,fullAthanAndroid: null == fullAthanAndroid ? _self.fullAthanAndroid : fullAthanAndroid // ignore: cast_nullable_to_non_nullable
as bool,iosClipSeconds: null == iosClipSeconds ? _self.iosClipSeconds : iosClipSeconds // ignore: cast_nullable_to_non_nullable
as int,preReminderMinutes: null == preReminderMinutes ? _self.preReminderMinutes : preReminderMinutes // ignore: cast_nullable_to_non_nullable
as int,snoozeMinutes: null == snoozeMinutes ? _self.snoozeMinutes : snoozeMinutes // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
