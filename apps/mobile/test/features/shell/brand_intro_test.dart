import 'package:daily_muslim/features/shell/presentation/brand_intro.dart';
import 'package:daily_muslim/features/shell/presentation/scroll_insets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('The opening intro (§15 D100, D101)', () {
    Future<List<String>> pump(
      WidgetTester tester, {
      bool still = false,
      ValueListenable<bool>? ready,
    }) async {
      final taps = <String>[];
      if (still) {
        tester.platformDispatcher.accessibilityFeaturesTestValue =
            const FakeAccessibilityFeatures(disableAnimations: true);
        addTearDown(
          tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
        );
      }
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => ValueListenableBuilder(
            valueListenable: ready ?? ValueNotifier(true),
            builder: (context, isReady, _) => BrandIntro(
              ready: isReady,
              child: child ?? const SizedBox.shrink(),
            ),
          ),
          home: Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () => taps.add('app'),
                child: const Text('App'),
              ),
            ),
          ),
        ),
      );
      return taps;
    }

    /// Frames for [length], 50 ms apart.
    Future<void> play(WidgetTester tester, Duration length) async {
      for (var i = 0; i <= length.inMilliseconds ~/ 50; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
    }

    testWidgets('shows the mark over the app, then leaves the app alone', (
      tester,
    ) async {
      await pump(tester);
      expect(find.byType(Image), findsOneWidget);
      await play(tester, BrandIntro.duration);
      expect(find.byType(Image), findsNothing);
      expect(find.text('App'), findsOneWidget);
    });

    testWidgets('it waits, lamp lit, until the app is ready, then fades '
        'into it', (tester) async {
      final ready = ValueNotifier(false);
      await pump(tester, ready: ready);
      await play(tester, BrandIntro.duration * 2);
      expect(find.byType(Image), findsOneWidget);
      ready.value = true;
      await play(tester, BrandIntro.duration);
      expect(find.byType(Image), findsNothing);
    });

    testWidgets('it waits at most the longest hold', (tester) async {
      await pump(tester, ready: ValueNotifier(false));
      await play(tester, BrandIntro.duration + BrandIntro.longestHold);
      await play(tester, BrandIntro.duration);
      expect(find.byType(Image), findsNothing);
    });

    testWidgets('a tap skips it without reaching the app below', (
      tester,
    ) async {
      final taps = await pump(tester);
      await tester.pump();
      await tester.tap(find.text('App'), warnIfMissed: false);
      expect(taps, isEmpty);
      await play(tester, BrandIntro.skipDuration * 2);
      expect(find.byType(Image), findsNothing);
      await tester.tap(find.text('App'));
      expect(taps, ['app']);
    });

    testWidgets('a screen reader reaches the app at once', (tester) async {
      await pump(tester);
      expect(find.bySemanticsLabel('App'), findsOneWidget);
      await play(tester, BrandIntro.duration);
    });

    testWidgets('the app keeps its state when the intro leaves', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) =>
              BrandIntro(child: child ?? const SizedBox.shrink()),
          home: const Scaffold(body: TextField()),
        ),
      );
      await tester.enterText(find.byType(TextField), 'typed');
      await play(tester, BrandIntro.duration);
      expect(find.byType(Image), findsNothing);
      expect(find.text('typed'), findsOneWidget);
    });

    testWidgets('with reduced motion it is a short fade', (tester) async {
      await pump(tester, still: true);
      await play(tester, BrandIntro.reducedDuration);
      expect(find.byType(Image), findsNothing);
    });
  });

  testWidgets('a page scrolls clear of the system and tab bars (§15 D100)', (
    tester,
  ) async {
    late EdgeInsets insets;
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(padding: EdgeInsets.only(bottom: 48)),
        child: Builder(
          builder: (context) {
            insets = scrollInsets(context, horizontal: 16, top: 8);
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    expect(insets, const EdgeInsets.fromLTRB(16, 8, 16, 72));
  });
}
