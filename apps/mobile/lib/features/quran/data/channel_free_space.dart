import 'package:daily_muslim/features/quran/domain/build_search_index.dart';
import 'package:flutter/services.dart';

/// [ReadFreeSpace] over the `dm/storage` channel: `File.usableSpace` on
/// Android, `volumeAvailableCapacityForImportantUsage` on iOS (§15 D106).
/// `null` when the platform has no handler; the download then relies on
/// the write itself failing with a full disk.
final class ChannelFreeSpace implements ReadFreeSpace {
  /// The adapter.
  const new();

  static const _channel = MethodChannel('dm/storage');

  @override
  Future<int?> call(String directory) async {
    try {
      return await _channel.invokeMethod<int>('usableBytes', directory);
    } on MissingPluginException {
      return null;
    } on PlatformException {
      return null;
    }
  }
}
