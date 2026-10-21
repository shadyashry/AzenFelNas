// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bench_failure_document.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BenchFailureDocument {

/// Schema version; 1.
 int get schemaVersion;/// The failure.
 BenchFailureDetailDocument get failure;
/// Create a copy of BenchFailureDocument
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BenchFailureDocumentCopyWith<BenchFailureDocument> get copyWith => _$BenchFailureDocumentCopyWithImpl<BenchFailureDocument>(this as BenchFailureDocument, _$identity);

  /// Serializes this BenchFailureDocument to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as BenchFailureDocument;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BenchFailureDocument&&(identical(other.schemaVersion, _this.schemaVersion) || other.schemaVersion == _this.schemaVersion)&&(identical(other.failure, _this.failure) || other.failure == _this.failure));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as BenchFailureDocument;
  return Object.hash(runtimeType,_this.schemaVersion,_this.failure);
}

@override
String toString() {
  final _this = this as BenchFailureDocument;
  return 'BenchFailureDocument(schemaVersion: ${_this.schemaVersion}, failure: ${_this.failure})';
}


}

/// @nodoc
abstract mixin class $BenchFailureDocumentCopyWith<$Res>  {
  factory $BenchFailureDocumentCopyWith(BenchFailureDocument value, $Res Function(BenchFailureDocument) _then) = _$BenchFailureDocumentCopyWithImpl;
@useResult
$Res call({
 int schemaVersion, BenchFailureDetailDocument failure
});


$BenchFailureDetailDocumentCopyWith<$Res> get failure;

}
/// @nodoc
class _$BenchFailureDocumentCopyWithImpl<$Res>
    implements $BenchFailureDocumentCopyWith<$Res> {
  _$BenchFailureDocumentCopyWithImpl(this._self, this._then);

  final BenchFailureDocument _self;
  final $Res Function(BenchFailureDocument) _then;

/// Create a copy of BenchFailureDocument
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? schemaVersion = null,Object? failure = null,}) {
  return _then(BenchFailureDocument(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,failure: null == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as BenchFailureDetailDocument,
  ));
}
/// Create a copy of BenchFailureDocument
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BenchFailureDetailDocumentCopyWith<$Res> get failure {
  
  return $BenchFailureDetailDocumentCopyWith<$Res>(_self.failure, (value) {
    return _then(_self.copyWith(failure: value));
  });
}
}


/// Adds pattern-matching-related methods to [BenchFailureDocument].
extension BenchFailureDocumentPatterns on BenchFailureDocument {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BenchFailureDocument value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BenchFailureDocument() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BenchFailureDocument value)  $default,){
final _that = this;
switch (_that) {
case _BenchFailureDocument():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BenchFailureDocument value)?  $default,){
final _that = this;
switch (_that) {
case _BenchFailureDocument() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int schemaVersion,  BenchFailureDetailDocument failure)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BenchFailureDocument() when $default != null:
return $default(_that.schemaVersion,_that.failure);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int schemaVersion,  BenchFailureDetailDocument failure)  $default,) {final _that = this;
switch (_that) {
case _BenchFailureDocument():
return $default(_that.schemaVersion,_that.failure);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int schemaVersion,  BenchFailureDetailDocument failure)?  $default,) {final _that = this;
switch (_that) {
case _BenchFailureDocument() when $default != null:
return $default(_that.schemaVersion,_that.failure);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BenchFailureDocument implements BenchFailureDocument {
  const _BenchFailureDocument({required this.schemaVersion, required this.failure});
  factory _BenchFailureDocument.fromJson(Map<String, dynamic> json) => _$BenchFailureDocumentFromJson(json);

/// Schema version; 1.
@override final  int schemaVersion;
/// The failure.
@override final  BenchFailureDetailDocument failure;

/// Create a copy of BenchFailureDocument
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BenchFailureDocumentCopyWith<_BenchFailureDocument> get copyWith => __$BenchFailureDocumentCopyWithImpl<_BenchFailureDocument>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BenchFailureDocumentToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _BenchFailureDocument&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.failure, failure) || other.failure == failure));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,schemaVersion,failure);
}

@override
String toString() {
    return 'BenchFailureDocument(schemaVersion: $schemaVersion, failure: $failure)';
}


}

/// @nodoc
abstract mixin class _$BenchFailureDocumentCopyWith<$Res> implements $BenchFailureDocumentCopyWith<$Res> {
  factory _$BenchFailureDocumentCopyWith(_BenchFailureDocument value, $Res Function(_BenchFailureDocument) _then) = __$BenchFailureDocumentCopyWithImpl;
@override @useResult
$Res call({
 int schemaVersion, BenchFailureDetailDocument failure
});


@override $BenchFailureDetailDocumentCopyWith<$Res> get failure;

}
/// @nodoc
class __$BenchFailureDocumentCopyWithImpl<$Res>
    implements _$BenchFailureDocumentCopyWith<$Res> {
  __$BenchFailureDocumentCopyWithImpl(this._self, this._then);

  final _BenchFailureDocument _self;
  final $Res Function(_BenchFailureDocument) _then;

/// Create a copy of BenchFailureDocument
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? schemaVersion = null,Object? failure = null,}) {
  return _then(_BenchFailureDocument(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,failure: null == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as BenchFailureDetailDocument,
  ));
}

/// Create a copy of BenchFailureDocument
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BenchFailureDetailDocumentCopyWith<$Res> get failure {
  
  return $BenchFailureDetailDocumentCopyWith<$Res>(_self.failure, (value) {
    return _then(_self.copyWith(failure: value));
  });
}
}

// dart format on
