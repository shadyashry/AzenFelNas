// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'accuracy_approval_document.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AccuracyApprovalDocument {

/// Reviewer.
 String get reviewer;/// Approval date, `YYYY-MM-DD`.
 String get date;
/// Create a copy of AccuracyApprovalDocument
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AccuracyApprovalDocumentCopyWith<AccuracyApprovalDocument> get copyWith => _$AccuracyApprovalDocumentCopyWithImpl<AccuracyApprovalDocument>(this as AccuracyApprovalDocument, _$identity);

  /// Serializes this AccuracyApprovalDocument to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AccuracyApprovalDocument;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AccuracyApprovalDocument&&(identical(other.reviewer, _this.reviewer) || other.reviewer == _this.reviewer)&&(identical(other.date, _this.date) || other.date == _this.date));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AccuracyApprovalDocument;
  return Object.hash(runtimeType,_this.reviewer,_this.date);
}

@override
String toString() {
  final _this = this as AccuracyApprovalDocument;
  return 'AccuracyApprovalDocument(reviewer: ${_this.reviewer}, date: ${_this.date})';
}


}

/// @nodoc
abstract mixin class $AccuracyApprovalDocumentCopyWith<$Res>  {
  factory $AccuracyApprovalDocumentCopyWith(AccuracyApprovalDocument value, $Res Function(AccuracyApprovalDocument) _then) = _$AccuracyApprovalDocumentCopyWithImpl;
@useResult
$Res call({
 String reviewer, String date
});




}
/// @nodoc
class _$AccuracyApprovalDocumentCopyWithImpl<$Res>
    implements $AccuracyApprovalDocumentCopyWith<$Res> {
  _$AccuracyApprovalDocumentCopyWithImpl(this._self, this._then);

  final AccuracyApprovalDocument _self;
  final $Res Function(AccuracyApprovalDocument) _then;

/// Create a copy of AccuracyApprovalDocument
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? reviewer = null,Object? date = null,}) {
  return _then(AccuracyApprovalDocument(
reviewer: null == reviewer ? _self.reviewer : reviewer // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [AccuracyApprovalDocument].
extension AccuracyApprovalDocumentPatterns on AccuracyApprovalDocument {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AccuracyApprovalDocument value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AccuracyApprovalDocument() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AccuracyApprovalDocument value)  $default,){
final _that = this;
switch (_that) {
case _AccuracyApprovalDocument():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AccuracyApprovalDocument value)?  $default,){
final _that = this;
switch (_that) {
case _AccuracyApprovalDocument() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String reviewer,  String date)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AccuracyApprovalDocument() when $default != null:
return $default(_that.reviewer,_that.date);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String reviewer,  String date)  $default,) {final _that = this;
switch (_that) {
case _AccuracyApprovalDocument():
return $default(_that.reviewer,_that.date);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String reviewer,  String date)?  $default,) {final _that = this;
switch (_that) {
case _AccuracyApprovalDocument() when $default != null:
return $default(_that.reviewer,_that.date);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AccuracyApprovalDocument implements AccuracyApprovalDocument {
  const _AccuracyApprovalDocument({required this.reviewer, required this.date});
  factory _AccuracyApprovalDocument.fromJson(Map<String, dynamic> json) => _$AccuracyApprovalDocumentFromJson(json);

/// Reviewer.
@override final  String reviewer;
/// Approval date, `YYYY-MM-DD`.
@override final  String date;

/// Create a copy of AccuracyApprovalDocument
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AccuracyApprovalDocumentCopyWith<_AccuracyApprovalDocument> get copyWith => __$AccuracyApprovalDocumentCopyWithImpl<_AccuracyApprovalDocument>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AccuracyApprovalDocumentToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AccuracyApprovalDocument&&(identical(other.reviewer, reviewer) || other.reviewer == reviewer)&&(identical(other.date, date) || other.date == date));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,reviewer,date);
}

@override
String toString() {
    return 'AccuracyApprovalDocument(reviewer: $reviewer, date: $date)';
}


}

/// @nodoc
abstract mixin class _$AccuracyApprovalDocumentCopyWith<$Res> implements $AccuracyApprovalDocumentCopyWith<$Res> {
  factory _$AccuracyApprovalDocumentCopyWith(_AccuracyApprovalDocument value, $Res Function(_AccuracyApprovalDocument) _then) = __$AccuracyApprovalDocumentCopyWithImpl;
@override @useResult
$Res call({
 String reviewer, String date
});




}
/// @nodoc
class __$AccuracyApprovalDocumentCopyWithImpl<$Res>
    implements _$AccuracyApprovalDocumentCopyWith<$Res> {
  __$AccuracyApprovalDocumentCopyWithImpl(this._self, this._then);

  final _AccuracyApprovalDocument _self;
  final $Res Function(_AccuracyApprovalDocument) _then;

/// Create a copy of AccuracyApprovalDocument
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? reviewer = null,Object? date = null,}) {
  return _then(_AccuracyApprovalDocument(
reviewer: null == reviewer ? _self.reviewer : reviewer // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
