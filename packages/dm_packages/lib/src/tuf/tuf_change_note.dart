import 'package:freezed_annotation/freezed_annotation.dart';

part 'tuf_change_note.freezed.dart';
part 'tuf_change_note.g.dart';

/// Change note shown when displayed times change.
@freezed
abstract class TufChangeNote with _$TufChangeNote {
  /// Creates a [TufChangeNote].
  const factory({
    /// Arabic.
    required String ar,

    /// English.
    required String en,
  }) = _TufChangeNote;

  /// Decodes [json]; throws `CheckedFromJsonException` when it does not
  /// have the schema's shape.
  factory fromJson(Map<String, Object?> json) => _$TufChangeNoteFromJson(json);
}
