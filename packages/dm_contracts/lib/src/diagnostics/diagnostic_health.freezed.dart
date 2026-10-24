// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'diagnostic_health.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DiagnosticHealth {

/// Delivery path.
 DiagnosticDeliveryPath get path;/// Derived state.
 DiagnosticHealthState get state;/// Reason names, in display order.
 List<String> get reasons;/// Probes in native order.
 List<DiagnosticProbe> get probes;/// UTC epoch ms of the native evaluation.
 int get evaluatedAtUtcMs;
/// Create a copy of DiagnosticHealth
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DiagnosticHealthCopyWith<DiagnosticHealth> get copyWith => _$DiagnosticHealthCopyWithImpl<DiagnosticHealth>(this as DiagnosticHealth, _$identity);

  /// Serializes this DiagnosticHealth to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as DiagnosticHealth;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DiagnosticHealth&&(identical(other.path, _this.path) || other.path == _this.path)&&(identical(other.state, _this.state) || other.state == _this.state)&&const DeepCollectionEquality().equals(other.reasons, _this.reasons)&&const DeepCollectionEquality().equals(other.probes, _this.probes)&&(identical(other.evaluatedAtUtcMs, _this.evaluatedAtUtcMs) || other.evaluatedAtUtcMs == _this.evaluatedAtUtcMs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as DiagnosticHealth;
  return Object.hash(runtimeType,_this.path,_this.state,const DeepCollectionEquality().hash(_this.reasons),const DeepCollectionEquality().hash(_this.probes),_this.evaluatedAtUtcMs);
}

@override
String toString() {
  final _this = this as DiagnosticHealth;
  return 'DiagnosticHealth(path: ${_this.path}, state: ${_this.state}, reasons: ${_this.reasons}, probes: ${_this.probes}, evaluatedAtUtcMs: ${_this.evaluatedAtUtcMs})';
}


}

