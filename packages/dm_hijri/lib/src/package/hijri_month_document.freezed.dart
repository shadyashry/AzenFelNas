// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'hijri_month_document.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$HijriMonthDocument {

/// Hijri year.
 int get hijriYear;/// Hijri month, 1–12.
 int get hijriMonth;/// Gregorian date of day 1, `YYYY-MM-DD`.
 String get gregorianStart;/// Confirmation status.
 HijriMonthStatusCode get status;/// Official announcement URL.
 String? get sourceUrl;
/// Create a copy of HijriMonthDocument
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HijriMonthDocumentCopyWith<HijriMonthDocument> get copyWith => _$HijriMonthDocumentCopyWithImpl<HijriMonthDocument>(this as HijriMonthDocument, _$identity);

  /// Serializes this HijriMonthDocument to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as HijriMonthDocument;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HijriMonthDocument&&(identical(other.hijriYear, _this.hijriYear) || other.hijriYear == _this.hijriYear)&&(identical(other.hijriMonth, _this.hijriMonth) || other.hijriMonth == _this.hijriMonth)&&(identical(other.gregorianStart, _this.gregorianStart) || other.gregorianStart == _this.gregorianStart)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.sourceUrl, _this.sourceUrl) || other.sourceUrl == _this.sourceUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as HijriMonthDocument;
  return Object.hash(runtimeType,_this.hijriYear,_this.hijriMonth,_this.gregorianStart,_this.status,_this.sourceUrl);
}

@override
String toString() {
  final _this = this as HijriMonthDocument;
  return 'HijriMonthDocument(hijriYear: ${_this.hijriYear}, hijriMonth: ${_this.hijriMonth}, gregorianStart: ${_this.gregorianStart}, status: ${_this.status}, sourceUrl: ${_this.sourceUrl})';
}


}

