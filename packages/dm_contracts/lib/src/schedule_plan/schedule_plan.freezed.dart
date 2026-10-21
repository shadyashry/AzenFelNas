// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'schedule_plan.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SchedulePlan {

/// Schema version; 1.
 int get schemaVersion;/// Monotonic plan generation.
 int get generation;/// Location context id.
 String get contextId;/// IANA zone of the plan (REQ-TIME-001).
 String get zoneId;/// Pinned TZDB version (REQ-TIME-001).
 String get tzdbVersion;/// When the plan was built.
 int get generatedAtUtcMs;/// End of the scheduled horizon (REQ-ALM-010).
 int get horizonEndUtcMs;/// Entries.
 List<SchedulePlanEntry> get entries;/// Delivery policy.
 SchedulePlanPolicy get policy;
/// Create a copy of SchedulePlan
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SchedulePlanCopyWith<SchedulePlan> get copyWith => _$SchedulePlanCopyWithImpl<SchedulePlan>(this as SchedulePlan, _$identity);

  /// Serializes this SchedulePlan to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SchedulePlan;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SchedulePlan&&(identical(other.schemaVersion, _this.schemaVersion) || other.schemaVersion == _this.schemaVersion)&&(identical(other.generation, _this.generation) || other.generation == _this.generation)&&(identical(other.contextId, _this.contextId) || other.contextId == _this.contextId)&&(identical(other.zoneId, _this.zoneId) || other.zoneId == _this.zoneId)&&(identical(other.tzdbVersion, _this.tzdbVersion) || other.tzdbVersion == _this.tzdbVersion)&&(identical(other.generatedAtUtcMs, _this.generatedAtUtcMs) || other.generatedAtUtcMs == _this.generatedAtUtcMs)&&(identical(other.horizonEndUtcMs, _this.horizonEndUtcMs) || other.horizonEndUtcMs == _this.horizonEndUtcMs)&&const DeepCollectionEquality().equals(other.entries, _this.entries)&&(identical(other.policy, _this.policy) || other.policy == _this.policy));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SchedulePlan;
  return Object.hash(runtimeType,_this.schemaVersion,_this.generation,_this.contextId,_this.zoneId,_this.tzdbVersion,_this.generatedAtUtcMs,_this.horizonEndUtcMs,const DeepCollectionEquality().hash(_this.entries),_this.policy);
}

@override
String toString() {
  final _this = this as SchedulePlan;
  return 'SchedulePlan(schemaVersion: ${_this.schemaVersion}, generation: ${_this.generation}, contextId: ${_this.contextId}, zoneId: ${_this.zoneId}, tzdbVersion: ${_this.tzdbVersion}, generatedAtUtcMs: ${_this.generatedAtUtcMs}, horizonEndUtcMs: ${_this.horizonEndUtcMs}, entries: ${_this.entries}, policy: ${_this.policy})';
}


}

/// @nodoc
abstract mixin class $SchedulePlanCopyWith<$Res>  {
  factory $SchedulePlanCopyWith(SchedulePlan value, $Res Function(SchedulePlan) _then) = _$SchedulePlanCopyWithImpl;
@useResult
$Res call({
 int schemaVersion, int generation, String contextId, String zoneId, String tzdbVersion, int generatedAtUtcMs, int horizonEndUtcMs, List<SchedulePlanEntry> entries, SchedulePlanPolicy policy
});


$SchedulePlanPolicyCopyWith<$Res> get policy;

}
/// @nodoc
class _$SchedulePlanCopyWithImpl<$Res>
    implements $SchedulePlanCopyWith<$Res> {
  _$SchedulePlanCopyWithImpl(this._self, this._then);

  final SchedulePlan _self;
  final $Res Function(SchedulePlan) _then;

/// Create a copy of SchedulePlan
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? schemaVersion = null,Object? generation = null,Object? contextId = null,Object? zoneId = null,Object? tzdbVersion = null,Object? generatedAtUtcMs = null,Object? horizonEndUtcMs = null,Object? entries = null,Object? policy = null,}) {
  return _then(SchedulePlan(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,generation: null == generation ? _self.generation : generation // ignore: cast_nullable_to_non_nullable
as int,contextId: null == contextId ? _self.contextId : contextId // ignore: cast_nullable_to_non_nullable
as String,zoneId: null == zoneId ? _self.zoneId : zoneId // ignore: cast_nullable_to_non_nullable
as String,tzdbVersion: null == tzdbVersion ? _self.tzdbVersion : tzdbVersion // ignore: cast_nullable_to_non_nullable
as String,generatedAtUtcMs: null == generatedAtUtcMs ? _self.generatedAtUtcMs : generatedAtUtcMs // ignore: cast_nullable_to_non_nullable
as int,horizonEndUtcMs: null == horizonEndUtcMs ? _self.horizonEndUtcMs : horizonEndUtcMs // ignore: cast_nullable_to_non_nullable
as int,entries: null == entries ? _self.entries : entries // ignore: cast_nullable_to_non_nullable
as List<SchedulePlanEntry>,policy: null == policy ? _self.policy : policy // ignore: cast_nullable_to_non_nullable
as SchedulePlanPolicy,
  ));
}
/// Create a copy of SchedulePlan
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SchedulePlanPolicyCopyWith<$Res> get policy {
  
  return $SchedulePlanPolicyCopyWith<$Res>(_self.policy, (value) {
    return _then(_self.copyWith(policy: value));
  });
}
}