/// @nodoc
abstract mixin class $DiagnosticHealthCopyWith<$Res>  {
  factory $DiagnosticHealthCopyWith(DiagnosticHealth value, $Res Function(DiagnosticHealth) _then) = _$DiagnosticHealthCopyWithImpl;
@useResult
$Res call({
 DiagnosticDeliveryPath path, DiagnosticHealthState state, List<String> reasons, List<DiagnosticProbe> probes, int evaluatedAtUtcMs
});




}
/// @nodoc
class _$DiagnosticHealthCopyWithImpl<$Res>
    implements $DiagnosticHealthCopyWith<$Res> {
  _$DiagnosticHealthCopyWithImpl(this._self, this._then);

  final DiagnosticHealth _self;
  final $Res Function(DiagnosticHealth) _then;

/// Create a copy of DiagnosticHealth
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? path = null,Object? state = null,Object? reasons = null,Object? probes = null,Object? evaluatedAtUtcMs = null,}) {
  return _then(DiagnosticHealth(
path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as DiagnosticDeliveryPath,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as DiagnosticHealthState,reasons: null == reasons ? _self.reasons : reasons // ignore: cast_nullable_to_non_nullable
as List<String>,probes: null == probes ? _self.probes : probes // ignore: cast_nullable_to_non_nullable
as List<DiagnosticProbe>,evaluatedAtUtcMs: null == evaluatedAtUtcMs ? _self.evaluatedAtUtcMs : evaluatedAtUtcMs // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [DiagnosticHealth].
extension DiagnosticHealthPatterns on DiagnosticHealth {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DiagnosticHealth value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DiagnosticHealth() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DiagnosticHealth value)  $default,){
final _that = this;
switch (_that) {
case _DiagnosticHealth():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DiagnosticHealth value)?  $default,){
final _that = this;
switch (_that) {
case _DiagnosticHealth() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DiagnosticDeliveryPath path,  DiagnosticHealthState state,  List<String> reasons,  List<DiagnosticProbe> probes,  int evaluatedAtUtcMs)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DiagnosticHealth() when $default != null:
return $default(_that.path,_that.state,_that.reasons,_that.probes,_that.evaluatedAtUtcMs);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DiagnosticDeliveryPath path,  DiagnosticHealthState state,  List<String> reasons,  List<DiagnosticProbe> probes,  int evaluatedAtUtcMs)  $default,) {final _that = this;
switch (_that) {
case _DiagnosticHealth():
return $default(_that.path,_that.state,_that.reasons,_that.probes,_that.evaluatedAtUtcMs);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DiagnosticDeliveryPath path,  DiagnosticHealthState state,  List<String> reasons,  List<DiagnosticProbe> probes,  int evaluatedAtUtcMs)?  $default,) {final _that = this;
switch (_that) {
case _DiagnosticHealth() when $default != null:
return $default(_that.path,_that.state,_that.reasons,_that.probes,_that.evaluatedAtUtcMs);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DiagnosticHealth implements DiagnosticHealth {
  const _DiagnosticHealth({required this.path, required this.state, required  List<String> reasons, required  List<DiagnosticProbe> probes, required this.evaluatedAtUtcMs}): _reasons = reasons,_probes = probes;
  factory _DiagnosticHealth.fromJson(Map<String, dynamic> json) => _$DiagnosticHealthFromJson(json);

/// Delivery path.
@override final  DiagnosticDeliveryPath path;
/// Derived state.
@override final  DiagnosticHealthState state;
/// Reason names, in display order.
 final  List<String> _reasons;
/// Reason names, in display order.
@override List<String> get reasons {
  if (_reasons is EqualUnmodifiableListView) return _reasons;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_reasons);
}

/// Probes in native order.
 final  List<DiagnosticProbe> _probes;
/// Probes in native order.
@override List<DiagnosticProbe> get probes {
  if (_probes is EqualUnmodifiableListView) return _probes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_probes);
}

/// UTC epoch ms of the native evaluation.
@override final  int evaluatedAtUtcMs;

/// Create a copy of DiagnosticHealth
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DiagnosticHealthCopyWith<_DiagnosticHealth> get copyWith => __$DiagnosticHealthCopyWithImpl<_DiagnosticHealth>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DiagnosticHealthToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DiagnosticHealth&&(identical(other.path, path) || other.path == path)&&(identical(other.state, state) || other.state == state)&&const DeepCollectionEquality().equals(other.reasons, _reasons)&&const DeepCollectionEquality().equals(other.probes, _probes)&&(identical(other.evaluatedAtUtcMs, evaluatedAtUtcMs) || other.evaluatedAtUtcMs == evaluatedAtUtcMs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,path,state,const DeepCollectionEquality().hash(_reasons),const DeepCollectionEquality().hash(_probes),evaluatedAtUtcMs);
}

@override
String toString() {
    return 'DiagnosticHealth(path: $path, state: $state, reasons: $reasons, probes: $probes, evaluatedAtUtcMs: $evaluatedAtUtcMs)';
}


}

