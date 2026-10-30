// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quran_edition.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_QuranEdition _$QuranEditionFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_QuranEdition', json, ($checkedConvert) {
      $checkKeys(
        json,
        allowedKeys: const [
          'riwayah',
          'publisher',
          'printEdition',
          'pageCount',
          'suraCount',
          'verseCount',
          'sources',
        ],
      );
      final val = _QuranEdition(
        riwayah: $checkedConvert('riwayah', (v) => v as String),
        publisher: $checkedConvert('publisher', (v) => v as String),
        printEdition: $checkedConvert('printEdition', (v) => v as String),
        pageCount: $checkedConvert('pageCount', (v) => (v as num).toInt()),
        suraCount: $checkedConvert('suraCount', (v) => (v as num).toInt()),
        verseCount: $checkedConvert('verseCount', (v) => (v as num).toInt()),
        sources: $checkedConvert(
          'sources',
          (v) => (v as List<dynamic>)
              .map((e) => QuranSource.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$QuranEditionToJson(_QuranEdition instance) =>
    <String, dynamic>{
      'riwayah': instance.riwayah,
      'publisher': instance.publisher,
      'printEdition': instance.printEdition,
      'pageCount': instance.pageCount,
      'suraCount': instance.suraCount,
      'verseCount': instance.verseCount,
      'sources': instance.sources.map((e) => e.toJson()).toList(),
    };
