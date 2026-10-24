import 'dart:convert';

import 'package:daily_muslim/features/athan/application/write_widget_snapshot.dart';
import 'package:dm_contracts/athan_scheduler_api.dart';
import 'package:dm_contracts/dm_contracts.dart';
import 'package:flutter/services.dart';

/// [WriteWidgetSnapshot] over pigeon `AthanSchedulerApi.writeSnapshot`
/// (§7.8); a missing host is a refusal.
final class PigeonWriteWidgetSnapshot implements WriteWidgetSnapshot {
  /// The adapter over [_api].
  const new(this._api);

  final AthanSchedulerApi _api;

  @override
  Future<bool> call(Snapshot snapshot) async {
    try {
      return await _api.writeSnapshot(jsonEncode(snapshot.toJson()));
    } on PlatformException {
      return false;
    }
  }
}
