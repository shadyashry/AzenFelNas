// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calculation_trace_document.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CalculationTraceDocument _$CalculationTraceDocumentFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('_CalculationTraceDocument', json, ($checkedConvert) {
  $checkKeys(
    json,
    allowedKeys: const [
      'schemaVersion',
      'calculationId',
      'day',
      'inputs',
      'provenance',
      'times',
    ],
  );
  final val = _CalculationTraceDocument(
    schemaVersion: $checkedConvert('schemaVersion', (v) => (v as num).toInt()),
    calculationId: $checkedConvert('calculationId', (v) => v as String),
    day: $checkedConvert('day', (v) => v as String),
    inputs: $checkedConvert(
      'inputs',
      (v) => TraceInputsDocument.fromJson(v as Map<String, dynamic>),
    ),
    provenance: $checkedConvert(
      'provenance',
      (v) => TraceProvenanceDocument.fromJson(v as Map<String, dynamic>),
    ),
    times: $checkedConvert(
      'times',
      (v) => (v as List<dynamic>)
          .map((e) => TraceTimeDocument.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
  );
  return val;
});

Map<String, dynamic> _$CalculationTraceDocumentToJson(
  _CalculationTraceDocument instance,
) => <String, dynamic>{
  'schemaVersion': instance.schemaVersion,
  'calculationId': instance.calculationId,
  'day': instance.day,
  'inputs': instance.inputs.toJson(),
  'provenance': instance.provenance.toJson(),
  'times': instance.times.map((e) => e.toJson()).toList(),
};
