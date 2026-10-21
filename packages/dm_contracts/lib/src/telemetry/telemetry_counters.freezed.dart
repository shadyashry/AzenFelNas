// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'telemetry_counters.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TelemetryCounters {

/// Activations per package type.
 Map<PackageTypeCode, int> get packageActivations;/// Evaluations per health state.
 Map<HealthStateCode, int> get healthState;/// Athan Test outcomes.
 TestResultCounts get testResults;/// Sync outcomes.
 SyncOutcomeCounts get syncOutcome;
/// Create a copy of TelemetryCounters
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TelemetryCountersCopyWith<TelemetryCounters> get copyWith => _$TelemetryCountersCopyWithImpl<TelemetryCounters>(this as TelemetryCounters, _$identity);

  /// Serializes this TelemetryCounters to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as TelemetryCounters;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TelemetryCounters&&const DeepCollectionEquality().equals(other.packageActivations, _this.packageActivations)&&const DeepCollectionEquality().equals(other.healthState, _this.healthState)&&(identical(other.testResults, _this.testResults) || other.testResults == _this.testResults)&&(identical(other.syncOutcome, _this.syncOutcome) || other.syncOutcome == _this.syncOutcome));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as TelemetryCounters;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.packageActivations),const DeepCollectionEquality().hash(_this.healthState),_this.testResults,_this.syncOutcome);
}

@override
String toString() {
  final _this = this as TelemetryCounters;
  return 'TelemetryCounters(packageActivations: ${_this.packageActivations}, healthState: ${_this.healthState}, testResults: ${_this.testResults}, syncOutcome: ${_this.syncOutcome})';
}


}

/// @nodoc
abstract mixin class $TelemetryCountersCopyWith<$Res>  {
  factory $TelemetryCountersCopyWith(TelemetryCounters value, $Res Function(TelemetryCounters) _then) = _$TelemetryCountersCopyWithImpl;
@useResult
$Res call({
 Map<PackageTypeCode, int> packageActivations, Map<HealthStateCode, int> healthState, TestResultCounts testResults, SyncOutcomeCounts syncOutcome
});


$TestResultCountsCopyWith<$Res> get testResults;$SyncOutcomeCountsCopyWith<$Res> get syncOutcome;

}
/// @nodoc
class _$TelemetryCountersCopyWithImpl<$Res>
    implements $TelemetryCountersCopyWith<$Res> {
  _$TelemetryCountersCopyWithImpl(this._self, this._then);

  final TelemetryCounters _self;
  final $Res Function(TelemetryCounters) _then;

/// Create a copy of TelemetryCounters
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? packageActivations = null,Object? healthState = null,Object? testResults = null,Object? syncOutcome = null,}) {
  return _then(TelemetryCounters(
packageActivations: null == packageActivations ? _self.packageActivations : packageActivations // ignore: cast_nullable_to_non_nullable
as Map<PackageTypeCode, int>,healthState: null == healthState ? _self.healthState : healthState // ignore: cast_nullable_to_non_nullable
as Map<HealthStateCode, int>,testResults: null == testResults ? _self.testResults : testResults // ignore: cast_nullable_to_non_nullable
as TestResultCounts,syncOutcome: null == syncOutcome ? _self.syncOutcome : syncOutcome // ignore: cast_nullable_to_non_nullable
as SyncOutcomeCounts,
  ));
}
/// Create a copy of TelemetryCounters
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TestResultCountsCopyWith<$Res> get testResults {
  
  return $TestResultCountsCopyWith<$Res>(_self.testResults, (value) {
    return _then(_self.copyWith(testResults: value));
  });
}/// Create a copy of TelemetryCounters
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SyncOutcomeCountsCopyWith<$Res> get syncOutcome {
  
  return $SyncOutcomeCountsCopyWith<$Res>(_self.syncOutcome, (value) {
    return _then(_self.copyWith(syncOutcome: value));
  });
}
}


