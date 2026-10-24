// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'diagnostic_files.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DiagnosticFiles {

/// The event-log ring, oldest first.
@JsonKey(name: 'events.jsonl') List<EventLogEntry> get events;/// Athan Health as Dart evaluated it.
@JsonKey(name: 'health.json') DiagnosticHealth get health;/// The applied plan without texts or sounds.
@JsonKey(name: 'plan_redacted.json') DiagnosticPlan get plan;/// Active packages.
@JsonKey(name: 'packages.json') List<DiagnosticPackage> get packages;/// Device facts.
@JsonKey(name: 'device.json') DiagnosticDevice get device;/// The active context at 0.01°, or null when there is none.
@JsonKey(name: 'context.json', includeIfNull: true) DiagnosticContext? get context;
/// Create a copy of DiagnosticFiles
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DiagnosticFilesCopyWith<DiagnosticFiles> get copyWith => _$DiagnosticFilesCopyWithImpl<DiagnosticFiles>(this as DiagnosticFiles, _$identity);

  /// Serializes this DiagnosticFiles to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as DiagnosticFiles;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DiagnosticFiles&&const DeepCollectionEquality().equals(other.events, _this.events)&&(identical(other.health, _this.health) || other.health == _this.health)&&(identical(other.plan, _this.plan) || other.plan == _this.plan)&&const DeepCollectionEquality().equals(other.packages, _this.packages)&&(identical(other.device, _this.device) || other.device == _this.device)&&(identical(other.context, _this.context) || other.context == _this.context));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as DiagnosticFiles;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.events),_this.health,_this.plan,const DeepCollectionEquality().hash(_this.packages),_this.device,_this.context);
}

@override
String toString() {
  final _this = this as DiagnosticFiles;
  return 'DiagnosticFiles(events: ${_this.events}, health: ${_this.health}, plan: ${_this.plan}, packages: ${_this.packages}, device: ${_this.device}, context: ${_this.context})';
}


}

/// @nodoc
abstract mixin class $DiagnosticFilesCopyWith<$Res>  {
  factory $DiagnosticFilesCopyWith(DiagnosticFiles value, $Res Function(DiagnosticFiles) _then) = _$DiagnosticFilesCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'events.jsonl') List<EventLogEntry> events,@JsonKey(name: 'health.json') DiagnosticHealth health,@JsonKey(name: 'plan_redacted.json') DiagnosticPlan plan,@JsonKey(name: 'packages.json') List<DiagnosticPackage> packages,@JsonKey(name: 'device.json') DiagnosticDevice device,@JsonKey(name: 'context.json', includeIfNull: true) DiagnosticContext? context
});


$DiagnosticHealthCopyWith<$Res> get health;$DiagnosticPlanCopyWith<$Res> get plan;$DiagnosticDeviceCopyWith<$Res> get device;$DiagnosticContextCopyWith<$Res>? get context;

}
/// @nodoc
class _$DiagnosticFilesCopyWithImpl<$Res>
    implements $DiagnosticFilesCopyWith<$Res> {
  _$DiagnosticFilesCopyWithImpl(this._self, this._then);

  final DiagnosticFiles _self;
  final $Res Function(DiagnosticFiles) _then;

/// Create a copy of DiagnosticFiles
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? events = null,Object? health = null,Object? plan = null,Object? packages = null,Object? device = null,Object? context = freezed,}) {
  return _then(DiagnosticFiles(
events: null == events ? _self.events : events // ignore: cast_nullable_to_non_nullable
as List<EventLogEntry>,health: null == health ? _self.health : health // ignore: cast_nullable_to_non_nullable
as DiagnosticHealth,plan: null == plan ? _self.plan : plan // ignore: cast_nullable_to_non_nullable
as DiagnosticPlan,packages: null == packages ? _self.packages : packages // ignore: cast_nullable_to_non_nullable
as List<DiagnosticPackage>,device: null == device ? _self.device : device // ignore: cast_nullable_to_non_nullable
as DiagnosticDevice,context: freezed == context ? _self.context : context // ignore: cast_nullable_to_non_nullable
as DiagnosticContext?,
  ));
}
/// Create a copy of DiagnosticFiles
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DiagnosticHealthCopyWith<$Res> get health {
  
  return $DiagnosticHealthCopyWith<$Res>(_self.health, (value) {
    return _then(_self.copyWith(health: value));
  });
}/// Create a copy of DiagnosticFiles
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DiagnosticPlanCopyWith<$Res> get plan {
  
  return $DiagnosticPlanCopyWith<$Res>(_self.plan, (value) {
    return _then(_self.copyWith(plan: value));
  });
}/// Create a copy of DiagnosticFiles
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DiagnosticDeviceCopyWith<$Res> get device {
  
  return $DiagnosticDeviceCopyWith<$Res>(_self.device, (value) {
    return _then(_self.copyWith(device: value));
  });
}/// Create a copy of DiagnosticFiles
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DiagnosticContextCopyWith<$Res>? get context {
    if (_self.context == null) {
    return null;
  }

  return $DiagnosticContextCopyWith<$Res>(_self.context!, (value) {
    return _then(_self.copyWith(context: value));
  });
}
}


