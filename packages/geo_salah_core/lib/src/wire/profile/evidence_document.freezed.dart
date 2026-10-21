// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'evidence_document.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$EvidenceDocument {

/// Sources.
 List<EvidenceSourceDocument> get sources;/// Benchmark set id.
 String get benchmarkSet;/// Holdout report id; always written, `null` when absent.
@JsonKey(includeIfNull: true) String? get holdoutReport;/// Benchmark report id; always written, `null` when absent.
@JsonKey(includeIfNull: true) String? get benchmarkReportId;
/// Create a copy of EvidenceDocument
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EvidenceDocumentCopyWith<EvidenceDocument> get copyWith => _$EvidenceDocumentCopyWithImpl<EvidenceDocument>(this as EvidenceDocument, _$identity);

  /// Serializes this EvidenceDocument to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as EvidenceDocument;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EvidenceDocument&&const DeepCollectionEquality().equals(other.sources, _this.sources)&&(identical(other.benchmarkSet, _this.benchmarkSet) || other.benchmarkSet == _this.benchmarkSet)&&(identical(other.holdoutReport, _this.holdoutReport) || other.holdoutReport == _this.holdoutReport)&&(identical(other.benchmarkReportId, _this.benchmarkReportId) || other.benchmarkReportId == _this.benchmarkReportId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as EvidenceDocument;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.sources),_this.benchmarkSet,_this.holdoutReport,_this.benchmarkReportId);
}

@override
String toString() {
  final _this = this as EvidenceDocument;
  return 'EvidenceDocument(sources: ${_this.sources}, benchmarkSet: ${_this.benchmarkSet}, holdoutReport: ${_this.holdoutReport}, benchmarkReportId: ${_this.benchmarkReportId})';
}


}

