// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'approvals_document.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ApprovalsDocument {

/// Religious approval.
@JsonKey(includeIfNull: true) ReligiousApprovalDocument? get religious;/// Accuracy approval.
@JsonKey(includeIfNull: true) AccuracyApprovalDocument? get accuracy;
/// Create a copy of ApprovalsDocument
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ApprovalsDocumentCopyWith<ApprovalsDocument> get copyWith => _$ApprovalsDocumentCopyWithImpl<ApprovalsDocument>(this as ApprovalsDocument, _$identity);

  /// Serializes this ApprovalsDocument to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ApprovalsDocument;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ApprovalsDocument&&(identical(other.religious, _this.religious) || other.religious == _this.religious)&&(identical(other.accuracy, _this.accuracy) || other.accuracy == _this.accuracy));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ApprovalsDocument;
  return Object.hash(runtimeType,_this.religious,_this.accuracy);
}

@override
String toString() {
  final _this = this as ApprovalsDocument;
  return 'ApprovalsDocument(religious: ${_this.religious}, accuracy: ${_this.accuracy})';
}


}

/// @nodoc
abstract mixin class $ApprovalsDocumentCopyWith<$Res>  {
  factory $ApprovalsDocumentCopyWith(ApprovalsDocument value, $Res Function(ApprovalsDocument) _then) = _$ApprovalsDocumentCopyWithImpl;
@useResult
$Res call({
@JsonKey(includeIfNull: true) ReligiousApprovalDocument? religious,@JsonKey(includeIfNull: true) AccuracyApprovalDocument? accuracy
});


$ReligiousApprovalDocumentCopyWith<$Res>? get religious;$AccuracyApprovalDocumentCopyWith<$Res>? get accuracy;

}
/// @nodoc
class _$ApprovalsDocumentCopyWithImpl<$Res>
    implements $ApprovalsDocumentCopyWith<$Res> {
  _$ApprovalsDocumentCopyWithImpl(this._self, this._then);

  final ApprovalsDocument _self;
  final $Res Function(ApprovalsDocument) _then;

/// Create a copy of ApprovalsDocument
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? religious = freezed,Object? accuracy = freezed,}) {
  return _then(ApprovalsDocument(
religious: freezed == religious ? _self.religious : religious // ignore: cast_nullable_to_non_nullable
as ReligiousApprovalDocument?,accuracy: freezed == accuracy ? _self.accuracy : accuracy // ignore: cast_nullable_to_non_nullable
as AccuracyApprovalDocument?,
  ));
}
/// Create a copy of ApprovalsDocument
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ReligiousApprovalDocumentCopyWith<$Res>? get religious {
    if (_self.religious == null) {
    return null;
  }

  return $ReligiousApprovalDocumentCopyWith<$Res>(_self.religious!, (value) {
    return _then(_self.copyWith(religious: value));
  });
}/// Create a copy of ApprovalsDocument
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AccuracyApprovalDocumentCopyWith<$Res>? get accuracy {
    if (_self.accuracy == null) {
    return null;
  }

  return $AccuracyApprovalDocumentCopyWith<$Res>(_self.accuracy!, (value) {
    return _then(_self.copyWith(accuracy: value));
  });
}
}


