import 'package:daily_muslim/features/athan/domain/athan_voice.dart';
import 'package:daily_muslim/features/athan/domain/read_athan_sound_names.dart';
import 'package:daily_muslim/features/athan/domain/voice_ports.dart';
import 'package:daily_muslim/features/athan/presentation/athan_voices_page.dart';
import 'package:daily_muslim/features/settings/domain/setting_key.dart';
import 'package:daily_muslim/features/settings/domain/settings_ports.dart';
import 'package:daily_muslim/features/settings/presentation/settings_providers.dart';
import 'package:dm_contracts/dm_contracts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/state_harness.dart';
import '../support/athan_overrides.dart';
import '../support/fake_athan_platform.dart';
import '../support/fake_voices.dart';

final class _Writes implements WriteSetting {
  final writes = <String, Object?>{};

  @override
  Future<void> write<T>(SettingKey<T> key, T value) async =>
      writes[key.wire] = value;
}

final AthanVoice _standard = fakeVoice('std');
final AthanVoice _fajr = fakeVoice(
  'fjr',
  designation: VoiceDesignation.fajr,
  review: VoiceReview.pending,
);

Widget _app(
  Widget page, {
  required FakeVoiceDisk disk,
  FakeVoiceAudioHost? host,
  FakeVoicePreview? preview,
  _Writes? writes,
  String? athan,
  String? fajr,
  List<String> bundled = const [],
  Map<String, SoundName> names = const {},
  Locale locale = const Locale('en'),
}) => localizedApp(
  Scaffold(body: page),
  locale: locale,
  overrides: [
    ...athanOverrides(
      FakeAthanPlatform(),
      <EventLogEntry>[],
      voices: [_standard, _fajr],
      sounds: bundled,
      soundNames: names,
      disk: disk,
      host: host,
      preview: preview,
    ),
    writeSettingProvider.overrideWithValue(writes ?? _Writes()),
    athanSoundSettingProvider.overrideWith((ref) => Stream.value(athan)),
    fajrSoundSettingProvider.overrideWith((ref) => Stream.value(fajr)),
  ],
);

void _phone(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 2.625;
  addTearDown(tester.view.reset);
}

