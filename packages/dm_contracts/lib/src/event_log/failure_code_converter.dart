import 'package:dm_core_types/dm_core_types.dart';
import 'package:json_annotation/json_annotation.dart';

/// Reads and writes a [FailureCode] by its Appendix J wire name.
final class FailureCodeConverter implements JsonConverter<FailureCode, String> {
  /// Creates the converter.
  const new();

  @override
  FailureCode fromJson(String json) =>
      FailureCode.fromWire(json) ??
      (throw FormatException('Unknown failure code: $json'));

  @override
  String toJson(FailureCode code) => code.wire;
}
