// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'diagnostic_plan.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DiagnosticPlan {

/// Status.
 DiagnosticPlanStatus get status;/// Plan generation, when applied.
 int? get generation;/// Number of entries, when applied.
 int? get entryCount;
/// Create a copy of DiagnosticPlan
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DiagnosticPlanCopyWith<DiagnosticPlan> get copyWith => _$DiagnosticPlanCopyWithImpl<DiagnosticPlan>(this as DiagnosticPlan, _$identity);

  /// Serializes this DiagnosticPlan to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as DiagnosticPlan;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DiagnosticPlan&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.generation, _this.generation) || other.generation == _this.generation)&&(identical(other.entryCount, _this.entryCount) || other.entryCount == _this.entryCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as DiagnosticPlan;
  return Object.hash(runtimeType,_this.status,_this.generation,_this.entryCount);
}

@override
String toString() {
  final _this = this as DiagnosticPlan;
  return 'DiagnosticPlan(status: ${_this.status}, generation: ${_this.generation}, entryCount: ${_this.entryCount})';
}


}

/// @nodoc
abstract mixin class $DiagnosticPlanCopyWith<$Res>  {
  factory $DiagnosticPlanCopyWith(DiagnosticPlan value, $Res Function(DiagnosticPlan) _then) = _$DiagnosticPlanCopyWithImpl;
@useResult
$Res call({
 DiagnosticPlanStatus status, int? generation, int? entryCount
});




}
/// @nodoc
class _$DiagnosticPlanCopyWithImpl<$Res>
    implements $DiagnosticPlanCopyWith<$Res> {
  _$DiagnosticPlanCopyWithImpl(this._self, this._then);

  final DiagnosticPlan _self;
  final $Res Function(DiagnosticPlan) _then;

/// Create a copy of DiagnosticPlan
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? generation = freezed,Object? entryCount = freezed,}) {
  return _then(DiagnosticPlan(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as DiagnosticPlanStatus,generation: freezed == generation ? _self.generation : generation // ignore: cast_nullable_to_non_nullable
as int?,entryCount: freezed == entryCount ? _self.entryCount : entryCount // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [DiagnosticPlan].
extension DiagnosticPlanPatterns on DiagnosticPlan {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DiagnosticPlan value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DiagnosticPlan() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DiagnosticPlan value)  $default,){
final _that = this;
switch (_that) {
case _DiagnosticPlan():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DiagnosticPlan value)?  $default,){
final _that = this;
switch (_that) {
case _DiagnosticPlan() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DiagnosticPlanStatus status,  int? generation,  int? entryCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DiagnosticPlan() when $default != null:
return $default(_that.status,_that.generation,_that.entryCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DiagnosticPlanStatus status,  int? generation,  int? entryCount)  $default,) {final _that = this;
switch (_that) {
case _DiagnosticPlan():
return $default(_that.status,_that.generation,_that.entryCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DiagnosticPlanStatus status,  int? generation,  int? entryCount)?  $default,) {final _that = this;
switch (_that) {
case _DiagnosticPlan() when $default != null:
return $default(_that.status,_that.generation,_that.entryCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DiagnosticPlan implements DiagnosticPlan {
  const _DiagnosticPlan({required this.status, this.generation, this.entryCount});
  factory _DiagnosticPlan.fromJson(Map<String, dynamic> json) => _$DiagnosticPlanFromJson(json);

/// Status.
@override final  DiagnosticPlanStatus status;
/// Plan generation, when applied.
@override final  int? generation;
/// Number of entries, when applied.
@override final  int? entryCount;

/// Create a copy of DiagnosticPlan
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DiagnosticPlanCopyWith<_DiagnosticPlan> get copyWith => __$DiagnosticPlanCopyWithImpl<_DiagnosticPlan>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DiagnosticPlanToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DiagnosticPlan&&(identical(other.status, status) || other.status == status)&&(identical(other.generation, generation) || other.generation == generation)&&(identical(other.entryCount, entryCount) || other.entryCount == entryCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,status,generation,entryCount);
}

@override
String toString() {
    return 'DiagnosticPlan(status: $status, generation: $generation, entryCount: $entryCount)';
}


}

/// @nodoc
abstract mixin class _$DiagnosticPlanCopyWith<$Res> implements $DiagnosticPlanCopyWith<$Res> {
  factory _$DiagnosticPlanCopyWith(_DiagnosticPlan value, $Res Function(_DiagnosticPlan) _then) = __$DiagnosticPlanCopyWithImpl;
@override @useResult
$Res call({
 DiagnosticPlanStatus status, int? generation, int? entryCount
});




}
/// @nodoc
class __$DiagnosticPlanCopyWithImpl<$Res>
    implements _$DiagnosticPlanCopyWith<$Res> {
  __$DiagnosticPlanCopyWithImpl(this._self, this._then);

  final _DiagnosticPlan _self;
  final $Res Function(_DiagnosticPlan) _then;

/// Create a copy of DiagnosticPlan
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? generation = freezed,Object? entryCount = freezed,}) {
  return _then(_DiagnosticPlan(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as DiagnosticPlanStatus,generation: freezed == generation ? _self.generation : generation // ignore: cast_nullable_to_non_nullable
as int?,entryCount: freezed == entryCount ? _self.entryCount : entryCount // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
