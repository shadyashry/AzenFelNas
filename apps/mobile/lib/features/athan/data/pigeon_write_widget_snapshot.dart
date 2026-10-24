import 'package:daily_muslim/features/athan/domain/write_widget_snapshot.dart';
import 'package:dm_contracts/athan_scheduler_api.dart';
import 'package:flutter/services.dart';

/// [WriteWidgetSnapshot] over pigeon `AthanSchedulerApi.writeSnapshot`
/// (§7.8); a missing host is a refusal.
final class PigeonWriteWidgetSnapshot implements WriteWidgetSnapshot {
  /// The adapter over [_api].
  const new(this._api);

  final AthanSchedulerApi _api;

  @override
  Future<bool> call(EncodedSnapshot snapshot) async {
    try {
      return await _api.writeSnapshot(snapshot.json);
    } on PlatformException {
      return false;
    }
  }
}
