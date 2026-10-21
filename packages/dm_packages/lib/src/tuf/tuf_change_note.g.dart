// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tuf_change_note.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TufChangeNote _$TufChangeNoteFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_TufChangeNote', json, ($checkedConvert) {
      $checkKeys(json, allowedKeys: const ['ar', 'en']);
      final val = _TufChangeNote(
        ar: $checkedConvert('ar', (v) => v as String),
        en: $checkedConvert('en', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$TufChangeNoteToJson(_TufChangeNote instance) =>
    <String, dynamic>{'ar': instance.ar, 'en': instance.en};