/// Adds pattern-matching-related methods to [DiagnosticFiles].
extension DiagnosticFilesPatterns on DiagnosticFiles {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DiagnosticFiles value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DiagnosticFiles() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DiagnosticFiles value)  $default,){
final _that = this;
switch (_that) {
case _DiagnosticFiles():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DiagnosticFiles value)?  $default,){
final _that = this;
switch (_that) {
case _DiagnosticFiles() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'events.jsonl')  List<EventLogEntry> events, @JsonKey(name: 'health.json')  DiagnosticHealth health, @JsonKey(name: 'plan_redacted.json')  DiagnosticPlan plan, @JsonKey(name: 'packages.json')  List<DiagnosticPackage> packages, @JsonKey(name: 'device.json')  DiagnosticDevice device, @JsonKey(name: 'context.json', includeIfNull: true)  DiagnosticContext? context)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DiagnosticFiles() when $default != null:
return $default(_that.events,_that.health,_that.plan,_that.packages,_that.device,_that.context);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'events.jsonl')  List<EventLogEntry> events, @JsonKey(name: 'health.json')  DiagnosticHealth health, @JsonKey(name: 'plan_redacted.json')  DiagnosticPlan plan, @JsonKey(name: 'packages.json')  List<DiagnosticPackage> packages, @JsonKey(name: 'device.json')  DiagnosticDevice device, @JsonKey(name: 'context.json', includeIfNull: true)  DiagnosticContext? context)  $default,) {final _that = this;
switch (_that) {
case _DiagnosticFiles():
return $default(_that.events,_that.health,_that.plan,_that.packages,_that.device,_that.context);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'events.jsonl')  List<EventLogEntry> events, @JsonKey(name: 'health.json')  DiagnosticHealth health, @JsonKey(name: 'plan_redacted.json')  DiagnosticPlan plan, @JsonKey(name: 'packages.json')  List<DiagnosticPackage> packages, @JsonKey(name: 'device.json')  DiagnosticDevice device, @JsonKey(name: 'context.json', includeIfNull: true)  DiagnosticContext? context)?  $default,) {final _that = this;
switch (_that) {
case _DiagnosticFiles() when $default != null:
return $default(_that.events,_that.health,_that.plan,_that.packages,_that.device,_that.context);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DiagnosticFiles implements DiagnosticFiles {
  const _DiagnosticFiles({@JsonKey(name: 'events.jsonl') required  List<EventLogEntry> events, @JsonKey(name: 'health.json') required this.health, @JsonKey(name: 'plan_redacted.json') required this.plan, @JsonKey(name: 'packages.json') required  List<DiagnosticPackage> packages, @JsonKey(name: 'device.json') required this.device, @JsonKey(name: 'context.json', includeIfNull: true) required this.context}): _events = events,_packages = packages;
  factory _DiagnosticFiles.fromJson(Map<String, dynamic> json) => _$DiagnosticFilesFromJson(json);

/// The event-log ring, oldest first.
 final  List<EventLogEntry> _events;
/// The event-log ring, oldest first.
@override@JsonKey(name: 'events.jsonl') List<EventLogEntry> get events {
  if (_events is EqualUnmodifiableListView) return _events;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_events);
}

/// Athan Health as Dart evaluated it.
@override@JsonKey(name: 'health.json') final  DiagnosticHealth health;
/// The applied plan without texts or sounds.
@override@JsonKey(name: 'plan_redacted.json') final  DiagnosticPlan plan;
/// Active packages.
 final  List<DiagnosticPackage> _packages;
/// Active packages.
@override@JsonKey(name: 'packages.json') List<DiagnosticPackage> get packages {
  if (_packages is EqualUnmodifiableListView) return _packages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_packages);
}

/// Device facts.
@override@JsonKey(name: 'device.json') final  DiagnosticDevice device;
/// The active context at 0.01°, or null when there is none.
@override@JsonKey(name: 'context.json', includeIfNull: true) final  DiagnosticContext? context;

/// Create a copy of DiagnosticFiles
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DiagnosticFilesCopyWith<_DiagnosticFiles> get copyWith => __$DiagnosticFilesCopyWithImpl<_DiagnosticFiles>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DiagnosticFilesToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DiagnosticFiles&&const DeepCollectionEquality().equals(other.events, _events)&&(identical(other.health, health) || other.health == health)&&(identical(other.plan, plan) || other.plan == plan)&&const DeepCollectionEquality().equals(other.packages, _packages)&&(identical(other.device, device) || other.device == device)&&(identical(other.context, context) || other.context == context));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_events),health,plan,const DeepCollectionEquality().hash(_packages),device,context);
}

