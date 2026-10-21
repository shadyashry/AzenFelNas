import 'package:json_annotation/json_annotation.dart';

/// Wire form of `ElevationSource` (§6.2) in `bench_request.v1`.
@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum ElevationSourceCode {
  /// `GNSS`.
  gnss,

  /// `MANUAL`.
  manual,
}
