// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'evidence_document.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_EvidenceDocument _$EvidenceDocumentFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_EvidenceDocument', json, ($checkedConvert) {
      $checkKeys(
        json,
        allowedKeys: const [
          'sources',
          'benchmarkSet',
          'holdoutReport',
          'benchmarkReportId',
        ],
      );
      final val = _EvidenceDocument(
        sources: $checkedConvert(
          'sources',
          (v) => (v as List<dynamic>)
              .map(
                (e) =>
                    EvidenceSourceDocument.fromJson(e as Map<String, dynamic>),
              )
              .toList(),
        ),
        benchmarkSet: $checkedConvert('benchmarkSet', (v) => v as String),
        holdoutReport: $checkedConvert('holdoutReport', (v) => v as String?),
        benchmarkReportId: $checkedConvert(
          'benchmarkReportId',
          (v) => v as String?,
        ),
      );
      return val;
    });

Map<String, dynamic> _$EvidenceDocumentToJson(_EvidenceDocument instance) =>
    <String, dynamic>{
      'sources': instance.sources.map((e) => e.toJson()).toList(),
      'benchmarkSet': instance.benchmarkSet,
      'holdoutReport': instance.holdoutReport,
      'benchmarkReportId': instance.benchmarkReportId,
    };
