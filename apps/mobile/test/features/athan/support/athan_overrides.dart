import 'package:daily_muslim/features/athan/application/record_athan_test_result.dart';
import 'package:daily_muslim/features/athan/data/event_log_last_test.dart';
import 'package:daily_muslim/features/athan/domain/athan_grant.dart';
import 'package:daily_muslim/features/athan/domain/athan_voice.dart';
import 'package:daily_muslim/features/athan/domain/read_athan_sounds.dart';
import 'package:daily_muslim/features/athan/presentation/athan_providers.dart';
import 'package:daily_muslim/features/athan/presentation/athan_voice_providers.dart';
import 'package:daily_muslim/features/quran/presentation/quran_providers.dart';
import 'package:dm_contracts/dm_contracts.dart';
import 'package:flutter_riverpod/misc.dart';

import '../../../support/fake_athan_grant.dart';
import 'fake_athan_platform.dart';
import 'fake_voices.dart';

final class _Sounds implements ReadAthanSounds {
  const new(this._ids);

  final List<String> _ids;

  @override
  Future<List<String>> call() async => _ids;
}

/// Binds every Athan port to [platform], the event log to [log], the
/// bundled sounds to [sounds], the voice catalog to [voices] (on [disk],
/// [host] and [preview]) and permission prompts to [grant]; ticks are
/// driven by hand.
List<Override> athanOverrides(
  FakeAthanPlatform platform,
  List<EventLogEntry> log, {
  List<String> sounds = const [],
  List<AthanVoice> voices = const [],
  FakeVoiceDisk? disk,
  FakeVoiceAudioHost? host,
  FakeVoicePreview? preview,
  RequestAthanGrant? grant,
}) {
  final voiceDisk = disk ?? FakeVoiceDisk();
  return [
    readVoiceCatalogProvider.overrideWithValue(FakeVoiceCatalog(voices)),
    voiceDiskProvider.overrideWithValue(voiceDisk),
    voiceOriginProvider.overrideWithValue(FakeVoiceOrigin(voiceDisk)),
    voiceAudioHostProvider.overrideWithValue(host ?? FakeVoiceAudioHost()),
    voicePreviewProvider.overrideWithValue(preview ?? FakeVoicePreview()),
    readFreeSpaceProvider.overrideWithValue(const FakeFreeSpace(null)),
    requestAthanGrantProvider.overrideWithValue(grant ?? FakeAthanGrant()),
    readPlatformHealthProvider.overrideWithValue(platform),
    armAthanTestProvider.overrideWithValue(platform.arm),
    drainNativeEventsProvider.overrideWithValue(platform.drain),
    recordAthanTestResultProvider.overrideWithValue(
      RecordAthanTestResult((e) async => log.add(e)),
    ),
    readLastTestHeardProvider.overrideWithValue(
      EventLogLastTest(() async => log),
    ),
    readAthanSoundsProvider.overrideWithValue(_Sounds(sounds)),
    athanTicksProvider.overrideWith((ref) => const Stream<int>.empty()),
  ];
}
