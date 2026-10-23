import 'dart:convert';

import 'package:daily_muslim/features/athan/domain/athan_platform_ports.dart';
import 'package:daily_muslim/features/athan/domain/native_event.dart';
import 'package:dm_contracts/athan_scheduler_api.dart';
import 'package:dm_contracts/dm_contracts.dart';
import 'package:flutter/services.dart';
import 'package:json_annotation/json_annotation.dart';

/// [DrainNativeEvents] over pigeon `AthanSchedulerApi.drainEvents` (§7.8):
/// each line is parsed against `event_log.v1`; lines that fail are dropped
/// (the closed attrs allow-list is the privacy guard, REQ-PRIV-001).
final class PigeonDrainNativeEvents implements DrainNativeEvents {
  /// The adapter draining [_api] into [_append].
  const new(this._api, this._append);

  final AthanSchedulerApi _api;
  final Future<void> Function(EventLogEntry entry) _append;

  @override
  Future<List<NativeEvent>> call() async {
    final List<String> lines;
    try {
      lines = await _api.drainEvents();
    } on PlatformException {
      return const [];
    }
    final events = <NativeEvent>[];
    for (final line in lines) {
      if (parse(line) case final EventLogEntry entry) {
        await _append(entry);
        events.add(NativeEvent(entry.code, entryId: entry.attrs.entryId));
      }
    }
    return events;
  }

  /// The entry in [line], or null when it is not a valid `event_log.v1`.
  static EventLogEntry? parse(String line) {
    try {
      return switch (jsonDecode(line)) {
        final Map<String, Object?> json => EventLogEntry.fromJson(json),
        _ => null,
      };
    } on FormatException {
      return null;
    } on CheckedFromJsonException {
      return null;
    }
  }
}