/// Adds pattern-matching-related methods to [SchedulePlan].
extension SchedulePlanPatterns on SchedulePlan {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SchedulePlan value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SchedulePlan() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SchedulePlan value)  $default,){
final _that = this;
switch (_that) {
case _SchedulePlan():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SchedulePlan value)?  $default,){
final _that = this;
switch (_that) {
case _SchedulePlan() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int schemaVersion,  int generation,  String contextId,  String zoneId,  String tzdbVersion,  int generatedAtUtcMs,  int horizonEndUtcMs,  List<SchedulePlanEntry> entries,  SchedulePlanPolicy policy)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SchedulePlan() when $default != null:
return $default(_that.schemaVersion,_that.generation,_that.contextId,_that.zoneId,_that.tzdbVersion,_that.generatedAtUtcMs,_that.horizonEndUtcMs,_that.entries,_that.policy);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int schemaVersion,  int generation,  String contextId,  String zoneId,  String tzdbVersion,  int generatedAtUtcMs,  int horizonEndUtcMs,  List<SchedulePlanEntry> entries,  SchedulePlanPolicy policy)  $default,) {final _that = this;
switch (_that) {
case _SchedulePlan():
return $default(_that.schemaVersion,_that.generation,_that.contextId,_that.zoneId,_that.tzdbVersion,_that.generatedAtUtcMs,_that.horizonEndUtcMs,_that.entries,_that.policy);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int schemaVersion,  int generation,  String contextId,  String zoneId,  String tzdbVersion,  int generatedAtUtcMs,  int horizonEndUtcMs,  List<SchedulePlanEntry> entries,  SchedulePlanPolicy policy)?  $default,) {final _that = this;
switch (_that) {
case _SchedulePlan() when $default != null:
return $default(_that.schemaVersion,_that.generation,_that.contextId,_that.zoneId,_that.tzdbVersion,_that.generatedAtUtcMs,_that.horizonEndUtcMs,_that.entries,_that.policy);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SchedulePlan implements SchedulePlan {
  const _SchedulePlan({required this.schemaVersion, required this.generation, required this.contextId, required this.zoneId, required this.tzdbVersion, required this.generatedAtUtcMs, required this.horizonEndUtcMs, required  List<SchedulePlanEntry> entries, required this.policy}): _entries = entries;
  factory _SchedulePlan.fromJson(Map<String, dynamic> json) => _$SchedulePlanFromJson(json);

/// Schema version; 1.
@override final  int schemaVersion;
/// Monotonic plan generation.
@override final  int generation;
/// Location context id.
@override final  String contextId;
/// IANA zone of the plan (REQ-TIME-001).
@override final  String zoneId;
/// Pinned TZDB version (REQ-TIME-001).
@override final  String tzdbVersion;
/// When the plan was built.
@override final  int generatedAtUtcMs;
/// End of the scheduled horizon (REQ-ALM-010).
@override final  int horizonEndUtcMs;
/// Entries.
 final  List<SchedulePlanEntry> _entries;
/// Entries.
@override List<SchedulePlanEntry> get entries {
  if (_entries is EqualUnmodifiableListView) return _entries;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_entries);
}

/// Delivery policy.
@override final  SchedulePlanPolicy policy;

/// Create a copy of SchedulePlan
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SchedulePlanCopyWith<_SchedulePlan> get copyWith => __$SchedulePlanCopyWithImpl<_SchedulePlan>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SchedulePlanToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SchedulePlan&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.generation, generation) || other.generation == generation)&&(identical(other.contextId, contextId) || other.contextId == contextId)&&(identical(other.zoneId, zoneId) || other.zoneId == zoneId)&&(identical(other.tzdbVersion, tzdbVersion) || other.tzdbVersion == tzdbVersion)&&(identical(other.generatedAtUtcMs, generatedAtUtcMs) || other.generatedAtUtcMs == generatedAtUtcMs)&&(identical(other.horizonEndUtcMs, horizonEndUtcMs) || other.horizonEndUtcMs == horizonEndUtcMs)&&const DeepCollectionEquality().equals(other.entries, _entries)&&(identical(other.policy, policy) || other.policy == policy));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,schemaVersion,generation,contextId,zoneId,tzdbVersion,generatedAtUtcMs,horizonEndUtcMs,const DeepCollectionEquality().hash(_entries),policy);
}

