import 'dart:async';

import 'package:daily_muslim/features/athan/domain/athan_playback.dart';
import 'package:daily_muslim/features/athan/presentation/athan_voice_providers.dart';
import 'package:daily_muslim/features/shell/presentation/athan_stop_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/state_harness.dart';

final class _Playback implements AthanPlayback {
  new({required this.playingAtStart});

  final bool playingAtStart;
  final changes = StreamController<bool>.broadcast();
  int stops = 0;

  @override
  Future<bool> athanPlaying() async => playingAtStart;

  @override
  Future<void> stopAthan() async {
    stops++;
    changes.add(false);
  }

  @override
  Stream<bool> get athanChanges => changes.stream;
}

Widget _app(_Playback playback, {Locale locale = const Locale('en')}) =>
    localizedApp(
      const Scaffold(bottomNavigationBar: AthanStopBar()),
      locale: locale,
      overrides: [athanPlaybackProvider.overrideWithValue(playback)],
    );

void main() {
  testWidgets('REQ-ALM-043 an Athan playing when the app opens shows a Stop '
      'that ends it, and the bar goes', (tester) async {
    final playback = _Playback(playingAtStart: true);
    await tester.pumpWidget(_app(playback));
    await tester.pumpAndSettle();

    expect(find.text('The Athan is playing'), findsOneWidget);
    await tester.tap(find.text('Stop'));
    await tester.pumpAndSettle();

    expect(playback.stops, 1);
    expect(find.text('The Athan is playing'), findsNothing);
  });

  testWidgets('REQ-ALM-043 the Stop appears when an Athan starts while the '
      'app is open, in Arabic too', (tester) async {
    final playback = _Playback(playingAtStart: false);
    await tester.pumpWidget(_app(playback, locale: const Locale('ar')));
    await tester.pumpAndSettle();
    expect(find.byType(FilledButton), findsNothing);

    playback.changes.add(true);
    await tester.pumpAndSettle();

    expect(find.text('الأذان يُرفع الآن'), findsOneWidget);
    expect(find.text('إيقاف'), findsOneWidget);
  });
}
