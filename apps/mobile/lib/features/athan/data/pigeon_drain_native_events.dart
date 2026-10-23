import 'dart:convert';

import 'package:daily_muslim/features/athan/application/athan_platform_ports.dart';
import 'package:dm_contracts/athan_scheduler_api.dart';
import 'package:dm_contracts/dm_contracts.dart';
import 'package:flutter/services.dart';
import 'package:json_annotation/json_annotation.dart';

/// [DrainNativeEvents] over pigeon `AthanSchedulerApi.drainEvents` (§7.8):
/// each line is parsed against `event_log.v1`; lines that fail are dropped
/// (the closed attrs allow-list is the privacy guard, REQ-PRIV-001).
final class PigeonDrainNativeEvents implements DrainNativeEvents {
  /// The adapter over [_api].
  const new(this._api);

  final AthanSchedulerApi _api;

  @override
  Future<List<EventLogEntry>> call() async {
    final List<String> lines;
    try {
      lines = await _api.drainEvents();
    } on PlatformException {
      return const [];
    }
    return [
      for (final line in lines)
        if (parse(line) case final EventLogEntry entry) entry,
    ];
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
