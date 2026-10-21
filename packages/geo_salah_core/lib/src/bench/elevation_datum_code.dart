import 'package:json_annotation/json_annotation.dart';

/// Wire form of `ElevationDatum` (§6.2) in `bench_request.v1`.
@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum ElevationDatumCode {
  /// `WGS84_ELLIPSOID`.
  wgs84Ellipsoid,

  /// `EGM2008`.
  egm2008,

  /// `UNKNOWN`.
  unknown,
}