/// Adds pattern-matching-related methods to [TelemetryCounters].
extension TelemetryCountersPatterns on TelemetryCounters {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TelemetryCounters value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TelemetryCounters() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TelemetryCounters value)  $default,){
final _that = this;
switch (_that) {
case _TelemetryCounters():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TelemetryCounters value)?  $default,){
final _that = this;
switch (_that) {
case _TelemetryCounters() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Map<PackageTypeCode, int> packageActivations,  Map<HealthStateCode, int> healthState,  TestResultCounts testResults,  SyncOutcomeCounts syncOutcome)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TelemetryCounters() when $default != null:
return $default(_that.packageActivations,_that.healthState,_that.testResults,_that.syncOutcome);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Map<PackageTypeCode, int> packageActivations,  Map<HealthStateCode, int> healthState,  TestResultCounts testResults,  SyncOutcomeCounts syncOutcome)  $default,) {final _that = this;
switch (_that) {
case _TelemetryCounters():
return $default(_that.packageActivations,_that.healthState,_that.testResults,_that.syncOutcome);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Map<PackageTypeCode, int> packageActivations,  Map<HealthStateCode, int> healthState,  TestResultCounts testResults,  SyncOutcomeCounts syncOutcome)?  $default,) {final _that = this;
switch (_that) {
case _TelemetryCounters() when $default != null:
return $default(_that.packageActivations,_that.healthState,_that.testResults,_that.syncOutcome);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TelemetryCounters implements TelemetryCounters {
  const _TelemetryCounters({required  Map<PackageTypeCode, int> packageActivations, required  Map<HealthStateCode, int> healthState, required this.testResults, required this.syncOutcome}): _packageActivations = packageActivations,_healthState = healthState;
  factory _TelemetryCounters.fromJson(Map<String, dynamic> json) => _$TelemetryCountersFromJson(json);

/// Activations per package type.
 final  Map<PackageTypeCode, int> _packageActivations;
/// Activations per package type.
@override Map<PackageTypeCode, int> get packageActivations {
  if (_packageActivations is EqualUnmodifiableMapView) return _packageActivations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_packageActivations);
}

/// Evaluations per health state.
 final  Map<HealthStateCode, int> _healthState;
/// Evaluations per health state.
@override Map<HealthStateCode, int> get healthState {
  if (_healthState is EqualUnmodifiableMapView) return _healthState;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_healthState);
}

/// Athan Test outcomes.
@override final  TestResultCounts testResults;
/// Sync outcomes.
@override final  SyncOutcomeCounts syncOutcome;

/// Create a copy of TelemetryCounters
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TelemetryCountersCopyWith<_TelemetryCounters> get copyWith => __$TelemetryCountersCopyWithImpl<_TelemetryCounters>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TelemetryCountersToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TelemetryCounters&&const DeepCollectionEquality().equals(other.packageActivations, _packageActivations)&&const DeepCollectionEquality().equals(other.healthState, _healthState)&&(identical(other.testResults, testResults) || other.testResults == testResults)&&(identical(other.syncOutcome, syncOutcome) || other.syncOutcome == syncOutcome));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_packageActivations),const DeepCollectionEquality().hash(_healthState),testResults,syncOutcome);
}

@override
String toString() {
    return 'TelemetryCounters(packageActivations: $packageActivations, healthState: $healthState, testResults: $testResults, syncOutcome: $syncOutcome)';
}


}

/// @nodoc
abstract mixin class _$TelemetryCountersCopyWith<$Res> implements $TelemetryCountersCopyWith<$Res> {
  factory _$TelemetryCountersCopyWith(_TelemetryCounters value, $Res Function(_TelemetryCounters) _then) = __$TelemetryCountersCopyWithImpl;
@override @useResult
$Res call({
 Map<PackageTypeCode, int> packageActivations, Map<HealthStateCode, int> healthState, TestResultCounts testResults, SyncOutcomeCounts syncOutcome
});


@override $TestResultCountsCopyWith<$Res> get testResults;@override $SyncOutcomeCountsCopyWith<$Res> get syncOutcome;

}
/// @nodoc
class __$TelemetryCountersCopyWithImpl<$Res>
    implements _$TelemetryCountersCopyWith<$Res> {
  __$TelemetryCountersCopyWithImpl(this._self, this._then);

  final _TelemetryCounters _self;
  final $Res Function(_TelemetryCounters) _then;

/// Create a copy of TelemetryCounters
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? packageActivations = null,Object? healthState = null,Object? testResults = null,Object? syncOutcome = null,}) {
  return _then(_TelemetryCounters(
packageActivations: null == packageActivations ? _self._packageActivations : packageActivations // ignore: cast_nullable_to_non_nullable
as Map<PackageTypeCode, int>,healthState: null == healthState ? _self._healthState : healthState // ignore: cast_nullable_to_non_nullable
as Map<HealthStateCode, int>,testResults: null == testResults ? _self.testResults : testResults // ignore: cast_nullable_to_non_nullable
as TestResultCounts,syncOutcome: null == syncOutcome ? _self.syncOutcome : syncOutcome // ignore: cast_nullable_to_non_nullable
as SyncOutcomeCounts,
  ));
}

/// Create a copy of TelemetryCounters
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TestResultCountsCopyWith<$Res> get testResults {
  
  return $TestResultCountsCopyWith<$Res>(_self.testResults, (value) {
    return _then(_self.copyWith(testResults: value));
  });
}/// Create a copy of TelemetryCounters
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SyncOutcomeCountsCopyWith<$Res> get syncOutcome {
  
  return $SyncOutcomeCountsCopyWith<$Res>(_self.syncOutcome, (value) {
    return _then(_self.copyWith(syncOutcome: value));
  });
}
}

// dart format on