/// @nodoc
abstract mixin class $HijriMonthDocumentCopyWith<$Res>  {
  factory $HijriMonthDocumentCopyWith(HijriMonthDocument value, $Res Function(HijriMonthDocument) _then) = _$HijriMonthDocumentCopyWithImpl;
@useResult
$Res call({
 int hijriYear, int hijriMonth, String gregorianStart, HijriMonthStatusCode status, String? sourceUrl
});




}
/// @nodoc
class _$HijriMonthDocumentCopyWithImpl<$Res>
    implements $HijriMonthDocumentCopyWith<$Res> {
  _$HijriMonthDocumentCopyWithImpl(this._self, this._then);

  final HijriMonthDocument _self;
  final $Res Function(HijriMonthDocument) _then;

/// Create a copy of HijriMonthDocument
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? hijriYear = null,Object? hijriMonth = null,Object? gregorianStart = null,Object? status = null,Object? sourceUrl = freezed,}) {
  return _then(HijriMonthDocument(
hijriYear: null == hijriYear ? _self.hijriYear : hijriYear // ignore: cast_nullable_to_non_nullable
as int,hijriMonth: null == hijriMonth ? _self.hijriMonth : hijriMonth // ignore: cast_nullable_to_non_nullable
as int,gregorianStart: null == gregorianStart ? _self.gregorianStart : gregorianStart // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as HijriMonthStatusCode,sourceUrl: freezed == sourceUrl ? _self.sourceUrl : sourceUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [HijriMonthDocument].
extension HijriMonthDocumentPatterns on HijriMonthDocument {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HijriMonthDocument value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HijriMonthDocument() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HijriMonthDocument value)  $default,){
final _that = this;
switch (_that) {
case _HijriMonthDocument():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HijriMonthDocument value)?  $default,){
final _that = this;
switch (_that) {
case _HijriMonthDocument() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int hijriYear,  int hijriMonth,  String gregorianStart,  HijriMonthStatusCode status,  String? sourceUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HijriMonthDocument() when $default != null:
return $default(_that.hijriYear,_that.hijriMonth,_that.gregorianStart,_that.status,_that.sourceUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int hijriYear,  int hijriMonth,  String gregorianStart,  HijriMonthStatusCode status,  String? sourceUrl)  $default,) {final _that = this;
switch (_that) {
case _HijriMonthDocument():
return $default(_that.hijriYear,_that.hijriMonth,_that.gregorianStart,_that.status,_that.sourceUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int hijriYear,  int hijriMonth,  String gregorianStart,  HijriMonthStatusCode status,  String? sourceUrl)?  $default,) {final _that = this;
switch (_that) {
case _HijriMonthDocument() when $default != null:
return $default(_that.hijriYear,_that.hijriMonth,_that.gregorianStart,_that.status,_that.sourceUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HijriMonthDocument implements HijriMonthDocument {
  const _HijriMonthDocument({required this.hijriYear, required this.hijriMonth, required this.gregorianStart, required this.status, this.sourceUrl});
  factory _HijriMonthDocument.fromJson(Map<String, dynamic> json) => _$HijriMonthDocumentFromJson(json);

/// Hijri year.
@override final  int hijriYear;
/// Hijri month, 1–12.
@override final  int hijriMonth;
/// Gregorian date of day 1, `YYYY-MM-DD`.
@override final  String gregorianStart;
/// Confirmation status.
@override final  HijriMonthStatusCode status;
/// Official announcement URL.
@override final  String? sourceUrl;

/// Create a copy of HijriMonthDocument
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HijriMonthDocumentCopyWith<_HijriMonthDocument> get copyWith => __$HijriMonthDocumentCopyWithImpl<_HijriMonthDocument>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HijriMonthDocumentToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _HijriMonthDocument&&(identical(other.hijriYear, hijriYear) || other.hijriYear == hijriYear)&&(identical(other.hijriMonth, hijriMonth) || other.hijriMonth == hijriMonth)&&(identical(other.gregorianStart, gregorianStart) || other.gregorianStart == gregorianStart)&&(identical(other.status, status) || other.status == status)&&(identical(other.sourceUrl, sourceUrl) || other.sourceUrl == sourceUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,hijriYear,hijriMonth,gregorianStart,status,sourceUrl);
}

@override
String toString() {
    return 'HijriMonthDocument(hijriYear: $hijriYear, hijriMonth: $hijriMonth, gregorianStart: $gregorianStart, status: $status, sourceUrl: $sourceUrl)';
}


}

/// @nodoc
abstract mixin class _$HijriMonthDocumentCopyWith<$Res> implements $HijriMonthDocumentCopyWith<$Res> {
  factory _$HijriMonthDocumentCopyWith(_HijriMonthDocument value, $Res Function(_HijriMonthDocument) _then) = __$HijriMonthDocumentCopyWithImpl;
@override @useResult
$Res call({
 int hijriYear, int hijriMonth, String gregorianStart, HijriMonthStatusCode status, String? sourceUrl
});




}
/// @nodoc
class __$HijriMonthDocumentCopyWithImpl<$Res>
    implements _$HijriMonthDocumentCopyWith<$Res> {
  __$HijriMonthDocumentCopyWithImpl(this._self, this._then);

  final _HijriMonthDocument _self;
  final $Res Function(_HijriMonthDocument) _then;

/// Create a copy of HijriMonthDocument
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? hijriYear = null,Object? hijriMonth = null,Object? gregorianStart = null,Object? status = null,Object? sourceUrl = freezed,}) {
  return _then(_HijriMonthDocument(
hijriYear: null == hijriYear ? _self.hijriYear : hijriYear // ignore: cast_nullable_to_non_nullable
as int,hijriMonth: null == hijriMonth ? _self.hijriMonth : hijriMonth // ignore: cast_nullable_to_non_nullable
as int,gregorianStart: null == gregorianStart ? _self.gregorianStart : gregorianStart // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as HijriMonthStatusCode,sourceUrl: freezed == sourceUrl ? _self.sourceUrl : sourceUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
