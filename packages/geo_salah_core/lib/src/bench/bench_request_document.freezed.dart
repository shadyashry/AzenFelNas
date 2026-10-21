// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bench_request_document.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BenchRequestDocument {

/// Schema version; 1.
 int get schemaVersion;/// The observer.
 BenchObserverDocument get observer;/// Prayer profile id.
 String get profileId;/// Prayer day, `YYYY-MM-DD` in the observer's zone.
 String get day;/// Hijri state of the day; echoed as the trace's `inputs.hijri`.
 TraceHijriInputsDocument get hijri;
/// Create a copy of BenchRequestDocument
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BenchRequestDocumentCopyWith<BenchRequestDocument> get copyWith => _$BenchRequestDocumentCopyWithImpl<BenchRequestDocument>(this as BenchRequestDocument, _$identity);

  /// Serializes this BenchRequestDocument to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as BenchRequestDocument;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BenchRequestDocument&&(identical(other.schemaVersion, _this.schemaVersion) || other.schemaVersion == _this.schemaVersion)&&(identical(other.observer, _this.observer) || other.observer == _this.observer)&&(identical(other.profileId, _this.profileId) || other.profileId == _this.profileId)&&(identical(other.day, _this.day) || other.day == _this.day)&&(identical(other.hijri, _this.hijri) || other.hijri == _this.hijri));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as BenchRequestDocument;
  return Object.hash(runtimeType,_this.schemaVersion,_this.observer,_this.profileId,_this.day,_this.hijri);
}

@override
String toString() {
  final _this = this as BenchRequestDocument;
  return 'BenchRequestDocument(schemaVersion: ${_this.schemaVersion}, observer: ${_this.observer}, profileId: ${_this.profileId}, day: ${_this.day}, hijri: ${_this.hijri})';
}


}

/// @nodoc
abstract mixin class $BenchRequestDocumentCopyWith<$Res>  {
  factory $BenchRequestDocumentCopyWith(BenchRequestDocument value, $Res Function(BenchRequestDocument) _then) = _$BenchRequestDocumentCopyWithImpl;
@useResult
$Res call({
 int schemaVersion, BenchObserverDocument observer, String profileId, String day, TraceHijriInputsDocument hijri
});


$BenchObserverDocumentCopyWith<$Res> get observer;$TraceHijriInputsDocumentCopyWith<$Res> get hijri;

}
/// @nodoc
class _$BenchRequestDocumentCopyWithImpl<$Res>
    implements $BenchRequestDocumentCopyWith<$Res> {
  _$BenchRequestDocumentCopyWithImpl(this._self, this._then);

  final BenchRequestDocument _self;
  final $Res Function(BenchRequestDocument) _then;

/// Create a copy of BenchRequestDocument
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? schemaVersion = null,Object? observer = null,Object? profileId = null,Object? day = null,Object? hijri = null,}) {
  return _then(BenchRequestDocument(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,observer: null == observer ? _self.observer : observer // ignore: cast_nullable_to_non_nullable
as BenchObserverDocument,profileId: null == profileId ? _self.profileId : profileId // ignore: cast_nullable_to_non_nullable
as String,day: null == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as String,hijri: null == hijri ? _self.hijri : hijri // ignore: cast_nullable_to_non_nullable
as TraceHijriInputsDocument,
  ));
}
/// Create a copy of BenchRequestDocument
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BenchObserverDocumentCopyWith<$Res> get observer {
  
  return $BenchObserverDocumentCopyWith<$Res>(_self.observer, (value) {
    return _then(_self.copyWith(observer: value));
  });
}/// Create a copy of BenchRequestDocument
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TraceHijriInputsDocumentCopyWith<$Res> get hijri {
  
  return $TraceHijriInputsDocumentCopyWith<$Res>(_self.hijri, (value) {
    return _then(_self.copyWith(hijri: value));
  });
}
}


