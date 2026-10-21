// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'confidence_label_document.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
ConfidenceLabelDocument _$ConfidenceLabelDocumentFromJson(
  Map<String, dynamic> json
) {
        switch (json['kind']) {
                  case 'CALCULATED':
          return CalculatedLabelDocument.fromJson(
            json
          );
                case 'AUTHORITY_ALIGNED':
          return AuthorityAlignedLabelDocument.fromJson(
            json
          );
                case 'VERIFIED':
          return VerifiedLabelDocument.fromJson(
            json
          );
                case 'ESTIMATED':
          return EstimatedLabelDocument.fromJson(
            json
          );
                case 'OBSERVED':
          return ObservedLabelDocument.fromJson(
            json
          );
                case 'UNKNOWN':
          return UnknownLabelDocument.fromJson(
            json
          );
        
          default:
            throw CheckedFromJsonException(
  json,
  'kind',
  'ConfidenceLabelDocument',
  'Invalid union type "${json['kind']}"!'
);
        }
      
}

/// @nodoc
mixin _$ConfidenceLabelDocument {



  /// Serializes this ConfidenceLabelDocument to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ConfidenceLabelDocument);
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'ConfidenceLabelDocument()';
}


}

/// @nodoc
class $ConfidenceLabelDocumentCopyWith<$Res>  {
$ConfidenceLabelDocumentCopyWith(ConfidenceLabelDocument _, $Res Function(ConfidenceLabelDocument) __);
}


