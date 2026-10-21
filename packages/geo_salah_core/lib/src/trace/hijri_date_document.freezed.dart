// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'hijri_date_document.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$HijriDateDocument {

/// Hijri year.
 int get year;/// Hijri month, 1–12.
 int get month;/// Day of month, 1–30.
 int get day;
/// Create a copy of HijriDateDocument
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HijriDateDocumentCopyWith<HijriDateDocument> get copyWith => _$HijriDateDocumentCopyWithImpl<HijriDateDocument>(this as HijriDateDocument, _$identity);

  /// Serializes this HijriDateDocument to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as HijriDateDocument;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HijriDateDocument&&(identical(other.year, _this.year) || other.year == _this.year)&&(identical(other.month, _this.month) || other.month == _this.month)&&(identical(other.day, _this.day) || other.day == _this.day));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as HijriDateDocument;
  return Object.hash(runtimeType,_this.year,_this.month,_this.day);
}

@override
String toString() {
  final _this = this as HijriDateDocument;
  return 'HijriDateDocument(year: ${_this.year}, month: ${_this.month}, day: ${_this.day})';
}


}

/// @nodoc
abstract mixin class $HijriDateDocumentCopyWith<$Res>  {
  factory $HijriDateDocumentCopyWith(HijriDateDocument value, $Res Function(HijriDateDocument) _then) = _$HijriDateDocumentCopyWithImpl;
@useResult
$Res call({
 int year, int month, int day
});




}
/// @nodoc
class _$HijriDateDocumentCopyWithImpl<$Res>
    implements $HijriDateDocumentCopyWith<$Res> {
  _$HijriDateDocumentCopyWithImpl(this._self, this._then);

  final HijriDateDocument _self;
  final $Res Function(HijriDateDocument) _then;

/// Create a copy of HijriDateDocument
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? year = null,Object? month = null,Object? day = null,}) {
  return _then(HijriDateDocument(
year: null == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int,month: null == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as int,day: null == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [HijriDateDocument].
extension HijriDateDocumentPatterns on HijriDateDocument {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HijriDateDocument value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HijriDateDocument() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HijriDateDocument value)  $default,){
final _that = this;
switch (_that) {
case _HijriDateDocument():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HijriDateDocument value)?  $default,){
final _that = this;
switch (_that) {
case _HijriDateDocument() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int year,  int month,  int day)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HijriDateDocument() when $default != null:
return $default(_that.year,_that.month,_that.day);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int year,  int month,  int day)  $default,) {final _that = this;
switch (_that) {
case _HijriDateDocument():
return $default(_that.year,_that.month,_that.day);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int year,  int month,  int day)?  $default,) {final _that = this;
switch (_that) {
case _HijriDateDocument() when $default != null:
return $default(_that.year,_that.month,_that.day);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HijriDateDocument implements HijriDateDocument {
  const _HijriDateDocument({required this.year, required this.month, required this.day});
  factory _HijriDateDocument.fromJson(Map<String, dynamic> json) => _$HijriDateDocumentFromJson(json);

/// Hijri year.
@override final  int year;
/// Hijri month, 1–12.
@override final  int month;
/// Day of month, 1–30.
@override final  int day;

/// Create a copy of HijriDateDocument
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HijriDateDocumentCopyWith<_HijriDateDocument> get copyWith => __$HijriDateDocumentCopyWithImpl<_HijriDateDocument>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HijriDateDocumentToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _HijriDateDocument&&(identical(other.year, year) || other.year == year)&&(identical(other.month, month) || other.month == month)&&(identical(other.day, day) || other.day == day));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,year,month,day);
}

@override
String toString() {
    return 'HijriDateDocument(year: $year, month: $month, day: $day)';
}


}

/// @nodoc
abstract mixin class _$HijriDateDocumentCopyWith<$Res> implements $HijriDateDocumentCopyWith<$Res> {
  factory _$HijriDateDocumentCopyWith(_HijriDateDocument value, $Res Function(_HijriDateDocument) _then) = __$HijriDateDocumentCopyWithImpl;
@override @useResult
$Res call({
 int year, int month, int day
});




}
/// @nodoc
class __$HijriDateDocumentCopyWithImpl<$Res>
    implements _$HijriDateDocumentCopyWith<$Res> {
  __$HijriDateDocumentCopyWithImpl(this._self, this._then);

  final _HijriDateDocument _self;
  final $Res Function(_HijriDateDocument) _then;

/// Create a copy of HijriDateDocument
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? year = null,Object? month = null,Object? day = null,}) {
  return _then(_HijriDateDocument(
year: null == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int,month: null == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as int,day: null == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
