import 'package:json_annotation/json_annotation.dart';

/// Wire form of `ObserverSource` (§6.2) in `bench_request.v1`.
@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum ObserverSourceCode {
  /// `DEVICE`.
  device,

  /// `PINNED`.
  pinned,

  /// `MANUAL`.
  manual,

  /// `MOSQUE`.
  mosque,

  /// `BENCHMARK`.
  benchmark,
}