/// Adds pattern-matching-related methods to [BenchRequestDocument].
extension BenchRequestDocumentPatterns on BenchRequestDocument {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BenchRequestDocument value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BenchRequestDocument() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BenchRequestDocument value)  $default,){
final _that = this;
switch (_that) {
case _BenchRequestDocument():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BenchRequestDocument value)?  $default,){
final _that = this;
switch (_that) {
case _BenchRequestDocument() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int schemaVersion,  BenchObserverDocument observer,  String profileId,  String day,  TraceHijriInputsDocument hijri)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BenchRequestDocument() when $default != null:
return $default(_that.schemaVersion,_that.observer,_that.profileId,_that.day,_that.hijri);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int schemaVersion,  BenchObserverDocument observer,  String profileId,  String day,  TraceHijriInputsDocument hijri)  $default,) {final _that = this;
switch (_that) {
case _BenchRequestDocument():
return $default(_that.schemaVersion,_that.observer,_that.profileId,_that.day,_that.hijri);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int schemaVersion,  BenchObserverDocument observer,  String profileId,  String day,  TraceHijriInputsDocument hijri)?  $default,) {final _that = this;
switch (_that) {
case _BenchRequestDocument() when $default != null:
return $default(_that.schemaVersion,_that.observer,_that.profileId,_that.day,_that.hijri);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BenchRequestDocument implements BenchRequestDocument {
  const _BenchRequestDocument({required this.schemaVersion, required this.observer, required this.profileId, required this.day, required this.hijri});
  factory _BenchRequestDocument.fromJson(Map<String, dynamic> json) => _$BenchRequestDocumentFromJson(json);

/// Schema version; 1.
@override final  int schemaVersion;
/// The observer.
@override final  BenchObserverDocument observer;
/// Prayer profile id.
@override final  String profileId;
/// Prayer day, `YYYY-MM-DD` in the observer's zone.
@override final  String day;
/// Hijri state of the day; echoed as the trace's `inputs.hijri`.
@override final  TraceHijriInputsDocument hijri;

/// Create a copy of BenchRequestDocument
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BenchRequestDocumentCopyWith<_BenchRequestDocument> get copyWith => __$BenchRequestDocumentCopyWithImpl<_BenchRequestDocument>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BenchRequestDocumentToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _BenchRequestDocument&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.observer, observer) || other.observer == observer)&&(identical(other.profileId, profileId) || other.profileId == profileId)&&(identical(other.day, day) || other.day == day)&&(identical(other.hijri, hijri) || other.hijri == hijri));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,schemaVersion,observer,profileId,day,hijri);
}

@override
String toString() {
    return 'BenchRequestDocument(schemaVersion: $schemaVersion, observer: $observer, profileId: $profileId, day: $day, hijri: $hijri)';
}


}

/// @nodoc
abstract mixin class _$BenchRequestDocumentCopyWith<$Res> implements $BenchRequestDocumentCopyWith<$Res> {
  factory _$BenchRequestDocumentCopyWith(_BenchRequestDocument value, $Res Function(_BenchRequestDocument) _then) = __$BenchRequestDocumentCopyWithImpl;
@override @useResult
$Res call({
 int schemaVersion, BenchObserverDocument observer, String profileId, String day, TraceHijriInputsDocument hijri
});


@override $BenchObserverDocumentCopyWith<$Res> get observer;@override $TraceHijriInputsDocumentCopyWith<$Res> get hijri;

}
/// @nodoc
class __$BenchRequestDocumentCopyWithImpl<$Res>
    implements _$BenchRequestDocumentCopyWith<$Res> {
  __$BenchRequestDocumentCopyWithImpl(this._self, this._then);

  final _BenchRequestDocument _self;
  final $Res Function(_BenchRequestDocument) _then;

/// Create a copy of BenchRequestDocument
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? schemaVersion = null,Object? observer = null,Object? profileId = null,Object? day = null,Object? hijri = null,}) {
  return _then(_BenchRequestDocument(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,observer: null == observer ? _self.observer : observer // ignore: cast_nullable_to_non_nullable
as BenchObserverDocument,profileId: null == profileId ? _self.profileId : profileId // ignore: cast_nullable_to_non_nullable
as String,day: null == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as String,hijri: null == hijri ? _self.hijri : hijri // ignore: cast_nullable_to_non_nullable
as TraceHijriInputsDocument,
  ));
}

/// Create a copy of BenchRequestDocument
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BenchObserverDocumentCopyWith<$Res> get observer {
  
  return $BenchObserverDocumentCopyWith<$Res>(_self.observer, (value) {
    return _then(_self.copyWith(observer: value));
  });
}/// Create a copy of BenchRequestDocument
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TraceHijriInputsDocumentCopyWith<$Res> get hijri {
  
  return $TraceHijriInputsDocumentCopyWith<$Res>(_self.hijri, (value) {
    return _then(_self.copyWith(hijri: value));
  });
}
}

// dart format on
