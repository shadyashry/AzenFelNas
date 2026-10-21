// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'event_origin_document.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
EventOriginDocument _$EventOriginDocumentFromJson(
  Map<String, dynamic> json
) {
        switch (json['kind']) {
                  case 'PRIMARY':
          return PrimaryOriginDocument.fromJson(
            json
          );
                case 'FALLBACK':
          return FallbackOriginDocument.fromJson(
            json
          );
                case 'NO_EVENT':
          return NoEventOriginDocument.fromJson(
            json
          );
        
          default:
            throw CheckedFromJsonException(
  json,
  'kind',
  'EventOriginDocument',
  'Invalid union type "${json['kind']}"!'
);
        }
      
}

/// @nodoc
mixin _$EventOriginDocument {



  /// Serializes this EventOriginDocument to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is EventOriginDocument);
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'EventOriginDocument()';
}


}

/// @nodoc
class $EventOriginDocumentCopyWith<$Res>  {
$EventOriginDocumentCopyWith(EventOriginDocument _, $Res Function(EventOriginDocument) __);
}


/// Adds pattern-matching-related methods to [EventOriginDocument].
extension EventOriginDocumentPatterns on EventOriginDocument {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( PrimaryOriginDocument value)?  primary,TResult Function( FallbackOriginDocument value)?  fallback,TResult Function( NoEventOriginDocument value)?  noEvent,required TResult orElse(),}){
final _that = this;
switch (_that) {
case PrimaryOriginDocument() when primary != null:
return primary(_that);case FallbackOriginDocument() when fallback != null:
return fallback(_that);case NoEventOriginDocument() when noEvent != null:
return noEvent(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( PrimaryOriginDocument value)  primary,required TResult Function( FallbackOriginDocument value)  fallback,required TResult Function( NoEventOriginDocument value)  noEvent,}){
final _that = this;
switch (_that) {
case PrimaryOriginDocument():
return primary(_that);case FallbackOriginDocument():
return fallback(_that);case NoEventOriginDocument():
return noEvent(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( PrimaryOriginDocument value)?  primary,TResult? Function( FallbackOriginDocument value)?  fallback,TResult? Function( NoEventOriginDocument value)?  noEvent,}){
final _that = this;
switch (_that) {
case PrimaryOriginDocument() when primary != null:
return primary(_that);case FallbackOriginDocument() when fallback != null:
return fallback(_that);case NoEventOriginDocument() when noEvent != null:
return noEvent(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  primary,TResult Function(@HighLatitudeMethodDocumentConverter()  HighLatitudeMethodDocument method)?  fallback,TResult Function( NoEventReasonCode reason)?  noEvent,required TResult orElse(),}) {final _that = this;
switch (_that) {
case PrimaryOriginDocument() when primary != null:
return primary();case FallbackOriginDocument() when fallback != null:
return fallback(_that.method);case NoEventOriginDocument() when noEvent != null:
return noEvent(_that.reason);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  primary,required TResult Function(@HighLatitudeMethodDocumentConverter()  HighLatitudeMethodDocument method)  fallback,required TResult Function( NoEventReasonCode reason)  noEvent,}) {final _that = this;
switch (_that) {
case PrimaryOriginDocument():
return primary();case FallbackOriginDocument():
return fallback(_that.method);case NoEventOriginDocument():
return noEvent(_that.reason);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  primary,TResult? Function(@HighLatitudeMethodDocumentConverter()  HighLatitudeMethodDocument method)?  fallback,TResult? Function( NoEventReasonCode reason)?  noEvent,}) {final _that = this;
switch (_that) {
case PrimaryOriginDocument() when primary != null:
return primary();case FallbackOriginDocument() when fallback != null:
return fallback(_that.method);case NoEventOriginDocument() when noEvent != null:
return noEvent(_that.reason);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class PrimaryOriginDocument implements EventOriginDocument {
  const PrimaryOriginDocument({ String? $type}): $type = $type ?? 'PRIMARY';
  factory PrimaryOriginDocument.fromJson(Map<String, dynamic> json) => _$PrimaryOriginDocumentFromJson(json);



@JsonKey(name: 'kind')
final String $type;



@override
Map<String, dynamic> toJson() {
  return _$PrimaryOriginDocumentToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is PrimaryOriginDocument);
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'EventOriginDocument.primary()';
}


}




/// @nodoc
@JsonSerializable()

class FallbackOriginDocument implements EventOriginDocument {
  const FallbackOriginDocument({@HighLatitudeMethodDocumentConverter() required this.method,  String? $type}): $type = $type ?? 'FALLBACK';
  factory FallbackOriginDocument.fromJson(Map<String, dynamic> json) => _$FallbackOriginDocumentFromJson(json);

@HighLatitudeMethodDocumentConverter() final  HighLatitudeMethodDocument method;

@JsonKey(name: 'kind')
final String $type;


/// Create a copy of EventOriginDocument
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FallbackOriginDocumentCopyWith<FallbackOriginDocument> get copyWith => _$FallbackOriginDocumentCopyWithImpl<FallbackOriginDocument>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FallbackOriginDocumentToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is FallbackOriginDocument&&(identical(other.method, method) || other.method == method));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,method);
}

@override
String toString() {
    return 'EventOriginDocument.fallback(method: $method)';
}


}

/// @nodoc
abstract mixin class $FallbackOriginDocumentCopyWith<$Res> implements $EventOriginDocumentCopyWith<$Res> {
  factory $FallbackOriginDocumentCopyWith(FallbackOriginDocument value, $Res Function(FallbackOriginDocument) _then) = _$FallbackOriginDocumentCopyWithImpl;
@useResult
$Res call({
@HighLatitudeMethodDocumentConverter() HighLatitudeMethodDocument method
});


$HighLatitudeMethodDocumentCopyWith<$Res> get method;

}
/// @nodoc
class _$FallbackOriginDocumentCopyWithImpl<$Res>
    implements $FallbackOriginDocumentCopyWith<$Res> {
  _$FallbackOriginDocumentCopyWithImpl(this._self, this._then);

  final FallbackOriginDocument _self;
  final $Res Function(FallbackOriginDocument) _then;

/// Create a copy of EventOriginDocument
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? method = null,}) {
  return _then(FallbackOriginDocument(
method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as HighLatitudeMethodDocument,
  ));
}

