import 'package:daily_muslim/features/shell/presentation/brand_intro.dart';
import 'package:daily_muslim/features/shell/presentation/scroll_insets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('The opening intro (§15 D100)', () {
    Future<List<String>> pump(WidgetTester tester, {bool still = false}) async {
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
          builder: (context, child) =>
              BrandIntro(child: child ?? const SizedBox.shrink()),
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

    testWidgets('shows the mark over the app, then leaves the app alone', (
      tester,
    ) async {
      await pump(tester);
      expect(find.byType(Image), findsOneWidget);
      // The first frame starts the clock.
      await tester.pump();
      await tester.pump(BrandIntro.duration);
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.byType(Image), findsNothing);
      expect(find.text('App'), findsOneWidget);
    });

    testWidgets('never blocks a tap or a screen reader', (tester) async {
      final taps = await pump(tester);
      await tester.tap(find.text('App'));
      expect(taps, ['app']);
      expect(find.bySemanticsLabel('App'), findsOneWidget);
      await tester.pump(BrandIntro.duration);
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
      await tester.pump();
      await tester.pump(BrandIntro.duration);
      await tester.pump();
      expect(find.text('typed'), findsOneWidget);
    });

    testWidgets('with reduced motion it is a short fade', (tester) async {
      await pump(tester, still: true);
      await tester.pump();
      await tester.pump(BrandIntro.reducedDuration);
      await tester.pump(const Duration(milliseconds: 50));
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