@override
String toString() {
    return 'SchedulePlan(schemaVersion: $schemaVersion, generation: $generation, contextId: $contextId, zoneId: $zoneId, tzdbVersion: $tzdbVersion, generatedAtUtcMs: $generatedAtUtcMs, horizonEndUtcMs: $horizonEndUtcMs, entries: $entries, policy: $policy)';
}


}

/// @nodoc
abstract mixin class _$SchedulePlanCopyWith<$Res> implements $SchedulePlanCopyWith<$Res> {
  factory _$SchedulePlanCopyWith(_SchedulePlan value, $Res Function(_SchedulePlan) _then) = __$SchedulePlanCopyWithImpl;
@override @useResult
$Res call({
 int schemaVersion, int generation, String contextId, String zoneId, String tzdbVersion, int generatedAtUtcMs, int horizonEndUtcMs, List<SchedulePlanEntry> entries, SchedulePlanPolicy policy
});


@override $SchedulePlanPolicyCopyWith<$Res> get policy;

}
/// @nodoc
class __$SchedulePlanCopyWithImpl<$Res>
    implements _$SchedulePlanCopyWith<$Res> {
  __$SchedulePlanCopyWithImpl(this._self, this._then);

  final _SchedulePlan _self;
  final $Res Function(_SchedulePlan) _then;

/// Create a copy of SchedulePlan
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? schemaVersion = null,Object? generation = null,Object? contextId = null,Object? zoneId = null,Object? tzdbVersion = null,Object? generatedAtUtcMs = null,Object? horizonEndUtcMs = null,Object? entries = null,Object? policy = null,}) {
  return _then(_SchedulePlan(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,generation: null == generation ? _self.generation : generation // ignore: cast_nullable_to_non_nullable
as int,contextId: null == contextId ? _self.contextId : contextId // ignore: cast_nullable_to_non_nullable
as String,zoneId: null == zoneId ? _self.zoneId : zoneId // ignore: cast_nullable_to_non_nullable
as String,tzdbVersion: null == tzdbVersion ? _self.tzdbVersion : tzdbVersion // ignore: cast_nullable_to_non_nullable
as String,generatedAtUtcMs: null == generatedAtUtcMs ? _self.generatedAtUtcMs : generatedAtUtcMs // ignore: cast_nullable_to_non_nullable
as int,horizonEndUtcMs: null == horizonEndUtcMs ? _self.horizonEndUtcMs : horizonEndUtcMs // ignore: cast_nullable_to_non_nullable
as int,entries: null == entries ? _self._entries : entries // ignore: cast_nullable_to_non_nullable
as List<SchedulePlanEntry>,policy: null == policy ? _self.policy : policy // ignore: cast_nullable_to_non_nullable
as SchedulePlanPolicy,
  ));
}

/// Create a copy of SchedulePlan
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SchedulePlanPolicyCopyWith<$Res> get policy {
  
  return $SchedulePlanPolicyCopyWith<$Res>(_self.policy, (value) {
    return _then(_self.copyWith(policy: value));
  });
}
}

// dart format on
