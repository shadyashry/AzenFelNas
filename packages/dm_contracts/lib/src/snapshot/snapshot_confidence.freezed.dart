// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'snapshot_confidence.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SnapshotConfidence {

/// Label kind.
 ConfidenceKindCode get kind;/// Report id, source, range, count or reason (REQ-UX-001).
 String? get detail;
/// Create a copy of SnapshotConfidence
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnapshotConfidenceCopyWith<SnapshotConfidence> get copyWith => _$SnapshotConfidenceCopyWithImpl<SnapshotConfidence>(this as SnapshotConfidence, _$identity);

  /// Serializes this SnapshotConfidence to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SnapshotConfidence;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnapshotConfidence&&(identical(other.kind, _this.kind) || other.kind == _this.kind)&&(identical(other.detail, _this.detail) || other.detail == _this.detail));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SnapshotConfidence;
  return Object.hash(runtimeType,_this.kind,_this.detail);
}

@override
String toString() {
  final _this = this as SnapshotConfidence;
  return 'SnapshotConfidence(kind: ${_this.kind}, detail: ${_this.detail})';
}


}

/// @nodoc
abstract mixin class $SnapshotConfidenceCopyWith<$Res>  {
  factory $SnapshotConfidenceCopyWith(SnapshotConfidence value, $Res Function(SnapshotConfidence) _then) = _$SnapshotConfidenceCopyWithImpl;
@useResult
$Res call({
 ConfidenceKindCode kind, String? detail
});




}
/// @nodoc
class _$SnapshotConfidenceCopyWithImpl<$Res>
    implements $SnapshotConfidenceCopyWith<$Res> {
  _$SnapshotConfidenceCopyWithImpl(this._self, this._then);

  final SnapshotConfidence _self;
  final $Res Function(SnapshotConfidence) _then;

/// Create a copy of SnapshotConfidence
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? kind = null,Object? detail = freezed,}) {
  return _then(SnapshotConfidence(
kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as ConfidenceKindCode,detail: freezed == detail ? _self.detail : detail // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [SnapshotConfidence].
extension SnapshotConfidencePatterns on SnapshotConfidence {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnapshotConfidence value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnapshotConfidence() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnapshotConfidence value)  $default,){
final _that = this;
switch (_that) {
case _SnapshotConfidence():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnapshotConfidence value)?  $default,){
final _that = this;
switch (_that) {
case _SnapshotConfidence() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ConfidenceKindCode kind,  String? detail)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnapshotConfidence() when $default != null:
return $default(_that.kind,_that.detail);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ConfidenceKindCode kind,  String? detail)  $default,) {final _that = this;
switch (_that) {
case _SnapshotConfidence():
return $default(_that.kind,_that.detail);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ConfidenceKindCode kind,  String? detail)?  $default,) {final _that = this;
switch (_that) {
case _SnapshotConfidence() when $default != null:
return $default(_that.kind,_that.detail);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnapshotConfidence implements SnapshotConfidence {
  const _SnapshotConfidence({required this.kind, this.detail});
  factory _SnapshotConfidence.fromJson(Map<String, dynamic> json) => _$SnapshotConfidenceFromJson(json);

/// Label kind.
@override final  ConfidenceKindCode kind;
/// Report id, source, range, count or reason (REQ-UX-001).
@override final  String? detail;

/// Create a copy of SnapshotConfidence
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnapshotConfidenceCopyWith<_SnapshotConfidence> get copyWith => __$SnapshotConfidenceCopyWithImpl<_SnapshotConfidence>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnapshotConfidenceToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnapshotConfidence&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.detail, detail) || other.detail == detail));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,kind,detail);
}

@override
String toString() {
    return 'SnapshotConfidence(kind: $kind, detail: $detail)';
}


}

/// @nodoc
abstract mixin class _$SnapshotConfidenceCopyWith<$Res> implements $SnapshotConfidenceCopyWith<$Res> {
  factory _$SnapshotConfidenceCopyWith(_SnapshotConfidence value, $Res Function(_SnapshotConfidence) _then) = __$SnapshotConfidenceCopyWithImpl;
@override @useResult
$Res call({
 ConfidenceKindCode kind, String? detail
});




}
/// @nodoc
class __$SnapshotConfidenceCopyWithImpl<$Res>
    implements _$SnapshotConfidenceCopyWith<$Res> {
  __$SnapshotConfidenceCopyWithImpl(this._self, this._then);

  final _SnapshotConfidence _self;
  final $Res Function(_SnapshotConfidence) _then;

/// Create a copy of SnapshotConfidence
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? kind = null,Object? detail = freezed,}) {
  return _then(_SnapshotConfidence(
kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as ConfidenceKindCode,detail: freezed == detail ? _self.detail : detail // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
