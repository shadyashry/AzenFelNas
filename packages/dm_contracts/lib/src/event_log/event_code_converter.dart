import 'package:dm_core_types/dm_core_types.dart';
import 'package:json_annotation/json_annotation.dart';

/// Reads and writes an [EventCode] by its Appendix J wire name.
final class EventCodeConverter implements JsonConverter<EventCode, String> {
  /// Creates the converter.
  const new();

  @override
  EventCode fromJson(String json) =>
      EventCode.fromWire(json) ??
      (throw FormatException('Unknown event code: $json'));

  @override
  String toJson(EventCode code) => code.wire;
}