/// @nodoc
abstract mixin class _$DiagnosticHealthCopyWith<$Res> implements $DiagnosticHealthCopyWith<$Res> {
  factory _$DiagnosticHealthCopyWith(_DiagnosticHealth value, $Res Function(_DiagnosticHealth) _then) = __$DiagnosticHealthCopyWithImpl;
@override @useResult
$Res call({
 DiagnosticDeliveryPath path, DiagnosticHealthState state, List<String> reasons, List<DiagnosticProbe> probes, int evaluatedAtUtcMs
});




}
/// @nodoc
class __$DiagnosticHealthCopyWithImpl<$Res>
    implements _$DiagnosticHealthCopyWith<$Res> {
  __$DiagnosticHealthCopyWithImpl(this._self, this._then);

  final _DiagnosticHealth _self;
  final $Res Function(_DiagnosticHealth) _then;

/// Create a copy of DiagnosticHealth
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? path = null,Object? state = null,Object? reasons = null,Object? probes = null,Object? evaluatedAtUtcMs = null,}) {
  return _then(_DiagnosticHealth(
path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as DiagnosticDeliveryPath,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as DiagnosticHealthState,reasons: null == reasons ? _self._reasons : reasons // ignore: cast_nullable_to_non_nullable
as List<String>,probes: null == probes ? _self._probes : probes // ignore: cast_nullable_to_non_nullable
as List<DiagnosticProbe>,evaluatedAtUtcMs: null == evaluatedAtUtcMs ? _self.evaluatedAtUtcMs : evaluatedAtUtcMs // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$DiagnosticProbe {

/// Probe name.
 String get name;/// The outcome; null when the platform could not tell.
@JsonKey(includeIfNull: true) bool? get positive;
/// Create a copy of DiagnosticProbe
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DiagnosticProbeCopyWith<DiagnosticProbe> get copyWith => _$DiagnosticProbeCopyWithImpl<DiagnosticProbe>(this as DiagnosticProbe, _$identity);

  /// Serializes this DiagnosticProbe to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as DiagnosticProbe;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DiagnosticProbe&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.positive, _this.positive) || other.positive == _this.positive));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as DiagnosticProbe;
  return Object.hash(runtimeType,_this.name,_this.positive);
}

@override
String toString() {
  final _this = this as DiagnosticProbe;
  return 'DiagnosticProbe(name: ${_this.name}, positive: ${_this.positive})';
}


}

/// @nodoc
abstract mixin class $DiagnosticProbeCopyWith<$Res>  {
  factory $DiagnosticProbeCopyWith(DiagnosticProbe value, $Res Function(DiagnosticProbe) _then) = _$DiagnosticProbeCopyWithImpl;
@useResult
$Res call({
 String name,@JsonKey(includeIfNull: true) bool? positive
});




}
/// @nodoc
class _$DiagnosticProbeCopyWithImpl<$Res>
    implements $DiagnosticProbeCopyWith<$Res> {
  _$DiagnosticProbeCopyWithImpl(this._self, this._then);

  final DiagnosticProbe _self;
  final $Res Function(DiagnosticProbe) _then;

/// Create a copy of DiagnosticProbe
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? positive = freezed,}) {
  return _then(DiagnosticProbe(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,positive: freezed == positive ? _self.positive : positive // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}

}


/// Adds pattern-matching-related methods to [DiagnosticProbe].
extension DiagnosticProbePatterns on DiagnosticProbe {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DiagnosticProbe value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DiagnosticProbe() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DiagnosticProbe value)  $default,){
final _that = this;
switch (_that) {
case _DiagnosticProbe():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DiagnosticProbe value)?  $default,){
final _that = this;
switch (_that) {
case _DiagnosticProbe() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name, @JsonKey(includeIfNull: true)  bool? positive)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DiagnosticProbe() when $default != null:
return $default(_that.name,_that.positive);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name, @JsonKey(includeIfNull: true)  bool? positive)  $default,) {final _that = this;
switch (_that) {
case _DiagnosticProbe():
return $default(_that.name,_that.positive);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name, @JsonKey(includeIfNull: true)  bool? positive)?  $default,) {final _that = this;
switch (_that) {
case _DiagnosticProbe() when $default != null:
return $default(_that.name,_that.positive);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DiagnosticProbe implements DiagnosticProbe {
  const _DiagnosticProbe({required this.name, @JsonKey(includeIfNull: true) required this.positive});
  factory _DiagnosticProbe.fromJson(Map<String, dynamic> json) => _$DiagnosticProbeFromJson(json);

/// Probe name.
@override final  String name;
/// The outcome; null when the platform could not tell.
@override@JsonKey(includeIfNull: true) final  bool? positive;

/// Create a copy of DiagnosticProbe
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DiagnosticProbeCopyWith<_DiagnosticProbe> get copyWith => __$DiagnosticProbeCopyWithImpl<_DiagnosticProbe>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DiagnosticProbeToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DiagnosticProbe&&(identical(other.name, name) || other.name == name)&&(identical(other.positive, positive) || other.positive == positive));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,name,positive);
}

@override
String toString() {
    return 'DiagnosticProbe(name: $name, positive: $positive)';
}


}

/// @nodoc
abstract mixin class _$DiagnosticProbeCopyWith<$Res> implements $DiagnosticProbeCopyWith<$Res> {
  factory _$DiagnosticProbeCopyWith(_DiagnosticProbe value, $Res Function(_DiagnosticProbe) _then) = __$DiagnosticProbeCopyWithImpl;
@override @useResult
$Res call({
 String name,@JsonKey(includeIfNull: true) bool? positive
});




}
/// @nodoc
class __$DiagnosticProbeCopyWithImpl<$Res>
    implements _$DiagnosticProbeCopyWith<$Res> {
  __$DiagnosticProbeCopyWithImpl(this._self, this._then);

  final _DiagnosticProbe _self;
  final $Res Function(_DiagnosticProbe) _then;

/// Create a copy of DiagnosticProbe
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? positive = freezed,}) {
  return _then(_DiagnosticProbe(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,positive: freezed == positive ? _self.positive : positive // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}


}

// dart format on