/// @nodoc
abstract mixin class $EvidenceDocumentCopyWith<$Res>  {
  factory $EvidenceDocumentCopyWith(EvidenceDocument value, $Res Function(EvidenceDocument) _then) = _$EvidenceDocumentCopyWithImpl;
@useResult
$Res call({
 List<EvidenceSourceDocument> sources, String benchmarkSet,@JsonKey(includeIfNull: true) String? holdoutReport,@JsonKey(includeIfNull: true) String? benchmarkReportId
});




}
/// @nodoc
class _$EvidenceDocumentCopyWithImpl<$Res>
    implements $EvidenceDocumentCopyWith<$Res> {
  _$EvidenceDocumentCopyWithImpl(this._self, this._then);

  final EvidenceDocument _self;
  final $Res Function(EvidenceDocument) _then;

/// Create a copy of EvidenceDocument
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? sources = null,Object? benchmarkSet = null,Object? holdoutReport = freezed,Object? benchmarkReportId = freezed,}) {
  return _then(EvidenceDocument(
sources: null == sources ? _self.sources : sources // ignore: cast_nullable_to_non_nullable
as List<EvidenceSourceDocument>,benchmarkSet: null == benchmarkSet ? _self.benchmarkSet : benchmarkSet // ignore: cast_nullable_to_non_nullable
as String,holdoutReport: freezed == holdoutReport ? _self.holdoutReport : holdoutReport // ignore: cast_nullable_to_non_nullable
as String?,benchmarkReportId: freezed == benchmarkReportId ? _self.benchmarkReportId : benchmarkReportId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [EvidenceDocument].
extension EvidenceDocumentPatterns on EvidenceDocument {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EvidenceDocument value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EvidenceDocument() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EvidenceDocument value)  $default,){
final _that = this;
switch (_that) {
case _EvidenceDocument():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EvidenceDocument value)?  $default,){
final _that = this;
switch (_that) {
case _EvidenceDocument() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<EvidenceSourceDocument> sources,  String benchmarkSet, @JsonKey(includeIfNull: true)  String? holdoutReport, @JsonKey(includeIfNull: true)  String? benchmarkReportId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EvidenceDocument() when $default != null:
return $default(_that.sources,_that.benchmarkSet,_that.holdoutReport,_that.benchmarkReportId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<EvidenceSourceDocument> sources,  String benchmarkSet, @JsonKey(includeIfNull: true)  String? holdoutReport, @JsonKey(includeIfNull: true)  String? benchmarkReportId)  $default,) {final _that = this;
switch (_that) {
case _EvidenceDocument():
return $default(_that.sources,_that.benchmarkSet,_that.holdoutReport,_that.benchmarkReportId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<EvidenceSourceDocument> sources,  String benchmarkSet, @JsonKey(includeIfNull: true)  String? holdoutReport, @JsonKey(includeIfNull: true)  String? benchmarkReportId)?  $default,) {final _that = this;
switch (_that) {
case _EvidenceDocument() when $default != null:
return $default(_that.sources,_that.benchmarkSet,_that.holdoutReport,_that.benchmarkReportId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EvidenceDocument implements EvidenceDocument {
  const _EvidenceDocument({required  List<EvidenceSourceDocument> sources, required this.benchmarkSet, @JsonKey(includeIfNull: true) required this.holdoutReport, @JsonKey(includeIfNull: true) required this.benchmarkReportId}): _sources = sources;
  factory _EvidenceDocument.fromJson(Map<String, dynamic> json) => _$EvidenceDocumentFromJson(json);

/// Sources.
 final  List<EvidenceSourceDocument> _sources;
/// Sources.
@override List<EvidenceSourceDocument> get sources {
  if (_sources is EqualUnmodifiableListView) return _sources;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sources);
}

/// Benchmark set id.
@override final  String benchmarkSet;
/// Holdout report id; always written, `null` when absent.
@override@JsonKey(includeIfNull: true) final  String? holdoutReport;
/// Benchmark report id; always written, `null` when absent.
@override@JsonKey(includeIfNull: true) final  String? benchmarkReportId;

/// Create a copy of EvidenceDocument
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EvidenceDocumentCopyWith<_EvidenceDocument> get copyWith => __$EvidenceDocumentCopyWithImpl<_EvidenceDocument>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EvidenceDocumentToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _EvidenceDocument&&const DeepCollectionEquality().equals(other.sources, _sources)&&(identical(other.benchmarkSet, benchmarkSet) || other.benchmarkSet == benchmarkSet)&&(identical(other.holdoutReport, holdoutReport) || other.holdoutReport == holdoutReport)&&(identical(other.benchmarkReportId, benchmarkReportId) || other.benchmarkReportId == benchmarkReportId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_sources),benchmarkSet,holdoutReport,benchmarkReportId);
}

@override
String toString() {
    return 'EvidenceDocument(sources: $sources, benchmarkSet: $benchmarkSet, holdoutReport: $holdoutReport, benchmarkReportId: $benchmarkReportId)';
}


}

/// @nodoc
abstract mixin class _$EvidenceDocumentCopyWith<$Res> implements $EvidenceDocumentCopyWith<$Res> {
  factory _$EvidenceDocumentCopyWith(_EvidenceDocument value, $Res Function(_EvidenceDocument) _then) = __$EvidenceDocumentCopyWithImpl;
@override @useResult
$Res call({
 List<EvidenceSourceDocument> sources, String benchmarkSet,@JsonKey(includeIfNull: true) String? holdoutReport,@JsonKey(includeIfNull: true) String? benchmarkReportId
});




}
/// @nodoc
class __$EvidenceDocumentCopyWithImpl<$Res>
    implements _$EvidenceDocumentCopyWith<$Res> {
  __$EvidenceDocumentCopyWithImpl(this._self, this._then);

  final _EvidenceDocument _self;
  final $Res Function(_EvidenceDocument) _then;

/// Create a copy of EvidenceDocument
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sources = null,Object? benchmarkSet = null,Object? holdoutReport = freezed,Object? benchmarkReportId = freezed,}) {
  return _then(_EvidenceDocument(
sources: null == sources ? _self._sources : sources // ignore: cast_nullable_to_non_nullable
as List<EvidenceSourceDocument>,benchmarkSet: null == benchmarkSet ? _self.benchmarkSet : benchmarkSet // ignore: cast_nullable_to_non_nullable
as String,holdoutReport: freezed == holdoutReport ? _self.holdoutReport : holdoutReport // ignore: cast_nullable_to_non_nullable
as String?,benchmarkReportId: freezed == benchmarkReportId ? _self.benchmarkReportId : benchmarkReportId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
