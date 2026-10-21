// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bench_failure_detail_document.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BenchFailureDetailDocument {

/// Appendix J code (REQ-ERR-002).
@FailureCodeConverter() FailureCode get code;/// One-line detail; never coordinates (REQ-PRIV-001).
 String? get detail;
/// Create a copy of BenchFailureDetailDocument
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BenchFailureDetailDocumentCopyWith<BenchFailureDetailDocument> get copyWith => _$BenchFailureDetailDocumentCopyWithImpl<BenchFailureDetailDocument>(this as BenchFailureDetailDocument, _$identity);

  /// Serializes this BenchFailureDetailDocument to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as BenchFailureDetailDocument;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BenchFailureDetailDocument&&(identical(other.code, _this.code) || other.code == _this.code)&&(identical(other.detail, _this.detail) || other.detail == _this.detail));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as BenchFailureDetailDocument;
  return Object.hash(runtimeType,_this.code,_this.detail);
}

@override
String toString() {
  final _this = this as BenchFailureDetailDocument;
  return 'BenchFailureDetailDocument(code: ${_this.code}, detail: ${_this.detail})';
}


}

/// @nodoc
abstract mixin class $BenchFailureDetailDocumentCopyWith<$Res>  {
  factory $BenchFailureDetailDocumentCopyWith(BenchFailureDetailDocument value, $Res Function(BenchFailureDetailDocument) _then) = _$BenchFailureDetailDocumentCopyWithImpl;
@useResult
$Res call({
@FailureCodeConverter() FailureCode code, String? detail
});




}
/// @nodoc
class _$BenchFailureDetailDocumentCopyWithImpl<$Res>
    implements $BenchFailureDetailDocumentCopyWith<$Res> {
  _$BenchFailureDetailDocumentCopyWithImpl(this._self, this._then);

  final BenchFailureDetailDocument _self;
  final $Res Function(BenchFailureDetailDocument) _then;

/// Create a copy of BenchFailureDetailDocument
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? code = null,Object? detail = freezed,}) {
  return _then(BenchFailureDetailDocument(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as FailureCode,detail: freezed == detail ? _self.detail : detail // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [BenchFailureDetailDocument].
extension BenchFailureDetailDocumentPatterns on BenchFailureDetailDocument {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BenchFailureDetailDocument value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BenchFailureDetailDocument() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BenchFailureDetailDocument value)  $default,){
final _that = this;
switch (_that) {
case _BenchFailureDetailDocument():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BenchFailureDetailDocument value)?  $default,){
final _that = this;
switch (_that) {
case _BenchFailureDetailDocument() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@FailureCodeConverter()  FailureCode code,  String? detail)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BenchFailureDetailDocument() when $default != null:
return $default(_that.code,_that.detail);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@FailureCodeConverter()  FailureCode code,  String? detail)  $default,) {final _that = this;
switch (_that) {
case _BenchFailureDetailDocument():
return $default(_that.code,_that.detail);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@FailureCodeConverter()  FailureCode code,  String? detail)?  $default,) {final _that = this;
switch (_that) {
case _BenchFailureDetailDocument() when $default != null:
return $default(_that.code,_that.detail);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BenchFailureDetailDocument implements BenchFailureDetailDocument {
  const _BenchFailureDetailDocument({@FailureCodeConverter() required this.code, this.detail});
  factory _BenchFailureDetailDocument.fromJson(Map<String, dynamic> json) => _$BenchFailureDetailDocumentFromJson(json);

/// Appendix J code (REQ-ERR-002).
@override@FailureCodeConverter() final  FailureCode code;
/// One-line detail; never coordinates (REQ-PRIV-001).
@override final  String? detail;

/// Create a copy of BenchFailureDetailDocument
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BenchFailureDetailDocumentCopyWith<_BenchFailureDetailDocument> get copyWith => __$BenchFailureDetailDocumentCopyWithImpl<_BenchFailureDetailDocument>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BenchFailureDetailDocumentToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _BenchFailureDetailDocument&&(identical(other.code, code) || other.code == code)&&(identical(other.detail, detail) || other.detail == detail));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,code,detail);
}

@override
String toString() {
    return 'BenchFailureDetailDocument(code: $code, detail: $detail)';
}


}

/// @nodoc
abstract mixin class _$BenchFailureDetailDocumentCopyWith<$Res> implements $BenchFailureDetailDocumentCopyWith<$Res> {
  factory _$BenchFailureDetailDocumentCopyWith(_BenchFailureDetailDocument value, $Res Function(_BenchFailureDetailDocument) _then) = __$BenchFailureDetailDocumentCopyWithImpl;
@override @useResult
$Res call({
@FailureCodeConverter() FailureCode code, String? detail
});




}
/// @nodoc
class __$BenchFailureDetailDocumentCopyWithImpl<$Res>
    implements _$BenchFailureDetailDocumentCopyWith<$Res> {
  __$BenchFailureDetailDocumentCopyWithImpl(this._self, this._then);

  final _BenchFailureDetailDocument _self;
  final $Res Function(_BenchFailureDetailDocument) _then;

/// Create a copy of BenchFailureDetailDocument
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? code = null,Object? detail = freezed,}) {
  return _then(_BenchFailureDetailDocument(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as FailureCode,detail: freezed == detail ? _self.detail : detail // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
