import 'dart:async';

import 'package:daily_muslim/features/athan/domain/voice_ports.dart';
import 'package:flutter/services.dart';

/// [VoiceAudioHost] and [VoicePreview] over the `dm/athan_audio` channel
/// (§15 D111). Android copies a verified voice to the device-protected
/// `athan/<soundId>.m4a` the alarm service plays (§15 D94) and previews
/// files on the alarm stream through athan-core's `PreviewPlayer`, which an
/// Athan stops and which never starts over one. Without a handler (iOS
/// until AthanKit takes downloaded voices) nothing installs or plays.
final class ChannelVoiceAudio implements VoiceAudioHost, VoicePreview {
  /// The adapter on [_channel].
  new([this._channel = const MethodChannel(channelName)]) {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'previewEnded') _ended.add(null);
    });
  }

  /// The channel name shared with `MainActivity`.
  static const String channelName = 'dm/athan_audio';

  final MethodChannel _channel;
  final StreamController<void> _ended = StreamController<void>.broadcast();

  @override
  Future<bool> install(String soundId, String path, String sha256) =>
      _bool('install', {'soundId': soundId, 'path': path, 'sha256': sha256});

  @override
  Future<void> uninstall(String soundId) =>
      _bool('remove', {'soundId': soundId});

  @override
  Future<bool> play(String path) => _bool('preview', {'path': path});

  @override
  Future<void> stop() => _bool('stopPreview', null);

  @override
  Stream<void> get ended => _ended.stream;

  Future<bool> _bool(String method, Object? arguments) async {
    try {
      return await _channel.invokeMethod<bool>(method, arguments) ?? false;
    } on MissingPluginException {
      return false;
    } on PlatformException {
      return false;
    }
  }
}