/// Adds pattern-matching-related methods to [ApprovalsDocument].
extension ApprovalsDocumentPatterns on ApprovalsDocument {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ApprovalsDocument value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ApprovalsDocument() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ApprovalsDocument value)  $default,){
final _that = this;
switch (_that) {
case _ApprovalsDocument():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ApprovalsDocument value)?  $default,){
final _that = this;
switch (_that) {
case _ApprovalsDocument() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(includeIfNull: true)  ReligiousApprovalDocument? religious, @JsonKey(includeIfNull: true)  AccuracyApprovalDocument? accuracy)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ApprovalsDocument() when $default != null:
return $default(_that.religious,_that.accuracy);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(includeIfNull: true)  ReligiousApprovalDocument? religious, @JsonKey(includeIfNull: true)  AccuracyApprovalDocument? accuracy)  $default,) {final _that = this;
switch (_that) {
case _ApprovalsDocument():
return $default(_that.religious,_that.accuracy);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(includeIfNull: true)  ReligiousApprovalDocument? religious, @JsonKey(includeIfNull: true)  AccuracyApprovalDocument? accuracy)?  $default,) {final _that = this;
switch (_that) {
case _ApprovalsDocument() when $default != null:
return $default(_that.religious,_that.accuracy);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ApprovalsDocument implements ApprovalsDocument {
  const _ApprovalsDocument({@JsonKey(includeIfNull: true) required this.religious, @JsonKey(includeIfNull: true) required this.accuracy});
  factory _ApprovalsDocument.fromJson(Map<String, dynamic> json) => _$ApprovalsDocumentFromJson(json);

/// Religious approval.
@override@JsonKey(includeIfNull: true) final  ReligiousApprovalDocument? religious;
/// Accuracy approval.
@override@JsonKey(includeIfNull: true) final  AccuracyApprovalDocument? accuracy;

/// Create a copy of ApprovalsDocument
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ApprovalsDocumentCopyWith<_ApprovalsDocument> get copyWith => __$ApprovalsDocumentCopyWithImpl<_ApprovalsDocument>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ApprovalsDocumentToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ApprovalsDocument&&(identical(other.religious, religious) || other.religious == religious)&&(identical(other.accuracy, accuracy) || other.accuracy == accuracy));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,religious,accuracy);
}

@override
String toString() {
    return 'ApprovalsDocument(religious: $religious, accuracy: $accuracy)';
}


}

/// @nodoc
abstract mixin class _$ApprovalsDocumentCopyWith<$Res> implements $ApprovalsDocumentCopyWith<$Res> {
  factory _$ApprovalsDocumentCopyWith(_ApprovalsDocument value, $Res Function(_ApprovalsDocument) _then) = __$ApprovalsDocumentCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(includeIfNull: true) ReligiousApprovalDocument? religious,@JsonKey(includeIfNull: true) AccuracyApprovalDocument? accuracy
});


@override $ReligiousApprovalDocumentCopyWith<$Res>? get religious;@override $AccuracyApprovalDocumentCopyWith<$Res>? get accuracy;

}
/// @nodoc
class __$ApprovalsDocumentCopyWithImpl<$Res>
    implements _$ApprovalsDocumentCopyWith<$Res> {
  __$ApprovalsDocumentCopyWithImpl(this._self, this._then);

  final _ApprovalsDocument _self;
  final $Res Function(_ApprovalsDocument) _then;

/// Create a copy of ApprovalsDocument
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? religious = freezed,Object? accuracy = freezed,}) {
  return _then(_ApprovalsDocument(
religious: freezed == religious ? _self.religious : religious // ignore: cast_nullable_to_non_nullable
as ReligiousApprovalDocument?,accuracy: freezed == accuracy ? _self.accuracy : accuracy // ignore: cast_nullable_to_non_nullable
as AccuracyApprovalDocument?,
  ));
}

/// Create a copy of ApprovalsDocument
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ReligiousApprovalDocumentCopyWith<$Res>? get religious {
    if (_self.religious == null) {
    return null;
  }

  return $ReligiousApprovalDocumentCopyWith<$Res>(_self.religious!, (value) {
    return _then(_self.copyWith(religious: value));
  });
}/// Create a copy of ApprovalsDocument
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AccuracyApprovalDocumentCopyWith<$Res>? get accuracy {
    if (_self.accuracy == null) {
    return null;
  }

  return $AccuracyApprovalDocumentCopyWith<$Res>(_self.accuracy!, (value) {
    return _then(_self.copyWith(accuracy: value));
  });
}
}

// dart format on