void main() {
  testWidgets('REQ-ALM-055 a voice bundled with the app is the Athan sound '
      'until the user chooses, and is a choice, never a download', (
    tester,
  ) async {
    _phone(tester);
    await tester.pumpWidget(
      _app(
        const AthanVoicesPage(slot: VoiceSlot.athan),
        disk: FakeVoiceDisk(),
        bundled: ['std'],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Voice std'), findsOneWidget);
    expect(find.text('Download'), findsNothing);
    final row = find.ancestor(
      of: find.text('Voice std'),
      matching: find.byType(ListTile),
    );
    expect(
      find.descendant(of: row, matching: find.byIcon(Icons.check_circle)),
      findsOneWidget,
    );
  });

  testWidgets('a bundled voice is shown by its manifest name in the '
      "page's language (§15 D123)", (tester) async {
    _phone(tester);
    const names = {
      'abdelbasit': SoundName(en: 'Abdul Basit', ar: 'عبد الباسط'),
    };
    for (final (locale, name) in [
      (const Locale('en'), 'Abdul Basit'),
      (const Locale('ar'), 'عبد الباسط'),
    ]) {
      await tester.pumpWidget(
        _app(
          const AthanVoicesPage(slot: VoiceSlot.athan),
          disk: FakeVoiceDisk(),
          bundled: ['abdelbasit'],
          names: names,
          locale: locale,
        ),
      );
      await tester.pumpAndSettle();
      final row = find.ancestor(
        of: find.text(name),
        matching: find.byType(ListTile),
      );
      expect(
        find.descendant(of: row, matching: find.byIcon(Icons.check_circle)),
        findsOneWidget,
      );
    }
  });

  testWidgets('REQ-ALM-052 a Fajr voice is offered for Fajr only; Fajr can '
      'follow the Athan voice', (tester) async {
    _phone(tester);
    final disk = FakeVoiceDisk();
    await tester.pumpWidget(
      _app(const AthanVoicesPage(slot: VoiceSlot.athan), disk: disk),
    );
    await tester.pumpAndSettle();
    expect(find.text('Voice std'), findsOneWidget);
    expect(find.text('Voice fjr'), findsNothing);
    expect(find.text('Same as the Athan voice'), findsNothing);
    expect(find.text('Phone alarm tone'), findsOneWidget);

    await tester.pumpWidget(
      _app(const AthanVoicesPage(slot: VoiceSlot.fajr), disk: disk),
    );
    await tester.pumpAndSettle();
    expect(find.text('Voice std'), findsOneWidget);
    expect(find.text('Voice fjr'), findsOneWidget);
    expect(find.text('Same as the Athan voice'), findsOneWidget);
    expect(find.textContaining('Fajr Athan · 3:03'), findsOneWidget);
    expect(
      find.text('Not yet listened to in full: for testing only'),
      findsOneWidget,
    );
    expect(find.textContaining('CC BY 3.0 · Fixture creator'), findsWidgets);
  });

  testWidgets('REQ-ALM-051 Download fetches, checks and installs the voice; '
      'it is then chosen with a tap', (tester) async {
    _phone(tester);
    final disk = FakeVoiceDisk();
    final host = FakeVoiceAudioHost();
    final writes = _Writes();
    await tester.pumpWidget(
      _app(
        const AthanVoicesPage(slot: VoiceSlot.athan),
        disk: disk,
        host: host,
        writes: writes,
      ),
    );
    await tester.pumpAndSettle();
    // Not downloaded: the row cannot be chosen.
    await tester.tap(find.text('Voice std'));
    await tester.pumpAndSettle();
    expect(writes.writes, isEmpty);

    await tester.tap(find.text('Download'));
    await tester.pumpAndSettle();
    expect(host.installed, {'std'});
    expect(disk.files['std'], VoiceFileState.verified);
    expect(find.text('On this phone'), findsOneWidget);

    await tester.tap(find.text('Voice std'));
    await tester.pumpAndSettle();
    expect(writes.writes, {'soundId': 'std'});
  });

  testWidgets('REQ-ALM-054 Listen plays the local file and Stop ends it; the '
      'button follows a preview that ends by itself', (tester) async {
    _phone(tester);
    final disk = FakeVoiceDisk()..files['std'] = VoiceFileState.verified;
    final preview = FakeVoicePreview();
    await tester.pumpWidget(
      _app(
        const AthanVoicesPage(slot: VoiceSlot.athan),
        disk: disk,
        preview: preview,
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Listen'));
    await tester.pumpAndSettle();
    expect(preview.playing, '/voices/std.m4a');
    expect(find.byTooltip('Stop'), findsOneWidget);

    await tester.tap(find.byTooltip('Stop'));
    await tester.pumpAndSettle();
    expect(preview.playing, isNull);
    expect(find.byTooltip('Listen'), findsOneWidget);

    await tester.tap(find.byTooltip('Listen'));
    await tester.pumpAndSettle();
    preview.finish();
    await tester.pumpAndSettle();
    expect(find.byTooltip('Listen'), findsOneWidget);
  });

  testWidgets('REQ-ALM-054 a preview refused while an Athan plays never shows '
      'as playing', (tester) async {
    _phone(tester);
    final disk = FakeVoiceDisk()..files['std'] = VoiceFileState.verified;
    final preview = FakeVoicePreview()..athanPlaying = true;
    await tester.pumpWidget(
      _app(
        const AthanVoicesPage(slot: VoiceSlot.athan),
        disk: disk,
        preview: preview,
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Listen'));
    await tester.pumpAndSettle();
    expect(preview.started, isEmpty);
    expect(find.byTooltip('Stop'), findsNothing);
  });

  testWidgets('removing the chosen voice deletes it and sets the choice back '
      'to its default at once', (tester) async {
    _phone(tester);
    final disk = FakeVoiceDisk()..files['fjr'] = VoiceFileState.verified;
    final host = FakeVoiceAudioHost();
    final writes = _Writes();
    await tester.pumpWidget(
      _app(
        const AthanVoicesPage(slot: VoiceSlot.fajr),
        disk: disk,
        host: host,
        writes: writes,
        fajr: 'fjr',
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Remove from phone'));
    await tester.pumpAndSettle();
    expect(disk.files, isEmpty);
    expect(writes.writes, {'fajrSoundId': null});
    expect(find.text('Download'), findsNWidgets(2));
  });

  testWidgets('REQ-ALM-053 a chosen voice whose file is gone is named with '
      'the sound that plays instead', (tester) async {
    _phone(tester);
    await tester.pumpWidget(
      _app(
        const Column(
          children: [
            VoiceSlotTile(slot: VoiceSlot.athan),
            VoiceSlotTile(slot: VoiceSlot.fajr),
          ],
        ),
        disk: FakeVoiceDisk(),
        athan: 'std',
        fajr: 'fjr',
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.text(
        'Voice std is not on this phone any more, so Phone alarm tone plays '
        'instead. Download it again to bring it back.',
      ),
      findsOneWidget,
    );
    expect(
      find.text(
        'Voice fjr is not on this phone any more, so Phone alarm tone plays '
        'instead. Download it again to bring it back.',
      ),
      findsOneWidget,
    );

    // The Fajr page ticks what plays: the Athan voice it falls back to.
    await tester.pumpWidget(
      _app(
        const AthanVoicesPage(slot: VoiceSlot.fajr),
        disk: FakeVoiceDisk(),
        athan: 'std',
        fajr: 'fjr',
      ),
    );
    await tester.pumpAndSettle();
    ListTile row(String title) => tester.widget<ListTile>(
      find.ancestor(of: find.text(title), matching: find.byType(ListTile)),
    );
    expect(row('Same as the Athan voice').selected, isTrue);
    expect(row('Phone alarm tone').selected, isFalse);
  });

  testWidgets('REQ-UX-030 the voices page lays out in Arabic (RTL) without '
      'overflow', (tester) async {
    _phone(tester);
    await tester.pumpWidget(
      _app(
        const AthanVoicesPage(slot: VoiceSlot.fajr),
        disk: FakeVoiceDisk()..files['fjr'] = VoiceFileState.verified,
        locale: const Locale('ar'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('صوت أذان الفجر'), findsOneWidget);
    expect(find.text('صوت fjr'), findsOneWidget);
    expect(find.text('نفس صوت الأذان'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
