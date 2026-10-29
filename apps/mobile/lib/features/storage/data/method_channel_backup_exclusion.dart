import 'package:daily_muslim/features/storage/domain/exclude_from_backup.dart';
import 'package:flutter/services.dart';

/// iOS: sets `URLResourceValues.isExcludedFromBackup` on the directory
/// through the `BackupExclusionChannel` in `ios/Runner/AppDelegate.swift`
/// (§15 D76; moves to pigeon with the other platform APIs in S20).
final class MethodChannelBackupExclusion implements ExcludeFromBackup {
  /// The adapter on [channel].
  const new([this.channel = const MethodChannel(channelName)]);

  /// The channel name shared with the Swift side.
  static const channelName = 'app.azenfelnas/backup_exclusion';

  /// The method name shared with the Swift side.
  static const method = 'excludeFromBackup';

  /// The channel.
  final MethodChannel channel;

  @override
  Future<bool> call(String directoryPath) async {
    try {
      return await channel.invokeMethod<bool>(method, {
            'path': directoryPath,
          }) ??
          false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }
}