/// Create a copy of EventOriginDocument
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HighLatitudeMethodDocumentCopyWith<$Res> get method {
  
  return $HighLatitudeMethodDocumentCopyWith<$Res>(_self.method, (value) {
    return _then(_self.copyWith(method: value));
  });
}
}

/// @nodoc
@JsonSerializable()

class NoEventOriginDocument implements EventOriginDocument {
  const NoEventOriginDocument({required this.reason,  String? $type}): $type = $type ?? 'NO_EVENT';
  factory NoEventOriginDocument.fromJson(Map<String, dynamic> json) => _$NoEventOriginDocumentFromJson(json);

 final  NoEventReasonCode reason;

@JsonKey(name: 'kind')
final String $type;


/// Create a copy of EventOriginDocument
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NoEventOriginDocumentCopyWith<NoEventOriginDocument> get copyWith => _$NoEventOriginDocumentCopyWithImpl<NoEventOriginDocument>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NoEventOriginDocumentToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is NoEventOriginDocument&&(identical(other.reason, reason) || other.reason == reason));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,reason);
}

@override
String toString() {
    return 'EventOriginDocument.noEvent(reason: $reason)';
}


}

/// @nodoc
abstract mixin class $NoEventOriginDocumentCopyWith<$Res> implements $EventOriginDocumentCopyWith<$Res> {
  factory $NoEventOriginDocumentCopyWith(NoEventOriginDocument value, $Res Function(NoEventOriginDocument) _then) = _$NoEventOriginDocumentCopyWithImpl;
@useResult
$Res call({
 NoEventReasonCode reason
});




}
/// @nodoc
class _$NoEventOriginDocumentCopyWithImpl<$Res>
    implements $NoEventOriginDocumentCopyWith<$Res> {
  _$NoEventOriginDocumentCopyWithImpl(this._self, this._then);

  final NoEventOriginDocument _self;
  final $Res Function(NoEventOriginDocument) _then;

/// Create a copy of EventOriginDocument
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? reason = null,}) {
  return _then(NoEventOriginDocument(
reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as NoEventReasonCode,
  ));
}


}

// dart format on
