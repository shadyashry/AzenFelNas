import 'package:daily_muslim/features/shell/presentation/brand_intro.dart';
import 'package:daily_muslim/features/shell/presentation/scroll_insets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('The opening intro (§15 D100, D101, D106)', () {
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

    /// Past the decode wait, the first frame and the motion: the logo
    /// settled. The test binding never reports a rasterized frame, so the
    /// motion starts at its fallback.
    Duration settled() => BrandIntro.decodeWait * 2 + BrandIntro.motionDuration;

    /// Past the settled logo and its fade into the app, with a frame or two
    /// of headroom for each animation's start.
    Duration gone() => settled() + BrandIntro.exitDuration * 2;

    testWidgets('opens on the launch screen picture, the logo at its launch '
        'size, then opens out to fill the screen', (tester) async {
      await pump(tester, ready: ValueNotifier(false));
      expect(find.byType(Image), findsOneWidget);
      final image = tester.widget<Image>(find.byType(Image));
      expect((image.image as AssetImage).assetName, BrandIntro.asset);
      final first = tester.getRect(find.byType(Image));
      final screen = tester.view.physicalSize / tester.view.devicePixelRatio;
      // Centred on the whole screen at the launch size, as natively.
      expect(first.center, Offset(screen.width / 2, screen.height / 2));
      expect(first.width, moreOrLessEquals(BrandIntro.launchSide));
      await play(tester, settled());
      final last = tester.getRect(find.byType(Image));
      expect(last.center, first.center);
      expect(last.width, moreOrLessEquals(BrandIntro.fullSideIn(screen)));
    });

    testWidgets('on a phone in portrait the settled logo spans the full '
        'width; in landscape it leaves room below', (tester) async {
      tester.view
        ..physicalSize = const Size(1080, 2340)
        ..devicePixelRatio = 2.625;
      addTearDown(tester.view.reset);
      await pump(tester, ready: ValueNotifier(false));
      await play(tester, settled());
      final portrait = tester.view.physicalSize / tester.view.devicePixelRatio;
      expect(
        tester.getRect(find.byType(Image)).width,
        moreOrLessEquals(portrait.width),
      );
      tester.view.physicalSize = const Size(2340, 1080);
      await tester.pump();
      final landscape = tester.view.physicalSize / tester.view.devicePixelRatio;
      final rect = tester.getRect(find.byType(Image));
      expect(rect.height, lessThan(landscape.height));
      expect(rect.center.dy, moreOrLessEquals(landscape.height / 2));
    });

    testWidgets('shows the logo over the app, then leaves the app alone', (
      tester,
    ) async {
      await pump(tester);
      expect(find.byType(Image), findsOneWidget);
      await play(tester, gone());
      expect(find.byType(Image), findsNothing);
      expect(find.text('App'), findsOneWidget);
    });

    testWidgets('from the launch picture to the app takes under the design '
        'target of 2 seconds when the app is ready', (tester) async {
      await pump(tester);
      // Up to the motion's start: the launch picture still on screen.
      await play(tester, BrandIntro.decodeWait * 2);
      expect(find.byType(Image), findsOneWidget);
      await play(tester, const Duration(milliseconds: 1900));
      expect(find.byType(Image), findsNothing);
    });

    testWidgets('it waits, still, until the app is ready, then fades '
        'into it', (tester) async {
      final ready = ValueNotifier(false);
      await pump(tester, ready: ready);
      await play(tester, settled() * 2);
      expect(find.byType(Image), findsOneWidget);
      ready.value = true;
      await play(tester, BrandIntro.exitDuration * 2);
      expect(find.byType(Image), findsNothing);
    });

    testWidgets('a slow start shows a loading line rather than replaying '
        'the motion', (tester) async {
      await pump(tester, ready: ValueNotifier(false));
      await play(tester, settled());
      expect(find.byType(LinearProgressIndicator), findsNothing);
      final rest = tester.getRect(find.byType(Image));
      await play(tester, BrandIntro.loadingAfter);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(tester.getRect(find.byType(Image)), rest);
    });

    testWidgets('it waits at most the longest hold', (tester) async {
      await pump(tester, ready: ValueNotifier(false));
      await play(tester, settled() + BrandIntro.longestHold);
      await play(tester, BrandIntro.exitDuration);
      expect(find.byType(Image), findsNothing);
    });

    testWidgets('a tap skips it without reaching the app below', (
      tester,
    ) async {
      final taps = await pump(tester);
      await tester.pump();
      await tester.tap(find.text('App'), warnIfMissed: false);
      expect(taps, isEmpty);
      await play(tester, BrandIntro.quickExitDuration * 2);
      expect(find.byType(Image), findsNothing);
      await tester.tap(find.text('App'));
      expect(taps, ['app']);
    });

    testWidgets('a screen reader reaches the app with the first frame', (
      tester,
    ) async {
      await pump(tester);
      // The first frame waits at most for the logo to decode.
      await tester.pump(BrandIntro.decodeWait);
      expect(find.bySemanticsLabel('App'), findsOneWidget);
      await play(tester, gone());
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
      await play(tester, gone());
      expect(find.byType(Image), findsNothing);
      expect(find.text('typed'), findsOneWidget);
    });

    testWidgets('with reduced motion the logo stays still, then a short '
        'fade', (tester) async {
      final ready = ValueNotifier(false);
      await pump(tester, still: true, ready: ready);
      final first = tester.getRect(find.byType(Image));
      await play(tester, settled());
      expect(tester.getRect(find.byType(Image)), first);
      expect(first.width, moreOrLessEquals(BrandIntro.launchSide));
      ready.value = true;
      await play(tester, BrandIntro.quickExitDuration);
      expect(find.byType(Image), findsNothing);
    });

    testWidgets('a resume does not replay it', (tester) async {
      await pump(tester);
      await play(tester, gone());
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump();
      tester.binding.handleAppLifecycleStateChanged(
        AppLifecycleState.resumed,
      );
      await play(tester, const Duration(milliseconds: 200));
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
