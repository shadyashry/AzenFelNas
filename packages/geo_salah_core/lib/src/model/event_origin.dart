import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:geo_salah_core/src/model/high_latitude_method.dart';
import 'package:geo_salah_core/src/model/no_event_reason.dart';

part 'event_origin.freezed.dart';

/// How a prayer time was obtained (§6.2, REQ-DOM-002): its rule's own root,
/// a high-latitude fallback, or no time at all. A fallback is never used
/// where the rule has a root.
@freezed
sealed class EventOrigin with _$EventOrigin {
  /// The event's rule produced the time.
  const factory primary() = Primary;

  /// The high-latitude [method] produced the time.
  const factory fallback(HighLatitudeMethod method) = Fallback;

  /// No time exists, for [reason].
  const factory noEvent(NoEventReason reason) = NoEvent;
}