@override
String toString() {
    return 'DiagnosticFiles(events: $events, health: $health, plan: $plan, packages: $packages, device: $device, context: $context)';
}


}

/// @nodoc
abstract mixin class _$DiagnosticFilesCopyWith<$Res> implements $DiagnosticFilesCopyWith<$Res> {
  factory _$DiagnosticFilesCopyWith(_DiagnosticFiles value, $Res Function(_DiagnosticFiles) _then) = __$DiagnosticFilesCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'events.jsonl') List<EventLogEntry> events,@JsonKey(name: 'health.json') DiagnosticHealth health,@JsonKey(name: 'plan_redacted.json') DiagnosticPlan plan,@JsonKey(name: 'packages.json') List<DiagnosticPackage> packages,@JsonKey(name: 'device.json') DiagnosticDevice device,@JsonKey(name: 'context.json', includeIfNull: true) DiagnosticContext? context
});


@override $DiagnosticHealthCopyWith<$Res> get health;@override $DiagnosticPlanCopyWith<$Res> get plan;@override $DiagnosticDeviceCopyWith<$Res> get device;@override $DiagnosticContextCopyWith<$Res>? get context;

}
/// @nodoc
class __$DiagnosticFilesCopyWithImpl<$Res>
    implements _$DiagnosticFilesCopyWith<$Res> {
  __$DiagnosticFilesCopyWithImpl(this._self, this._then);

  final _DiagnosticFiles _self;
  final $Res Function(_DiagnosticFiles) _then;

/// Create a copy of DiagnosticFiles
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? events = null,Object? health = null,Object? plan = null,Object? packages = null,Object? device = null,Object? context = freezed,}) {
  return _then(_DiagnosticFiles(
events: null == events ? _self._events : events // ignore: cast_nullable_to_non_nullable
as List<EventLogEntry>,health: null == health ? _self.health : health // ignore: cast_nullable_to_non_nullable
as DiagnosticHealth,plan: null == plan ? _self.plan : plan // ignore: cast_nullable_to_non_nullable
as DiagnosticPlan,packages: null == packages ? _self._packages : packages // ignore: cast_nullable_to_non_nullable
as List<DiagnosticPackage>,device: null == device ? _self.device : device // ignore: cast_nullable_to_non_nullable
as DiagnosticDevice,context: freezed == context ? _self.context : context // ignore: cast_nullable_to_non_nullable
as DiagnosticContext?,
  ));
}

/// Create a copy of DiagnosticFiles
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DiagnosticHealthCopyWith<$Res> get health {
  
  return $DiagnosticHealthCopyWith<$Res>(_self.health, (value) {
    return _then(_self.copyWith(health: value));
  });
}/// Create a copy of DiagnosticFiles
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DiagnosticPlanCopyWith<$Res> get plan {
  
  return $DiagnosticPlanCopyWith<$Res>(_self.plan, (value) {
    return _then(_self.copyWith(plan: value));
  });
}/// Create a copy of DiagnosticFiles
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DiagnosticDeviceCopyWith<$Res> get device {
  
  return $DiagnosticDeviceCopyWith<$Res>(_self.device, (value) {
    return _then(_self.copyWith(device: value));
  });
}/// Create a copy of DiagnosticFiles
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DiagnosticContextCopyWith<$Res>? get context {
    if (_self.context == null) {
    return null;
  }

  return $DiagnosticContextCopyWith<$Res>(_self.context!, (value) {
    return _then(_self.copyWith(context: value));
  });
}
}

// dart format on
