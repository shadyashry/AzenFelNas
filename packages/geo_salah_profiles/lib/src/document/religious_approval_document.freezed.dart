// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'religious_approval_document.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ReligiousApprovalDocument {

/// Reviewer.
 String get reviewer;/// Reviewer qualification.
 String get qualification;/// Approval date, `YYYY-MM-DD`.
 String get date;/// What was approved, e.g. `rules`, `rounding`.
 List<String> get scope;
/// Create a copy of ReligiousApprovalDocument
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReligiousApprovalDocumentCopyWith<ReligiousApprovalDocument> get copyWith => _$ReligiousApprovalDocumentCopyWithImpl<ReligiousApprovalDocument>(this as ReligiousApprovalDocument, _$identity);

  /// Serializes this ReligiousApprovalDocument to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ReligiousApprovalDocument;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReligiousApprovalDocument&&(identical(other.reviewer, _this.reviewer) || other.reviewer == _this.reviewer)&&(identical(other.qualification, _this.qualification) || other.qualification == _this.qualification)&&(identical(other.date, _this.date) || other.date == _this.date)&&const DeepCollectionEquality().equals(other.scope, _this.scope));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ReligiousApprovalDocument;
  return Object.hash(runtimeType,_this.reviewer,_this.qualification,_this.date,const DeepCollectionEquality().hash(_this.scope));
}

@override
String toString() {
  final _this = this as ReligiousApprovalDocument;
  return 'ReligiousApprovalDocument(reviewer: ${_this.reviewer}, qualification: ${_this.qualification}, date: ${_this.date}, scope: ${_this.scope})';
}


}

/// @nodoc
abstract mixin class $ReligiousApprovalDocumentCopyWith<$Res>  {
  factory $ReligiousApprovalDocumentCopyWith(ReligiousApprovalDocument value, $Res Function(ReligiousApprovalDocument) _then) = _$ReligiousApprovalDocumentCopyWithImpl;
@useResult
$Res call({
 String reviewer, String qualification, String date, List<String> scope
});




}
/// @nodoc
class _$ReligiousApprovalDocumentCopyWithImpl<$Res>
    implements $ReligiousApprovalDocumentCopyWith<$Res> {
  _$ReligiousApprovalDocumentCopyWithImpl(this._self, this._then);

  final ReligiousApprovalDocument _self;
  final $Res Function(ReligiousApprovalDocument) _then;

/// Create a copy of ReligiousApprovalDocument
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? reviewer = null,Object? qualification = null,Object? date = null,Object? scope = null,}) {
  return _then(ReligiousApprovalDocument(
reviewer: null == reviewer ? _self.reviewer : reviewer // ignore: cast_nullable_to_non_nullable
as String,qualification: null == qualification ? _self.qualification : qualification // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,scope: null == scope ? _self.scope : scope // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [ReligiousApprovalDocument].
extension ReligiousApprovalDocumentPatterns on ReligiousApprovalDocument {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReligiousApprovalDocument value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReligiousApprovalDocument() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReligiousApprovalDocument value)  $default,){
final _that = this;
switch (_that) {
case _ReligiousApprovalDocument():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReligiousApprovalDocument value)?  $default,){
final _that = this;
switch (_that) {
case _ReligiousApprovalDocument() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String reviewer,  String qualification,  String date,  List<String> scope)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReligiousApprovalDocument() when $default != null:
return $default(_that.reviewer,_that.qualification,_that.date,_that.scope);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String reviewer,  String qualification,  String date,  List<String> scope)  $default,) {final _that = this;
switch (_that) {
case _ReligiousApprovalDocument():
return $default(_that.reviewer,_that.qualification,_that.date,_that.scope);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String reviewer,  String qualification,  String date,  List<String> scope)?  $default,) {final _that = this;
switch (_that) {
case _ReligiousApprovalDocument() when $default != null:
return $default(_that.reviewer,_that.qualification,_that.date,_that.scope);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReligiousApprovalDocument implements ReligiousApprovalDocument {
  const _ReligiousApprovalDocument({required this.reviewer, required this.qualification, required this.date, required  List<String> scope}): _scope = scope;
  factory _ReligiousApprovalDocument.fromJson(Map<String, dynamic> json) => _$ReligiousApprovalDocumentFromJson(json);

/// Reviewer.
@override final  String reviewer;
/// Reviewer qualification.
@override final  String qualification;
/// Approval date, `YYYY-MM-DD`.
@override final  String date;
/// What was approved, e.g. `rules`, `rounding`.
 final  List<String> _scope;
/// What was approved, e.g. `rules`, `rounding`.
@override List<String> get scope {
  if (_scope is EqualUnmodifiableListView) return _scope;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_scope);
}


/// Create a copy of ReligiousApprovalDocument
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReligiousApprovalDocumentCopyWith<_ReligiousApprovalDocument> get copyWith => __$ReligiousApprovalDocumentCopyWithImpl<_ReligiousApprovalDocument>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReligiousApprovalDocumentToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReligiousApprovalDocument&&(identical(other.reviewer, reviewer) || other.reviewer == reviewer)&&(identical(other.qualification, qualification) || other.qualification == qualification)&&(identical(other.date, date) || other.date == date)&&const DeepCollectionEquality().equals(other.scope, _scope));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,reviewer,qualification,date,const DeepCollectionEquality().hash(_scope));
}

@override
String toString() {
    return 'ReligiousApprovalDocument(reviewer: $reviewer, qualification: $qualification, date: $date, scope: $scope)';
}


}

/// @nodoc
abstract mixin class _$ReligiousApprovalDocumentCopyWith<$Res> implements $ReligiousApprovalDocumentCopyWith<$Res> {
  factory _$ReligiousApprovalDocumentCopyWith(_ReligiousApprovalDocument value, $Res Function(_ReligiousApprovalDocument) _then) = __$ReligiousApprovalDocumentCopyWithImpl;
@override @useResult
$Res call({
 String reviewer, String qualification, String date, List<String> scope
});




}
/// @nodoc
class __$ReligiousApprovalDocumentCopyWithImpl<$Res>
    implements _$ReligiousApprovalDocumentCopyWith<$Res> {
  __$ReligiousApprovalDocumentCopyWithImpl(this._self, this._then);

  final _ReligiousApprovalDocument _self;
  final $Res Function(_ReligiousApprovalDocument) _then;

/// Create a copy of ReligiousApprovalDocument
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? reviewer = null,Object? qualification = null,Object? date = null,Object? scope = null,}) {
  return _then(_ReligiousApprovalDocument(
reviewer: null == reviewer ? _self.reviewer : reviewer // ignore: cast_nullable_to_non_nullable
as String,qualification: null == qualification ? _self.qualification : qualification // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,scope: null == scope ? _self._scope : scope // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
