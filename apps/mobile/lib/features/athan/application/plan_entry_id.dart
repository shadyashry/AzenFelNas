import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:dm_contracts/dm_contracts.dart';
import 'package:geo_salah_core/geo_salah_core.dart';

/// The deterministic plan entry id (§7.7): lowercase hex of
/// `sha256(UTF-8 "contextId|day|event|kind")[0:16]`, with the wire names of
/// event and kind and an empty event for `HORIZON_WARNING` (§15 D80).
///
/// The same entry in two generations has the same id, so native code
/// reconciles by id and derives request codes from it (REQ-ALM-021).
abstract final class PlanEntryId {
  /// The id of the [kind] entry of [event] on [day] (`YYYY-MM-DD`).
  static String of({
    required String contextId,
    required String day,
    required ScheduleEntryKind kind,
    PrayerEventCode? event,
  }) {
    final eventWire = event == null ? '' : _wire(event.name);
    final key = '$contextId|$day|$eventWire|${_wire(kind.name)}';
    return sha256.convert(utf8.encode(key)).toString().substring(0, 16);
  }

  /// `preReminder` → `PRE_REMINDER`: the screaming-snake wire name.
  static String _wire(String name) =>
      name.replaceAllMapped(RegExp('[A-Z]'), (m) => '_${m[0]}').toUpperCase();
}
