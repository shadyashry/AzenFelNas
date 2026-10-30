import 'package:daily_muslim/features/shell/presentation/brand_intro.dart';
import 'package:daily_muslim/features/shell/presentation/scroll_insets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('The opening intro (§15 D113)', () {
    Future<List<String>> pump(
      WidgetTester tester, {
      bool still = false,
      bool brief = false,
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
              brief: brief,
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

    /// The test binding never decodes the asset or reports a rasterized
    /// frame, so the motion starts at the decode wait's fallback.
    const begun = BrandIntro.decodeWait;

    /// Past the motion: the logo at rest.
    Duration settled() => begun + BrandIntro.motionDuration;

    /// Past the rest and the crossfade into the app, with a frame or two of
    /// headroom for each animation's start.
    Duration gone() => settled() + BrandIntro.exitDuration * 2;

    /// The logo's own opacity, nearest the image.
    double logoOpacity(WidgetTester tester) => tester
        .widget<Opacity>(
          find
              .ancestor(of: find.byType(Image), matching: find.byType(Opacity))
              .first,
        )
        .opacity;

    Size screenOf(WidgetTester tester) =>
        tester.view.physicalSize / tester.view.devicePixelRatio;

    testWidgets('opens on the bare launch ground, then fades the logo in '
        'from 97 to 100 % at its resting place', (tester) async {
      await pump(tester, ready: ValueNotifier(false));
      expect(find.byType(Image), findsOneWidget);
      final image = tester.widget<Image>(find.byType(Image));
      expect((image.image as AssetImage).assetName, BrandIntro.asset);
      expect(logoOpacity(tester), 0);
      final rest = BrandIntro.logoRectIn(screenOf(tester), EdgeInsets.zero);
      final first = tester.getRect(find.byType(Image));
      expect(first.center, offsetMoreOrLessEquals(rest.center));
      expect(first.width, moreOrLessEquals(rest.width * 0.97));
      // Part way through the fade-in: part visible and growing.
      await play(tester, begun + const Duration(milliseconds: 350));
      expect(logoOpacity(tester), inExclusiveRange(0, 1));
      expect(
        tester.getRect(find.byType(Image)).width,
        inExclusiveRange(rest.width * 0.97, rest.width),
      );
      await play(tester, BrandIntro.motionDuration);
      expect(logoOpacity(tester), 1);
      expect(tester.getRect(find.byType(Image)), rectMoreOrLessEquals(rest));
    });

    testWidgets('the light plays once: at rest nothing moves', (tester) async {
      await pump(tester, ready: ValueNotifier(false));
      await play(tester, settled());
      expect(tester.binding.hasScheduledFrame, isFalse);
      final rest = tester.getRect(find.byType(Image));
      await play(tester, const Duration(milliseconds: 800));
      expect(tester.getRect(find.byType(Image)), rectMoreOrLessEquals(rest));
    });

    testWidgets('the logo stays square, with margins, inside the safe area '
        'on a small phone and in landscape', (tester) async {
      const safe = EdgeInsets.only(top: 24, bottom: 48);
      tester.view
        ..physicalSize = const Size(640, 1136)
        ..devicePixelRatio = 2
        ..padding = FakeViewPadding(top: safe.top * 2, bottom: safe.bottom * 2);
      addTearDown(tester.view.reset);
      await pump(tester, ready: ValueNotifier(false));
      await play(tester, settled());
      void fits() {
        final area = safe.deflateRect(Offset.zero & screenOf(tester));
        final logo = tester.getRect(find.byType(Image));
        expect(logo.width, moreOrLessEquals(logo.height));
        expect(logo.left, greaterThan(area.left + 16));
        expect(logo.right, lessThan(area.right - 16));
        expect(logo.top, greaterThan(area.top));
        expect(logo.bottom, lessThan(area.bottom));
      }

      fits();
      tester.view.physicalSize = const Size(1136, 640);
      await tester.pump();
      fits();
      expect(
        tester.getRect(find.byType(Image)).height,
        lessThanOrEqualTo((320 - safe.vertical) * 0.62 + 1e-9),
      );
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

    testWidgets('the crossfade into a ready app ends about 1.95 s after the '
        'fade-in starts', (tester) async {
      await pump(tester);
      await play(tester, settled());
      expect(find.byType(Image), findsOneWidget);
      await play(
        tester,
        BrandIntro.exitDuration + const Duration(milliseconds: 100),
      );
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
      expect(tester.getRect(find.byType(Image)), rectMoreOrLessEquals(rest));
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
      await play(tester, BrandIntro.briefFade * 2);
      expect(find.byType(Image), findsNothing);
      await tester.tap(find.text('App'));
      expect(taps, ['app']);
      // The skipped fade-in does not start once the intro has gone.
      await play(tester, begun);
      expect(find.byType(Image), findsNothing);
    });

    testWidgets('a screen reader reaches the app with the first frame', (
      tester,
    ) async {
      await pump(tester);
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

    for (final (name, still, brief) in const [
      ('with reduced motion', true, false),
      ('when the launch opened a link', false, true),
    ]) {
      testWidgets('$name the logo stays at its size, with a short fade in '
          'and out and no light', (tester) async {
        final ready = ValueNotifier(false);
        await pump(tester, still: still, brief: brief, ready: ready);
        final rest = BrandIntro.logoRectIn(screenOf(tester), EdgeInsets.zero);
        expect(tester.getRect(find.byType(Image)), rectMoreOrLessEquals(rest));
        await play(tester, begun + BrandIntro.briefFade);
        expect(logoOpacity(tester), 1);
        expect(tester.getRect(find.byType(Image)), rectMoreOrLessEquals(rest));
        expect(
          find.descendant(
            of: find
                .ancestor(
                  of: find.byType(Image),
                  matching: find.byType(Stack),
                )
                .first,
            matching: find.byType(CustomPaint),
          ),
          findsNothing,
        );
        await play(tester, BrandIntro.briefRest);
        expect(tester.binding.hasScheduledFrame, isFalse);
        ready.value = true;
        await play(tester, BrandIntro.briefFade * 2);
        expect(find.byType(Image), findsNothing);
      });
    }

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