/// Adds pattern-matching-related methods to [ConfidenceLabelDocument].
extension ConfidenceLabelDocumentPatterns on ConfidenceLabelDocument {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( CalculatedLabelDocument value)?  calculated,TResult Function( AuthorityAlignedLabelDocument value)?  authorityAligned,TResult Function( VerifiedLabelDocument value)?  verified,TResult Function( EstimatedLabelDocument value)?  estimated,TResult Function( ObservedLabelDocument value)?  observed,TResult Function( UnknownLabelDocument value)?  unknown,required TResult orElse(),}){
final _that = this;
switch (_that) {
case CalculatedLabelDocument() when calculated != null:
return calculated(_that);case AuthorityAlignedLabelDocument() when authorityAligned != null:
return authorityAligned(_that);case VerifiedLabelDocument() when verified != null:
return verified(_that);case EstimatedLabelDocument() when estimated != null:
return estimated(_that);case ObservedLabelDocument() when observed != null:
return observed(_that);case UnknownLabelDocument() when unknown != null:
return unknown(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( CalculatedLabelDocument value)  calculated,required TResult Function( AuthorityAlignedLabelDocument value)  authorityAligned,required TResult Function( VerifiedLabelDocument value)  verified,required TResult Function( EstimatedLabelDocument value)  estimated,required TResult Function( ObservedLabelDocument value)  observed,required TResult Function( UnknownLabelDocument value)  unknown,}){
final _that = this;
switch (_that) {
case CalculatedLabelDocument():
return calculated(_that);case AuthorityAlignedLabelDocument():
return authorityAligned(_that);case VerifiedLabelDocument():
return verified(_that);case EstimatedLabelDocument():
return estimated(_that);case ObservedLabelDocument():
return observed(_that);case UnknownLabelDocument():
return unknown(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( CalculatedLabelDocument value)?  calculated,TResult? Function( AuthorityAlignedLabelDocument value)?  authorityAligned,TResult? Function( VerifiedLabelDocument value)?  verified,TResult? Function( EstimatedLabelDocument value)?  estimated,TResult? Function( ObservedLabelDocument value)?  observed,TResult? Function( UnknownLabelDocument value)?  unknown,}){
final _that = this;
switch (_that) {
case CalculatedLabelDocument() when calculated != null:
return calculated(_that);case AuthorityAlignedLabelDocument() when authorityAligned != null:
return authorityAligned(_that);case VerifiedLabelDocument() when verified != null:
return verified(_that);case EstimatedLabelDocument() when estimated != null:
return estimated(_that);case ObservedLabelDocument() when observed != null:
return observed(_that);case UnknownLabelDocument() when unknown != null:
return unknown(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  calculated,TResult Function( String benchmarkReportId)?  authorityAligned,TResult Function( String sourceRef,  int freshUntilUtcMs)?  verified,TResult Function( int rangeMinutes)?  estimated,TResult Function( int count,  int lastSeenUtcMs)?  observed,TResult Function( String reasonCode)?  unknown,required TResult orElse(),}) {final _that = this;
switch (_that) {
case CalculatedLabelDocument() when calculated != null:
return calculated();case AuthorityAlignedLabelDocument() when authorityAligned != null:
return authorityAligned(_that.benchmarkReportId);case VerifiedLabelDocument() when verified != null:
return verified(_that.sourceRef,_that.freshUntilUtcMs);case EstimatedLabelDocument() when estimated != null:
return estimated(_that.rangeMinutes);case ObservedLabelDocument() when observed != null:
return observed(_that.count,_that.lastSeenUtcMs);case UnknownLabelDocument() when unknown != null:
return unknown(_that.reasonCode);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  calculated,required TResult Function( String benchmarkReportId)  authorityAligned,required TResult Function( String sourceRef,  int freshUntilUtcMs)  verified,required TResult Function( int rangeMinutes)  estimated,required TResult Function( int count,  int lastSeenUtcMs)  observed,required TResult Function( String reasonCode)  unknown,}) {final _that = this;
switch (_that) {
case CalculatedLabelDocument():
return calculated();case AuthorityAlignedLabelDocument():
return authorityAligned(_that.benchmarkReportId);case VerifiedLabelDocument():
return verified(_that.sourceRef,_that.freshUntilUtcMs);case EstimatedLabelDocument():
return estimated(_that.rangeMinutes);case ObservedLabelDocument():
return observed(_that.count,_that.lastSeenUtcMs);case UnknownLabelDocument():
return unknown(_that.reasonCode);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  calculated,TResult? Function( String benchmarkReportId)?  authorityAligned,TResult? Function( String sourceRef,  int freshUntilUtcMs)?  verified,TResult? Function( int rangeMinutes)?  estimated,TResult? Function( int count,  int lastSeenUtcMs)?  observed,TResult? Function( String reasonCode)?  unknown,}) {final _that = this;
switch (_that) {
case CalculatedLabelDocument() when calculated != null:
return calculated();case AuthorityAlignedLabelDocument() when authorityAligned != null:
return authorityAligned(_that.benchmarkReportId);case VerifiedLabelDocument() when verified != null:
return verified(_that.sourceRef,_that.freshUntilUtcMs);case EstimatedLabelDocument() when estimated != null:
return estimated(_that.rangeMinutes);case ObservedLabelDocument() when observed != null:
return observed(_that.count,_that.lastSeenUtcMs);case UnknownLabelDocument() when unknown != null:
return unknown(_that.reasonCode);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class CalculatedLabelDocument implements ConfidenceLabelDocument {
  const CalculatedLabelDocument({ String? $type}): $type = $type ?? 'CALCULATED';
  factory CalculatedLabelDocument.fromJson(Map<String, dynamic> json) => _$CalculatedLabelDocumentFromJson(json);



@JsonKey(name: 'kind')
final String $type;



@override
Map<String, dynamic> toJson() {
  return _$CalculatedLabelDocumentToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is CalculatedLabelDocument);
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'ConfidenceLabelDocument.calculated()';
}


}




/// @nodoc
@JsonSerializable()

class AuthorityAlignedLabelDocument implements ConfidenceLabelDocument {
  const AuthorityAlignedLabelDocument({required this.benchmarkReportId,  String? $type}): $type = $type ?? 'AUTHORITY_ALIGNED';
  factory AuthorityAlignedLabelDocument.fromJson(Map<String, dynamic> json) => _$AuthorityAlignedLabelDocumentFromJson(json);

 final  String benchmarkReportId;

@JsonKey(name: 'kind')
final String $type;


/// Create a copy of ConfidenceLabelDocument
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthorityAlignedLabelDocumentCopyWith<AuthorityAlignedLabelDocument> get copyWith => _$AuthorityAlignedLabelDocumentCopyWithImpl<AuthorityAlignedLabelDocument>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AuthorityAlignedLabelDocumentToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthorityAlignedLabelDocument&&(identical(other.benchmarkReportId, benchmarkReportId) || other.benchmarkReportId == benchmarkReportId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,benchmarkReportId);
}

@override
String toString() {
    return 'ConfidenceLabelDocument.authorityAligned(benchmarkReportId: $benchmarkReportId)';
}


}

/// @nodoc
abstract mixin class $AuthorityAlignedLabelDocumentCopyWith<$Res> implements $ConfidenceLabelDocumentCopyWith<$Res> {
  factory $AuthorityAlignedLabelDocumentCopyWith(AuthorityAlignedLabelDocument value, $Res Function(AuthorityAlignedLabelDocument) _then) = _$AuthorityAlignedLabelDocumentCopyWithImpl;
@useResult
$Res call({
 String benchmarkReportId
});




}
/// @nodoc
class _$AuthorityAlignedLabelDocumentCopyWithImpl<$Res>
    implements $AuthorityAlignedLabelDocumentCopyWith<$Res> {
  _$AuthorityAlignedLabelDocumentCopyWithImpl(this._self, this._then);

  final AuthorityAlignedLabelDocument _self;
  final $Res Function(AuthorityAlignedLabelDocument) _then;

/// Create a copy of ConfidenceLabelDocument
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? benchmarkReportId = null,}) {
  return _then(AuthorityAlignedLabelDocument(
benchmarkReportId: null == benchmarkReportId ? _self.benchmarkReportId : benchmarkReportId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
@JsonSerializable()

class VerifiedLabelDocument implements ConfidenceLabelDocument {
  const VerifiedLabelDocument({required this.sourceRef, required this.freshUntilUtcMs,  String? $type}): $type = $type ?? 'VERIFIED';
  factory VerifiedLabelDocument.fromJson(Map<String, dynamic> json) => _$VerifiedLabelDocumentFromJson(json);

 final  String sourceRef;
 final  int freshUntilUtcMs;

@JsonKey(name: 'kind')
final String $type;


/// Create a copy of ConfidenceLabelDocument
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VerifiedLabelDocumentCopyWith<VerifiedLabelDocument> get copyWith => _$VerifiedLabelDocumentCopyWithImpl<VerifiedLabelDocument>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VerifiedLabelDocumentToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is VerifiedLabelDocument&&(identical(other.sourceRef, sourceRef) || other.sourceRef == sourceRef)&&(identical(other.freshUntilUtcMs, freshUntilUtcMs) || other.freshUntilUtcMs == freshUntilUtcMs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,sourceRef,freshUntilUtcMs);
}

@override
String toString() {
    return 'ConfidenceLabelDocument.verified(sourceRef: $sourceRef, freshUntilUtcMs: $freshUntilUtcMs)';
}


}

/// @nodoc
abstract mixin class $VerifiedLabelDocumentCopyWith<$Res> implements $ConfidenceLabelDocumentCopyWith<$Res> {
  factory $VerifiedLabelDocumentCopyWith(VerifiedLabelDocument value, $Res Function(VerifiedLabelDocument) _then) = _$VerifiedLabelDocumentCopyWithImpl;
@useResult
$Res call({
 String sourceRef, int freshUntilUtcMs
});




}
/// @nodoc
class _$VerifiedLabelDocumentCopyWithImpl<$Res>
    implements $VerifiedLabelDocumentCopyWith<$Res> {
  _$VerifiedLabelDocumentCopyWithImpl(this._self, this._then);

  final VerifiedLabelDocument _self;
  final $Res Function(VerifiedLabelDocument) _then;

/// Create a copy of ConfidenceLabelDocument
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? sourceRef = null,Object? freshUntilUtcMs = null,}) {
  return _then(VerifiedLabelDocument(
sourceRef: null == sourceRef ? _self.sourceRef : sourceRef // ignore: cast_nullable_to_non_nullable
as String,freshUntilUtcMs: null == freshUntilUtcMs ? _self.freshUntilUtcMs : freshUntilUtcMs // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
@JsonSerializable()

class EstimatedLabelDocument implements ConfidenceLabelDocument {
  const EstimatedLabelDocument({required this.rangeMinutes,  String? $type}): $type = $type ?? 'ESTIMATED';
  factory EstimatedLabelDocument.fromJson(Map<String, dynamic> json) => _$EstimatedLabelDocumentFromJson(json);

 final  int rangeMinutes;

@JsonKey(name: 'kind')
final String $type;


/// Create a copy of ConfidenceLabelDocument
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EstimatedLabelDocumentCopyWith<EstimatedLabelDocument> get copyWith => _$EstimatedLabelDocumentCopyWithImpl<EstimatedLabelDocument>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EstimatedLabelDocumentToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is EstimatedLabelDocument&&(identical(other.rangeMinutes, rangeMinutes) || other.rangeMinutes == rangeMinutes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,rangeMinutes);
}

@override
String toString() {
    return 'ConfidenceLabelDocument.estimated(rangeMinutes: $rangeMinutes)';
}


}

/// @nodoc
abstract mixin class $EstimatedLabelDocumentCopyWith<$Res> implements $ConfidenceLabelDocumentCopyWith<$Res> {
  factory $EstimatedLabelDocumentCopyWith(EstimatedLabelDocument value, $Res Function(EstimatedLabelDocument) _then) = _$EstimatedLabelDocumentCopyWithImpl;
@useResult
$Res call({
 int rangeMinutes
});




}
/// @nodoc
class _$EstimatedLabelDocumentCopyWithImpl<$Res>
    implements $EstimatedLabelDocumentCopyWith<$Res> {
  _$EstimatedLabelDocumentCopyWithImpl(this._self, this._then);

  final EstimatedLabelDocument _self;
  final $Res Function(EstimatedLabelDocument) _then;

/// Create a copy of ConfidenceLabelDocument
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? rangeMinutes = null,}) {
  return _then(EstimatedLabelDocument(
rangeMinutes: null == rangeMinutes ? _self.rangeMinutes : rangeMinutes // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
@JsonSerializable()

class ObservedLabelDocument implements ConfidenceLabelDocument {
  const ObservedLabelDocument({required this.count, required this.lastSeenUtcMs,  String? $type}): $type = $type ?? 'OBSERVED';
  factory ObservedLabelDocument.fromJson(Map<String, dynamic> json) => _$ObservedLabelDocumentFromJson(json);

 final  int count;
 final  int lastSeenUtcMs;

@JsonKey(name: 'kind')
final String $type;


/// Create a copy of ConfidenceLabelDocument
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ObservedLabelDocumentCopyWith<ObservedLabelDocument> get copyWith => _$ObservedLabelDocumentCopyWithImpl<ObservedLabelDocument>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ObservedLabelDocumentToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ObservedLabelDocument&&(identical(other.count, count) || other.count == count)&&(identical(other.lastSeenUtcMs, lastSeenUtcMs) || other.lastSeenUtcMs == lastSeenUtcMs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,count,lastSeenUtcMs);
}

@override
String toString() {
    return 'ConfidenceLabelDocument.observed(count: $count, lastSeenUtcMs: $lastSeenUtcMs)';
}


}

/// @nodoc
abstract mixin class $ObservedLabelDocumentCopyWith<$Res> implements $ConfidenceLabelDocumentCopyWith<$Res> {
  factory $ObservedLabelDocumentCopyWith(ObservedLabelDocument value, $Res Function(ObservedLabelDocument) _then) = _$ObservedLabelDocumentCopyWithImpl;
@useResult
$Res call({
 int count, int lastSeenUtcMs
});




}
/// @nodoc
class _$ObservedLabelDocumentCopyWithImpl<$Res>
    implements $ObservedLabelDocumentCopyWith<$Res> {
  _$ObservedLabelDocumentCopyWithImpl(this._self, this._then);

  final ObservedLabelDocument _self;
  final $Res Function(ObservedLabelDocument) _then;

/// Create a copy of ConfidenceLabelDocument
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? count = null,Object? lastSeenUtcMs = null,}) {
  return _then(ObservedLabelDocument(
count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,lastSeenUtcMs: null == lastSeenUtcMs ? _self.lastSeenUtcMs : lastSeenUtcMs // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
@JsonSerializable()

class UnknownLabelDocument implements ConfidenceLabelDocument {
  const UnknownLabelDocument({required this.reasonCode,  String? $type}): $type = $type ?? 'UNKNOWN';
  factory UnknownLabelDocument.fromJson(Map<String, dynamic> json) => _$UnknownLabelDocumentFromJson(json);

 final  String reasonCode;

@JsonKey(name: 'kind')
final String $type;


/// Create a copy of ConfidenceLabelDocument
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UnknownLabelDocumentCopyWith<UnknownLabelDocument> get copyWith => _$UnknownLabelDocumentCopyWithImpl<UnknownLabelDocument>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UnknownLabelDocumentToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is UnknownLabelDocument&&(identical(other.reasonCode, reasonCode) || other.reasonCode == reasonCode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,reasonCode);
}

@override
String toString() {
    return 'ConfidenceLabelDocument.unknown(reasonCode: $reasonCode)';
}


}

/// @nodoc
abstract mixin class $UnknownLabelDocumentCopyWith<$Res> implements $ConfidenceLabelDocumentCopyWith<$Res> {
  factory $UnknownLabelDocumentCopyWith(UnknownLabelDocument value, $Res Function(UnknownLabelDocument) _then) = _$UnknownLabelDocumentCopyWithImpl;
@useResult
$Res call({
 String reasonCode
});




}
/// @nodoc
class _$UnknownLabelDocumentCopyWithImpl<$Res>
    implements $UnknownLabelDocumentCopyWith<$Res> {
  _$UnknownLabelDocumentCopyWithImpl(this._self, this._then);

  final UnknownLabelDocument _self;
  final $Res Function(UnknownLabelDocument) _then;

/// Create a copy of ConfidenceLabelDocument
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? reasonCode = null,}) {
  return _then(UnknownLabelDocument(
reasonCode: null == reasonCode ? _self.reasonCode : reasonCode // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
